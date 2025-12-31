import 'package:flutter/material.dart';
import 'package:slackalog/loadingIconButton.dart';
import 'package:slackalog/slackSetupDeleteAlertDialog.dart';
import 'package:slackalog/slackSetupDetailsPageButtons.dart';
import 'package:slackalog/slackSetupImage.dart';
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
                      FullSizeImage(slackSetup: slackSetup),
                      Text(
                        slackSetup.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(slackSetup.description),
                      // Row(
                      //   children: [
                      //     IconButton.filled(
                      //       onPressed: () =>
                      //           _gotoUpsertPage(context, slackSetup),
                      //       icon: Icon(Icons.edit),
                      //     ),
                      //     LoadingIconButton(
                      //       onPressed: () => _confirmDelete(context),
                      //       icon: Icon(Icons.delete),
                      //     ),
                      //   ],
                      // ),
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
