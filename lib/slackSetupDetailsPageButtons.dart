import 'package:flutter/material.dart';

class SlackSetupDetailsPageButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SlackSetupDetailsPageButtons({
    super.key,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8, // Sets the width to 80% of the available width
      child: Card(
        child: Padding(
          padding: EdgeInsetsGeometry.all(3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              IconButton.filled(onPressed: onEdit, icon: Icon(Icons.edit, size: 30)),
              IconButton.filled(onPressed: onDelete , icon: Icon(Icons.delete, size: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
