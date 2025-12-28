import 'package:slackalog/slackSetupModel.dart';
import 'package:http/http.dart' as http;
import 'package:slackalog/apiClient.dart';

abstract class ISlackSetupRepository {
  Future<SlackSetupModel> getSlackSetup();
}

class SlackSetupRepository implements ISlackSetupRepository {
  // final http.Client client;
  final IAPIClient apiClient;

  SlackSetupRepository({required this.apiClient});

  @override
  Future<SlackSetupModel> getSlackSetup() async {
    
    return SlackSetupModel(name: "Example", description: "This is an example Slack setup.");
  }
}