import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({
    super.key,
    required this.originName,
    required this.destinationName,
    required this.estimatedCost,
    this.searchDelay = const Duration(milliseconds: 2200),
  });

  final String originName;
  final String destinationName;
  final int estimatedCost;
  final Duration searchDelay;

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  Timer? _searchTimer;
  bool _showMatches = false;
  final Set<String> _requestedMatches = <String>{};

  @override
  void initState() {
    super.initState();
    _searchTimer = Timer(widget.searchDelay, () {
      if (mounted) setState(() => _showMatches = true);
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  String _shortPlaceName(String value) {
    final cleaned = value.replaceFirst('จาก: ', '').trim();
    final firstPart = cleaned.split(',').first.trim();
    return firstPart.length > 18 ? '${firstPart.substring(0, 17)}…' : firstPart;
  }

  void _requestToJoin(String name) {
    setState(() => _requestedMatches.add(name));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ส่งคำขอร่วมทางให้ $name แล้ว'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstFare = math.max(50, widget.estimatedCost);
    final secondFare = math.max(45, firstFare - 5);
    final candidates = [
      _MatchCandidate(
        name: 'Krit P.',
        initial: 'K',
        rating: '4.9',
        rides: '120 rides',
        vehicle: 'Honda Civic',
        seats: '2 seats left',
        departure: 'Leaves in 15 mins',
        fare: firstFare,
        avatarColor: AppColors.primaryLight,
      ),
      _MatchCandidate(
        name: 'Nara S.',
        initial: 'N',
        rating: '4.8',
        rides: '85 rides',
        vehicle: 'Toyota Yaris',
        seats: '1 seat left',
        departure: 'Leaves in 30 mins',
        fare: secondFare,
        avatarColor: const Color(0xFFFFA51F),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _MatchingHeader(
              routeLabel:
                  '${_shortPlaceName(widget.originName)} → ${_shortPlaceName(widget.destinationName)}',
              onBack: () => Navigator.pop(context),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  const _SearchingCard(),
                  const SizedBox(height: 36),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 480),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, .06),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _showMatches
                        ? Column(
                            key: const ValueKey('matching-results'),
                            children: [
                              for (
                                var index = 0;
                                index < candidates.length;
                                index++
                              ) ...[
                                _MatchCard(
                                  candidate: candidates[index],
                                  requested: _requestedMatches.contains(
                                    candidates[index].name,
                                  ),
                                  onRequest: () =>
                                      _requestToJoin(candidates[index].name),
                                ),
                                if (index != candidates.length - 1)
                                  const SizedBox(height: 16),
                              ],
                            ],
                          )
                        : const _SearchingPlaceholder(
                            key: ValueKey('matching-placeholder'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _MatchingBottomNavigation(),
    );
  }
}

class _MatchingHeader extends StatelessWidget {
  const _MatchingHeader({required this.routeLabel, required this.onBack});

  final String routeLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 29,
                color: AppColors.textSecondary,
              ),
              tooltip: 'ย้อนกลับ',
            ),
          ),
          SizedBox(
            width: 236,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 48,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PaiDuayDi',
                      maxLines: 1,
                      softWrap: false,
                      style: AppTypography.brandTitle.copyWith(
                        fontSize: 39,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                ),
                Text(
                  routeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 12,
            child: Icon(
              Icons.more_vert_rounded,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchingCard extends StatelessWidget {
  const _SearchingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4D9E0)),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Searching for matches...',
            textAlign: TextAlign.center,
            style: AppTypography.heading3.copyWith(fontSize: 23),
          ),
          const SizedBox(height: 9),
          Text(
            'Finding the best routes for you.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchingPlaceholder extends StatelessWidget {
  const _SearchingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 38),
    child: Column(
      children: [
        Text(
          'กำลังค้นหาคนที่ไปเส้นทางเดียวกับคุณ',
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'ระบบกำลังเปรียบเทียบเส้นทางและเวลาเดินทาง',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        ),
      ],
    ),
  );
}

class _MatchCandidate {
  const _MatchCandidate({
    required this.name,
    required this.initial,
    required this.rating,
    required this.rides,
    required this.vehicle,
    required this.seats,
    required this.departure,
    required this.fare,
    required this.avatarColor,
  });

  final String name;
  final String initial;
  final String rating;
  final String rides;
  final String vehicle;
  final String seats;
  final String departure;
  final int fare;
  final Color avatarColor;
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.candidate,
    required this.requested,
    required this.onRequest,
  });

  final _MatchCandidate candidate;
  final bool requested;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD4D9E0)),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _VerifiedAvatar(candidate: candidate),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.name,
                      style: AppTypography.heading3.copyWith(fontSize: 23),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_border_rounded,
                          color: AppColors.accentYellow,
                          size: 22,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${candidate.rating} (${candidate.rides})',
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F9),
                  border: Border.all(color: const Color(0xFFD4D9E0)),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '฿ ${candidate.fare}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.accentYellow,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFD4D9E0)),
          ),
          _MatchDetailLine(
            icon: Icons.directions_car_filled_outlined,
            iconColor: AppColors.accentYellow,
            text: '${candidate.vehicle} • ${candidate.seats}',
          ),
          const SizedBox(height: 10),
          _MatchDetailLine(
            icon: Icons.schedule_rounded,
            iconColor: AppColors.primaryLight,
            text: candidate.departure,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: requested ? null : onRequest,
              icon: requested
                  ? const Icon(Icons.check_circle_rounded, size: 21)
                  : const SizedBox.shrink(),
              label: Text(
                requested ? 'ส่งคำขอแล้ว' : 'ขอร่วมทาง',
                style: AppTypography.button.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                disabledBackgroundColor: const Color(0xFF96DCC4),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedAvatar extends StatelessWidget {
  const _VerifiedAvatar({required this.candidate});

  final _MatchCandidate candidate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: candidate.avatarColor,
            child: Text(
              candidate.initial,
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -2,
            child: Container(
              width: 23,
              height: 23,
              decoration: BoxDecoration(
                color: const Color(0xFF2FD3A0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchDetailLine extends StatelessWidget {
  const _MatchDetailLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 22, color: iconColor),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
    ],
  );
}

class _MatchingBottomNavigation extends StatelessWidget {
  const _MatchingBottomNavigation();

  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.borderLight)),
    ),
    child: SafeArea(
      top: false,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _MatchingNavItem(icon: Icons.home_outlined, label: 'Home'),
          _MatchingNavItem(
            icon: Icons.route_outlined,
            label: 'My Trips',
            active: true,
          ),
          _MatchingNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
          ),
          _MatchingNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}

class _MatchingNavItem extends StatelessWidget {
  const _MatchingNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryLight : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryUltraLight : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: color),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
