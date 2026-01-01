import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupCard.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupPage.dart';

class SlackSetupListView extends StatefulWidget {
  final Future<SlackSetupModelList> slackSetups;
  final GoToSlackSetupCallback onGoToDetails;

  const SlackSetupListView({
    super.key,
    required this.slackSetups,
    required this.onGoToDetails,
  });

  @override
  State<SlackSetupListView> createState() => _SlackSetupListViewState();
}

class _SlackSetupListViewState extends State<SlackSetupListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, slackSetupSnap) {
        List<Widget> children;
        if (slackSetupSnap.hasData) {
          children = <Widget>[
            ListenableBuilder(
              listenable: slackSetupSnap.data!,
              builder: (BuildContext context, Widget? child) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: slackSetupSnap.data!.list.length,
                    itemBuilder: (context, index) {
                      SlackSetupModel slackSetup =
                          slackSetupSnap.data!.list[index];
                      return SlackSetupCard(
                        slackSetup: slackSetup,
                        onTap: () {
                          widget.onGoToDetails(context, slackSetup);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ];
        } else if (slackSetupSnap.hasError) {
          children = <Widget>[
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${slackSetupSnap.error}'),
            ),
          ];
        } else {
          children = const <Widget>[
            SizedBox(width: 60, height: 60, child: CircularProgressIndicator()),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Loading...'),
            ),
          ];
        }
        return Column(children: children);
      },
      future: widget.slackSetups,
    );
  }
}
