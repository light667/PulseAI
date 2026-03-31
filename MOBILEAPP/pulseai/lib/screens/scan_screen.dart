import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:camera/camera.dart';
import 'package:pulseai/services/scan_service.dart';
import 'package:pulseai/screens/scan_result_screen.dart';
import '../core/theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  CameraController? _cameraController;
  final ScanService _scanService = ScanService();
  bool _isScanning = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // D\u00e9sactiver la cam\u00e9ra sur Web car non support\u00e9e
    if (kIsWeb) {
      print('Camera not supported on Web');
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
      return;
    }
    
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() => _isCameraInitialized = true);
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startScan() async {
    if (!_isCameraInitialized || _isScanning) return;

    setState(() => _isScanning = true);

    try {
      final image = await _cameraController!.takePicture();
      final result = await _scanService.scanMedication(image);

      if (mounted) {
        setState(() => _isScanning = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Camera Preview (Optional: keep it running in background for effect, or remove)
          if (_isCameraInitialized)
            Opacity(
              opacity: 0.3,
              child: SizedBox.expand(
                child: CameraPreview(_cameraController!),
              ),
            ),
          
          // Coming Soon Overlay
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.science_outlined, color: Colors.white, size: 64),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                const Text(
                  "Available Soon",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 12),
                Text(
                  "This feature is currently under intensive development.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),

          // Header Overlay
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Medication Scanner",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.5, end: 0),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    return [
      Positioned(top: 0, left: 0, child: _buildCorner(0)),
      Positioned(top: 0, right: 0, child: _buildCorner(1)),
      Positioned(bottom: 0, left: 0, child: _buildCorner(2)),
      Positioned(bottom: 0, right: 0, child: _buildCorner(3)),
    ];
  }

  Widget _buildCorner(int index) {
    return RotatedBox(
      quarterTurns: index,
      child: Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white, width: 4),
            left: BorderSide(color: Colors.white, width: 4),
          ),
        ),
      ),
    );
  }
}
