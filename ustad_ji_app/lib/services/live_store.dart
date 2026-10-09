import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/api_job.dart';
import 'job_api_service.dart';

/// Polls the backend every N seconds and notifies listeners when
/// the open-jobs list changes. Powers the worker feed.
class LiveStore extends ChangeNotifier {
  List<ApiJob> _openJobs = [];
  bool _loading = false;
  bool _backendUp = false;
  Timer? _pollTimer;

  List<ApiJob> get openJobs => _openJobs;
  bool get loading => _loading;
  bool get backendUp => _backendUp;

  void start({Duration interval = const Duration(seconds: 4)}) {
    _pollTimer?.cancel();
    _refresh();
    _pollTimer = Timer.periodic(interval, (_) => _refresh());
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refreshNow() => _refresh();

  Future<void> _refresh() async {
    _loading = true;
    _backendUp = await JobApiService.isBackendUp();
    if (_backendUp) {
      final jobs = await JobApiService.listOpenJobs();
      _openJobs = jobs;
    }
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

/// Global singleton — the app shares one polling loop.
final liveStore = LiveStore();