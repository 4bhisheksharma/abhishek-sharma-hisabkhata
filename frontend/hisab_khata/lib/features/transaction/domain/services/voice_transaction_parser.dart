/// Service to parse voice input and extract transaction details
class VoiceTransactionParser {
  /// Parse transaction details from spoken text
  /// Examples:
  /// - "add 200 rs for chocolate" -> amount: 200, description: "chocolate"
  /// - "500 rupees for milk and eggs" -> amount: 500, description: "milk and eggs"
  /// - "1000 for groceries" -> amount: 1000, description: "groceries"
  static ParsedTransaction? parse(String spokenText) {
    if (spokenText.isEmpty) return null;

    final text = spokenText.toLowerCase().trim();

    // Try multiple patterns to extract amount and description
    double? amount;
    String? description;

    // Pattern 1: "add X rs/rupees for Y"
    RegExp pattern1 = RegExp(
      r'(?:add\s+)?(\d+(?:\.\d+)?)\s*(?:rs|rupees?|रुपैया)\s*(?:for|to)?\s*(.+)',
      caseSensitive: false,
    );

    // Pattern 2: "X rs/rupees for Y"
    RegExp pattern2 = RegExp(
      r'(\d+(?:\.\d+)?)\s*(?:rs|rupees?|रुपैया)\s+(?:for|to)?\s*(.+)',
      caseSensitive: false,
    );

    // Pattern 3: "X for Y"
    RegExp pattern3 = RegExp(
      r'(?:add\s+)?(\d+(?:\.\d+)?)\s+(?:for|to)\s+(.+)',
      caseSensitive: false,
    );

    // Pattern 4: Just "X Y" where Y is description
    RegExp pattern4 = RegExp(r'(\d+(?:\.\d+)?)\s+(.+)', caseSensitive: false);

    Match? match;

    // Try patterns in order of specificity
    match = pattern1.firstMatch(text);
    if (match != null) {
      amount = double.tryParse(match.group(1) ?? '');
      description = _cleanDescription(match.group(2) ?? '');
    }

    if (amount == null || description == null) {
      match = pattern2.firstMatch(text);
      if (match != null) {
        amount = double.tryParse(match.group(1) ?? '');
        description = _cleanDescription(match.group(2) ?? '');
      }
    }

    if (amount == null || description == null) {
      match = pattern3.firstMatch(text);
      if (match != null) {
        amount = double.tryParse(match.group(1) ?? '');
        description = _cleanDescription(match.group(2) ?? '');
      }
    }

    if (amount == null || description == null) {
      match = pattern4.firstMatch(text);
      if (match != null) {
        amount = double.tryParse(match.group(1) ?? '');
        final desc = match.group(2) ?? '';
        // Only use pattern 4 if description doesn't start with common filler words
        if (!desc.startsWith(RegExp(r'(and|or|the|a|an)\s'))) {
          description = _cleanDescription(desc);
        }
      }
    }

    if (amount != null &&
        amount > 0 &&
        description != null &&
        description.isNotEmpty) {
      return ParsedTransaction(
        amount: amount,
        description: description,
        originalText: spokenText,
      );
    }

    return null;
  }

  /// Clean up the description by removing common filler words at start
  static String _cleanDescription(String description) {
    String cleaned = description.trim();

    // Remove common prefixes
    final prefixes = [
      'the',
      'a',
      'an',
      'some',
      'for',
      'to',
      'buying',
      'purchasing',
    ];

    for (final prefix in prefixes) {
      if (cleaned.toLowerCase().startsWith('$prefix ')) {
        cleaned = cleaned.substring(prefix.length + 1).trim();
      }
    }

    return cleaned;
  }

  /// Get suggested descriptions based on partial input
  static List<String> getSuggestions(String partial) {
    // Common transaction items
    final suggestions = [
      'groceries',
      'milk',
      'bread',
      'vegetables',
      'fruits',
      'chocolate',
      'snacks',
      'drinks',
      'medicine',
      'stationery',
      'clothes',
      'shoes',
      'electronics',
      'mobile recharge',
      'fuel',
      'food',
      'restaurant',
      'coffee',
      'tea',
    ];

    if (partial.isEmpty) return suggestions;

    final lowercasePartial = partial.toLowerCase();
    return suggestions
        .where((s) => s.toLowerCase().contains(lowercasePartial))
        .toList();
  }
}

/// Data class for parsed transaction details
class ParsedTransaction {
  final double amount;
  final String description;
  final String originalText;

  const ParsedTransaction({
    required this.amount,
    required this.description,
    required this.originalText,
  });

  @override
  String toString() {
    return 'ParsedTransaction(amount: $amount, description: $description)';
  }
}
