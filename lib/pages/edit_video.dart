import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart' show OpacityTransition;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:video_editor/video_editor.dart';

import '../models/export_result.dart';
import '../themes/colors.dart';
import 'crop.dart';
import 'first_page.dart';
import 'video_acceleration.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, required this.file});

  final File file;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  late final VideoEditorController _controller = VideoEditorController.file(
    widget.file,
    minDuration: const Duration(seconds: 1),
    maxDuration: const Duration(seconds: 10),
  );

  @override
  void initState() {
    print(widget.file);
    super.initState();
    _controller
        .initialize(aspectRatio: 9 / 16)
        .then((_) => setState(() {}))
        .catchError((error) {
      // handle minumum duration bigger than video duration error
      Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );

  void _exportVideo() async {
    var path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);

    _exportingProgress.value = 0;
    _isExporting.value = true;
    final myImagePath = '$path/BIsnap';

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    } else if (status.isGranted) {
      await _controller.exportVideo(
        outDir: myImagePath,
        onProgress: (stats, value) => _exportingProgress.value = value,
        onError: (e, s) => _showErrorSnackBar("Error on export video :("),
        onCompleted: (file) {
          _isExporting.value = false;
          if (!mounted) return;
        },
      );
    }
  }

  void _exportCover() async {
    var path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
    final myImagePath = '$path/BIsnap';
    await _controller.extractCover(
      outDir: myImagePath,
      onError: (e, s) => _showErrorSnackBar("Error on cover exportation :("),
      onCompleted: (cover) {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => CoverResultPopup(cover: cover),
        );
      },
    );
  }

  gettmp_ved() async {
    await _controller.exportVideo(
      onProgress: (stats, value) => _exportingProgress.value = value,
      onError: (e, s) => _showErrorSnackBar("Error on export video :("),
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller.initialized
            ? SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _topNavBar(),
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CropGridViewer.preview(
                                              controller: _controller),
                                          AnimatedBuilder(
                                            animation: _controller.video,
                                            builder: (_, __) =>
                                                OpacityTransition(
                                              visible: !_controller.isPlaying,
                                              child: GestureDetector(
                                                onTap: _controller.video.play,
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      CoverViewer(controller: _controller)
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 0),
                                  child: Column(
                                    children: [
                                      TabBar(
                                        tabs: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: Icon(
                                                        Icons.content_cut)),
                                                Text('Trim')
                                              ]),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Padding(
                                                  padding: EdgeInsets.all(5),
                                                  child:
                                                      Icon(Icons.video_label)),
                                              Text('Cover')
                                            ],
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: _trimSlider(),
                                            ),
                                            _coverSelection(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: _isExporting,
                                  builder: (_, bool export, __) =>
                                      OpacityTransition(
                                    visible: export,
                                    child: AlertDialog(
                                      title: ValueListenableBuilder(
                                        valueListenable: _exportingProgress,
                                        builder: (_, double value, __) => Text(
                                          "Exporting video ${(value * 100).ceil()}%",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  List<String> ppl_names = [
    "Reda",
    "Omar",
    "manel",
    "heba",
    "meriem",
    "abdellah"
  ];
  List<String> ppl_images = [
    "assets/ppl/1.jpeg", //
    "assets/ppl/2.jpeg",
    "assets/ppl/3.jpeg",
    "assets/ppl/4.jpeg",
    "assets/ppl/5.jpeg",
    "assets/ppl/6.jpeg"
  ];

  shareimage() async {
    print(_controller.file.path);
    Share.shareFiles(['${_controller.file.path}/'],
        text: "${_controller.file}", subject: "${_controller.file}");
  }

  int number = 0;
  send_snap(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            //share
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: GestureDetector(
                onTap: () {
                  //_exportVideo();
                  shareimage();
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // radius of 10
                      color: Color.fromARGB(
                          255, 244, 244, 244), // green as background color
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            color: Colors.white,
                            icon: Icon(
                              Icons.share,
                              color: Colors.black,
                            ),
                            onPressed: () {},
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Share outside the App",
                          ),
                        ],
                      ),
                    )),
              ),
            ),
            //send as message
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: ppl_names.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(10), // radius of 10
                          color: Color.fromARGB(
                              255, 244, 244, 244), // green as background color
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(ppl_images[index]),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                ppl_names[index],
                              ),
                              Expanded(
                                child: SizedBox.shrink(),
                              ),
                              Radio(
                                  value: index,
                                  groupValue: number,
                                  onChanged: (int? value) {
                                    setState(() {
                                      number = value!;
                                      print(number); //selected value
                                    });
                                  })
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Container(
          color: pink2,
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CAM()),
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Rotate unclockwise',
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      _controller.rotate90Degrees(RotateDirection.left),
                  icon: const Icon(Icons.rotate_left),
                  tooltip: 'Rotate unclockwise',
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () =>
                      _controller.rotate90Degrees(RotateDirection.right),
                  icon: const Icon(Icons.rotate_right),
                  tooltip: 'Rotate clockwise',
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => CropScreen(controller: _controller),
                    ),
                  ),
                  icon: const Icon(Icons.crop),
                  tooltip: 'Open crop screen',
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () async {
                    await _controller.exportVideo(
                      onProgress: (stats, value) =>
                          _exportingProgress.value = value,
                      onError: (e, s) =>
                          _showErrorSnackBar("Error on export video :("),
                      onCompleted: (file) {
                        print("file111==: ${file}");
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => VedAccelerator(
                              ved: file,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.speed),
                  tooltip: 'Open crop screen',
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () async {},
                  icon: const Icon(Icons.edit),
                  tooltip: 'Open crop screen',
                ),
              ),
              Expanded(
                child: PopupMenuButton(
                  tooltip: 'Open export menu',
                  icon: const Icon(Icons.save),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: _exportCover,
                      child: const Text('Export cover'),
                    ),
                    PopupMenuItem(
                      onTap: _exportVideo,
                      child: const Text('Export video'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    send_snap(context);
                  },
                  icon: const Icon(Icons.send),
                  tooltip: 'Leave editor',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          _controller,
          _controller.video,
        ]),
        builder: (_, __) {
          final duration = _controller.videoDuration.inSeconds;
          final pos = _controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(_controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(_controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: _controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: CoverSelection(
            controller: _controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color: const CoverSelectionStyle().selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
