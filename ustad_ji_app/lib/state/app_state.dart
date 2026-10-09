import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_user.dart';

class AppState extends ChangeNotifier {
  UserModel? _user;
  bool _onboarded = false;

  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isWorker => _user?.role == 'worker';
  bool get onboarded => _onboarded;

  void completeOnboarding() {
    _onboarded = true;
    notifyListeners();
  }

  void login(dynamic user) {
    if (user is UserModel) {
      _user = user;
    } else if (user is AuthUser) {
      _user = UserModel(
        id: user.uid,
        name: user.fullName,
        phone: user.phone,
        role: user.role,
        skill: user.skill,
        city: user.city,
        rating: user.rating,
        totalJobs: user.totalJobs,
      );
    }
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void updateProfile({
    String? name,
    String? skill,
    String? city,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(name: name, skill: skill, city: city);
    notifyListeners();
  }
}

final appState = AppState();