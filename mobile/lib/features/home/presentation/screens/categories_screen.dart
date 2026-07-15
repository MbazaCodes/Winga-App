import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'id': 'fundi', 'sw': 'Fundi', 'emoji': '🛠️', 'desc': 'Ujezi, Umeme, Maji, Kuchomelea...'},
      {'id': 'dalali', 'sw': 'Dalali', 'emoji': '🏘️', 'desc': 'Viwanja, Nyumba, Magari, Vifaa...'},
      {'id': 'electronics', 'sw': 'Elektroniki', 'emoji': '📱', 'desc': 'Simu, Laptop, TV, Redio...'},
      {'id': 'clothing', 'sw': 'Mavazi', 'emoji': '👕', 'desc': 'Nguo za kike, kiume na watoto'},
      {'id': 'shoes', 'sw': 'Viatu', 'emoji': '👟', 'desc': 'Raba, Ofisini, Sandals, Watoto'},
      {'id': 'beauty', 'sw': 'Vipodozi', 'emoji': '💄', 'desc': 'Make-up, Perfume, Mafuta'},
      {'id': 'hardware', 'sw': 'Ujenzi', 'emoji': '🔨', 'desc': 'Rangi, Mabati, Misumari, Saruji'},
      {'id': 'kitchen', 'sw': 'Nyumbani', 'emoji': '🍳', 'desc': 'Vyombo, Majiko, Fridge, Mapambo'},
      {'id': 'other', 'sw': 'Zaidi', 'emoji': '⋯', 'desc': 'Bidhaa nyingine yoyote unayotaka'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kategoria Zote', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w800)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          return GestureDetector(
            onTap: () => context.push('/book?category=${cat['sw']}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: WingaColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(child: Text(cat['emoji'], style: const TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat['sw'], style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(cat['desc'], style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
