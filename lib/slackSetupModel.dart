import 'package:uuid/uuid.dart';

class SlackSetupModel {
  String name;
  String description;
  String length;
  UuidValue ID;

  SlackSetupModel({
    required this.name,
    required this.description,
    required this.ID,
    required this.length,
  });

  factory SlackSetupModel.fromJson(Map<String, dynamic> json) {
    return SlackSetupModel(
      name: json['name'],
      description: json['description'],
      ID: UuidValue.fromList((Uuid.parse(json['id']))),
      length: json['length'],
    );
  }
}
