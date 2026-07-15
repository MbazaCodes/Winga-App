import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';

class BookingScreen extends StatefulWidget {
  final String? initialCategory;
  const BookingScreen({super.key, this.initialCategory});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final supabase = Supabase.instance.client;

  String _selectedCategory = '';
  String _selectedSubCategory = '';

  // Location State
  String? _selectedRegion;
  String? _selectedDistrict;
  String? _selectedWard;
  final _exactLocationCtrl = TextEditingController();
  final _shoppingAreaCtrl = TextEditingController(text: 'Kariakoo Market');

  String _selectedServiceType = '';
  String _selectedDelivery = '';
  final _noteCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  final Map<String, Map<String, List<String>>> _locationData = {
    'Dar es Salaam': {
      'Ilala': ['Kariakoo', 'Gerezani', 'Jangwani', 'Upanga', 'Kisutu', 'Mchafukoge'],
      'Kinondoni': ['Magomeni', 'Makumbusho', 'Kijitonyama', 'Hananasif', 'Mwananyamala'],
      'Temeke': ['Kurasini', 'Mbagala', 'Chang\'ombe', 'Keko'],
      'Ubungo': ['Ubungo', 'Manzese', 'Mabibo', 'Kimara', 'Mbezi'],
      'Kigamboni': ['Kigamboni', 'Tungi', 'Mjimwema'],
    },
    'Arusha': {
      'Arusha City': ['Sekei', 'Themi', 'Kaloleni', 'Levolosi'],
      'Arumeru': ['Usa River', 'Akheri'],
    },
    'Mwanza': {
      'Nyamagana': ['Mwanza City', 'Pasiansi', 'Igogo'],
      'Ilemela': ['Kirumba', 'Kitangari'],
    },
    'Dodoma': {
      'Dodoma City': ['Kikuyu', 'Tambukareli', 'Majengo'],
    }
  };

  final Map<String, String> _districtToMarket = {
    'Ilala': 'Kariakoo Market / Machinga Complex',
    'Kinondoni': 'Mwenge Market / Tandale',
    'Temeke': 'Temeke Stereo / Tandika',
    'Ubungo': 'Mbezi Louis / Manzese Market',
    'Arusha City': 'Arusha Central Market',
    'Nyamagana': 'Mwanza Central Market',
    'Dodoma City': 'Dodoma Central Market (Saba Saba)',
  };

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'fundi', 'sw': 'Fundi', 'emoji': '🛠️',
      'subs': ['Ujezi/Mason', 'Umeme', 'Maji/Plumbing', 'Kuchomelea', 'Fanicha', 'AC & Ubaridi', 'Simu & Kompyuta', 'Makanika (Gari)']
    },
    {
      'id': 'dalali', 'sw': 'Dalali', 'emoji': '🏘️',
      'subs': ['Nyumba (Kupanga)', 'Nyumba (Kununua)', 'Viwanja', 'Magari', 'Mashamba', 'Vifaa vya Sherehe', 'Ofisi/Fremu']
    },
    {
      'id': 'electronics', 'sw': 'Elektroniki', 'emoji': '📱',
      'subs': ['Simu & Tablet', 'Laptop/PC', 'TV & Audio', 'Fridge & Cookers', 'Solars & Power', 'Camera & Games']
    },
    {
      'id': 'clothing', 'sw': 'Mavazi', 'emoji': '👕',
      'subs': ['Wanawake', 'Wanaume', 'Watoto', 'Mitumba (Grade A)', 'Vitenge & Batiki', 'Uniforms']
    },
    {
      'id': 'shoes', 'sw': 'Viatu', 'emoji': '👟',
      'subs': ['Wanawake', 'Wanaume', 'Watoto', 'Raba/Sneakers', 'Viatu vya Ofisi', 'Sandals/Pendo']
    },
    {
      'id': 'beauty', 'sw': 'Vipodozi', 'emoji': '💄',
      'subs': ['Make-up', 'Perfume', 'Mafuta ya Ngozi', 'Wigi & Nywele', 'Saluni & Kucha']
    },
    {
      'id': 'hardware', 'sw': 'Ujenzi', 'emoji': '🔨',
      'subs': ['Rangi & Brashi', 'Mabati & Misumari', 'Saruji & Nondo', 'Vifaa vya Umeme', 'Tiles & Marbles']
    },
    {
      'id': 'kitchen', 'sw': 'Nyumbani', 'emoji': '🍳',
      'subs': ['Vyombo vya Jikoni', 'Majiko ya Gesi', 'Fridge & Mikrowevu', 'Mapambo ya Ndani', 'Pazia & Mashuka']
    },
    {
      'id': 'other', 'sw': 'Zaidi', 'emoji': '⋯',
      'subs': ['Chakula/Soko', 'Dawa/Pharmacy', 'Usafiri/Logistics', 'Huduma Nyingine']
    },
  ];

  final List<Map<String, dynamic>> _serviceTypes = [
    {'key': 'hourly', 'label': 'Saa 1 (Haraka)', 'price': 15000},
    {'key': 'half_day', 'label': 'Nusu Siku (Masaa 4)', 'price': 25000},
    {'key': 'full_day', 'label': 'Siku Nzima (Masaa 8)', 'price': 40000},
  ];

  final List<Map<String, dynamic>> _deliveryMethods = [
    {'key': 'with_client', 'label': 'Niko Naye', 'emoji': '🚶'},
    {'key': 'deliver', 'label': 'Niletee', 'emoji': '🛵'},
    {'key': 'pickup', 'label': 'Nitafuata', 'emoji': '📍'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  int get _price {
    if (_selectedServiceType.isEmpty) return 0;
    return _serviceTypes.firstWhere((s) => s['key'] == _selectedServiceType)['price'];
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    final activeCat = _categories.firstWhere((c) => c['sw'] == _selectedCategory, orElse: () => {});
    final hasSubs = (activeCat['subs'] as List?)?.isNotEmpty ?? false;

    if (_selectedCategory.isEmpty) { setState(() => _error = 'Tafadhali chagua kategoria'); return; }
    if (hasSubs && _selectedSubCategory.isEmpty) { setState(() => _error = 'Tafadhali chagua aina ya $_selectedCategory'); return; }
    if (_selectedRegion == null) { setState(() => _error = 'Chagua Mkoa'); return; }
    if (_selectedDistrict == null) { setState(() => _error = 'Chagua Wilaya'); return; }
    if (_selectedWard == null) { setState(() => _error = 'Chagua Kata'); return; }
    if (_selectedServiceType.isEmpty) { setState(() => _error = 'Chagua aina ya huduma'); return; }

    setState(() => _loading = true);
    try {
      final uid = WingaSession.safeUid;
      if (uid.isEmpty) throw 'Ingia kwenye akaunti kwanza';

      final String fullCategory = _selectedSubCategory.isNotEmpty
          ? '$_selectedCategory ($_selectedSubCategory)'
          : _selectedCategory;

      final meetingPoint = '$_selectedWard, $_selectedDistrict, $_selectedRegion. ${_exactLocationCtrl.text.trim()}';

      await supabase.from('requests').insert({
        'customer_id': uid,
        'category': fullCategory,
        'meeting_point': meetingPoint,
        'shopping_area': _shoppingAreaCtrl.text.trim(),
        'service_type': _selectedServiceType,
        'delivery_method': _selectedDelivery,
        'estimated_price': _price,
        'total_price': _price,
        'city': _selectedRegion,
        'area': _selectedDistrict,
        'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        'status': 'searching',
      });

      if (mounted) context.pushReplacement('/messages');
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCatObj = _categories.firstWhere((c) => c['sw'] == _selectedCategory, orElse: () => {});
    final List<dynamic> subs = activeCatObj['subs'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Omba Winga 🛒', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('1. Chagua Kategoria Kuu'),
            _categoryGrid(),
            const SizedBox(height: 12),

            if (subs.isNotEmpty) ...[
              _sectionTitle('2. Unahitaji ${_selectedCategory} wa aina gani?'),
              _subCategoryFlowGrid(subs),
              const SizedBox(height: 20),
            ],

            _sectionTitle('${subs.isNotEmpty ? '3' : '2'}. Mahali pa Kukutana (Location)'),
            _locationSelectors(),
            const SizedBox(height: 20),

            _sectionTitle('${subs.isNotEmpty ? '4' : '3'}. Eneo la Ununuzi'),
            _textField(_shoppingAreaCtrl, 'Eneo la kufanya manunuzi...'),
            const SizedBox(height: 20),

            _sectionTitle('${subs.isNotEmpty ? '5' : '4'}. Aina ya Huduma (Muda)'),
            _serviceTypeSelector(),
            const SizedBox(height: 20),

            _sectionTitle('${subs.isNotEmpty ? '6' : '5'}. Namna ya Upokeaji'),
            _deliveryMethodSelector(),
            const SizedBox(height: 20),

            _sectionTitle('${subs.isNotEmpty ? '7' : '6'}. Maelezo ya Ziada (Optional)'),
            _textField(_noteCtrl, 'Andika maelezo yoyote muhimu kwa Winga wako...', maxLines: 3),
            const SizedBox(height: 28),

            _priceCard(),
            const SizedBox(height: 24),

            if (_error != null) _errorView(),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WingaColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: WingaColors.primary.withOpacity(0.4),
                ),
                child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Tuma Ombi la Winga', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 4),
    child: Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
  );

  Widget _locationSelectors() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]
      ),
      child: Column(
        children: [
          _dropdown('Mkoa (Region)', _selectedRegion, _locationData.keys.toList(), (v) {
            setState(() {
              _selectedRegion = v;
              _selectedDistrict = null;
              _selectedWard = null;
            });
          }),
          const SizedBox(height: 12),

          if (_selectedRegion != null)
            _dropdown('Wilaya (District)', _selectedDistrict, _locationData[_selectedRegion]!.keys.toList(), (v) {
              setState(() {
                _selectedDistrict = v;
                _selectedWard = null;
                if (_districtToMarket.containsKey(v)) {
                  _shoppingAreaCtrl.text = _districtToMarket[v]!;
                }
              });
            }),

          const SizedBox(height: 12),

          if (_selectedDistrict != null)
            _dropdown('Kata (Ward)', _selectedWard, _locationData[_selectedRegion]![_selectedDistrict]!, (v) {
              setState(() => _selectedWard = v);
            }),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _textField(_exactLocationCtrl, 'Mtaa / Nyumba / Ofisi...', shadow: false),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ramani inakuja hivi punde...'))
                  );
                },
                child: Container(
                  height: 54, width: 54,
                  decoration: BoxDecoration(
                    color: WingaColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WingaColors.primary.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: WingaColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _textField(TextEditingController ctrl, String hint, {int maxLines = 1, bool shadow = true}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: shadow ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))] : [],
    ),
    child: TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.all(18),
        fillColor: Colors.transparent,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
      ),
      style: const TextStyle(fontFamily: 'Inter', fontSize: 15),
    ),
  );

  Widget _categoryGrid() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]
    ),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1
      ),
      itemCount: _categories.length,
      itemBuilder: (ctx, i) {
        final cat = _categories[i];
        final active = _selectedCategory == cat['sw'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = active ? '' : cat['sw'];
              _selectedSubCategory = '';
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: active ? WingaColors.primary : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: active ? Colors.transparent : const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat['emoji'], style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(cat['sw'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : const Color(0xFF4B5563))),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _subCategoryFlowGrid(List<dynamic> subs) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]
    ),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.8,
      ),
      itemCount: subs.length,
      itemBuilder: (ctx, i) {
        final s = subs[i];
        final active = _selectedSubCategory == s;
        return GestureDetector(
          onTap: () => setState(() => _selectedSubCategory = active ? '' : s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: active ? WingaColors.primary : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: active ? Colors.transparent : const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Text(s,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.black87)),
            ),
          ),
        );
      },
    ),
  );

  Widget _serviceTypeSelector() => Column(
    children: _serviceTypes.map((st) {
      final active = _selectedServiceType == st['key'];
      return GestureDetector(
        onTap: () => setState(() => _selectedServiceType = active ? '' : st['key']),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: active ? WingaColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? Colors.transparent : const Color(0xFFE5E7EB)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(st['label'], style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.black)),
              Text('TZS ${st['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w800, color: active ? Colors.white.withOpacity(0.8) : WingaColors.primary)),
            ],
          ),
        ),
      );
    }).toList(),
  );

  Widget _deliveryMethodSelector() => Row(
    children: _deliveryMethods.map((dm) {
      final active = _selectedDelivery == dm['key'];
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedDelivery = active ? '' : dm['key']),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active ? WingaColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: active ? Colors.transparent : const Color(0xFFE5E7EB)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                Text(dm['emoji'], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 6),
                Text(dm['label'], style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF4B5563))),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _priceCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: WingaColors.primary.withOpacity(0.1)),
    ),
    child: Column(
      children: [
        const Text('GHARAMA INAYOKADIRIWA', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: 1)),
        const SizedBox(height: 6),
        Text(_price > 0 ? 'TZS ${_price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}' : '—',
          style: const TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w900, color: WingaColors.primary)),
      ],
    ),
  );

  Widget _errorView() => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFFECACA))),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(_error!, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFB91C1C), fontWeight: FontWeight.w500))),
      ],
    ),
  );
}
