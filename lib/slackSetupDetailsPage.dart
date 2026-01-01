import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupDeleteAlertDialog.dart';
import 'package:slackalog/slackSetupDetailsPageButtons.dart';
import 'package:slackalog/slackSetupCarousel.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupPage.dart';
import 'package:slackalog/slackSetupUpsertPage.dart';

class SlackSetupDetailsPage extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final DeleteSlackSetupCallback onDelete;

  const SlackSetupDetailsPage({
    super.key,
    required this.slackSetup,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SlackSetupDeleteAlertDialog(
          onPressed: () async => await onDelete(slackSetup),
        );
      },
    );
  }

  void _gotoUpsertPage(BuildContext context, SlackSetupModel slackSetup) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SlackSetupUpsertPage(slackSetup: slackSetup, title: 'UPDATE'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: slackSetup,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Details')),
          body: Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Center(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // View-only carousel of setup images (tap any photo to open fullscreen)
                      ImageCarousel(
                        imagePaths: slackSetup.imagePaths,
                        height: 300,
                        heroTagPrefix: 'slack-${slackSetup.id}',
                        onImageTap: (index) {
                          if (index == null) return;
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ImageCarouselFullScreen(
                              imagePaths: slackSetup.imagePaths,
                              initialIndex: index,
                              heroTagPrefix: 'slack-${slackSetup.id}',
                            ),
                          ));
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slackSetup.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text('${slackSetup.length}m'),
                      const SizedBox(height: 8),
                      Text(slackSetup.description),
                    ],
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: SlackSetupDetailsPageButtons(
                      onDelete: () => _confirmDelete(context),
                      onEdit: () => _gotoUpsertPage(context, slackSetup),
                    ),
                  ),
                ],
              ), //
            ),
          ),
        );
      },
    );
  }
}
