import 'package:flutter/foundation.dart';

/// A single active job shared between customer and worker views.
/// Simulates the backend job queue / WebSocket channel.
class ActiveJob {
  final String id;
  final String description;
  final String category;
  final int baselinePrice;
  final int bidAmount;
  final String customerName;
  final String customerPhone;
  final String workerName;
  final String workerPhone;
  final String address;
  final DateTime createdAt;

  ActiveJob({
    required this.id,
    required this.description,
    required this.category,
    required this.baselinePrice,
    required this.bidAmount,
    required this.customerName,
    required this.customerPhone,
    required this.workerName,
    required this.workerPhone,
    required this.address,
    required this.createdAt,
  });
}

class JobStore extends ChangeNotifier {
  ActiveJob? _activeJob;
  final List<ActiveJob> _history = [];

  ActiveJob? get activeJob => _activeJob;
  List<ActiveJob> get history => List.unmodifiable(_history);

  void postJob(ActiveJob job) {
    _activeJob = job;
    notifyListeners();
  }

  void completeJob() {
    if (_activeJob != null) {
      _history.insert(0, _activeJob!);
      _activeJob = null;
      notifyListeners();
    }
  }

  void clear() {
    _activeJob = null;
    _history.clear();
    notifyListeners();
  }
}

/// Global singleton — shared across the app for the demo.
final jobStore = JobStore();