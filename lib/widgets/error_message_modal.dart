import 'package:babel_novel/widgets/error_display_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorMessageModal extends StatelessWidget {
  const ErrorMessageModal({super.key, required this.message});
  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AlertDialog(
      title: const Text('Opps.. My Bad'),
      backgroundColor: Theme.of(context).colorScheme.background,
      content: ErrorDisplayWidget(message: message),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        ElevatedButton(
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.redo_rounded),
              SizedBox(width: 5),
              Text('Try Again'),
            ],
          ),
          onPressed: () {
            Navigator.of(context).pop();

            // _isDialogShowing = false; // Reset the flag when dialog is dismissed
          },
        ),
      ],
    );
  }
}
