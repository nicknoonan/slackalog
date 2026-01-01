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
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // This is key
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsetsGeometry.fromLTRB(20, 3, 20, 3,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  IconButton.filled(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit, size: 30),
                  ),
                  IconButton.filled(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete, size: 30),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
