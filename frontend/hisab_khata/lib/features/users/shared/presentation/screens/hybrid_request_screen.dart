import 'package:flutter/material.dart';
import 'package:hisab_khata/features/hybrid_switch/presentation/screens/hybrid_switch_screen.dart';

class HybridRequestScreen extends StatefulWidget {
  final bool isBusinessAccount;
  final bool isBusinessVerified;

  const HybridRequestScreen({
    super.key,
    required this.isBusinessAccount,
    this.isBusinessVerified = false,
  });

  @override
  State<HybridRequestScreen> createState() => _HybridRequestScreenState();
}

class _HybridRequestScreenState extends State<HybridRequestScreen> {
  @override
  Widget build(BuildContext context) {
    // Keep this screen as a compatibility wrapper for existing navigation.
    // Source of truth now lives in the feature-based HybridSwitchPage.
    return const HybridSwitchPage();
  }
}
