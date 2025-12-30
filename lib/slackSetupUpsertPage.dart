import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slackalog/measurePage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupTextField.dart';

class SlackSetupUpsertPage extends StatefulWidget {
  final SlackSetupModel? slackSetup;
  final AsyncCallback onSave;

  const SlackSetupUpsertPage({
    super.key,
    this.slackSetup,
    required this.onSave,
  });

  @override
  State<SlackSetupUpsertPage> createState() => _SlackSetupUpsertPageState();
}

class _SlackSetupUpsertPageState extends State<SlackSetupUpsertPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: widget.slackSetup?.name ?? '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: widget.slackSetup?.description ?? '',
    );
    final TextEditingController lengthController = TextEditingController(
      text: widget.slackSetup?.length.toString() ?? '',
    );
    String title = widget.slackSetup == null ? 'Create' : 'Update';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Stack(
          children: [
            FormInputs(
              nameController: nameController,
              descriptionController: descriptionController,
              lengthController: lengthController,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SaveButton(onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class FormInputs extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController lengthController;

  const FormInputs({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.lengthController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
            child: Column(
              spacing: 10,
              children: [
                SlackSetupTextField(
                  controller: nameController,
                  hintText: "Give your slack setup a fun name!",
                ),
                LengthInput(lengthController: lengthController),
                SlackSetupTextField(
                  controller: descriptionController,
                  maxLines: 5,
                  hintText:
                      "Describe your slack setup. What makes it special? How to find it? What are some tips for setting it up? Whats your favorite memory there?",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: Text('Save'),
      ),
    );
  }
}

class LengthInput extends StatelessWidget {
  final TextEditingController lengthController;

  const LengthInput({super.key, required this.lengthController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SlackSetupTextField(
          controller: lengthController,
          textInputType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hintText: "How long is this setup? (in meters)",
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            iconSize: 20,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => MeasurePage(),
                ),
              );
            },
            icon: Icon(Icons.camera_enhance),
          ),
        ),
      ],
    );
  }
}
