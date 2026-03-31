import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanResultScreen extends StatelessWidget {
  final Map<String, dynamic>? result;

  const ScanResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final medication = result?['medication'] ?? {
      "name": "Doliprane 1000mg",
      "active_ingredient": "Paracétamol",
      "manufacturer": "Sanofi",
      "description": "Antalgique et antipyrétique indiqué en cas de douleur et/ou fièvre.",
    };

    return Scaffold(
      backgroundColor: const Color(0xFFA0DCD5), // Mint/Teal background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                child: Center(
                  child: Icon(
                    Icons.medication,
                    size: 120,
                    color: colorScheme.primary.withOpacity(0.5),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                ),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Doliprane 1000mg',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Sûr',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Paracétamol • Sanofi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Description'),
                  const Text(
                    'Indiqué pour les douleurs et/ou fièvre telles que maux de tête, états grippaux, douleurs dentaires, courbatures, règles douloureuses.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Posologie'),
                  _buildInfoRow(Icons.access_time, 'Toutes les 4 à 6 heures'),
                  _buildInfoRow(Icons.warning_amber, 'Max 4g par jour'),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Effets Secondaires Possibles'),
                  const Text(
                    '• Réactions allergiques rares\n• Troubles hépatiques en cas de surdosage',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('AJOUTER À MA PHARMACIE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}
