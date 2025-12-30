import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupImage.dart';
import 'package:slackalog/slackSetupModel.dart';

class SlackSetupCard extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final VoidCallback? onTap;

  const SlackSetupCard({super.key, required this.slackSetup, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              spacing: 5.0,
              children: [
                PreviewImage(slackSetup: slackSetup),
                Expanded(
                  child: Column(
                    children: [
                      Text(slackSetup.name),
                      Text(slackSetup.description),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
