import 'package:flutter/material.dart';
import 'package:hisab_khata/shared/providers/locale_provider.dart';

class LanguageSwitcher extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  final String? initialLanguage;

  const LanguageSwitcher({super.key, this.onLanguageChanged, this.initialLanguage});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeProvider = LocaleProvider.of(context);
      final currentLocale = localeProvider?.locale.languageCode ?? 'en';
      if (widget.initialLanguage != null && widget.initialLanguage != currentLocale) {
        localeProvider?.changeLanguage(widget.initialLanguage!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProvider.of(context);
    final currentLocale = localeProvider?.locale.languageCode ?? 'en';

    return DropdownButton<String>(
      value: currentLocale,
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'ne', child: Text('नेपाली')),
      ],
      onChanged: (value) {
        if (value != null) {
          localeProvider?.changeLanguage(value);
          widget.onLanguageChanged?.call(value);
        }
      },
      underline: const SizedBox.shrink(),
      icon: const Icon(Icons.language, color: Colors.grey),
    );
  }
}
