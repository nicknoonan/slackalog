class SlackSetupModel {
  String name;
  String description;

  SlackSetupModel({
    required this.name,
    required this.description,
  });

  factory SlackSetupModel.fromJson(Map<String, dynamic> json) {
    return SlackSetupModel(
      name: json['name'],
      description: json['description'],
    );
  }
}
