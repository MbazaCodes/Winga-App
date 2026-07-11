import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/location_repository.dart';

final locationRepoProvider = Provider((_) => LocationRepository());

final allLocationsProvider =
    FutureProvider<List<Map<String, List<dynamic>>>>((ref) async {
  final repo = ref.read(locationRepoProvider);
  final locs = await repo.getAllLocations();

  // Group by city
  final Map<String, List<dynamic>> grouped = {};
  for (final l in locs) {
    grouped.putIfAbsent(l.city, () => []).add(l);
  }

  return grouped.entries
      .map((e) => {e.key: e.value})
      .toList();
});

/// Full-screen city/area picker used at booking time.
/// Returns the selected [WingaLocation] to the caller via GoRouter.
class CityPickerScreen extends ConsumerStatefulWidget {
  const CityPickerScreen({super.key});

  @override
  ConsumerState<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends ConsumerState<CityPickerScreen> {
  String _search = '';
  String? _selectedCity;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(allLocationsProvider);

    return Scaffold(
      backgroundColor: WingaColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Chagua Mahali'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Tafuta mji au eneo...',
                prefixIcon:
                    const Icon(Icons.search_rounded, color: WingaColors.primary),
                filled: true,
                fillColor: WingaColors.primarySurface,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: data.when(
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: WingaColors.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (groups) {
          final repo = ref.read(locationRepoProvider);
          // Flatten and filter
          return FutureBuilder<List<dynamic>>(
            future: repo.getAllLocations(),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(
                    child: CircularProgressIndicator(
                        color: WingaColors.primary));
              }
              final allLocs = snap.data!;
              final filtered = _search.isEmpty
                  ? allLocs
                  : allLocs
                      .where((l) =>
                          l.city.toLowerCase().contains(_search) ||
                          (l.area?.toLowerCase().contains(_search) ??
                              false) ||
                          l.region.toLowerCase().contains(_search))
                      .toList();

              // Group by city
              final Map<String, List<dynamic>> byCityMap = {};
              for (final l in filtered) {
                byCityMap.putIfAbsent(l.city, () => []).add(l);
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: byCityMap.length,
                itemBuilder: (_, i) {
                  final city = byCityMap.keys.elementAt(i);
                  final areas = byCityMap[city]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // City header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: Row(
                          children: [
                            const Icon(Icons.location_city_rounded,
                                size: 16, color: WingaColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              city,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: WingaColors.primary),
                            ),
                            Expanded(
                                child: Divider(
                              indent: 10,
                              color: WingaColors.border,
                            )),
                          ],
                        ),
                      ),
                      // Areas
                      ...areas.map((loc) => ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: WingaColors.primarySurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.place_rounded,
                                  size: 18,
                                  color: WingaColors.primary),
                            ),
                            title: Text(
                              loc.area ?? loc.city,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${loc.region}, ${loc.country}',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  color: WingaColors.textSecondary),
                            ),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: WingaColors.textLight),
                            onTap: () {
                              // Return selected location to caller
                              context.pop({
                                'id': loc.id,
                                'city': loc.city,
                                'area': loc.area,
                                'region': loc.region,
                                'display': loc.displayName,
                                'lat': loc.lat,
                                'lng': loc.lng,
                              });
                            },
                          )),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
