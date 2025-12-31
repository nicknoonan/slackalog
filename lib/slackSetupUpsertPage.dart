import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slackalog/measurePage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupTextField.dart';
import 'package:slackalog/main.dart';
import 'package:uuid/uuid.dart';
import 'slackSetupRepository.dart';

class SlackSetupUpsertPage extends StatefulWidget {
  SlackSetupModel? slackSetup;
  final String title;

  SlackSetupUpsertPage({super.key, this.slackSetup, required this.title});

  @override
  State<SlackSetupUpsertPage> createState() => _SlackSetupUpsertPageState();
}

class _SlackSetupUpsertPageState extends State<SlackSetupUpsertPage> {
  final slackSetupRepository = getIt<ISlackSetupRepository>();
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();

  Future<void> handlePressed() async {
    var updatedModel = SlackSetupModel( 
      name: nameController.text,
      description: descriptionController.text,
      id: widget.slackSetup?.id ?? Uuid().v1obj(),
      length: lengthController.text,
    );

    if (widget.slackSetup != null) {
      widget.slackSetup!.update(updatedModel);
    } else {
      widget.slackSetup = updatedModel;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    await slackSetupRepository.upsertSlackSetup(updatedModel);

    if (mounted) {
      setState(() {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop<SlackSetupModel>(updatedModel);
        }
        else { 
          isLoading = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.slackSetup?.name ?? '';
    descriptionController.text = widget.slackSetup?.description ?? '';
    lengthController.text = widget.slackSetup?.length.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Stack(
          children: [
            FormInputs(
              nameController: nameController,
              descriptionController: descriptionController,
              lengthController: lengthController,
            ),
            SaveButton(onPressed: handlePressed, isLoading: isLoading),
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
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Align(
            // Alignment(x, y) where y = -1.0 is top, 0.0 is center, 1.0 is bottom.
            // -0.5 positions the center of the Text widget at the top 50% of the button.
            alignment: Alignment(0.0, -0.4),
            child: isLoading
                ? Container(
                    width: 24, // Adjust size as needed
                    height: 24, // Adjust size as needed
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(strokeWidth: 3),
                  )
                : Text('SAVE'),
          ),
        ),
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
            iconSize: 30,
            onPressed: () async {
              var length = await Navigator.of(context).push<int>(
                MaterialPageRoute(
                  builder: (BuildContext context) => MeasurePage(),
                ),
              );
              lengthController.text = length.toString();
            },
            icon: Icon(Icons.camera_enhance),
          ),
        ),
      ],
    );
  }
}
