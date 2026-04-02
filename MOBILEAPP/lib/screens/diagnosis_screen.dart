import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulseai/services/diagnosis_service.dart';
import 'package:pulseai/services/api_service.dart';
import 'package:pulseai/services/history_service.dart';
import 'package:pulseai/screens/diagnosis_result_screen.dart';
import 'package:pulseai/l10n/generated/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final DiagnosisService _diagnosisService = DiagnosisService();
  final HistoryService _historyService = HistoryService();
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isListening = false;
  bool _showAllQuick = false;
  bool _isAnalyzing = false;

  Widget _buildQuickSymptomsList(AppLocalizations l10n) {
    final symptoms = [
      {'label': l10n.symptomVomiting, 'icon': Icons.sick_outlined},
      {'label': l10n.symptomNausea, 'icon': Icons.waves},
      {'label': l10n.symptomBackPain, 'icon': Icons.back_hand},
      {'label': l10n.symptomHeadache, 'icon': Icons.psychology},
      {'label': l10n.symptomAbdominalPainAcute, 'icon': Icons.healing},
      {'label': l10n.symptomFever, 'icon': Icons.thermostat},
      {'label': l10n.symptomAbdominalPainLow, 'icon': Icons.healing},
      {'label': l10n.symptomCough, 'icon': Icons.masks},
      {'label': l10n.symptomNasalCongestion, 'icon': Icons.sick},
      {'label': l10n.symptomHeartburn, 'icon': Icons.local_fire_department},
    ];

    final displayedSymptoms = _showAllQuick ? symptoms : symptoms.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayedSymptoms.map((symptom) {
            return InkWell(
              onTap: () => _addSymptom(symptom['label'] as String),
              borderRadius: BorderRadius.circular(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(symptom['icon'] as IconData, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          symptom['label'] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).scale();
          }).toList(),
        ),
        if (symptoms.length > 6)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showAllQuick = !_showAllQuick;
                });
              },
              child: Text(
                _showAllQuick ? 'Show less' : 'See all',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {}); // Update send button color/state
    });
  }

  void _listen() async {
    if (!_isListening) {
      try {
        bool available = await _speech.initialize(
          onStatus: (val) => debugPrint('onStatus: $val'),
          onError: (val) {
            debugPrint('onError: $val');
            if (mounted) setState(() => _isListening = false);
          },
        );
        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (val) => setState(() {
              _textController.text = val.recognizedWords;
            }),
            localeId: 'en_US',
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Speech recognition not available.'), backgroundColor: AppTheme.error),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition error.'), backgroundColor: AppTheme.error),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _analyze() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your symptoms.'), backgroundColor: AppTheme.error),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Assuming English is natively processed now
      String symptomsEn = _textController.text;

      final results = await _diagnosisService.diagnose(symptoms: [symptomsEn]);

      if (mounted) {
        await _historyService.saveDiagnosis(
          symptoms: _textController.text,
          results: results,
        );
        setState(() => _isAnalyzing = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => DiagnosisResultScreen(results: results)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Diagnosis error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _addSymptom(String symptom) {
    final currentText = _textController.text;
    if (currentText.isEmpty) {
      _textController.text = symptom;
    } else {
      _textController.text = '$currentText, $symptom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF0077B6), Color(0xFF023E8A), Color(0xFF0096C7)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Triage',
                        style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                      ).animate().fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Text(
                        'Describe your symptoms to receive an instant medical assessment.',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.85)),
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Main Content
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Premium AI Triage Input Box - High Contrast Redesign
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white, // Solid white for absolute clarity
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: TextField(
                                            controller: _textController,
                                            maxLines: 5,
                                            minLines: 1,
                                            cursorColor: AppTheme.primaryBlue,
                                            style: const TextStyle(
                                              color: Colors.black87, // High contrast black text
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Describe your symptoms here...',
                                              hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                                              border: InputBorder.none,
                                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: GestureDetector(
                                          onTap: _isAnalyzing ? null : _analyze,
                                          child: AnimatedContainer(
                                            duration: 300.ms,
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: _textController.text.isEmpty 
                                                  ? LinearGradient(colors: [Colors.grey[300]!, Colors.grey[300]!])
                                                  : AppTheme.primaryGradient,
                                              shape: BoxShape.circle,
                                              boxShadow: _textController.text.isEmpty ? [] : [
                                                BoxShadow(
                                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                            ),
                                            child: _isAnalyzing 
                                                ? const SizedBox(
                                                    width: 24, 
                                                    height: 24, 
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2, 
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.send_rounded, 
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _actionButton(
                                      _isListening ? Icons.mic_off : Icons.mic,
                                      _isListening ? 'Stop' : 'Voice Scan',
                                      _listen,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _actionButton(
                                      Icons.camera_alt_outlined, 
                                      'Camera Scan', 
                                      () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon.')))
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                              const SizedBox(height: 32),

                              const Text(
                                'Common Symptoms',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ).animate().fadeIn(delay: 400.ms),
                              
                              const SizedBox(height: 16),
                              
                              _buildQuickSymptomsList(AppLocalizations.of(context)!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
