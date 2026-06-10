import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class VeneraNetworkImage extends StatelessWidget {
  const VeneraNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.borderRadius,
  });

  final String url;
  final BoxFit fit;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  bool get _isAsset => url.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    final child = _isAsset
        ? Image.asset(
            url,
            fit: fit,
            height: height,
            width: width,
            errorBuilder: _errorPlaceholder,
          )
        : Image.network(
            url,
            fit: fit,
            height: height,
            width: width,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: height,
                width: width,
                color: AppColors.card,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.gold.withOpacity(0.5)),
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: _errorPlaceholder,
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _errorPlaceholder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      height: height,
      width: width,
      color: AppColors.card,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined,
          color: AppColors.cream.withOpacity(0.25)),
    );
  }
}
