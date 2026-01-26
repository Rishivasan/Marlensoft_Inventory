import 'package:flutter_riverpod/legacy.dart';

class HeaderModel {
  final String title;
  final String subtitle;

  const HeaderModel({
    required this.title,
    required this.subtitle,
  });
}

final headerProvider = StateProvider<HeaderModel>((ref) {
  return const HeaderModel(
    title: "Dashboard",
    subtitle: "Welcome! Select a menu to view details.",
  );
});

