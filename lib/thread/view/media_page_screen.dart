import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/data.dart';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: GestureDetector(
          onVerticalDragEnd: (details) => context.pop(),
          child: SizedBox(
            width: 100.w,
            height: 100.h,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                if (widget.gallery[index].type == 'image') {
                  return Hero(
                    tag: widget.gallery[index].url,
                    child: CustomNetworkImage(
                      imageUrl: '$s3Url${widget.gallery[index].url}',
                      boxFit: BoxFit.contain,
                    ),
                  );
                } else {
                  return NetworkVideoPlayer(
                    video: widget.gallery[index],
                  );
                }
              },
              itemCount: widget.gallery.length,
            ),
          ),
        ),
      ),
    );
  }
}
