import 'package:flutter/material.dart';

void showPendingAlert(BuildContext context, String futureAction) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Funcionalidad pendiente'),
        content: Text('En el futuro esto hará: $futureAction.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          )
        ],
      );
    },
  );
}
