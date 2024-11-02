import 'package:flutter/material.dart';

class EmptyLibraryView extends StatelessWidget {
  const EmptyLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No entries found.\n"
        "Hit  + Import  below to get started",
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
