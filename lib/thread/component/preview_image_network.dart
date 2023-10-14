import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitend_member/thread/component/extended_image.dart';
import 'package:flutter/material.dart';

class PreviewImageNetwork extends StatefulWidget {
  const PreviewImageNetwork({
    super.key,
    this.width = 140,
    required this.url,
  });

  final int? width;
  final String url;

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
          height: widget.width!.toDouble() * 0.8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomExtendImage(
              url: widget.url,
              fit: BoxFit.cover,
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
