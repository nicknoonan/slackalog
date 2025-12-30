import 'package:flutter/material.dart';
import 'package:slackalog/loadingIconButton.dart';
import 'package:slackalog/slackSetupDeleteAlertDialog.dart';
import 'package:slackalog/slackSetupImage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupPage.dart';
import 'package:slackalog/slackSetupUpsertPage.dart';

class SlackSetupDetailsPage extends StatelessWidget {
  final SlackSetupModel slackSetup;
  final EditSlackSetupCallback onEdit;
  final DeleteSlackSetupCallback onDelete;

  const SlackSetupDetailsPage({
    super.key,
    required this.slackSetup,
    required this.onEdit,
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
        builder: (BuildContext context) => SlackSetupUpsertPage(
          slackSetup: slackSetup,
          onSave: () async => await onEdit(slackSetup),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Center(
          child: Column(
            children: [
              FullSizeImage(slackSetup: slackSetup),
              Text(slackSetup.name),
              Text(slackSetup.description),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: () => _gotoUpsertPage(context, slackSetup),
                    icon: Icon(Icons.edit),
                  ),
                  LoadingIconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
