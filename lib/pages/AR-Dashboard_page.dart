
import 'dart:async';
import 'dart:ui' as ui;
import 'package:image/image.dart'as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import '../widgets/dashboard_grid_M2_VR.dart';
import '../widgets/dashboard_grid_S1_VR.dart';
import '../widgets/dashboard_grid_S2_VR.dart';
import 'package:projekt_wzm_iot/widgets/dashboard_grid_M1_VR.dart';


class ARcode extends Page {
  static const pageName = 'AR-Dashboard'; // Definition des Pagename
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this, builder: (context)=>const AR_Dashboard_Page());
  }
}

class AR_Dashboard_Page extends StatefulWidget {
  const AR_Dashboard_Page({Key? key}) : super(key: key);
  @override
  State<AR_Dashboard_Page> createState() => _AR_Dashboard_Page_State();
}

class _AR_Dashboard_Page_State extends State<AR_Dashboard_Page> {

  final Color _FraunhoferColor = const Color.fromRGBO(23, 156, 125, 1);
  final _scannedFrameStreamController = StreamController<_ScannedFrame>();
  late CameraController _cameraController;
  final cameras = <CameraDescription>[];
  final stopwatch = Stopwatch();
  final _qrCode = QrCode();
  bool _processFrameReady = true;
  List<Matrix4> matrices = []; // To store collected matrices
  int chartnummer = 0;
  bool showcountvalue = false;


// this function enable the display of chart over the QR-code upon button press
  void chartinfo (int value) {
    setState(() {
      chartnummer = value;
    });
  }

  // This function implements a 3-second countdown when the button is pressed.
  void showcount(int i) {
    setState(() {
      showcountvalue = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // function to initialize the control of camera and start to capture image
  Future<void> _initializeCamera() async {
    cameras.addAll(await availableCameras());
    // You can now access the cameras list and initialize your camera controller
    _cameraController = CameraController(
      // Get a specific camera from the list
      cameras.first,
      // Define the resolution to use
      ResolutionPreset.medium,
      // Enable audio
    );
    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.startImageStream(_processFrame);      // Initialize camera stream and listen to captured frames
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Vision Demo",),
        backgroundColor: const Color.fromRGBO(23, 156, 125, 1),
      ),
      body: ListView(
        children: [
          _buildPreview(chartnummer),
          const ListTile(
            title:
            Center(child: Text("please place the QR code in the center of the screen and select your device", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ),
          const SizedBox( height: 20),
          showcountvalue?const Countdown():Container(),// if the value of showcountvalue is 1, it will start countdown
        Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(15.0), color: _FraunhoferColor),
                    alignment: Alignment.center,
                    child: TextButton(//the begin of the control to display the things in the form augmented reality
                      onPressed: () {
                        showcount(1);
                        chartinfo(1);
                      },
                      child: const Text(' Motor 1',
                          style:TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600 ,)
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(15.0), color: _FraunhoferColor),
                    alignment: Alignment.center, //
                    child: TextButton(// You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                      onPressed: () {
                        showcount(1);
                        chartinfo(2);
                      },
                      child: const Text(' Motor 2',
                          style:TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600 ,)
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(15.0), color: _FraunhoferColor),
                    alignment: Alignment.center, //
                    child: TextButton(// You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                      onPressed: () {
                        showcount(1);
                        chartinfo(3);
                      },
                      child: const Text(' Sensor 1',
                          style:TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600 ,)
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration( borderRadius: BorderRadius.circular(15.0), color: _FraunhoferColor),
                    alignment: Alignment.center, //
                    child: TextButton(// You can use other alignments like Alignment.topLeft, Alignment.bottomRight, etc.
                      onPressed: () {
                        showcount(1);
                        chartinfo(4);
                      },
                      child: const Text(' Sensor 2',
                          style:TextStyle(
                            color: Colors.black,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600 ,)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

// This function builds the widget that displays the camera feed and overlays it with
// information about the QR codes that are currently being scanned.
  Widget _buildPreview( int chartnumber) {
    // A StreamBuilder widget is used to create a dynamic widget that updates whenever
    // a new _ScannedFrame is added to the _scannedFrameStreamController stream.
    return StreamBuilder<_ScannedFrame>(
      stream: _scannedFrameStreamController.stream,
      initialData: null,
      builder: (context, snapshot) => snapshot.data != null
      // If the snapshot contains data, build the camera feed view
          ? LayoutBuilder(
             builder: (context, constraints) => ClipRect(
               clipBehavior: Clip.hardEdge,
               child: _buildFrame(
              snapshot.data!, constraints.maxWidth, constraints.maxWidth, chartnumber),
        ),
      )
          : const Center(
             child: CircularProgressIndicator(),
      ),
    );
  }


  Widget _buildFrame(_ScannedFrame frame, double width, double height, chartnumber) {
    final scaleFactor = width / frame.image.width.toDouble();
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        CustomPaint(
          painter: _CameraViewPainter( frame: frame),
          size: ui.Size(width, height)),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only( top: 300.0),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _FraunhoferColor,
                  width: 5.0,
                ),
              ),
            ),
          ),
        ),
        // If a QR code is detected in the frame, overlay an image on top of it
        (frame.qrCode != null)
            ? _buildImageOverlay(frame.qrCode!, scaleFactor,chartnumber)
            : Container(),
      ],
    );
  }



  Matrix4? initialScaledTransformationMatrix;
// This widget builds an overlay for the detected QR code

  Widget _buildImageOverlay(QrCode qrCode, double scaleFactor, chartnumber) {
    // Generate a transformation matrix from the QR code location
    final transformMatrix = qrCode.location?.computePerspectiveTransform().to3DPerspectiveMatrix();
    // Scale the transformation matrix according to the scaleFactor
    final scaledTransformationMatrix = transformMatrix != null
        ? Matrix4.diagonal3Values(scaleFactor, scaleFactor, scaleFactor) *
        Matrix4.fromFloat64List(transformMatrix)
        : null;

    final qrCodeSize = qrCode.location?.dimension.size.toDouble();
    final content = qrCode.content?.text;

    // If the QR code is of the correct size, its content is not null, and it corresponds to one of the required chart numbers...
    if (qrCodeSize != null && content != null && (chartnumber == 1 || chartnumber == 2 || chartnumber == 3 || chartnumber == 4) ) {
      stopwatch.start();    // Start the stopwatch to track time
      // If the transformation matrix is scaled and the stopwatch has not passed 3 seconds, set the initial transformation matrix
      if (scaledTransformationMatrix != null && stopwatch.elapsedMilliseconds <= 3000) {
        initialScaledTransformationMatrix= scaledTransformationMatrix;
        }
     if (initialScaledTransformationMatrix != null) {// Ensure it's not null
         return Transform(
         alignment: Alignment.center,
         transform: initialScaledTransformationMatrix!,
         child: Transform.scale(
          scale: 0.4,
           child: SizedBox(
             height: qrCodeSize*10,
             width: qrCodeSize*5,
             child: (){
               switch (chartnumber) {// The display of the chart will depend on the 'chartNumber', which is determined by the button selection.
               case 1: return DashboardM1VRGrid();
                 case 2: return DashboardM2VRGrid();
                 case 3: return DashboardS1VRGrid();
                 case 4: return DashboardS2VRGrid();
                 default: return Container(); // Fallback case
               }
             } (),
            ),
          ),
         );
      } else {
      return Container();
    }

    } else {
      return Container();
    }
  }

  /// Process a captured frame and scan it for QR codes
  Future<void> _processFrame(CameraImage cameraFrame) async {
    // Skip this frame if another frame is already being processed
    // (otherwise simultaneous processes could accumulate, leading to memory
    // leaks and crashes)
    if (!_processFrameReady) {
      return;
    }
    _processFrameReady = false;
    try {
      int imageWidth = cameraFrame.width;
      int imageHeight = cameraFrame.height;
      List<Uint8List> planes = [];

      for (int planeIndex = 0; planeIndex < 3; planeIndex++) {
        Uint8List buffer;
        int width;
        int height;
        if (planeIndex == 0) {
          width = cameraFrame.width;
          height = cameraFrame.height;
        } else {
          width = cameraFrame.width ~/ 2;
          height = cameraFrame.height ~/ 2;
        }
        buffer = Uint8List(width * height);
        int pixelStride = cameraFrame.planes[planeIndex].bytesPerPixel!;
        int rowStride = cameraFrame.planes[planeIndex].bytesPerRow;
        int index = 0;
        for (int i = 0; i < height; i++) {
          for (int j = 0; j < width; j++) {
            buffer[index++] = cameraFrame
                .planes[planeIndex].bytes[i * rowStride + j * pixelStride];
          }
        }

        planes.add(buffer);

      }

      // Function responsible for converting from YUV to RGB format
      Uint8List yuv420ToRgba8888(List<Uint8List> planes, int width, int height) {
        final yPlane = planes[0];
        final uPlane = planes[1];
        final vPlane = planes[2];

        final Uint8List rgbaBytes = Uint8List(width * height * 4);

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final int yIndex = y * width + x;
            final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

            final int yValue = yPlane[yIndex] & 0xFF;
            final int uValue = uPlane[uvIndex] & 0xFF;
            final int vValue = vPlane[uvIndex] & 0xFF;

            final int r = (yValue + 1.13983 * (vValue - 128)).round().clamp(0, 255);
            final int g =
            (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128))
                .round()
                .clamp(0, 255);
            final int b = (yValue + 2.03211 * (uValue - 128)).round().clamp(0, 255);

            final int rgbaIndex = yIndex * 4;
            rgbaBytes[rgbaIndex] = r.toUnsigned(8);
            rgbaBytes[rgbaIndex + 1] = g.toUnsigned(8);
            rgbaBytes[rgbaIndex + 2] = b.toUnsigned(8);
            rgbaBytes[rgbaIndex + 3] = 255; // Alpha value
          }
        }

        return rgbaBytes;
      }
      Uint8List data = yuv420ToRgba8888(planes, imageWidth, imageHeight);

      imglib.Image originalImage = imglib.Image.fromBytes(
        imageWidth,
        imageHeight,
        data,
        format: imglib.Format.rgba,
      );

      imglib.Image rotatedImage = imglib.copyRotate(originalImage, 90);

      //------------------------------
      Future<ui.Image> createImage(
          Uint8List buffer, int width, int height, ui.PixelFormat pixelFormat) {
        final Completer<ui.Image> completer = Completer();
        ui.decodeImageFromPixels(buffer, width, height, pixelFormat, (ui.Image img) {
          completer.complete(img);
        });
        return completer.future;
      }
//------------------------------------
      // Get the RGBA bytes, width, and height from the rotated image
      Uint8List rotatedData = rotatedImage.getBytes();
      int rotatedWidth = rotatedImage.width;
      int rotatedHeight = rotatedImage.height;
      //-------------------
      var image = await createImage(rotatedData, rotatedWidth, rotatedHeight, ui.PixelFormat.rgba8888);

      // Update the QR code by scanning the image cont  ent
      // _qrCode.scanRgbaBytes(data, imageWidth, imageHeight);
      _qrCode.scanRgbaBytes(rotatedData, rotatedWidth, rotatedHeight);

      // Publish an update for the UI
      _scannedFrameStreamController.add(
        _ScannedFrame(
          image: image,
          qrCode: _qrCode,
        ),
      );

    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    // Raise the flag to allow another frame to be processed
    _processFrameReady = true;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scannedFrameStreamController.close();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

}

/// A frame scanned for QR codes
class _ScannedFrame {
  final ui.Image image;
  final QrCode? qrCode;
  _ScannedFrame({
    required this.image,
    this.qrCode,
  });
}

// countdown function to realize the count 3 seconds
class Countdown extends StatefulWidget {
  const Countdown({super.key});

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _timer;
  int _start = 3;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("$_start", style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),),
    );
  }
}

/// A custom painter to show the camera frames
class _CameraViewPainter extends CustomPainter {
  _CameraViewPainter({required this.frame});

  final _ScannedFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
        size.width / frame.image.width, size.width / frame.image.width);
    canvas.drawImage(frame.image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

