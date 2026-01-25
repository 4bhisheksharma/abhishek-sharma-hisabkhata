/// Service to parse OCR extracted text and extract transaction details
class ImageTransactionParser {
  /// Parse transaction details from OCR text
  /// Examples:
  /// - "Total: Rs. 500\nChocolate" -> amount: 500, description: "Chocolate"
  /// - "Amount 1000 Groceries" -> amount: 1000, description: "Groceries"
  /// - "Rs 250\nMilk & Bread" -> amount: 250, description: "Milk & Bread"
  static ParsedImageTransaction? parse(String ocrText) {
    if (ocrText.isEmpty) return null;

    final text = ocrText.trim();
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    double? amount;
    String? description;
    List<String> remainingLines = [];

    // Pattern 1: Look for "Total", "Amount", "Price" keywords
    final totalPattern = RegExp(
      r'(?:total|amount|price|grand total|net total|payable|bill|pay)\s*:?\s*(?:rs\.?|₹)?\s*(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    // Pattern 2: Just currency symbol followed by number
    final currencyPattern = RegExp(
      r'(?:rs\.?|₹|rupees?)\s*(\d+(?:\.\d{1,2})?)',
      caseSensitive: false,
    );

    // Pattern 3: Number with decimal (likely to be amount)
    final numberPattern = RegExp(r'\b(\d{2,}(?:\.\d{1,2})?)\b');

    // Try to find amount in each line
    for (final line in lines) {
      // Try pattern 1 first (Total/Amount keywords)
      final totalMatch = totalPattern.firstMatch(line);
      if (totalMatch != null && amount == null) {
        amount = double.tryParse(totalMatch.group(1) ?? '');
        if (amount != null) continue;
      }

      // Try pattern 2 (currency symbol)
      if (amount == null) {
        final currencyMatch = currencyPattern.firstMatch(line);
        if (currencyMatch != null) {
          amount = double.tryParse(currencyMatch.group(1) ?? '');
          if (amount != null) continue;
        }
      }

      // Store line for potential description
      remainingLines.add(line);
    }

    // If still no amount, try finding the largest number (likely the total)
    if (amount == null) {
      double? maxAmount;
      String? amountLine;

      for (final line in lines) {
        final matches = numberPattern.allMatches(line);
        for (final match in matches) {
          final num = double.tryParse(match.group(1) ?? '');
          if (num != null && (maxAmount == null || num > maxAmount)) {
            maxAmount = num;
            amountLine = line;
          }
        }
      }

      amount = maxAmount;
      if (amountLine != null) {
        remainingLines.remove(amountLine);
      }
    }

    // Build description from remaining lines
    if (remainingLines.isNotEmpty) {
      // Filter out lines that look like amounts, dates, or noise
      final filteredLines = remainingLines.where((line) {
        // Skip lines that are just numbers
        if (RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(line)) return false;

        // Skip lines that look like dates
        if (RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{2,4}').hasMatch(line)) {
          return false;
        }

        // Skip very short lines (less than 3 characters)
        if (line.length < 3) return false;

        // Skip lines with only special characters
        if (RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(line)) return false;

        return true;
      }).toList();

      if (filteredLines.isNotEmpty) {
        // Take first meaningful line or combine first few lines
        if (filteredLines.length == 1) {
          description = filteredLines[0];
        } else {
          // Take first 2-3 lines that look like item descriptions
          final itemLines = filteredLines
              .take(3)
              .where((line) {
                // Prefer lines with alphabets
                return RegExp(r'[a-zA-Z]').hasMatch(line);
              })
              .take(2)
              .toList();

          description = itemLines.join(', ');
        }
      }
    }

    // Clean up description
    if (description != null) {
      description = _cleanDescription(description);
    }

    // If we couldn't extract meaningful description, use generic one
    if (description == null || description.isEmpty) {
      description = 'Item from receipt';
    }

    if (amount != null && amount > 0) {
      return ParsedImageTransaction(
        amount: amount,
        description: description,
        originalText: ocrText,
        confidence: _calculateConfidence(ocrText, amount, description),
      );
    }

    return null;
  }

  /// Clean up the description
  static String _cleanDescription(String description) {
    String cleaned = description.trim();

    // Remove common receipt keywords
    final keywords = [
      'total',
      'amount',
      'price',
      'bill',
      'invoice',
      'receipt',
      'grand total',
      'net total',
      'subtotal',
      'qty',
      'quantity',
      'rate',
    ];

    for (final keyword in keywords) {
      cleaned = cleaned
          .replaceAll(RegExp('\\b$keyword\\b', caseSensitive: false), '')
          .trim();
    }

    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove leading/trailing special characters
    cleaned = cleaned.replaceAll(RegExp(r'^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$'), '');

    return cleaned;
  }

  /// Calculate confidence score based on parsing results
  static double _calculateConfidence(
    String text,
    double amount,
    String description,
  ) {
    double confidence = 0.5; // Base confidence

    // Increase confidence if amount was found with keyword
    if (RegExp(
      r'(?:total|amount|price)',
      caseSensitive: false,
    ).hasMatch(text)) {
      confidence += 0.2;
    }

    // Increase confidence if currency symbol found
    if (RegExp(r'(?:rs\.?|₹|rupees?)', caseSensitive: false).hasMatch(text)) {
      confidence += 0.15;
    }

    // Increase confidence if description looks meaningful
    if (description.split(' ').length >= 2) {
      confidence += 0.15;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Extract multiple line items from receipt (advanced)
  static List<ParsedImageTransaction> parseMultipleItems(String ocrText) {
    final List<ParsedImageTransaction> items = [];
    final lines = ocrText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Pattern for line items: "Item name ... Rs. 100" or "Item 100"
    final lineItemPattern = RegExp(
      r'^(.+?)\s+(?:rs\.?|₹)?\s*(\d+(?:\.\d{1,2})?)$',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = lineItemPattern.firstMatch(line);
      if (match != null) {
        final desc = _cleanDescription(match.group(1) ?? '');
        final amt = double.tryParse(match.group(2) ?? '');

        if (amt != null && amt > 0 && desc.isNotEmpty && desc.length >= 3) {
          items.add(
            ParsedImageTransaction(
              amount: amt,
              description: desc,
              originalText: line,
              confidence: 0.7,
            ),
          );
        }
      }
    }

    return items;
  }
}

/// Data class for parsed image transaction details
class ParsedImageTransaction {
  final double amount;
  final String description;
  final String originalText;
  final double confidence; // 0.0 to 1.0

  const ParsedImageTransaction({
    required this.amount,
    required this.description,
    required this.originalText,
    this.confidence = 0.5,
  });

  @override
  String toString() {
    return 'ParsedImageTransaction(amount: $amount, description: $description, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
  }
}
