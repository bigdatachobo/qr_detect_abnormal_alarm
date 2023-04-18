import 'package:flutter/material.dart';

import 'home_page.dart';

Future<void> showInvalidCodeFormatDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Invalid code format'),
      content: const Text('The code must be \nin the format of \n"B00000_0000000000".'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showNoEmptySpacesDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: const Text('No empty spaces available.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showInboundSuccessDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Success'),
      content: const Text('입고 완료'),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (route) => false,
            );
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<void> showOutboundSuccessDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Success'),
      content: const Text('출고 완료'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (route) => false,
            );
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
