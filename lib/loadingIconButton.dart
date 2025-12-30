import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingIconButton extends StatelessWidget{
  final bool isLoading;
  final Icon icon;
  final VoidCallback onPressed;

  LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      icon: isLoading
          ? Container(
              width: 24, // Adjust size as needed
              height: 24, // Adjust size as needed
              padding: const EdgeInsets.all(2.0),
              child: const CircularProgressIndicator(strokeWidth: 3),
            )
          : icon, // Your default icon
      onPressed: isLoading
          ? null
          : onPressed, // Disable button while loading
      tooltip: isLoading ? 'Processing...' : 'Upload Data',
    );
  }
}
