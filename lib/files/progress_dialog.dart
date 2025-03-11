import 'package:flutter/material.dart';

void showProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing by tapping outside
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Please wait...", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    },
  );
}

void hideProgressDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop(); // Close the dialog
}
