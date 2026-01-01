import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SlackSetupModel with ChangeNotifier {
  String name;
  String description;
  String length;
  UuidValue id;
  List<String> imagePaths;

  SlackSetupModel({
    required this.name,
    required this.description,
    required this.id,
    required this.length,
    this.imagePaths = const [],
  });

  void update(SlackSetupModel model) {
    name = model.name;
    description = model.description;
    length = model.length;
    id = model.id;
    imagePaths = List<String>.from(model.imagePaths);

    notifyListeners();
  }

  factory SlackSetupModel.fromJson(Map<String, dynamic> json) {
    return SlackSetupModel(
      name: json['name'],
      description: json['description'],
      id: UuidValue.fromList((Uuid.parse(json['id']))),
      length: json['length'],
      imagePaths: json['imagePaths'] != null
          ? List<String>.from(json['imagePaths'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'id': id.toString(),
    'length': length,
    'imagePaths': imagePaths,
  };
}

abstract class ISlackSetupModelList {
  void add(SlackSetupModel model);
}

class SlackSetupModelList extends ISlackSetupModelList with ChangeNotifier {
  List<SlackSetupModel> list;

  SlackSetupModelList({required this.list});

  factory SlackSetupModelList.fromJson(Map<String, dynamic> json) {
    var slackSetups = json["list"] as List<dynamic>;
    var list = slackSetups
        .map((responseItem) => SlackSetupModel.fromJson(responseItem))
        .toList();

    return SlackSetupModelList(list: list);
  }

  Map<String, dynamic> toJson() => {'list': list};

  @override
  void add(SlackSetupModel model) {
    list.add(model);
    notifyListeners();
  }

  void delete(SlackSetupModel model) {
    list.removeWhere((element) => element.id == model.id);
    notifyListeners();
  }

  void upsert(SlackSetupModel model) {
    var index = list.indexWhere((element) => element.id == model.id);
    if (index >= 0) {
      list[index] = model;
    } else {
      list.add(model);
    }
    notifyListeners();
  }
}
