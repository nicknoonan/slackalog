import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/loadingIconButton.dart';

class SlackSetupDeleteAlertDialog extends StatefulWidget {
  final AsyncCallback onPressed;
  const SlackSetupDeleteAlertDialog({super.key, required this.onPressed});

  @override
  State<SlackSetupDeleteAlertDialog> createState() =>
      _SlackSetupDeleteAlertDialogState();
}

class _SlackSetupDeleteAlertDialogState
    extends State<SlackSetupDeleteAlertDialog> {
  bool isLoading = false;

  Future<void> handlePressed() async {
    setState(() {
      isLoading = true;
    });

    await widget.onPressed();

    setState(() {
      Navigator.of(context).pop(); // Dismiss dialog
      Navigator.of(context).pop(); // Dismiss dialog
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text(
        'Are you sure you want to permanently delete this slackline setup? This action cannot be undone.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: isLoading ? null : () =>
              Navigator.of(context).pop(), // Dismiss and return false
          child: const Text('CANCEL'),
        ),
        LoadingIconButton(
          onPressed: handlePressed,
          icon: Icon(Icons.delete),
          isLoading: isLoading,
        ),
      ],
    );
  }
}
