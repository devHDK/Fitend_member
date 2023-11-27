import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/thread/component/network_video_player.dart';
import 'package:fitend_member/thread/model/common/gallery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MediaPageScreen extends StatefulWidget {
  const MediaPageScreen({
    super.key,
    required this.pageIndex,
    required this.gallery,
  });

  final int pageIndex;
  final List<GalleryModel> gallery;

  @override
  State<MediaPageScreen> createState() => _MediaPageScreenState();
}

class _MediaPageScreenState extends State<MediaPageScreen> {
  PageController? _pageController;
  final TransformationController _transController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.pageIndex);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _pageController!.dispose();
    _transController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(Icons.close_sharp)),
          color: Colors.white,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          width: 100.w,
          height: 100.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (value) {
              _transController.value = Matrix4.identity();
            },
            itemBuilder: (context, index) {
              if (widget.gallery[index].type == 'image') {
                return Hero(
                  tag: widget.gallery[index].url,
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (_transController.value != Matrix4.identity()) {
                        _transController.value = Matrix4.identity();
                      }
                    },
                    onVerticalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dy > 1) {
                        context.pop();
                      }
                    },
                    child: InteractiveViewer(
                      transformationController: _transController,
                      minScale: 0.5,
                      maxScale: 10.0,
                      child: CustomNetworkImage(
                        imageUrl:
                            '${URLConstants.s3Url}${widget.gallery[index].url}',
                        boxFit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              } else {
                return GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy > 1) {
                      context.pop();
                    }
                  },
                  onDoubleTap: () {
                    if (_transController.value != Matrix4.identity()) {
                      _transController.value = Matrix4.identity();
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: _transController,
                    minScale: 0.5,
                    maxScale: 10.0,
                    child: NetworkVideoPlayer(
                      video: widget.gallery[index],
                    ),
                  ),
                );
              }
            },
            itemCount: widget.gallery.length,
          ),
        ),
      ),
    );
  }
}
