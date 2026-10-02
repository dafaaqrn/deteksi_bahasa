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
  bool _isSwitchingCamera = false; // guard baru
  String? _errorMessage;

  HandLandmarkerPlugin? _plugin;
  StreamSubscription<List<Hand>>? _landmarkSubscription;

  static const int sequenceLength = 30;
  final List<List<double>> _frameBuffer = [];

  // Ganti dari field biasa + setState, jadi ValueNotifier (hindari rebuild seluruh layar)
  final ValueNotifier<int> _handCountNotifier = ValueNotifier(0);
  final ValueNotifier<int> _bufferProgressNotifier = ValueNotifier(0);

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
    if (_isSwitchingCamera) return; // cegah proses numpuk
    _isSwitchingCamera = true;

    try {
      await _landmarkSubscription?.cancel();
      _landmarkSubscription = null;
      await _controller?.stopImageStream();
      await _controller?.dispose();
      _plugin?.dispose();
      _plugin = null;

      setState(() {
        _controller = null;
        _isInitialized = false;
        _frameBuffer.clear();
      });
      _handCountNotifier.value = 0;
      _bufferProgressNotifier.value = 0;

      final newController = CameraController(
        _cameras[index],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await newController.initialize();

      final newPlugin = HandLandmarkerPlugin.create(
        numHands: 2,
        minHandDetectionConfidence: 0.6,
        delegate: HandLandmarkerDelegate.cpu,
      );

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
    } finally {
      _isSwitchingCamera = false;
    }
  }

  void _onLandmarksDetected(List<Hand> hands) {
    // Tidak pakai setState di sini -> hindari rebuild seluruh layar tiap frame
    _handCountNotifier.value = hands.length;

    final featureVector = _buildFeatureVector(hands);
    _frameBuffer.add(featureVector);
    _bufferProgressNotifier.value = _frameBuffer.length;

    if (_frameBuffer.length >= sequenceLength) {
      final sequence = List<List<double>>.from(_frameBuffer);
      _frameBuffer.clear();
      _bufferProgressNotifier.value = 0;
      _onSequenceReady(sequence);
    }
  }

  List<double> _buildFeatureVector(List<Hand> hands) {
    List<double> slotA = List.filled(21 * 3, 0.0);
    List<double> slotB = List.filled(21 * 3, 0.0);

    if (hands.isNotEmpty) {
      final sortedHands = List<Hand>.from(hands)
        ..sort((a, b) => a.landmarks[0].x.compareTo(b.landmarks[0].x));

      if (sortedHands.isNotEmpty) {
        slotA = _flattenLandmarks(sortedHands[0]);
      }
      if (sortedHands.length >= 2) {
        slotB = _flattenLandmarks(sortedHands[1]);
      }
    }

    return [...slotA, ...slotB];
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
    debugPrint('Sequence siap: ${sequence.length} frame x ${sequence[0].length} fitur');
  }

  void _switchCamera() {
    if (_cameras.length < 2 || _isSwitchingCamera) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _startCamera(_selectedCameraIndex);
  }

  @override
  void dispose() {
    _landmarkSubscription?.cancel();
    _controller?.stopImageStream();
    _controller?.dispose();
    _plugin?.dispose();
    _handCountNotifier.dispose();
    _bufferProgressNotifier.dispose();
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
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _handCountNotifier,
                builder: (context, handCount, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _bufferProgressNotifier,
                    builder: (context, bufferCount, _) {
                      return Text(
                        'Tangan terdeteksi: $handCount | Frame: $bufferCount/$sequenceLength',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}