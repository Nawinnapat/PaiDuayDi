import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/services/route_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class HomeInsideFeatureScreen extends StatefulWidget {
  const HomeInsideFeatureScreen({
    super.key,
    required this.originName,
    required this.destinationName,
    this.route,
  });

  final String originName;
  final String destinationName;
  final RouteDetails? route;

  @override
  State<HomeInsideFeatureScreen> createState() =>
      _HomeInsideFeatureScreenState();
}

class _HomeInsideFeatureScreenState extends State<HomeInsideFeatureScreen> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 17, minute: 30);
  String _flexibleTime = '+ 15 min';
  String _travelMode = 'Share Taxi';
  int _peopleNeeded = 2;
  final Set<String> _preferences = {'Everyone'};

  int get _estimatedCost {
    final distanceKm = (widget.route?.distanceMeters ?? 11000) / 1000;
    return math.max(45, (distanceKm * 8 / _peopleNeeded).ceil());
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryLight),
        ),
        child: child!,
      ),
    );
    if (selected != null && mounted) setState(() => _time = selected);
  }

  String get _dateLabel {
    final now = DateTime.now();
    if (_date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day) {
      return 'Today';
    }
    return '${_date.day.toString().padLeft(2, '0')}/'
        '${_date.month.toString().padLeft(2, '0')}/${_date.year}';
  }

  void _togglePreference(String value) {
    setState(() {
      if (value == 'Everyone') {
        _preferences
          ..clear()
          ..add(value);
        return;
      }
      _preferences.remove('Everyone');
      if (!_preferences.add(value)) _preferences.remove(value);
      if (_preferences.isEmpty) _preferences.add('Everyone');
    });
  }

  void _startTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'สร้างทริปไป ${widget.destinationName} แล้ว กำลังค้นหาเพื่อนร่วมทาง',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          tooltip: 'ย้อนกลับ',
        ),
        title: Text(
          'Create Trip',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('When?'),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _ValueCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: _dateLabel,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ValueCard(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: _time.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _SubsectionTitle('Flexible departure time'),
              const SizedBox(height: 9),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Exact', '+ 15 min', '+ 30 min', '+ 1 hour']
                    .map(
                      (value) => _ChoiceChip(
                        label: value,
                        selected: _flexibleTime == value,
                        onTap: () => setState(() => _flexibleTime = value),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('How are you traveling?'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TravelCard(
                      icon: Icons.local_taxi_outlined,
                      label: 'Share Taxi',
                      selected: _travelMode == 'Share Taxi',
                      onTap: () => setState(() => _travelMode = 'Share Taxi'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TravelCard(
                      icon: Icons.local_shipping_outlined,
                      label: 'Delivery app',
                      selected: _travelMode == 'Delivery app',
                      onTap: () => setState(() => _travelMode = 'Delivery app'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Group Details'),
              const SizedBox(height: 10),
              _OutlinedRow(
                child: Row(
                  children: [
                    Expanded(child: Text('People needed', style: _fieldStyle)),
                    _RoundAction(
                      icon: Icons.remove_rounded,
                      enabled: _peopleNeeded > 1,
                      onTap: () => setState(() => _peopleNeeded--),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text(
                        '$_peopleNeeded',
                        textAlign: TextAlign.center,
                        style: AppTypography.titleSmall,
                      ),
                    ),
                    _RoundAction(
                      icon: Icons.add_rounded,
                      enabled: _peopleNeeded < 8,
                      onTap: () => setState(() => _peopleNeeded++),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _OutlinedRow(
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Est. cost / person', style: _fieldStyle),
                    ),
                    Text(
                      '฿ $_estimatedCost',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _OutlinedRow(
                height: 46,
                child: Row(
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 19,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Meeting Point (Optional)',
                        style: _fieldStyle.copyWith(color: AppColors.textLight),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Trip Preferences'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 9,
                children:
                    [
                          ('Everyone', null),
                          ('Female Only', Icons.female_rounded),
                          ('Male Only', Icons.male_rounded),
                          ('Quiet Ride', Icons.volume_off_outlined),
                          ('No Smoking', Icons.smoke_free_rounded),
                          ('Chat Friendly', Icons.chat_outlined),
                        ]
                        .map(
                          (item) => _PreferenceChip(
                            label: item.$1,
                            icon: item.$2,
                            selected: _preferences.contains(item.$1),
                            onTap: () => _togglePreference(item.$1),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 22),
              const _SectionTitle('Additional Note (Optional)'),
              const SizedBox(height: 10),
              TextField(
                minLines: 3,
                maxLines: 4,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Any specific details for your trip mates?',
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textLight,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: _inputBorder,
                  focusedBorder: _inputBorder.copyWith(
                    borderSide: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 51,
                child: FilledButton(
                  onPressed: _startTrip,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: Text('Start', style: AppTypography.button),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _CreateTripBottomNavigation(),
    );
  }
}

TextStyle get _fieldStyle => AppTypography.bodyMedium.copyWith(
  color: AppColors.textSecondary,
  fontSize: 13,
);

OutlineInputBorder get _inputBorder => OutlineInputBorder(
  borderRadius: BorderRadius.circular(9),
  borderSide: const BorderSide(color: AppColors.borderLight),
);

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.titleSmall.copyWith(fontSize: 14));
}

class _SubsectionTitle extends StatelessWidget {
  const _SubsectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppTypography.bodySmall.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.textMuted),
            const SizedBox(width: 9),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                ),
                Text(
                  value,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryUltraLight : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.borderLight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected ? AppColors.primaryLight : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TravelCard extends StatelessWidget {
  const _TravelCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 90,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryUltraLight : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primaryLight : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: selected ? AppColors.primaryLight : AppColors.textPrimary,
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: selected
                    ? AppColors.primaryLight
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedRow extends StatelessWidget {
  const _OutlinedRow({required this.child, this.height = 58});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(9),
    ),
    child: child,
  );
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.backgroundMuted,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 17,
        color: enabled ? AppColors.textSecondary : AppColors.textLight,
      ),
    ),
  );
}

class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryUltraLight : Colors.white,
        border: Border.all(
          color: selected ? AppColors.primaryLight : AppColors.borderLight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected ? AppColors.primaryLight : AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: selected
                  ? AppColors.primaryLight
                  : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CreateTripBottomNavigation extends StatelessWidget {
  const _CreateTripBottomNavigation();

  @override
  Widget build(BuildContext context) => Container(
    height: 68,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.borderLight)),
    ),
    child: SafeArea(
      top: false,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CreateTripNavItem(icon: Icons.home_outlined, label: 'Home'),
          _CreateTripNavItem(
            icon: Icons.route_outlined,
            label: 'My Trips',
            active: true,
          ),
          _CreateTripNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
          ),
          _CreateTripNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}

class _CreateTripNavItem extends StatelessWidget {
  const _CreateTripNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryLight : AppColors.textLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryUltraLight : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
