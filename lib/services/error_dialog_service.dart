import 'package:babel_novel/widgets/error_message_modal.dart';
import 'package:flutter/material.dart';

class ErrorDialogService {
  static final ErrorDialogService _instance = ErrorDialogService._internal();

  factory ErrorDialogService() {
    return _instance;
  }

  ErrorDialogService._internal();

  bool _isDialogShowing = false;

  void showErrorDialog(
      BuildContext context, String message, VoidCallback onRetry) {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      builder: (context) {
        return ErrorMessageModal(
          message: message,
        );
      },
    ).then((_) {
      _isDialogShowing = false;
      onRetry();
    });
  }
}
