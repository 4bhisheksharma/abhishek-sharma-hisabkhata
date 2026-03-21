import 'package:flutter/material.dart';

import '../../domain/entities/hybrid_switch_request_entity.dart';
import '../../domain/entities/hybrid_switch_status_entity.dart';

class HybridSwitchCard extends StatelessWidget {
  final HybridSwitchStatusEntity status;
  final HybridSwitchRequestEntity? latestRequest;

  const HybridSwitchCard({super.key, required this.status, this.latestRequest});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch to Hybrid',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _InfoRow(label: 'Account Type', value: status.accountType),
            _InfoRow(
              label: 'Business Verification',
              value: status.isBusinessVerified ? 'Verified' : 'Not Verified',
            ),
            _InfoRow(
              label: 'Can Request',
              value: status.canRequest ? 'Yes' : 'No',
            ),
            _InfoRow(
              label: 'Has Pending Request',
              value: status.hasPendingRequest ? 'Yes' : 'No',
            ),
            if (latestRequest != null) ...[
              const Divider(height: 22),
              const Text(
                'Latest Request',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _InfoRow(label: 'Status', value: latestRequest!.status),
              if ((latestRequest!.adminRemarks ?? '').isNotEmpty)
                _InfoRow(
                  label: 'Admin Feedback',
                  value: latestRequest!.adminRemarks!,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
