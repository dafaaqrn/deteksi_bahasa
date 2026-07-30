import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang ditemukan di perangkat ini.';
        });
        return;
      }

      _selectedCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _startCamera(_selectedCameraIndex);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengakses kamera: $e';
      });
    }
  }

  Future<void> _startCamera(int index) async {
  // Lepas kamera lama TERLEBIH DAHULU, dan tunggu sampai benar-benar selesai
  if (_controller != null) {
    await _controller!.dispose();
  }

  setState(() {
    _controller = null;
    _isInitialized = false;
  });

  final newController = CameraController(
    _cameras[index],
    ResolutionPreset.medium,
    enableAudio: false,
  );

  try {
    await newController.initialize();

    if (!mounted) return;
    setState(() {
      _controller = newController;
      _isInitialized = true;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'Gagal inisialisasi kamera: $e';
    });
  }
}

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Deteksi Bahasa Isyarat')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Bahasa Isyarat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Center(
  child: AspectRatio(
    aspectRatio: 1 / _controller!.value.aspectRatio,
    child: CameraPreview(_controller!),
  ),
),
    );
  }
}