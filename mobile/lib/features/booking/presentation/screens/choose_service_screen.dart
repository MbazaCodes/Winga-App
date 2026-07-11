import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/winga_widgets.dart';

class ChooseServiceScreen extends StatefulWidget {
  const ChooseServiceScreen({super.key});

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  int? _selected;

  static const _categories = [
    _Category('📱', 'Electronics', 'Phones, Accessories,\nGadgets & more'),
    _Category('👕', 'Clothing & Fashion', 'Men, Women, Kids\nwear & more'),
    _Category('👟', 'Shoes & Bags', 'Shoes, Bags, Belts\n& more'),
    _Category('💄', 'Cosmetics & Beauty', 'Makeup, Skincare,\nPerfumes & more'),
    _Category('🔨', 'Hardware & Tools', 'Building materials,\nTools & more'),
    _Category('🛋️', 'Home & Furniture', 'Furniture, Decor,\nHousehold items'),
    _Category('🍳', 'Kitchen & Utensils', 'Cookware, Utensils,\nContainers & more'),
    _Category('🔧', 'Spare Parts', 'Vehicle & Motorcycle\nparts & more'),
    _Category('📎', 'Stationery & Office', 'Office supplies,\nStationery & more'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WingaColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: WingaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Choose Service'),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: WingaStepIndicator(
              totalSteps: 6,
              currentStep: 1,
              labels: const [
                'Choose\nService',
                'Details',
                'Preferences',
                'Find Winga',
                'Request',
                'Confirm',
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'What do you need help with today?',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: WingaColors.primary,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Select a category and let a Winga assist you\nfind the best shops in Kariakoo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: WingaColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Popular Categories',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: WingaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3-column grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (ctx, i) => _CategoryCard(
                      category: _categories[i],
                      isSelected: _selected == i,
                      onTap: () {
                        setState(() => _selected = i);
                        Future.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            if (mounted) context.push('/book/details');
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Other option
                  GestureDetector(
                    onTap: () => context.push('/book/details'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: WingaColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: WingaColors.border),
                        boxShadow: WingaShadows.card,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: WingaColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('⋯',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Other (Not listed)',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: WingaColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "Can't find what you're looking for?",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: WingaColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: WingaColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trust badge
                  SafetyBanner(
                    message:
                        'All Wingas are verified & trusted\nYour safety and satisfaction are our priority.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Category {
  final String emoji;
  final String name;
  final String description;
  const _Category(this.emoji, this.name, this.description);
}

class _CategoryCard extends StatelessWidget {
  final _Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? WingaColors.primarySurface : WingaColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? WingaColors.primary : WingaColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: WingaShadows.card,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 8),
              Text(
                category.name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? WingaColors.primary
                      : WingaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  category.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: WingaColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? WingaColors.primary
                        : WingaColors.borderLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: isSelected
                        ? Colors.white
                        : WingaColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
