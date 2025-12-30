import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupModel.dart';

class HeroImage extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final double width;
  final double height;

  const HeroImage({
    super.key,
    required this.slackSetup,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: slackSetup.ID,
      child: SizedBox(
        width: width,
        height: height,
        child: Placeholder(
          color: Colors.purple, // Customize the color
          strokeWidth: 3.0, // Customize the line thickness
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
    return HeroImage(slackSetup: slackSetup, width: 40, height: 40);
  }
}

class FullSizeImage extends StatelessWidget {
  final SlackSetupModel slackSetup;

  const FullSizeImage({super.key, required this.slackSetup});

  @override
  Widget build(BuildContext context) {
    return HeroImage(slackSetup: slackSetup, width: 300, height: 300);
  }
}