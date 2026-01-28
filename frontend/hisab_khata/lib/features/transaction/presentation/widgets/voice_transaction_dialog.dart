import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../domain/services/voice_transaction_parser.dart';

/// Dialog for adding transaction via voice input
class VoiceTransactionDialog extends StatefulWidget {
  const VoiceTransactionDialog({super.key});

  @override
  State<VoiceTransactionDialog> createState() => _VoiceTransactionDialogState();
}

class _VoiceTransactionDialogState extends State<VoiceTransactionDialog>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isInitialized = false;
  String _transcribedText = '';
  ParsedTransaction? _parsedTransaction;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          setState(() {
            _errorMessage = 'Error: ${error.errorMsg}';
            _isListening = false;
          });
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      setState(() {
        _isInitialized = available;
        if (!available) {
          _errorMessage = 'Speech recognition not available on this device';
        }
      });

      // Auto-start listening when dialog opens
      if (available) {
        await Future.delayed(const Duration(milliseconds: 300));
        _startListening();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    setState(() {
      _transcribedText = '';
      _parsedTransaction = null;
      _errorMessage = '';
      _isListening = true;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;

          // Parse the text to extract transaction details
          if (_transcribedText.isNotEmpty) {
            _parsedTransaction = VoiceTransactionParser.parse(_transcribedText);
          }
        });
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void _confirm() {
    if (_parsedTransaction != null) {
      Navigator.of(context).pop(_parsedTransaction);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenWidth * 0.9 : 500,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: AppTheme.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voice Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isListening ? 'Listening...' : 'Tap mic to speak',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Microphone Animation
            if (_isListening)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: AppTheme.primaryBlue,
                    size: 40,
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _isInitialized ? _startListening : null,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isInitialized
                        ? AppTheme.primaryBlue
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 40),
                ),
              ),

            const SizedBox(height: 24),

            // Hint text
            if (!_isListening && _transcribedText.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Try saying: "Add 200 rs for chocolate"',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Transcribed text
            if (_transcribedText.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You said:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _transcribedText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Parsed transaction details
            if (_parsedTransaction != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Transaction Details',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                'Rs. ${_parsedTransaction!.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                _parsedTransaction!.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Error message
            if (_errorMessage.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              children: [
                if (_isListening)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _stopListening,
                      icon: const Icon(Icons.stop),
                      label: Text(AppLocalizations.of(context)!.stop),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else if (_parsedTransaction != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _startListening,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.confirm),
                    ),
                  ),
                ] else if (_transcribedText.isNotEmpty)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(AppLocalizations.of(context)!.tryAgain),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
