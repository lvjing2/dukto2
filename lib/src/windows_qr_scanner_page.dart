import 'dart:async';
import 'dart:io';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'connection_qr.dart';
import 'localization.dart';
import 'qr_image_decoder.dart';

/// Windows uses its own capture backend; other platforms keep mobile_scanner.
class WindowsQrScannerPage extends StatefulWidget {
  final CameraPlatform? camera;
  final Future<String?> Function()? pickImage;
  final Future<ConnectionQr?> Function(String)? decodeImage;
  const WindowsQrScannerPage({
    super.key,
    this.camera,
    this.pickImage,
    this.decodeImage,
  });

  @override
  State<WindowsQrScannerPage> createState() => _WindowsQrScannerPageState();
}

class _WindowsQrScannerPageState extends State<WindowsQrScannerPage>
    with WidgetsBindingObserver {
  late final CameraPlatform _camera = widget.camera ?? CameraPlatform.instance;
  List<CameraDescription> _cameras = [];
  int _index = 0;
  int? _id;
  double _aspect = 4 / 3;
  bool _loading = true;
  bool _readingImage = false;
  bool _closed = false;
  bool _finished = false;
  bool _active = true;
  bool _capturing = false;
  String? _error;
  Timer? _timer;
  StreamSubscription<CameraErrorEvent>? _errors;
  StreamSubscription<CameraClosingEvent>? _closing;
  Future<void> _work = Future.value();
  Future<void>? _frame;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_queue(() => _open(refresh: true)));
  }

  Future<void> _queue(Future<void> Function() operation) {
    _work = _work.then((_) => operation()).catchError((Object _) {
      if (mounted && !_closed) {
        setState(() {
          _loading = false;
          _error = context.l10n.cameraUnavailable;
        });
      }
    });
    return _work;
  }

  Future<void> _release() async {
    _timer?.cancel();
    _timer = null;
    await _frame;
    await _errors?.cancel();
    await _closing?.cancel();
    _errors = null;
    _closing = null;
    final id = _id;
    _id = null;
    if (id != null) {
      try {
        await _camera.dispose(id);
      } on Object {
        /* Device may be unplugged. */
      }
    }
  }

  Future<void> _open({bool refresh = false}) async {
    await _release();
    if (_closed || _finished || !_active || _readingImage) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (refresh) {
        _cameras = await _camera.availableCameras();
        final rear = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
        );
        _index = rear < 0 ? 0 : rear;
      }
      if (_closed || !_active || _readingImage) return;
      if (_cameras.isEmpty) {
        setState(() {
          _loading = false;
          _error = context.l10n.qrNoCamera;
        });
        return;
      }
      final id = await _camera.createCameraWithSettings(
        _cameras[_index],
        const MediaSettings(
          resolutionPreset: ResolutionPreset.high,
          enableAudio: false,
        ),
      );
      _id = id;
      _errors = _camera.onCameraError(id).listen((_) => _cameraFailed());
      _closing = _camera.onCameraClosing(id).listen((_) => _cameraFailed());
      final initialized = _camera
          .onCameraInitialized(id)
          .first
          .timeout(const Duration(seconds: 12));
      // Observe an early event failure even if initializeCamera itself throws.
      unawaited(initialized.then<void>((_) {}, onError: (Object _) {}));
      await _camera.initializeCamera(id);
      final event = await initialized;
      if (_closed || !_active || _readingImage) {
        await _release();
        return;
      }
      setState(() {
        _aspect = event.previewHeight > 0
            ? event.previewWidth / event.previewHeight
            : 4 / 3;
        _loading = false;
      });
      _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
        if (!_capturing &&
            !_closed &&
            !_finished &&
            _active &&
            !_readingImage) {
          _frame = _capture(id);
        }
      });
    } on Object {
      await _release();
      if (mounted && !_closed) {
        setState(() {
          _loading = false;
          _error = context.l10n.cameraUnavailable;
        });
      }
    }
  }

  void _cameraFailed() {
    _timer?.cancel();
    if (mounted && !_closed && !_finished && !_readingImage) {
      setState(() {
        _loading = false;
        _error = context.l10n.cameraUnavailable;
      });
      unawaited(_queue(_release));
    }
  }

  Future<void> _capture(int id) async {
    _capturing = true;
    String? temporary;
    ConnectionQr? qr;
    try {
      final photo = await _camera.takePicture(id);
      temporary = photo.path;
      qr = await (widget.decodeImage ?? readConnectionQrImage)(temporary);
    } on QrImageException catch (e) {
      if (e.reason == QrImageFailure.invalidQr && mounted && !_closed) {
        setState(() => _error = context.l10n.qrExpected);
      }
    } on Object {
      _cameraFailed();
    } finally {
      if (temporary != null) {
        try {
          await File(temporary).delete();
        } on FileSystemException {
          /* Already removed. */
        }
      }
      _capturing = false;
    }
    if (qr != null && !_closed && !_finished && _active && !_readingImage) {
      unawaited(_finish(qr));
    }
  }

  Future<void> _finish(ConnectionQr qr) async {
    if (_closed || _finished) return;
    _finished = true;
    await _queue(_release);
    if (mounted && !_closed) Navigator.pop(context, qr);
  }

  Future<void> _chooseImage() async {
    if (_readingImage || _finished) return;
    setState(() {
      _readingImage = true;
      _error = null;
    });
    await _queue(_release);
    if (_closed) return;
    try {
      final path = await (widget.pickImage?.call() ?? _pickImage());
      if (_closed) return;
      if (path != null) {
        final qr = await (widget.decodeImage ?? readConnectionQrImage)(path);
        if (_closed) return;
        if (qr != null) {
          await _finish(qr);
          return;
        }
        setState(() => _error = context.l10n.qrImageNotFound);
      }
    } on QrImageException catch (e) {
      if (mounted && !_closed) {
        setState(
          () => _error = switch (e.reason) {
            QrImageFailure.tooLarge => context.l10n.qrImageTooLarge,
            QrImageFailure.invalidQr => context.l10n.qrInvalid,
            QrImageFailure.unreadable => context.l10n.qrImageUnreadable,
          },
        );
      }
    } on Object {
      if (mounted && !_closed) {
        setState(() => _error = context.l10n.qrImageUnreadable);
      }
    } finally {
      if (mounted && !_closed && !_finished) {
        setState(() {
          _readingImage = false;
          _loading = false;
        });
      }
    }
  }

  Future<String?> _pickImage() async {
    final files = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'bmp'],
    );
    return files?.path;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active && !_readingImage && !_finished) {
      unawaited(_queue(() => _open(refresh: true)));
    } else {
      unawaited(_queue(_release));
    }
  }

  @override
  void dispose() {
    _closed = true;
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_queue(_release));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(strings.scanQr)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) => Column(
            children: [
              Expanded(
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator()
                      : _id != null &&
                            !_readingImage &&
                            _error != strings.cameraUnavailable
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: AspectRatio(
                            aspectRatio: _aspect,
                            child: ClipRect(child: _camera.buildPreview(_id!)),
                          ),
                        )
                      : Icon(
                          Icons.qr_code_scanner,
                          size: 72,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: size.maxHeight * .55),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            semanticsLabel: _error,
                          ),
                        ),
                      if (_cameras.length > 1)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: DropdownButtonFormField<int>(
                            initialValue: _index,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: strings.qrCamera,
                            ),
                            items: [
                              for (var i = 0; i < _cameras.length; i++)
                                DropdownMenuItem(
                                  value: i,
                                  child: Text(
                                    _cameras[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: _loading || _readingImage
                                ? null
                                : (value) {
                                    if (value != null) {
                                      _index = value;
                                      unawaited(_queue(() => _open()));
                                    }
                                  },
                          ),
                        ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            onPressed: _readingImage || _finished
                                ? null
                                : _chooseImage,
                            icon: _readingImage
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.image_outlined),
                            label: Text(strings.qrChooseImage),
                          ),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            onPressed: _loading || _readingImage || _finished
                                ? null
                                : () => unawaited(
                                    _queue(() => _open(refresh: true)),
                                  ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(strings.qrOpenCamera),
                          ),
                        ],
                      ),
                    ],
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
