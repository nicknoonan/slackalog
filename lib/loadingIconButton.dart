import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingIconButton extends StatelessWidget {
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
      onPressed: isLoading ? null : onPressed, // Disable button while loading
      tooltip: isLoading ? 'Processing...' : 'Upload Data',
    );
  }
}

class FutureLoadingIconButton extends StatefulWidget {
  final Future<void> onPressed;
  final Icon icon;

  const FutureLoadingIconButton({super.key, required this.onPressed, required this.icon});

  @override
  State<FutureLoadingIconButton> createState() => _FutureLoadingIconButtonState();
}

class _FutureLoadingIconButtonState extends State<FutureLoadingIconButton> {
  bool isLoading = false;

  Future<void> handlePressed() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ? FutureBuilder<void>(
      future: widget.onPressed,
      builder: (context, snapshot) {
        // 3. Handle the different connection states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIconButton(onPressed: handlePressed, icon: widget.icon, isLoading: true);
        } else if (snapshot.hasError) {
          // Handle errors if the Future throws an exception
          return Text('Error: ${snapshot.error}');
        } else {
          setState(() {
            isLoading = false;
          });
          return LoadingIconButton(onPressed: handlePressed, icon: widget.icon, isLoading: false);
        }
      },
    ) : LoadingIconButton(onPressed: handlePressed, icon: widget.icon, isLoading: false);
  }
}
