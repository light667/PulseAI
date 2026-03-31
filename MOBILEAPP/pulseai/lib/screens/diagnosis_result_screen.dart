import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/markdown_text.dart';
import '../core/utils/responsive.dart';

class DiagnosisResultScreen extends StatefulWidget {
  final Map<String, dynamic>? results;

  const DiagnosisResultScreen({super.key, this.results});

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("fr-FR");
      await _flutterTts.setPitch(1.2);
      await _flutterTts.setSpeechRate(1.05);
      await _flutterTts.setVolume(1.0);
      debugPrint("TTS init: fr-FR, P=1.2, R=1.05");
    } catch (e) {
      debugPrint("TTS error: $e");
    }
    
    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speak(String text) async {
    try {
      if (_isSpeaking) {
        // Force immediate stop
        setState(() => _isSpeaking = false);
        await _flutterTts.stop();
        // On web, might need to pause as well
        if (kIsWeb) {
          await _flutterTts.pause();
        }
      } else {
        setState(() => _isSpeaking = true);
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint("TTS speak error: $e");
      setState(() => _isSpeaking = false);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  String _getStringContent(dynamic content) {
    if (content == null) return "";
    if (content is String) return content;
    if (content is List) {
      return content.map((e) => e.toString()).join('\n');
    }
    return content.toString();
  }

  String _cleanMarkdown(String text) {
    // Enlever les dièses markdown
    text = text.replaceAll(RegExp(r'#+\s*'), '');
    // Enlever les astérisques pour le gras
    text = text.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    // Enlever les tirets de liste
    text = text.replaceAll(RegExp(r'^\s*[-•]\s*', multiLine: true), '• ');
    return text.trim();
  }

  List<String> _extractSections(String text) {
    // Séparer par lignes vides ou sections
    final sections = <String>[];
    final lines = text.split('\n');
    StringBuffer currentSection = StringBuffer();
    
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        if (currentSection.isNotEmpty) {
          sections.add(currentSection.toString().trim());
          currentSection = StringBuffer();
        }
      } else {
        if (currentSection.isNotEmpty) currentSection.write('\n');
        currentSection.write(line);
      }
    }
    
    if (currentSection.isNotEmpty) {
      sections.add(currentSection.toString().trim());
    }
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    String diagnosisText = "Aucun diagnostic disponible";
    String recommendationsText = "";
    String severity = "normal";
    
    if (widget.results != null) {
      final rawDiagnosis = widget.results!['diagnosis'];
      if (rawDiagnosis != null) {
         final extracted = _getStringContent(rawDiagnosis);
         if (extracted.isNotEmpty) diagnosisText = extracted;
      }
      
      recommendationsText = _getStringContent(widget.results!['recommendations']);
      
      final rawSeverity = widget.results!['severity'];
      if (rawSeverity != null) {
        severity = _getStringContent(rawSeverity).toLowerCase();
      }
    }

    Color severityColor = AppTheme.success;
    IconData severityIcon = Icons.check_circle_outline;
    String severityLabel = "État Normal";
    
    if (severity.contains('grave') || severity.contains('urgent')) {
      severityColor = AppTheme.error;
      severityIcon = Icons.warning_rounded;
      severityLabel = "Attention Requise";
    } else if (severity.contains('modéré') || severity.contains('moyen')) {
      severityColor = AppTheme.warning;
      severityIcon = Icons.error_outline;
      severityLabel = "À Surveiller";
    }

    final textToRead = "Diagnostic. $diagnosisText. Recommandations. $recommendationsText";

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Résultats du Diagnostic'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: Responsive.valueWhen(context, mobile: 8, tablet: 12, desktop: 16),
            ),
            child: TextButton.icon(
              onPressed: () => _speak(textToRead),
              icon: Icon(
                _isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: Responsive.valueWhen(context, mobile: 18, tablet: 20, desktop: 20),
              ),
              label: Text(
                _isSpeaking ? "Arrêter" : "Écouter",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: Responsive.valueWhen(context, mobile: 13, tablet: 14, desktop: 14),
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.valueWhen(context, mobile: 10, tablet: 14, desktop: 16),
                  vertical: Responsive.valueWhen(context, mobile: 6, tablet: 8, desktop: 8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.valueWhen(
            context,
            mobile: 12,
            tablet: 20,
            desktop: 24,
          ),
          vertical: Responsive.valueWhen(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de statut principal
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.valueWhen(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
                vertical: Responsive.valueWhen(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [severityColor, severityColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Responsive.valueWhen(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                )),
                boxShadow: [
                  BoxShadow(
                    color: severityColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    severityIcon,
                    color: Colors.white,
                    size: Responsive.valueWhen(context, mobile: 48, tablet: 52, desktop: 56),
                  ),
                  SizedBox(height: Responsive.valueWhen(context, mobile: 12, tablet: 14, desktop: 16)),
                  Text(
                    severityLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.valueWhen(context, mobile: 20, tablet: 22, desktop: 24),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.valueWhen(context, mobile: 6, tablet: 7, desktop: 8)),
                  Text(
                    'Analyse IA complétée',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: Responsive.valueWhen(context, mobile: 13, tablet: 13.5, desktop: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Diagnostic
            _buildSectionTitle('📋 Diagnostic', Icons.medical_information_outlined),
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.valueWhen(
                context,
                mobile: 14,
                tablet: 18,
                desktop: 20,
              )),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Responsive.valueWhen(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                )),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: MarkdownText(
                text: diagnosisText,
                style: TextStyle(
                  fontSize: Responsive.valueWhen(context, mobile: 14, tablet: 14.5, desktop: 15),
                  height: 1.6,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            
            if (recommendationsText.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildSectionTitle('💡 Recommandations', Icons.tips_and_updates_outlined),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(Responsive.valueWhen(
                  context,
                  mobile: 14,
                  tablet: 18,
                  desktop: 20,
                )),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Responsive.valueWhen(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  )),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.3), width: 1),
                ),
                child: MarkdownText(
                  text: recommendationsText,
                  style: TextStyle(
                    fontSize: Responsive.valueWhen(context, mobile: 14, tablet: 14.5, desktop: 15),
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Avertissement
            Container(
              padding: EdgeInsets.all(Responsive.valueWhen(
                context,
                mobile: 14,
                tablet: 18,
                desktop: 20,
              )),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(Responsive.valueWhen(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                )),
                border: Border.all(color: Colors.amber.shade300, width: 2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade800,
                    size: Responsive.valueWhen(context, mobile: 20, tablet: 22, desktop: 24),
                  ),
                  SizedBox(width: Responsive.valueWhen(context, mobile: 10, tablet: 11, desktop: 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: Responsive.valueWhen(context, mobile: 14, tablet: 15, desktop: 16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: Responsive.valueWhen(context, mobile: 3, tablet: 3.5, desktop: 4)),
                        Text(
                          'Ce diagnostic est une estimation basée sur l\'intelligence artificielle. Consultez toujours un professionnel de santé pour un diagnostic médical officiel et un traitement adapté.',
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontSize: Responsive.valueWhen(context, mobile: 12, tablet: 12.5, desktop: 13),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Accueil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Pourrait naviguer vers l'onglet hôpitaux
                    },
                    icon: const Icon(Icons.local_hospital),
                    label: const Text('Trouver Hôpital'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
