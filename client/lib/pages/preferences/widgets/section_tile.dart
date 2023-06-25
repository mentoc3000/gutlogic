import 'package:flutter/material.dart';

class SectionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionTile({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
      subtitle: subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall) : null,
    );
  }
}
