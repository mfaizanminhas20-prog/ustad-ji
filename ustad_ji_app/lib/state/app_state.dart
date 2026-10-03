import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

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

  void login(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

final appState = AppState();
