import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slackalog/measurePage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupTextField.dart';
import 'package:slackalog/main.dart';
import 'package:uuid/uuid.dart';
import 'slackSetupRepository.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker picker = ImagePicker();
  List<XFile> tmpImages = [];
  // Future<List<File>>? images;

  Future<void> handleSave() async {
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
        } else {
          isLoading = false;
        }
      });
    }
  }

  Future<void> handleAddImage() async {
    List<XFile> images = await picker.pickMultiImage();
    setState(() {
      images.forEach(tmpImages.add);
      tmpImages = tmpImages.toSet().toList(); //dedup
    });
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
              onAddImage: handleAddImage,
              onDeleteImage: (int index) {},
              imageFiles: tmpImages.map((xfile) => File(xfile.path)).toList(),
            ),
            SaveButton(onPressed: handleSave, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}

typedef ImageDeleteCallback = void Function(int);
typedef ImageAddCallback = void Function(String);

class FormInputs extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController lengthController;
  final ImageDeleteCallback onDeleteImage;
  final VoidCallback onAddImage;
  final List<File> imageFiles;

  const FormInputs({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.lengthController,
    required this.onDeleteImage,
    required this.onAddImage,
    required this.imageFiles,
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
                ImageInput(
                  onAdd: onAddImage,
                  onDelete: onDeleteImage,
                  imageFiles: imageFiles,
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

class ImageInput extends StatefulWidget {
  final ImageDeleteCallback onDelete;
  final VoidCallback onAdd;
  final List<File> imageFiles;

  const ImageInput({
    super.key,
    required this.onDelete,
    required this.onAdd,
    required this.imageFiles,
  });

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  // final List<String> imgList = ["IMAGE", "IMAGE 2", "IMAGE 3"];
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          CarouselSlider(
            items: widget.imageFiles
                .map(
                  (file) =>
                      Image.file(file, height: 800, width: double.infinity),
                )
                .toList(),
            carouselController: _controller,
            options: CarouselOptions(
              autoPlay: false,
              height: 300,
              enlargeCenterPage: true,
              aspectRatio: 19 / 9,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageFiles.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _controller.animateToPage(entry.key),
                child: Container(
                  width: 16.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: BoxBorder.all(
                      color: Theme.of(context).primaryColor,
                      width: 1,
                    ),
                    color: (Theme.of(context).primaryColor).withOpacity(
                      _current == entry.key ? 0.9 : 0.1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // This is key
            children: <Widget>[
              Card(
                elevation: 0.1,
                margin: EdgeInsets.all(0),
                child: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(1, 1, 1, 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 0,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => widget.onDelete(_current),
                        icon: Icon(Icons.delete_forever_sharp),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: widget.onAdd,
                        icon: Icon(Icons.add_a_photo),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
