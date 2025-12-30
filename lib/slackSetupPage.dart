import 'package:flutter/material.dart';
import 'package:slackalog/slackSetupListView.dart';
import 'package:slackalog/main.dart';
import 'package:slackalog/slackSetupCard.dart';
import 'package:slackalog/slackSetupDetailsPage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupRepository.dart';
import 'package:slackalog/slackSetupUpsertPage.dart';

typedef EditSlackSetupCallback = Future<void> Function(SlackSetupModel);
typedef DeleteSlackSetupCallback = Future<void> Function(SlackSetupModel);
typedef GoToSlackSetupCallback = void Function(BuildContext, SlackSetupModel);

class SlackSetupPage extends StatefulWidget {
  const SlackSetupPage({super.key});

  @override
  State<SlackSetupPage> createState() => _SlackSetupPageState();
}

class _SlackSetupPageState extends State<SlackSetupPage> {
  final slackSetupRepository = getIt<ISlackSetupRepository>();
  late Future<List<SlackSetupModel>> _slackSetupsFuture;

  @override
  void initState() {
    super.initState();
    _slackSetupsFuture = slackSetupRepository.getSlackSetups();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Center(
          child: Column(
            children: [
              Expanded(
                child: SlackSetupListView(
                  slackSetups: _slackSetupsFuture,
                  onGoToDetails: _gotoDetailsPage,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsetsGeometry.all(15),
          child: FloatingActionButton(
            onPressed: () => _gotoUpsertPage(context),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _editSlackSetup(SlackSetupModel slackSetup) async {
    await slackSetupRepository.upsertSlackSetup(slackSetup);
    setState(() {
      _slackSetupsFuture = slackSetupRepository.getSlackSetups();
    });
  }

  Future<void> _deleteSlackSetup(SlackSetupModel slackSetup) async {
    await slackSetupRepository.deleteSlackSetup(slackSetup);
    setState(() {
      _slackSetupsFuture = slackSetupRepository.getSlackSetups();
    });
  }

  void _gotoDetailsPage(BuildContext context, SlackSetupModel slackSetup) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SlackSetupDetailsPage(
          slackSetup: slackSetup,
          onDelete: _deleteSlackSetup,
          onEdit: _editSlackSetup,
        ),
      ),
    );
  }

  void _gotoUpsertPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SlackSetupUpsertPage(onSave: () async {}),
      ),
    );
  }
}
