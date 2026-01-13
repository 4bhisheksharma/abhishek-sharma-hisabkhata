import 'package:flutter/material.dart';

class LanguageSwitcher extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  final String? initialLanguage;

  const LanguageSwitcher({
    super.key,
    this.onLanguageChanged,
    this.initialLanguage,
  });

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedLanguage,
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'ne', child: Text('नेपाली')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedLanguage = value;
          });
          widget.onLanguageChanged?.call(value);
        }
      },
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.language, color: Colors.grey),
    );
  }
}
