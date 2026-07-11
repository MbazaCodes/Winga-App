import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/session.dart';
import '../../../../core/widgets/winga_button.dart';

class ShoppingListItem {
  final String name;
  final String quantity;
  final String? unit;
  final int? estimatedPrice;
  final String? notes;
  bool found;

  ShoppingListItem({
    required this.name,
    this.quantity = '1',
    this.unit,
    this.estimatedPrice,
    this.notes,
    this.found = false,
  });
}

class ShoppingListScreen extends ConsumerStatefulWidget {
  final String requestId;
  const ShoppingListScreen({super.key, required this.requestId});

  @override
  ConsumerState<ShoppingListScreen> createState() =>
      _ShoppingListScreenState();
}

class _ShoppingListScreenState
    extends ConsumerState<ShoppingListScreen> {
  final List<ShoppingListItem> _items = [];
  bool _saving = false;
  final _client = Supabase.instance.client;

  Future<void> _addItem() async {
    final result = await showModalBottomSheet<ShoppingListItem?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddItemSheet(),
    );
    if (result != null) setState(() => _items.add(result));
  }

  Future<void> _save() async {
    if (_items.isEmpty) return;
    setState(() => _saving = true);

    try {
      // Create list
      final listRow = await _client.from('shopping_lists').insert({
        'request_id': widget.requestId,
        'customer_id': WingaSession.safeUid,
        'title': 'Orodha ya Ununuzi',
      }).select().single();

      final listId = listRow['id'] as String;

      // Insert items
      final items = _items.asMap().entries.map((e) => {
            'list_id': listId,
            'name': e.value.name,
            'quantity': e.value.quantity,
            'unit': e.value.unit,
            'estimated_price': e.value.estimatedPrice,
            'notes': e.value.notes,
            'sort_order': e.key,
          }).toList();

      await _client.from('shopping_list_items').insert(items);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Orodha imetumwa kwa Winga wako'),
          backgroundColor: WingaColors.primary));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
    if (mounted) setState(() => _saving = false);
  }

  int get _totalEstimate =>
      _items.fold(0, (s, i) => s + (i.estimatedPrice ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Orodha ya Ununuzi'),
        actions: [
          TextButton(
            onPressed: _addItem,
            child: const Text('+ Ongeza',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: WingaColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_totalEstimate > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: WingaColors.primarySurface,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jumla ya Makisio',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: WingaColors.primary)),
                  Text('TZS ${_totalEstimate.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WingaColors.primary)),
                ],
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.list_alt_rounded,
                            size: 52, color: WingaColors.textLight),
                        const SizedBox(height: 12),
                        const Text('Orodha yako ipo hapa',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: WingaColors.textSecondary)),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _addItem,
                          child: const Text('+ Ongeza bidhaa ya kwanza'),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: _items.length,
                    onReorder: (old, nw) {
                      setState(() {
                        final item = _items.removeAt(old);
                        _items.insert(nw > old ? nw - 1 : nw, item);
                      });
                    },
                    itemBuilder: (_, i) {
                      final item = _items[i];
                      return _ItemTile(
                        key: ValueKey(i),
                        item: item,
                        onDelete: () =>
                            setState(() => _items.removeAt(i)),
                      );
                    },
                  ),
          ),
          if (_items.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 8, 20, 20 + MediaQuery.of(context).padding.bottom),
              child: WingaButton(
                label: 'Tuma Orodha kwa Winga',
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback onDelete;

  const _ItemTile({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: WingaColors.border)),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: WingaColors.primarySurface,
              borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: Text(
              item.quantity,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: WingaColors.primary),
            ),
          ),
        ),
        title: Text(item.name,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        subtitle: item.notes != null || item.estimatedPrice != null
            ? Text(
                [
                  if (item.estimatedPrice != null)
                    'TZS ${item.estimatedPrice}',
                  if (item.notes != null) item.notes!,
                ].join(' · '),
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: WingaColors.textSecondary))
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: WingaColors.error, size: 20),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  const _AddItemSheet();
  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'vipande';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: WingaColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ongeza Bidhaa',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Jina la bidhaa *',
              hintText: 'Mfano: Simu Samsung A14',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Idadi',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: InputDecoration(
                    labelText: 'Kipimo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: ['vipande', 'kg', 'lita', 'mfuko', 'sanduku']
                      .map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(u,
                                style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Makisio ya bei (TZS)',
              hintText: '45000',
              prefixText: 'TZS ',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: 'Maelezo zaidi (hiari)',
              hintText: 'Mfano: lazima iwe nyeusi, si bluu',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Ghairi'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: WingaColors.primary),
                  onPressed: () {
                    if (_nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(
                      context,
                      ShoppingListItem(
                        name: _nameCtrl.text.trim(),
                        quantity: _qtyCtrl.text.isEmpty
                            ? '1'
                            : _qtyCtrl.text,
                        unit: _unit,
                        estimatedPrice: int.tryParse(_priceCtrl.text),
                        notes: _notesCtrl.text.trim().isEmpty
                            ? null
                            : _notesCtrl.text.trim(),
                      ),
                    );
                  },
                  child: const Text('Ongeza',
                      style: TextStyle(
                          fontFamily: 'Inter', color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
