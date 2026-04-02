import 'package:flutter/material.dart';
import 'package:pulseai/core/theme/app_theme.dart';
import 'package:pulseai/core/widgets/modern_widgets.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';

class HealthTipsWidget extends StatelessWidget {
  const HealthTipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Hardcoded tips for now, could be fetched from backend later
    final tips = [
      {
        'icon': Icons.water_drop,
        'title': l10n.tipHydrationTitle,
        'desc': l10n.tipHydrationDesc,
        'color': Colors.blue.shade100,
        'iconColor': Colors.blue,
      },
      {
        'icon': Icons.directions_run,
        'title': l10n.tipExerciseTitle,
        'desc': l10n.tipExerciseDesc,
        'color': Colors.green.shade100,
        'iconColor': Colors.green,
      },
      {
        'icon': Icons.bedtime,
        'title': l10n.tipSleepTitle,
        'desc': l10n.tipSleepDesc,
        'color': Colors.purple.shade100,
        'iconColor': Colors.purple,
      },
      {
        'icon': Icons.restaurant,
        'title': l10n.tipDietTitle,
        'desc': l10n.tipDietDesc,
        'color': Colors.orange.shade100,
        'iconColor': Colors.orange,
      },
      {
        'icon': Icons.spa,
        'title': l10n.tipStressTitle,
        'desc': l10n.tipStressDesc,
        'color': Colors.teal.shade100,
        'iconColor': Colors.teal,
      },
      {
        'icon': Icons.wash,
        'title': l10n.tipHygieneTitle,
        'desc': l10n.tipHygieneDesc,
        'color': Colors.cyan.shade100,
        'iconColor': Colors.cyan,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.healthTipsTitle,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // This could navigate to a dedicated tips screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete wellness library coming soon!'))
                  );
                },
                child: const Text(
                  'See More',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3, // Show only 3 tips as requested
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 12),
                child: ModernCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tip['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              tip['icon'] as IconData,
                              color: tip['iconColor'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip['desc'] as String,
                        style: const TextStyle(
                          color: AppTheme.darkGrey,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
