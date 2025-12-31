import 'dart:convert';

import 'package:slackalog/slackSetupModel.dart';
import 'package:http/http.dart' as http;
import 'package:slackalog/apiClient.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

abstract class ISlackSetupRepository {
  Future<SlackSetupModelList> getSlackSetups();
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup);
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup);
}

class FileStoreSlackSetupRepository implements ISlackSetupRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    var file = File('$path/slackSetups.json');
    var exists = await file.exists();
    if (!exists) {
      var exampleJson = await rootBundle.loadString(
        'assets/exampleSlackSetups.json',
      );
      SlackSetupModelList setupModelList = SlackSetupModelList.fromJson(jsonDecode(exampleJson));
      file = await file.create();
      file = await file.writeAsString(jsonEncode(setupModelList));
    } 
    // uncomment if you want to reset on load
    // else {
    //   var exampleJson = await rootBundle.loadString(
    //     'assets/exampleSlackSetups.json',
    //   );
    //   SlackSetupModelList setupModelList = SlackSetupModelList.fromJson(jsonDecode(exampleJson));
    //   file = await file.writeAsString(jsonEncode(setupModelList));
    // }
    return file;
  }

  SlackSetupModelList? slackSetupsModel;

  FileStoreSlackSetupRepository();

  Future<SlackSetupModelList> _getSlackSetups() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      var json = jsonDecode(contents);

      var slackSetups = SlackSetupModelList.fromJson(json);

      return slackSetups;
    } catch (e) {
      // handle errors better here
      return SlackSetupModelList(list: []);
    }
  }

  @override
  Future<SlackSetupModelList> getSlackSetups() async {
    // TODO: use a better caching solution. maybe riverpod? or just rollout a proper in memory cache api.
    if (slackSetupsModel == null) {
      var slackSetups = await _getSlackSetups();

      slackSetupsModel = slackSetups;
    }

    return slackSetupsModel!;
  }

  @override
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup) async {
    var slackSetupsList = await getSlackSetups();
    slackSetupsList.list.removeWhere((element) => element.id == slackSetup.id);

    await _writeSlackSetups(slackSetupsList);
    slackSetupsModel?.delete(slackSetup);
  }

  @override
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup) async {
    var slackSetupsList = await getSlackSetups();
    var index = slackSetupsList.list.indexWhere(
      (element) => element.id == slackSetup.id,
    );
    if (index >= 0) {
      slackSetupsList.list[index] = slackSetup;
    } else {
      slackSetupsList.list.add(slackSetup);
    }
    await _writeSlackSetups(slackSetupsList);
    slackSetupsModel?.upsert(slackSetup);
  }

  Future<void> _writeSlackSetups(SlackSetupModelList slackSetupList) async {
    var contents = jsonEncode(slackSetupList);

    var file = await _localFile;

    // Write the file
    file = await file.writeAsString(contents);
  }
}

class ExampleSlackSetupRepository implements ISlackSetupRepository {
  // final http.Client client;
  final IAPIClient apiClient;

  SlackSetupModelList? slackSetupsModel;

  ExampleSlackSetupRepository({required this.apiClient});

  Future<List<SlackSetupModel>> _getSlackSetups() async {
    var getSlackSetupResponse = await apiClient.get(
      "/assets/exampleSlackSetups.json",
    );
    getSlackSetupResponse = getSlackSetupResponse as List<dynamic>;

    var slackSetups = getSlackSetupResponse
        .map((responseItem) => SlackSetupModel.fromJson(responseItem))
        .toList();

    return slackSetups;
  }

  @override
  Future<SlackSetupModelList> getSlackSetups() async {
    // TODO: use a better caching solution. maybe riverpod? or just rollout a proper in memory cache api.
    if (slackSetupsModel == null) {
      var slackSetups = await _getSlackSetups();
      // await Future.delayed(Duration(seconds: 1));

      slackSetupsModel = SlackSetupModelList(list: slackSetups);
    }

    return slackSetupsModel!;
  }

  @override
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup) async {
    // slackSetupsModel?.list.removeWhere((element) => element.ID == slackSetup.ID);
    slackSetupsModel?.delete(slackSetup);
    // await Future.delayed(Duration(seconds: 1));
  }

  @override
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup) async {
    slackSetupsModel?.upsert(slackSetup);
  }
}
