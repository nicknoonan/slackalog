import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slackalog/measurePage.dart';
import 'package:slackalog/slackSetupModel.dart';
import 'package:slackalog/slackSetupTextField.dart';
import 'package:slackalog/main.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import 'slackSetupRepository.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slackalog/slackSetupLocationSelection.dart';

class SlackSetupUpsertPage extends StatefulWidget {
  final SlackSetupModel? slackSetup;
  final String title;

  const SlackSetupUpsertPage({super.key, this.slackSetup, required this.title});

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
  LatLng? _selectedLocation;
  late final UuidValue _setupId;

  @override
  void initState() {
    super.initState();

    // Maintain a persistent id for this upsert page so repeated saves don't
    // create a new folder each time and duplicate images.
    _setupId = widget.slackSetup?.id ?? Uuid().v1obj();

    // Initialize selected location from existing model (optional)
    if (widget.slackSetup?.latitude != null && widget.slackSetup?.longitude != null) {
      _selectedLocation = LatLng(widget.slackSetup!.latitude!, widget.slackSetup!.longitude!);
    }

    // Load existing model image paths (they are stored relative to the
    // application documents directory). This resolves them to absolute paths
    // used by Image widgets, while keeping the model's stored paths relative.
    _loadExistingImages();
  }
  // Future<List<File>>? images;

  Future<void> handleSave() async {
    // Use the persistent setup id so repeated saves reference the same folder
    var updatedModel = SlackSetupModel(
      name: nameController.text,
      description: descriptionController.text,
      id: _setupId,
      length: lengthController.text,
      imagePaths: [], // populated after persisting files (relative)
      latitude: _selectedLocation?.latitude ?? widget.slackSetup?.latitude,
      longitude: _selectedLocation?.longitude ?? widget.slackSetup?.longitude,
    );

    // Persist images via repository (returns relative paths)
    final persistedRel = await slackSetupRepository.persistImages(tmpImages, _setupId.toString());

    updatedModel.imagePaths = persistedRel;

    // Resolve persisted relative paths to absolute paths for UI display
    try {
      final persistedAbs = await slackSetupRepository.resolveImagePaths(persistedRel);
      setState(() {
        tmpImages = persistedAbs.map((p) => XFile(p)).toList();
      });
    } catch (e) {
      debugPrint('Failed to resolve persisted image paths: $e');
    }

    // If an existing model was provided, update it in-place. Otherwise we leave
    // the new model to be returned to the caller (we don't mutate widget fields).
    if (widget.slackSetup != null) {
      widget.slackSetup!.update(updatedModel);
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

  Future<void> _loadExistingImages() async {
    if (widget.slackSetup?.imagePaths == null || widget.slackSetup!.imagePaths.isEmpty) {
      return;
    }

    try {
      final abs = await slackSetupRepository.resolveImagePaths(widget.slackSetup!.imagePaths);
      setState(() {
        tmpImages = abs.map((p) => XFile(p)).toList();
      });
    } catch (e) {
      debugPrint('Failed to resolve existing images: $e');
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
        child: Column(
          children: [
            Expanded(
              child: FormInputs(
                nameController: nameController,
                descriptionController: descriptionController,
                lengthController: lengthController,
                onAddImage: handleAddImage,
                onDeleteImage: (int index) {
                  setState(() {
                    if (index >= 0 && index < tmpImages.length) {
                      tmpImages.removeAt(index);
                    }
                  });
                },
                imageFiles: tmpImages.map((xfile) => File(xfile.path)).toList(),
                location: _selectedLocation,
                onEditLocation: () async {
                  final result = await Navigator.of(context).push<LatLng>(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (ctx) => SlackSetupLocationSelection(initialLocation: _selectedLocation),
                    ),
                  );
                  if (result != null) {
                    setState(() => _selectedLocation = result);
                  }
                },
                onClearLocation: () {
                  setState(() => _selectedLocation = null);
                },
              ),
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

typedef EditLocationCallback = Future<void> Function();
typedef ClearLocationCallback = void Function();

class FormInputs extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController lengthController;
  final ImageDeleteCallback onDeleteImage;
  final AsyncCallback onAddImage;
  final List<File> imageFiles;
  final LatLng? location;
  final EditLocationCallback onEditLocation;
  final ClearLocationCallback onClearLocation;

  const FormInputs({
    required this.nameController,
    required this.descriptionController,
    required this.lengthController,
    required this.onDeleteImage,
    required this.onAddImage,
    required this.imageFiles,
    required this.location,
    required this.onEditLocation,
    required this.onClearLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Use a scrollable column with clear spacing to make layout easier to reason about
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SlackSetupTextField(
            controller: nameController,
            hintText: "Give your slack setup a fun name!",
          ),
          const SizedBox(height: 12),
          LengthInput(lengthController: lengthController),
          const SizedBox(height: 12),
          SlackSetupTextField(
            controller: descriptionController,
            maxLines: 10,
            hintText:
                "Describe your slack setup. What makes it special? How to find it? What are some tips for setting it up? Whats your favorite memory there?",
          ),
          const SizedBox(height: 12),
          ImageInput(
            onAdd: onAddImage,
            onDelete: onDeleteImage,
            imageFiles: imageFiles,
          ),
          const SizedBox(height: 12),
          // Location picker (optional, last input)
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Location (optional)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (location != null) ...[
                    Text('Lat: ${location!.latitude.toStringAsFixed(6)}, Lon: ${location!.longitude.toStringAsFixed(6)}'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: onEditLocation, child: const Text('Edit')),
                        TextButton(onPressed: () => onClearLocation(), child: const Text('Remove')),
                      ],
                    ),
                  ] else ...[
                    FilledButton.tonal(onPressed: onEditLocation, child: const Text('Add location')),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const SaveButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
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
    );
  }
}

class LengthInput extends StatelessWidget {
  final TextEditingController lengthController;

  const LengthInput({required this.lengthController});

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
  final AsyncCallback onAdd;
  final List<File> imageFiles;

  const ImageInput({
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

  @override
  void didUpdateWidget(covariant ImageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newLen = widget.imageFiles.length;
    if (_current >= newLen) {
      setState(() {
        _current = newLen > 0 ? newLen - 1 : 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no images show a simple add button
    if (widget.imageFiles.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: FilledButton.icon(
            onPressed: widget.onAdd,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photos'),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: widget.imageFiles
              .map((file) => Image.file(file, fit: BoxFit.cover))
              .toList(),
          carouselController: _controller,
          options: CarouselOptions(
            enableInfiniteScroll: false,
            autoPlay: false,
            height: 500,
            enlargeCenterPage: true,
            aspectRatio: 19 / 9,
            initialPage: _current,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        _IndicatorDots(
          count: widget.imageFiles.length,
          current: _current,
          controller: _controller,
        ),
        const SizedBox(height: 8),
        _ImageActionButtons(
          onDelete: () => widget.onDelete(_current),
          onAdd: () async {
            await widget.onAdd();
            setState(() {
              _current = widget.imageFiles.length - 1;
              _controller.animateToPage(_current);
            });
          },
        ),
      ],
    );
  }
}

class _IndicatorDots extends StatelessWidget {
  final int count;
  final int current;
  final CarouselSliderController controller;

  const _IndicatorDots({
    required this.count,
    required this.current,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (i) {
        final isActive = i == current;
        return GestureDetector(
          onTap: () => controller.animateToPage(i),
          child: Container(
            width: isActive ? 16.0 : 12.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: color.withOpacity(isActive ? 0.9 : 0.2),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: color, width: 1),
            ),
          ),
        );
      }),
    );
  }
}

class _ImageActionButtons extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const _ImageActionButtons({
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.delete_forever_sharp),
          onPressed: onDelete,
          padding: EdgeInsets.zero,
        ),
        IconButton(
          icon: const Icon(Icons.add_a_photo),
          onPressed: onAdd,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
