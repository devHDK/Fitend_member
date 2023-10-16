import 'package:any_link_preview/any_link_preview.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkPreview extends StatefulWidget {
  const LinkPreview({
    super.key,
    required this.url,
    this.width = 140,
  });

  final String url;
  final int? width;

  @override
  State<LinkPreview> createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  @override
  void didUpdateWidget(covariant LinkPreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {}
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.width!.toDouble() * 0.8,
      width: 140,
      child: AnyLinkPreview(
        link: widget.url,
        titleStyle: h5Headline,
        bodyStyle: s3SubTitle.copyWith(
          color: GRAY_COLOR,
        ),
        errorWidget: GestureDetector(
          onTap: () => launchUrlString(widget.url),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Center(
              child: Text(
                widget.url,
                style: s3SubTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
