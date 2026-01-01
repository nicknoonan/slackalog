import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:slackalog/main.dart';
import 'package:slackalog/slackSetupRepository.dart';

/// A simple, reusable image carousel that shows a list of local image file paths.
/// When [isEditable] is false the carousel is view-only (no add/delete buttons).
class ImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final bool isEditable;
  final int initialIndex;
  final String? heroTagPrefix; // if provided, images will be wrapped in Hero widgets with tags `${heroTagPrefix}-$index`
  final ValueChanged<int?>? onImageTap; // optional callback when an image is tapped, receives the index

  const ImageCarousel({
    super.key,
    required this.imagePaths,
    this.height = 300,
    this.isEditable = false,
    this.initialIndex = 0,
    this.heroTagPrefix,
    this.onImageTap,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  @override
  void initState() {
    super.initState();

    _current = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // If any path appears relative, resolve them first (async). This lets the
    // rest of the widget assume absolute file system paths.
    final hasRelative = widget.imagePaths.any((p) => !(p.startsWith('/') || p.contains(':/')));
    if (hasRelative) {
      return FutureBuilder<List<String>>(
        future: getIt<ISlackSetupRepository>().resolveImagePaths(widget.imagePaths),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: widget.height, child: const Center(child: CircularProgressIndicator()));
          }
          final resolved = snapshot.data!;
          return _buildCarousel(context, resolved);
        },
      );
    }

    return _buildCarousel(context, widget.imagePaths);
  }

  Widget _buildCarousel(BuildContext context, List<String> paths) {
    if (paths.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Container(
            width: double.infinity,
            height: widget.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No photos available', style: TextStyle(color: Colors.black54)),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: CarouselSlider(
            items: paths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              Widget image = Image.file(
                File(path),
                fit: BoxFit.contain,
                width: double.infinity,
                cacheWidth: (widget.height * 2).toInt(),
                errorBuilder: (BuildContext ctx, Object error, StackTrace? stack) {
                  debugPrint('Image load failed for $path: $error');
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                  );
                },
              );

              if (widget.heroTagPrefix != null) {
                image = Hero(tag: '${widget.heroTagPrefix}-$index', child: image);
              }

              if (widget.onImageTap != null) {
                return GestureDetector(
                  onTap: () => widget.onImageTap!(index),
                  child: image,
                );
              }

              return image;
            }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              enableInfiniteScroll: false,
              height: widget.height,
              initialPage: widget.initialIndex,
              enlargeCenterPage: true,
              autoPlay: false,
              onPageChanged: (index, reason) => setState(() => _current = index),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: paths.asMap().entries.map((entry) {
            final isActive = entry.key == _current;
            final color = Theme.of(context).primaryColor;
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: isActive ? 16.0 : 10.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(isActive ? 0.9 : 0.2),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: color, width: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Full screen carousel page that supports hero transitions when a
/// matching Hero tag (e.g. `${heroTagPrefix}-0`) exists on the source.
class ImageCarouselFullScreen extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final String? heroTagPrefix;

  const ImageCarouselFullScreen({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: ImageCarousel(
            imagePaths: imagePaths,
            height: MediaQuery.of(context).size.height * 0.8,
            initialIndex: initialIndex,
            heroTagPrefix: heroTagPrefix,
            isEditable: false,
          ),
        ),
      ),
    );
  }
}
