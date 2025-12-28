import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  Widget _buildPlaceholder(BuildContext context, String url) {
    return placeholder ?? Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFff6f2d)),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String url, dynamic error) {
    return errorWidget ?? Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: _buildPlaceholder,
      errorWidget: _buildErrorWidget,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: width != null ? (width! * MediaQuery.of(context).devicePixelRatio).toInt() : null,
      memCacheHeight: height != null ? (height! * MediaQuery.of(context).devicePixelRatio).toInt() : null,
      maxWidthDiskCache: 1200,
      maxHeightDiskCache: 1200,
      cacheKey: imageUrl,
      useOldImageOnUrlChange: true,
    );

    if (borderRadius != null) {
      child = ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }
}