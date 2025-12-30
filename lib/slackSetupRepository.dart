import 'package:slackalog/slackSetupModel.dart';
import 'package:http/http.dart' as http;
import 'package:slackalog/apiClient.dart';

abstract class ISlackSetupRepository {
  Future<List<SlackSetupModel>> getSlackSetups();
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup);
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup);
}

class FileStoreSlackSetupRepository implements ISlackSetupRepository {

  FileStoreSlackSetupRepository();

  @override
  Future<List<SlackSetupModel>> getSlackSetups() async {
    // Implement file store retrieval logic here
    return [];
  }

  @override
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup) async {
    // Implement file store deletion logic here
  }

  @override
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup) async {
    // Implement file store upsert logic here
  }
}

class ExampleSlackSetupRepository implements ISlackSetupRepository {
  // final http.Client client;
  final IAPIClient apiClient;

  List<SlackSetupModel>? slackSetups;

  ExampleSlackSetupRepository({required this.apiClient});

  Future<List<SlackSetupModel>> _getSlackSetups() async {
    var getSlackSetupResponse = await apiClient.get(
      "/exampleSlackSetups1.json",
    );
    getSlackSetupResponse = getSlackSetupResponse as List<dynamic>;

    var slackSetups = getSlackSetupResponse
        .map((responseItem) => SlackSetupModel.fromJson(responseItem))
        .toList();

    return slackSetups;
  }

  @override
  Future<List<SlackSetupModel>> getSlackSetups() async {
    slackSetups ??= await _getSlackSetups();
    // await Future.delayed(Duration(seconds: 1));
    return slackSetups!;
  }

  @override
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup) async {
    slackSetups?.removeWhere((element) => element.ID == slackSetup.ID);
    // await Future.delayed(Duration(seconds: 1)); 
  }

  @override
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup) async {
    var index = slackSetups?.indexWhere(
      (element) => element.ID == slackSetup.ID,
    );
    if (index != null && index >= 0) {
      slackSetups?[index] = slackSetup;
    } else {
      slackSetups?.add(slackSetup);
    }
    await Future.delayed(Duration(seconds: 1));
  }
}
