import 'dart:io';

import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupCarousel.dart';
import 'package:slackalog/main.dart';
import 'package:slackalog/slackSetupRepository.dart';

class HeroImage extends StatelessWidget {
  final Object tag;
  final Widget child;
  final double width;
  final double height;

  const HeroImage({
    super.key,
    required this.tag,
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: child,
        ),
      ),
    );
  }
}


class PreviewImage extends StatelessWidget {
  final SlackSetupModel slackSetup;

  const PreviewImage({super.key, required this.slackSetup});

  @override
  Widget build(BuildContext context) {
    if (slackSetup.imagePaths.isNotEmpty) {
      final storedPath = slackSetup.imagePaths.first;
      return GestureDetector(
        // onTap: () {
        //   Navigator.of(context).push(MaterialPageRoute(
        //     builder: (ctx) => ImageCarouselFullScreen(
        //       imagePaths: slackSetup.imagePaths,
        //       initialIndex: 0,
        //       heroTagPrefix: 'slack-${slackSetup.id}',
        //     ),
        //   ));
        // },
        child: HeroImage(
          tag: 'slack-${slackSetup.id}-0',
          width: 70,
          height: 80,
          child: FutureBuilder<String>(
            future: getIt<ISlackSetupRepository>().resolveImagePath(storedPath),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return Container(color: Colors.grey.shade200);
              }

              final path = snap.data ?? storedPath;
              final file = File(path);
              if (!file.existsSync()) {
                debugPrint('Preview image file not found at resolved path $path');
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.black26)),
                );
              }

              return Image.file(
                file,
                fit: BoxFit.cover,
                width: 70,
                height: 80,
                cacheWidth: 240,
                errorBuilder: (ctx, error, stack) {
                  debugPrint('Preview image failed to load $path: $error');
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.black26)),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    return HeroImage(
      tag: slackSetup.id,
      width: 70,
      height: 80,
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_outlined, color: Colors.purple)),
      ),
    );
  }
}

class FullSizeImage extends StatelessWidget {
  final SlackSetupModel slackSetup;

  const FullSizeImage({super.key, required this.slackSetup});

  @override
  Widget build(BuildContext context) {
    if (slackSetup.imagePaths.isNotEmpty) {
      final storedPath = slackSetup.imagePaths.first;
      return HeroImage(
        tag: slackSetup.id,
        width: double.infinity,
        height: 300,
        child: FutureBuilder<String>(
          future: getIt<ISlackSetupRepository>().resolveImagePath(storedPath),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Container(color: Colors.grey.shade200);
            }

            final path = snap.data ?? storedPath;
            final file = File(path);
            if (!file.existsSync()) {
              debugPrint('Full size image file not found at resolved path $path');
              return Container(
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
              );
            }

            return Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              errorBuilder: (ctx, error, stack) {
                debugPrint('Full size image load failed $path: $error');
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                );
              },
            );
          },
        ),
      );
    }

    return HeroImage(
      tag: slackSetup.id,
      width: double.infinity,
      height: 300,
      child: Container(
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image_outlined, size: 48, color: Colors.purple)),
      ),
    );
  }
}
