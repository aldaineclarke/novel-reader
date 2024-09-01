import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/sadbook_asset.png'),
        const SizedBox(
          height: 20,
        ),
        Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
