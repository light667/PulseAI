import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pulseai/services/api_service.dart';
import 'package:pulseai/services/history_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/markdown_text.dart';
import '../core/utils/responsive.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  final HistoryService _historyService = HistoryService();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  String? _speakingMessage;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setPitch(1.2);
      await _flutterTts.setSpeechRate(1.05);
      await _flutterTts.setVolume(1.0);
    } catch (e) {
      debugPrint('TTS error: $e');
    }
    
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _speakingMessage = null);
    });

    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _speakingMessage = null);
    });
    
    _flutterTts.setErrorHandler((msg) {
       debugPrint('TTS Error: $msg');
       if (mounted) setState(() => _speakingMessage = null);
    });
  }

  Future<void> _speak(String text) async {
    try {
      if (_speakingMessage == text) {
        if (mounted) setState(() => _speakingMessage = null);
        await _flutterTts.stop();
        if (kIsWeb) await _flutterTts.pause();
      } else {
        await _flutterTts.stop();
        if (mounted) setState(() => _speakingMessage = text);
        await Future.delayed(const Duration(milliseconds: 100));
        await _flutterTts.speak(text);
      }
    } catch (e) {
      debugPrint('TTS speak error: $e');
      if (mounted) setState(() => _speakingMessage = null);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _saveSession();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'message': 'Hello! I am Lyra, your virtual medical assistant and therapist. How can I help you today?',
      'time': DateTime.now().subtract(const Duration(minutes: 1)),
    },
  ];
  
  List<Map<String, String>> _apiHistory = [];
  bool _isLoading = false;

  Future<void> _saveSession() async {
    if (_messages.length > 1) {
      await _historyService.saveChatSession(messages: _messages);
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final userMessage = _controller.text.trim();
    
    setState(() {
      _messages.add({
        'isUser': true,
        'message': userMessage,
        'time': DateTime.now(),
      });
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _apiService.chat(userMessage, _apiHistory);
      
      final botResponse = response['response'];
      final history = List<Map<String, dynamic>>.from(response['history']);
      
      _apiHistory = history.map((e) => {
        'role': e['role'].toString(),
        'content': e['content'].toString()
      }).toList();

      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'message': botResponse,
            'time': DateTime.now(),
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'message': 'Sorry, an error occurred. Please check your connection.',
            'time': DateTime.now(),
            'isError': true,
          });
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Lyra',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Elegant dark background variant for Lyra
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
            ),
          ),

          // Glowing aesthetic orbits
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.15)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['isUser'] as bool;
                      final isError = msg['isError'] as bool? ?? false;
                      
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) // Lyra Avatar
                              Container(
                                margin: const EdgeInsets.only(right: 8, bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primaryLight.withOpacity(0.5)),
                                ),
                                child: const Icon(Icons.psychology, color: AppTheme.primaryLight, size: 20),
                              ),
                            
                            // Chat Bubble
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isError 
                                      ? AppTheme.error.withOpacity(0.2)
                                      : isUser 
                                          ? AppTheme.primaryBlue.withOpacity(0.25)
                                          : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                                    bottomRight: Radius.circular(isUser ? 0 : 20),
                                  ),
                                  border: Border.all(
                                    color: isError 
                                        ? AppTheme.error.withOpacity(0.3) 
                                        : Colors.white.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MarkdownText(
                                      text: msg['message'] as String,
                                      style: TextStyle(
                                        color: isError ? Colors.red[200] : Colors.white,
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (!isUser) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _speak(msg['message'] as String),
                                            child: Icon(
                                              _speakingMessage == msg['message'] ? Icons.stop_circle_rounded : Icons.volume_up_rounded, 
                                              size: 20,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                              ),
                              SizedBox(width: 10),
                              Text('Lyra is thinking...', style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                
                // Bottom Input Area
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.12))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !_isLoading,
                              maxLines: null,
                              minLines: 1,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Message Lyra...',
                                hintStyle: const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _isLoading ? null : _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: _isLoading 
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.send_rounded, color: Colors.white, size: 24),
                            ),
                          ).animate().scale(duration: 200.ms),
                        ],
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
}