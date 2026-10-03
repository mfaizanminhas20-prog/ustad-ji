import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/job_response.dart';
import '../../services/contact_actions.dart';
import '../../theme/app_theme.dart';

class JobTrackingScreen extends StatefulWidget {
  final JobResponse result;
  const JobTrackingScreen({super.key, required this.result});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  final MapController _mapController = MapController();

  LatLng _customerPos = const LatLng(31.5204, 74.3587);
  LatLng _workerPos = const LatLng(31.5330, 74.3730);

  int _etaMinutes = 5;
  Timer? _moveTimer;
  Timer? _etaTimer;
  late String _workerPhone;

  @override
  void initState() {
    super.initState();
    _workerPhone =
        ContactActions.pickWorkerPhone(widget.result.workerBid.workerName);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initLocation();
      _startSimulation();
    });
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
        if (!mounted) return;
        setState(() {
          _customerPos = LatLng(pos.latitude, pos.longitude);
          _workerPos = LatLng(pos.latitude + 0.008, pos.longitude + 0.012);
        });
      }
    } catch (_) {}
    _recenter();
  }

  void _recenter() {
    try {
      _mapController.move(
        LatLng(
          (_customerPos.latitude + _workerPos.latitude) / 2,
          (_customerPos.longitude + _workerPos.longitude) / 2,
        ),
        14.5,
      );
    } catch (_) {}
  }

  void _startSimulation() {
    _moveTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) return;
      final latDiff = _customerPos.latitude - _workerPos.latitude;
      final lngDiff = _customerPos.longitude - _workerPos.longitude;

      setState(() {
        _workerPos = LatLng(
          _workerPos.latitude + latDiff * 0.10,
          _workerPos.longitude + lngDiff * 0.10,
        );
      });

      if (latDiff.abs() < 0.0003 && lngDiff.abs() < 0.0003) {
        t.cancel();
        _etaTimer?.cancel();
        if (mounted) setState(() => _etaMinutes = 0);
      }
    });

    _etaTimer = Timer.periodic(const Duration(seconds: 12), (t) {
      if (!mounted) return;
      if (_etaMinutes > 0) setState(() => _etaMinutes--);
    });
  }

  @override
  void dispose() {
    _moveTimer?.cancel();
    _etaTimer?.cancel();
    super.dispose();
  }

  Future<void> _call() async {
    final ok = await ContactActions.call(_workerPhone);
    if (!ok && mounted) {
      _snack('Could not open dialer on this device.');
    }
  }

  Future<void> _whatsapp() async {
    final ok = await ContactActions.whatsapp(
      _workerPhone,
      message:
          'Assalam o Alaikum ${widget.result.workerBid.workerName}, this is your customer from Ustad Ji. Are you on the way?',
    );
    if (!ok && mounted) {
      _snack('Could not open WhatsApp.');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final est = widget.result.estimatedPrice;
    final bid = widget.result.workerBid;
    final arrived = _etaMinutes == 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Live Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _workerPos,
                      initialZoom: 14.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.ustadji.app',
                        maxZoom: 19,
                      ),
                      PolylineLayer(polylines: [
                        Polyline(
                          points: [_workerPos, _customerPos],
                          color: AppColors.primary,
                          strokeWidth: 4,
                        ),
                      ]),
                      MarkerLayer(markers: [
                        Marker(
                          point: _workerPos,
                          width: 56,
                          height: 56,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.engineering,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        Marker(
                          point: _customerPos,
                          width: 48,
                          height: 48,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.danger, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.home,
                                color: AppColors.danger, size: 18),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: arrived ? AppColors.success : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            arrived
                                ? Icons.check_circle
                                : Icons.timer_outlined,
                            size: 14,
                            color:
                                arrived ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            arrived ? 'Arrived!' : 'ETA $_etaMinutes min',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: arrived
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: _recenter,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.my_location,
                            size: 16, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker card with call actions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.15),
                                child: const Icon(Icons.engineering,
                                    color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bid.workerName,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: AppColors.accent,
                                            size: 13),
                                        const SizedBox(width: 3),
                                        const Text('4.8 - 234 jobs',
                                            style: TextStyle(
                                                color:
                                                    AppColors.textSecondary,
                                                fontSize: 12)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets
                                                  .symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.success
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text('Verified',
                                              style: TextStyle(
                                                  color: AppColors.success,
                                                  fontSize: 9.5,
                                                  fontWeight:
                                                      FontWeight.w800)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined,
                                  size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(_workerPhone,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _call,
                                  icon: const Icon(Icons.phone, size: 18),
                                  label: const Text('Call'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                        color: AppColors.primary
                                            .withOpacity(0.3)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.sm),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _whatsapp,
                                  icon: const Icon(Icons.chat_bubble_outline,
                                      size: 18),
                                  label: const Text('WhatsApp'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.success,
                                    side: BorderSide(
                                        color: AppColors.success
                                            .withOpacity(0.3)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.sm),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 16),

                    // Price card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _row('Service', est.category),
                          const SizedBox(height: 12),
                          _row('Estimated',
                              '${est.currency} ${est.baselinePrice}'),
                          const SizedBox(height: 12),
                          _row(
                            'Final Bid',
                            bid.bidAmount != null
                                ? '${est.currency} ${bid.bidAmount}'
                                : '--',
                            valueColor: AppColors.success,
                            bold: true,
                          ),
                          const Divider(height: 28),
                          _row('Payment', 'Cash on completion',
                              valueColor: AppColors.textSecondary),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showRateSheet,
                        icon: const Icon(Icons.star_border, size: 18),
                        label: const Text('Rate This Ustad'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(
                              color: AppColors.accent.withOpacity(0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            const Text('How was your ustad?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child:
                      Icon(Icons.star, color: AppColors.accent, size: 38),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                child: const Text('Submit Review',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}