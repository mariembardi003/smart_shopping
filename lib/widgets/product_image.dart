import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A widget that displays product images with fallback handling.
/// Shows a cached network image if available, otherwise displays a placeholder.
class ProductImage extends StatelessWidget {
  /// The URL of the product image. Can be null or empty.
  final String? imageUrl;

  /// The width of the image. Defaults to 80.
  final double width;

  /// The height of the image. Defaults to 80.
  final double height;

  /// The border radius of the image. Defaults to 8.
  final double borderRadius;

  /// Whether to show a border around the image. Defaults to true.
  final bool showBorder;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 8,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(color: Colors.grey.shade300, width: 1)
            : null,
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: hasValidImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(),
                errorWidget: (context, url, error) => _buildPlaceholder(),
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 200),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  /// Builds the placeholder widget when no image is available or loading.
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.shopping_bag,
        size: width * 0.5, // Scale icon relative to container size
        color: Colors.grey.shade400,
      ),
    );
  }
}

/// A larger version of ProductImage optimized for product detail screens.
class ProductDetailImage extends StatelessWidget {
  /// The URL of the product image. Can be null or empty.
  final String? imageUrl;

  /// The size of the image container. Defaults to 200.
  final double size;

  const ProductDetailImage({
    super.key,
    this.imageUrl,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.grey.shade50,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: hasValidImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.contain, // Use contain to show full image
                placeholder: (context, url) => _buildDetailPlaceholder(),
                errorWidget: (context, url, error) => _buildDetailPlaceholder(),
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 200),
              )
            : _buildDetailPlaceholder(),
      ),
    );
  }

  /// Builds the placeholder widget for product detail view.
  Widget _buildDetailPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: size * 0.4,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: size * 0.08,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}