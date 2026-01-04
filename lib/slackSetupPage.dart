import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slackalog/slackSetupListView.dart';
import 'package:slackalog/main.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupRepository.dart';

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
  late Future<SlackSetupModelList> _slackSetupsFuture;

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
            onPressed: () => _gotoUpsertPage(),
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }


  void _gotoDetailsPage(BuildContext context, SlackSetupModel slackSetup) {
    // Use go_router to push a details page by id
    context.push('/details/${slackSetup.id.uuid}');
  }

  Future<void> _gotoUpsertPage() async {
    // Push the upsert route and await a potential SlackSetupModel result
    final result = await context.push('/upsert');

    if (mounted && result != null && result is SlackSetupModel) {
      context.push('/details/${result.id.uuid}');
    }
  }
}
