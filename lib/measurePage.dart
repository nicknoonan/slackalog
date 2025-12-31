import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class MeasurePage extends StatefulWidget {
  // final void Function(String) onTitleChanged;

  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  late ARKitController arkitController;
  vector.Vector3? startPosition;
  vector.Vector3? endPosition;
  List<List<String>> nodeNameStack = [];

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Measure Page')),
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          ARKitSceneView(
            enableTapRecognizer: true,
            onARKitViewCreated: onARKitViewCreated,
          ),
          floatingActionButtons(nodeNameStack.isEmpty),
          startPosition != null && endPosition != null
              ? floatingSubmitButton()
              : SizedBox(),
        ],
      ),
    );
  }

  Widget floatingSubmitButton() {
    final distance = startPosition!.distanceTo(endPosition!);

    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop<int>(distance.toInt());
        },
        label: Text(distance.toStringAsFixed(2)),
        icon: Icon(Icons.arrow_back_ios_sharp),
      ),
    );
  }

  Widget floatingActionButtons(bool isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Aligns buttons to the right
        spacing: 2,
        children: [
          IconButton.filled(
            onPressed: isEmpty ? null : clearNodes,
            icon: Icon(Icons.delete),
          ),
          IconButton.filled(
            onPressed: isEmpty ? null : popNodes,
            icon: Icon(Icons.undo),
          ),
        ],
      ),
    );
  }

  void setStartPosition(vector.Vector3? position) {
    setState(() {
      startPosition = position;
    });
  }

  void setEndPosition(vector.Vector3? position) {
    setState(() {
      endPosition = position;
    });
  }

  void pushNodes(List<ARKitNode> nodes) {
    for (var node in nodes) {
      arkitController.add(node);
    }
    nodeNameStack.add(nodes.map((node) => node.name).toList());
  }

  void popNodes() {
    if (nodeNameStack.isEmpty) return;

    setEndPosition(null);

    final names = nodeNameStack.removeLast();
    for (var name in names) {
      arkitController.remove(name);
    }

    if (nodeNameStack.isEmpty) {
      setStartPosition(null);
    }
  }

  void clearNodes() {
    while (nodeNameStack.isNotEmpty) {
      popNodes();
    }
  }

  void setTitle() {
    String title;
    if (startPosition == null && endPosition == null) {
      title = 'tap to measure distance';
    } else if (startPosition != null && endPosition == null) {
      title = 'tap again set end position';
    } else {
      title = _calculateDistanceBetweenPoints(startPosition!, endPosition!);
    }
    // widget.onTitleChanged(title);
  }

  ARKitNode createThickLine(
    vector.Vector3 from,
    vector.Vector3 to,
    double thickness,
    ARKitMaterial material,
  ) {
    final vector.Vector3 direction = to - from;
    final double distance = direction.length;

    // Create a cylinder with the specified thickness (radius) and calculated height (distance)
    final ARKitCylinder line = ARKitCylinder(
      radius: thickness / 2.0, // thickness is the diameter, so use radius/2
      height: distance,
    );

    // Apply the material to the cylinder
    line.materials.value = [material];

    // Create a node for the cylinder and align it between the two points
    final ARKitNode node = ARKitNode(
      geometry: line,
      transformation: _transformBetweenPoints(from, to, distance),
    );

    return node;
  }

  // Helper function to calculate the transformation matrix to align a cylinder (which is vertical by default)
  // with the direction between two 3D points.
  vector.Matrix4 _transformBetweenPoints(
    vector.Vector3 p1,
    vector.Vector3 p2,
    double distance,
  ) {
    final vector.Vector3 dir = (p2 - p1);
    final double len = dir.length;
    if (len <= 0.0) {
      return vector.Matrix4.identity();
    }

    final vector.Vector3 y =
        (dir / len); // desired up direction for the cylinder

    // Choose an arbitrary vector that's not parallel to y to build the orthonormal basis
    vector.Vector3 arbitrary = (y.x.abs() < 0.0001 && y.z.abs() < 0.0001)
        ? vector.Vector3(0.0, 0.0, 1.0)
        : vector.Vector3(0.0, 1.0, 0.0);

    vector.Vector3 x = arbitrary.cross(y);
    if (x.length2 <= 1e-8) {
      arbitrary = vector.Vector3(1.0, 0.0, 0.0);
      x = arbitrary.cross(y);
    }
    x.normalize();

    final vector.Vector3 z = y.cross(x);

    // Matrix4.columns takes column vectors (x-axis, y-axis, z-axis, translation)
    final vector.Vector3 mid = _getMiddleVector(p1, p2);
    return vector.Matrix4.columns(
      vector.Vector4(x.x, x.y, x.z, 0.0),
      vector.Vector4(y.x, y.y, y.z, 0.0),
      vector.Vector4(z.x, z.y, z.z, 0.0),
      vector.Vector4(mid.x, mid.y, mid.z, 1.0),
    );
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onARTap = (ar) {
      final point = ar.firstWhereOrNull(
        (o) => o.type == ARKitHitTestResultType.featurePoint,
      );
      if (point != null) {
        _onARTapHandler(point);
      }
    };
  }

  void _onARTapHandler(ARKitTestResult point) {
    if (nodeNameStack.length >= 2) {
      // handle the case where there are already two points selected
      // user should see a message saying slack lines can only have two anchors
      return;
    }

    var nodes = <ARKitNode>[];
    var uuid = Uuid();
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.blinn,
      diffuse: ARKitMaterialProperty.color(Colors.blue),
    );
    final sphere = ARKitSphere(radius: 0.03, materials: [material]);
    final name = uuid.v1();
    final node = ARKitNode(geometry: sphere, position: position, name: name);
    nodes.add(node);

    if (startPosition != null) {
      final distance = _calculateDistanceBetweenPoints(
        position,
        startPosition!,
      );
      final point = _getMiddleVector(position, startPosition!);
      final thickLine = createThickLine(
        startPosition!,
        position,
        0.01,
        material,
      );
      nodes.add(thickLine);
      setEndPosition(position);
    } else {
      setStartPosition(position);
    }

    pushNodes(nodes);
  }

  String _calculateDistanceBetweenPoints(vector.Vector3 A, vector.Vector3 B) {
    final length = A.distanceTo(B);
    return '${(length * 100).toStringAsFixed(2)} cm';
  }

  vector.Vector3 _getMiddleVector(vector.Vector3 A, vector.Vector3 B) {
    return vector.Vector3((A.x + B.x) / 2, (A.y + B.y) / 2, (A.z + B.z) / 2);
  }

  ARKitNode textNode(String text, name, vector.Vector3 point) {
    final textGeometry = ARKitText(
      text: text,
      extrusionDepth: 1,
      materials: [
        ARKitMaterial(diffuse: ARKitMaterialProperty.color(Colors.red)),
      ],
    );
    const scale = 0.001;
    final vectorScale = vector.Vector3(scale, scale, scale);
    return ARKitNode(
      geometry: textGeometry,
      position: point,
      scale: vectorScale,
      name: name,
    );
  }
}
