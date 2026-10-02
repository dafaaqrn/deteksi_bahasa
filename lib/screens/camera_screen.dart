import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

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

  HandLandmarkerPlugin? _plugin;
  StreamSubscription<List<Hand>>? _landmarkSubscription;

  // Buffer untuk 1 sequence = 30 frame x 126 fitur
  static const int sequenceLength = 30;
  final List<List<double>> _frameBuffer = [];
  List<Hand> _currentHands = [];

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
    // Hentikan plugin & stream lama dulu
    await _landmarkSubscription?.cancel();
    _landmarkSubscription = null;
    await _controller?.stopImageStream();
    if (_controller != null) {
      await _controller!.dispose();
    }
    _plugin?.dispose();
    _plugin = null;

    setState(() {
      _controller = null;
      _isInitialized = false;
      _frameBuffer.clear();
      _currentHands = [];
    });

    final newController = CameraController(
      _cameras[index],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await newController.initialize();

      // Inisialisasi plugin hand_landmarker
      final newPlugin = HandLandmarkerPlugin.create(
        numHands: 2,
        minHandDetectionConfidence: 0.6,
        delegate: HandLandmarkerDelegate.cpu, // CPU karena laptop dev tidak ada GPU; HP tetap bisa pakai gpu kalau mau nanti dites performanya
      );

      // Dengarkan hasil deteksi landmark
      _landmarkSubscription = newPlugin.landmarkStream.listen(_onLandmarksDetected);

      await newController.startImageStream((image) {
        newPlugin.processFrame(image, newController.description.sensorOrientation);
      });

      if (!mounted) return;
      setState(() {
        _controller = newController;
        _plugin = newPlugin;
        _isInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal inisialisasi kamera: $e';
      });
    }
  }

  void _onLandmarksDetected(List<Hand> hands) {
    if (!mounted) return;

    setState(() {
      _currentHands = hands;
    });

    // Bangun feature vector 126 nilai: slot ditentukan posisi X (kiri->kanan),
    // BUKAN handedness, supaya konsisten dengan collect_data.py di ml-model.
    final featureVector = _buildFeatureVector(hands);

    _frameBuffer.add(featureVector);

    if (_frameBuffer.length >= sequenceLength) {
      final sequence = List<List<double>>.from(_frameBuffer);
      _frameBuffer.clear();
      _onSequenceReady(sequence);
    }
  }

  List<double> _buildFeatureVector(List<Hand> hands) {
    List<double> slotA = List.filled(21 * 3, 0.0);
    List<double> slotB = List.filled(21 * 3, 0.0);

    if (hands.isNotEmpty) {
      // urutkan tangan berdasarkan posisi X landmark wrist (index 0), kiri ke kanan
      final sortedHands = List<Hand>.from(hands)
        ..sort((a, b) => a.landmarks[0].x.compareTo(b.landmarks[0].x));

      if (sortedHands.isNotEmpty) {
        slotA = _flattenLandmarks(sortedHands[0]);
      }
      if (sortedHands.length >= 2) {
        slotB = _flattenLandmarks(sortedHands[1]);
      }
    }

    return [...slotA, ...slotB]; // total 126 nilai
  }

  List<double> _flattenLandmarks(Hand hand) {
    final result = <double>[];
    for (final lm in hand.landmarks) {
      result.addAll([lm.x, lm.y, lm.z]);
    }
    return result;
  }

  void _onSequenceReady(List<List<double>> sequence) {
    // TODO: setelah model .tflite siap, panggil inference di sini.
    // Untuk sekarang, baru tampilkan info bahwa 1 sequence (30 frame) sudah terkumpul.
    debugPrint('Sequence siap: ${sequence.length} frame x ${sequence[0].length} fitur');
  }

  void _switchCamera() {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _landmarkSubscription?.cancel();
    _controller?.stopImageStream();
    _controller?.dispose();
    _plugin?.dispose();
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
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          // Indikator kecil: jumlah tangan terdeteksi + progress buffer frame
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tangan terdeteksi: ${_currentHands.length} | Frame: ${_frameBuffer.length}/$sequenceLength',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}