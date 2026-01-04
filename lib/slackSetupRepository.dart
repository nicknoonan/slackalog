import 'dart:convert';

import 'package:slackalog/slackSetupModel.dart';

import 'package:slackalog/apiClient.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

abstract class ISlackSetupRepository {
  Future<SlackSetupModelList> getSlackSetups();
  Future<void> deleteSlackSetup(SlackSetupModel slackSetup);
  Future<void> upsertSlackSetup(SlackSetupModel slackSetup);

  // Image/file helpers
  /// Persist a list of picked [XFile] images into a per-setup images folder.
  /// Returns the list of stored paths relative to the application documents directory.
  Future<List<String>> persistImages(List<XFile> images, String setupId);

  /// Resolve a stored image path (relative or absolute) to an absolute path.
  Future<String> resolveImagePath(String storedPath);

  /// Resolve a list of stored image paths to absolute paths.
  Future<List<String>> resolveImagePaths(List<String> storedPaths);

  /// Delete all images belonging to a setup (useful when a setup is deleted).
  Future<void> deleteSetupImages(String setupId);
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
    else {
      var exampleJson = await rootBundle.loadString(
        'assets/exampleSlackSetups.json',
      );
      SlackSetupModelList setupModelList = SlackSetupModelList.fromJson(jsonDecode(exampleJson));
      file = await file.writeAsString(jsonEncode(setupModelList));
    }
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

  @override
  Future<List<String>> persistImages(List<XFile> images, String setupId) async {
    final docs = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${docs.path}/slackalog_images/$setupId');
    await imagesDir.create(recursive: true);

    List<String> savedAbsPaths = [];

    for (final xfile in images) {
      final src = xfile.path;
      if (src.isEmpty) continue;

      final fileName = p.basename(src);
      String destPath = p.join(imagesDir.path, fileName);
      final destFile = File(destPath);

      // If already in the same location (already persisted here), keep it
      if (File(src).absolute.path == destFile.absolute.path) {
        savedAbsPaths.add(destPath);
        continue;
      }

      // If the file already exists in the target folder and the source isn't
      // the same file, prefer to reference the existing file (avoid creating
      // duplicates).
      if (await destFile.exists()) {
        savedAbsPaths.add(destFile.path);
        continue;
      }

      // Otherwise copy the source into the images folder using a unique name
      var uniqueDest = destPath;
      if (await File(uniqueDest).exists()) {
        final parts = fileName.split('.');
        final name = parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : fileName;
        final ext = parts.length > 1 ? '.${parts.last}' : '';
        int i = 1;
        while (await File(uniqueDest).exists()) {
          uniqueDest = p.join(imagesDir.path, '${name}_$i$ext');
          i++;
        }
      }

      try {
        final newFile = await File(src).copy(uniqueDest);
        savedAbsPaths.add(newFile.path);
      } catch (e) {
        debugPrint('Failed to persist image $src: $e');
      }
    }

    // Cleanup: remove any files in the folder that are no longer referenced
    try {
      final existing = imagesDir.listSync().whereType<File>().map((f) => f.path).toList();
      for (final filePath in existing) {
        if (!savedAbsPaths.contains(filePath)) {
          try {
            await File(filePath).delete();
          } catch (e) {
            debugPrint('Failed to delete orphaned image $filePath: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed during imagesDir cleanup: $e');
    }

    // Convert absolute paths to relative paths
    final rel = savedAbsPaths.map((p0) {
      if (p0.startsWith(docs.path)) {
        return p0.substring(docs.path.length + 1);
      }
      return p0;
    }).toList();

    return rel;
  }

  @override
  Future<String> resolveImagePath(String storedPath) async {
    if (storedPath.startsWith('/') || storedPath.contains(':')) {
      return storedPath;
    }
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, storedPath);
  }

  @override
  Future<List<String>> resolveImagePaths(List<String> storedPaths) async {
    final docs = await getApplicationDocumentsDirectory();
    return storedPaths.map((p0) {
      if (p0.startsWith('/') || p0.contains(':')) return p0;
      return p.join(docs.path, p0);
    }).toList();
  }

  @override
  Future<void> deleteSetupImages(String setupId) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'slackalog_images', setupId));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to delete setup images for $setupId: $e');
    }
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

  // Minimal implementations for filesystem-related APIs; Example repo doesn't
  // manage local images, so these implementations are pass-through or no-ops.
  @override
  Future<List<String>> persistImages(List<XFile> images, String setupId) async {
    // Return paths unchanged (caller should handle absolute/relative semantics)
    return images.map((x) => x.path).toList();
  }

  @override
  Future<String> resolveImagePath(String storedPath) async {
    if (storedPath.startsWith('/') || storedPath.contains(':')) return storedPath;
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, storedPath);
  }

  @override
  Future<List<String>> resolveImagePaths(List<String> storedPaths) async {
    final docs = await getApplicationDocumentsDirectory();
    return storedPaths.map((p0) {
      if (p0.startsWith('/') || p0.contains(':')) return p0;
      return p.join(docs.path, p0);
    }).toList();
  }

  @override
  Future<void> deleteSetupImages(String setupId) async {
    // No-op for example repo
    return;
  }
}
