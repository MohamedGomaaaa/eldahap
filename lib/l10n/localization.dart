import 'package:flutter/material.dart';

class L10n{
  static final all = [
    const Locale('en'),
    const Locale('ar'),
  ];
}

// to use generator
// flutter pub run easy_localization:generate -S assets/translations -f keys -O lib/l10n -o locale_keys.g.dart