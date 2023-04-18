import 'package:flutter/material.dart';
import 'database.dart';
import 'empty_space.dart';
import 'home_page.dart';
import 'qr_code_dialogs.dart';


void processMove(BuildContext context, String code, bool isQRCodeDetected) async {
  // Get empty spaces
  final emptySpaces = await getEmptySpaces();
  if (emptySpaces.isEmpty) {
    showDialog(
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
  } else {
    // Show empty spaces and let the user choose a new location
    final newLocationKey = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmptySpacePage(),
      ),
    );
    if (newLocationKey != null) {
      await moveItem(code, newLocationKey);
      Navigator.of(context).pop(true);
    } else {
      isQRCodeDetected = false;
    }
  }
}

void processQRCode(BuildContext context, String code, bool isInbound) async {
  if (isInbound) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmptySpacePage(),
      ),
    ).then((selectedLocationKey) async {
      await addOrUpdateItem(code, selectedLocationKey);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('입고 완료'),
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
            (route) => false,
      );
    });
  } else {
    // Set item as "출하" in the database
    await setItemAsOutbound(code);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('출고 완료'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
          (route) => false,
    );
  }
}
