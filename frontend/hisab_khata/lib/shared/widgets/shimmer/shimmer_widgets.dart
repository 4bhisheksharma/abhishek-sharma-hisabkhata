import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';

/// A single rectangular shimmer placeholder box.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// A circular shimmer placeholder (for avatars).
class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Dashboard shimmer — matches the SharedDashboard layout with stats card + list.
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: Row(
          children: [
            ShimmerCircle(size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 100, height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 60, height: 10),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats card placeholder
            Shimmer(
              color: Colors.white,
              colorOpacity: 0.3,
              duration: const Duration(milliseconds: 1800),
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section title placeholder
            const ShimmerBox(width: 140, height: 16),
            const SizedBox(height: 16),
            // List items
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const _ShimmerListTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile view shimmer — matches profile header + menu items layout.
class ProfileViewShimmer extends StatelessWidget {
  const ProfileViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(color: Color(0xFFE8F5F3)),
            child: Column(
              children: [
                const ShimmerCircle(size: 100),
                const SizedBox(height: 16),
                const ShimmerBox(width: 160, height: 20, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerBox(width: 100, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Menu items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                5,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ShimmerMenuItem(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile edit shimmer — matches form fields layout.
class ProfileEditShimmer extends StatelessWidget {
  const ProfileEditShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar placeholder
          const Center(child: ShimmerCircle(size: 100)),
          const SizedBox(height: 32),
          // Form fields
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 80, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(height: 48, borderRadius: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Submit button
          const ShimmerBox(height: 52, borderRadius: 12),
        ],
      ),
    );
  }
}

/// Verification screen shimmer — matches status card + form layout.
class VerificationShimmer extends StatelessWidget {
  const VerificationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card placeholder
          Shimmer(
            color: Colors.white,
            colorOpacity: 0.3,
            duration: const Duration(milliseconds: 1800),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 220,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ShimmerBox(width: 200, height: 18),
          const SizedBox(height: 12),
          // Form card placeholder
          Shimmer(
            color: Colors.white,
            colorOpacity: 0.3,
            duration: const Duration(milliseconds: 1800),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 14,
                    color: Colors.grey.shade200,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification list shimmer — matches grouped notification tiles.
class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Group header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: ShimmerBox(width: 80, height: 14),
        ),
        ...List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ShimmerNotificationTile(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: ShimmerBox(width: 60, height: 14),
        ),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ShimmerNotificationTile(),
          ),
        ),
      ],
    );
  }
}

/// Ticket list shimmer — matches my tickets screen layout.
class TicketListShimmer extends StatelessWidget {
  const TicketListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ShimmerTicketCard(),
    );
  }
}

/// Ticket detail shimmer
class TicketDetailShimmer extends StatelessWidget {
  const TicketDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          const ShimmerBox(width: 80, height: 28, borderRadius: 14),
          const SizedBox(height: 16),
          const ShimmerBox(width: 200, height: 22),
          const SizedBox(height: 8),
          const ShimmerBox(height: 14),
          const SizedBox(height: 4),
          const ShimmerBox(width: 250, height: 14),
          const SizedBox(height: 24),
          // Detail rows
          ...List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: const [
                  ShimmerBox(width: 100, height: 14),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(height: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Connection requests shimmer — matches tab content with request cards.
class ConnectionRequestsShimmer extends StatelessWidget {
  const ConnectionRequestsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ShimmerListTile(showTrailingButtons: true),
    );
  }
}

/// Connected users list shimmer — matches the connected users list items.
class ConnectedUsersListShimmer extends StatelessWidget {
  const ConnectedUsersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _ShimmerListTile(),
    );
  }
}

/// Analytics card shimmer — matches the analytics loading card.
class AnalyticsCardShimmer extends StatelessWidget {
  const AnalyticsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.3,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat rooms shimmer — matches chat room list tiles.
class ChatRoomsShimmer extends StatelessWidget {
  const ChatRoomsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            const ShimmerCircle(size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: 200, height: 12),
                ],
              ),
            ),
            const ShimmerBox(width: 40, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Chat messages shimmer — matches message bubbles.
class ChatMessagesShimmer extends StatelessWidget {
  const ChatMessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bubbles = [
      const _ShimmerBubble(isMe: false, width: 200),
      const _ShimmerBubble(isMe: true, width: 160),
      const _ShimmerBubble(isMe: false, width: 240),
      const _ShimmerBubble(isMe: true, width: 180),
      const _ShimmerBubble(isMe: false, width: 140),
      const _ShimmerBubble(isMe: true, width: 220),
    ];

    return ListView.separated(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: bubbles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => bubbles[i],
    );
  }
}

/// User details screen shimmer
class UserDetailsShimmer extends StatelessWidget {
  const UserDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile card
          Shimmer(
            color: Colors.white,
            colorOpacity: 0.3,
            duration: const Duration(milliseconds: 1800),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 140,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Summary cards
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 80, borderRadius: 12)),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 80, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 20),
          // Transactions list
          ...List.generate(
            5,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _ShimmerListTile(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Private helper widgets ────────────────────────────────────────

class _ShimmerListTile extends StatelessWidget {
  final bool showTrailingButtons;

  const _ShimmerListTile({this.showTrailingButtons = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            if (showTrailingButtons) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ] else
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerMenuItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerNotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 160,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerTicketCard extends StatelessWidget {
  const _ShimmerTicketCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      colorOpacity: 0.4,
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 180,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 60,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
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

class _ShimmerBubble extends StatelessWidget {
  final bool isMe;
  final double width;

  const _ShimmerBubble({required this.isMe, required this.width});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Shimmer(
        color: Colors.white,
        colorOpacity: 0.4,
        duration: const Duration(milliseconds: 1800),
        child: Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: isMe
                ? AppTheme.primaryBlue.withValues(alpha: 0.12)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Bulk add connection shimmer — matches search + user list layout.
class BulkAddConnectionShimmer extends StatelessWidget {
  const BulkAddConnectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar placeholder
        Padding(
          padding: const EdgeInsets.all(16),
          child: ShimmerBox(height: 48, borderRadius: 24),
        ),
        // List items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, __) =>
                const _ShimmerListTile(showTrailingButtons: false),
          ),
        ),
      ],
    );
  }
}
