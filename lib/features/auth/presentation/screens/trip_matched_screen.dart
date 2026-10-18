import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/route_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class TripMatchedScreen extends StatefulWidget {
  const TripMatchedScreen({
    super.key,
    required this.originName,
    required this.destinationName,
    this.originLocation,
    this.destinationLocation,
    this.route,
    required this.estimatedCost,
    required this.departureDateTime,
  });

  final String originName;
  final String destinationName;
  final LatLng? originLocation;
  final LatLng? destinationLocation;
  final RouteDetails? route;
  final int estimatedCost;
  final DateTime departureDateTime;

  @override
  State<TripMatchedScreen> createState() => _TripMatchedScreenState();
}

class _TripMatchedScreenState extends State<TripMatchedScreen> {
  bool _confirmed = false;
  RouteDetails? _route;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _route = widget.route;
    if (_route == null &&
        widget.originLocation != null &&
        widget.destinationLocation != null) {
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    setState(() => _isLoadingRoute = true);
    try {
      final result = await RouteService().computeRoute(
        origin: widget.originLocation!,
        destination: widget.destinationLocation!,
      );
      if (mounted) setState(() => _route = result);
    } catch (_) {
      // Keep the real locations visible even when a route cannot be fetched.
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  String _shortName(String value) {
    final name = value.replaceFirst('จาก: ', '').trim().split(',').first.trim();
    return name.length > 22 ? '${name.substring(0, 21)}…' : name;
  }

  String get _departureLabel {
    final date = widget.departureDateTime;
    final today = DateTime.now();
    final day =
        date.year == today.year &&
            date.month == today.month &&
            date.day == today.day
        ? 'วันนี้'
        : '${date.day}/${date.month}/${date.year}';
    return '$day ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TripMatchedHeader(
              routeLabel:
                  '${_shortName(widget.originName)} → ${_shortName(widget.destinationName)}',
              onBack: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _SuccessBanner(confirmed: _confirmed),
                  const SizedBox(height: 16),
                  _RouteCard(
                    origin: widget.originName,
                    destination: widget.destinationName,
                    originLocation: widget.originLocation,
                    destinationLocation: widget.destinationLocation,
                    route: _route,
                    isLoadingRoute: _isLoadingRoute,
                    departure: _departureLabel,
                    fare: widget.estimatedCost,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'เพื่อนร่วมทาง',
                        style: AppTypography.titleMedium.copyWith(fontSize: 19),
                      ),
                      Text(
                        '2 คน',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _CompanionCard(
                    name: 'Ploy C.',
                    initial: 'P',
                    rating: '4.9',
                    rides: '32 ทริป',
                    avatarColor: AppColors.primaryLight,
                    preferences: ['ชอบคุย', 'ไม่สูบบุหรี่'],
                  ),
                  const SizedBox(height: 12),
                  const _CompanionCard(
                    name: 'Ken T.',
                    initial: 'K',
                    rating: '4.8',
                    rides: '48 ทริป',
                    avatarColor: AppColors.accentYellow,
                    preferences: ['ฟังเพลงเบาๆ', 'ไม่สูบบุหรี่'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: _confirmed
                    ? null
                    : () => setState(() => _confirmed = true),
                icon: Icon(
                  _confirmed ? Icons.check_circle_rounded : Icons.check_rounded,
                  size: 21,
                ),
                label: Text(
                  _confirmed ? 'ยืนยันแล้ว' : 'ยืนยันเข้าร่วมทริป',
                  style: AppTypography.button.copyWith(fontSize: 18),
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
          ),
          const _TripMatchedBottomNavigation(),
        ],
      ),
    );
  }
}

class _TripMatchedHeader extends StatelessWidget {
  const _TripMatchedHeader({required this.routeLabel, required this.onBack});

  final String routeLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
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
              size: 27,
              color: AppColors.textSecondary,
            ),
            tooltip: 'ย้อนกลับ',
          ),
        ),
        SizedBox(
          width: 236,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'PaiDuayDi',
                    maxLines: 1,
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
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          right: 20,
          child: Icon(
            Icons.more_vert_rounded,
            size: 26,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.confirmed});

  final bool confirmed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    decoration: BoxDecoration(
      color: AppColors.primaryUltraLight,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.check_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                confirmed ? 'ยืนยันเข้าร่วมทริปแล้ว' : 'จับคู่สำเร็จแล้ว!',
                style: AppTypography.titleSmall.copyWith(fontSize: 17),
              ),
              Text(
                confirmed
                    ? 'คุณพร้อมเดินทางกับเพื่อนร่วมทาง'
                    : 'พบเพื่อนร่วมทาง 2 คน',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.origin,
    required this.destination,
    required this.originLocation,
    required this.destinationLocation,
    required this.route,
    required this.isLoadingRoute,
    required this.departure,
    required this.fare,
  });

  final String origin;
  final String destination;
  final LatLng? originLocation;
  final LatLng? destinationLocation;
  final RouteDetails? route;
  final bool isLoadingRoute;
  final String departure;
  final int fare;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      children: [
        _RouteStop(icon: Icons.radio_button_checked_rounded, name: origin),
        const SizedBox(height: 6),
        _RouteStop(icon: Icons.location_on_rounded, name: destination),
        const SizedBox(height: 13),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: double.infinity,
            height: 172,
            child: originLocation != null && destinationLocation != null
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: _TripMapPreview(
                          origin: originLocation!,
                          destination: destinationLocation!,
                          originName: origin,
                          destinationName: destination,
                          route: route,
                        ),
                      ),
                      if (isLoadingRoute)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: _MapStatus(label: 'กำลังโหลดเส้นทาง'),
                        )
                      else if (route == null)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: _MapStatus(label: 'ยังไม่พบเส้นทาง'),
                        ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Material(
                          color: Colors.white,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8),
                          child: IconButton(
                            tooltip: 'ขยายแผนที่',
                            icon: const Icon(Icons.fullscreen_rounded),
                            color: AppColors.textPrimary,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _FullScreenTripMap(
                                  origin: originLocation!,
                                  destination: destinationLocation!,
                                  originName: origin,
                                  destinationName: destination,
                                  route: route,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: AppColors.backgroundMuted,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'เลือกพิกัดจุดขึ้นรถและจุดหมายเพื่อแสดงแผนที่จริง',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _DetailChip(icon: Icons.schedule_rounded, label: departure),
            const _DetailChip(icon: Icons.people_alt_outlined, label: '3 คน'),
            _DetailChip(label: '$fare BAHT / คน', highlighted: true),
          ],
        ),
      ],
    ),
  );
}

class _RouteStop extends StatelessWidget {
  const _RouteStop({required this.icon, required this.name});

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.primaryLight, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          name.replaceFirst('จาก: ', ''),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.titleSmall.copyWith(fontSize: 13),
        ),
      ),
    ],
  );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({this.icon, required this.label, this.highlighted = false});

  final IconData? icon;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
    decoration: BoxDecoration(
      color: highlighted
          ? AppColors.primaryUltraLight
          : AppColors.backgroundMuted,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 3),
        ],
        Text(
          label,
          maxLines: 1,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: highlighted ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _TripMapPreview extends StatelessWidget {
  const _TripMapPreview({
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destinationName,
    required this.route,
  });

  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destinationName;
  final RouteDetails? route;

  Future<void> _fitMap(GoogleMapController controller) async {
    final points = [origin, destination, ...?route?.points];
    var south = points.first.latitude;
    var north = points.first.latitude;
    var west = points.first.longitude;
    var east = points.first.longitude;
    for (final point in points.skip(1)) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }
    if (north == south && east == west) {
      await controller.moveCamera(CameraUpdate.newLatLngZoom(origin, 15));
      return;
    }
    await controller.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GoogleMap(
    key: ValueKey(route?.encodedPolyline),
    initialCameraPosition: CameraPosition(
      target: LatLng(
        (origin.latitude + destination.latitude) / 2,
        (origin.longitude + destination.longitude) / 2,
      ),
      zoom: 12,
    ),
    onMapCreated: _fitMap,
    markers: {
      Marker(
        markerId: const MarkerId('trip-origin'),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'จุดขึ้นรถ', snippet: originName),
      ),
      Marker(
        markerId: const MarkerId('trip-destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: 'จุดหมาย', snippet: destinationName),
      ),
    },
    polylines: {
      if (route != null && route!.points.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('matched-trip-route'),
          points: route!.points,
          color: AppColors.primaryLight,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
    },
    mapToolbarEnabled: false,
    myLocationButtonEnabled: false,
    zoomControlsEnabled: false,
    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
    },
    scrollGesturesEnabled: true,
    zoomGesturesEnabled: true,
    rotateGesturesEnabled: false,
    tiltGesturesEnabled: false,
  );
}

class _FullScreenTripMap extends StatelessWidget {
  const _FullScreenTripMap({
    required this.origin,
    required this.destination,
    required this.originName,
    required this.destinationName,
    required this.route,
  });

  final LatLng origin;
  final LatLng destination;
  final String originName;
  final String destinationName;
  final RouteDetails? route;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('แผนที่เส้นทาง')),
    body: _TripMapPreview(
      origin: origin,
      destination: destination,
      originName: originName,
      destinationName: destinationName,
      route: route,
    ),
  );
}

class _MapStatus extends StatelessWidget {
  const _MapStatus({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
  );
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({
    required this.name,
    required this.initial,
    required this.rating,
    required this.rides,
    required this.avatarColor,
    required this.preferences,
  });

  final String name;
  final String initial;
  final String rating;
  final String rides;
  final Color avatarColor;
  final List<String> preferences;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 45,
              height: 45,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: avatarColor,
                    child: Text(
                      initial,
                      style: AppTypography.titleSmall.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: -1,
                    right: -1,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: AppColors.success,
                      child: Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleSmall.copyWith(fontSize: 17),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.accentYellow,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          '$rating · $rides',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              'ยืนยันตัวตน',
              style: AppTypography.bodySmall.copyWith(
                fontSize: 10,
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: [
            for (final preference in preferences)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMuted,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  preference,
                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

class _TripMatchedBottomNavigation extends StatelessWidget {
  const _TripMatchedBottomNavigation();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.borderLight)),
    ),
    child: SafeArea(
      top: false,
      child: const SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TripNavItem(icon: Icons.home_outlined, label: 'Home'),
            _TripNavItem(
              icon: Icons.route_outlined,
              label: 'My Trips',
              active: true,
            ),
            _TripNavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
            ),
            _TripNavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
          ],
        ),
      ),
    ),
  );
}

class _TripNavItem extends StatelessWidget {
  const _TripNavItem({
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
            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: color),
          ),
        ],
      ),
    );
  }
}
