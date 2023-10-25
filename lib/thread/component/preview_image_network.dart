import 'package:fitend_member/common/component/custom_network_image.dart';
import 'package:fitend_member/common/const/data.dart';
import 'package:flutter/material.dart';

class PreviewImageNetwork extends StatefulWidget {
  const PreviewImageNetwork({
    super.key,
    this.width = 140,
    this.height = 112,
    required this.url,
    this.boxFit = BoxFit.fitWidth,
  });

  final int? width;
  final int? height;
  final String url;
  final BoxFit? boxFit;

  @override
  State<PreviewImageNetwork> createState() => _PreviewImageNetworkState();
}

class _PreviewImageNetworkState extends State<PreviewImageNetwork> {
  @override
  void didUpdateWidget(covariant PreviewImageNetwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: widget.width!.toDouble(),
          height: widget.height!.toDouble(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomNetworkImage(
              key: ValueKey('$s3Url${widget.url}'),
              imageUrl: widget.url,
              boxFit: widget.boxFit!,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
