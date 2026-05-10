import 'package:flutter/foundation.dart';
import '../domain/models/session_model.dart';
import '../domain/repositories/session_repository.dart';

class SessionProvider with ChangeNotifier {
  final SessionRepository _repository;
  SessionModel? _activeSession;
  String _activeSessionId = '';

  SessionProvider(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _activeSession = await _repository.getActiveSession();
    _activeSessionId = await _repository.getActiveSessionId();
    notifyListeners();
  }

  SessionModel? get activeSession => _activeSession;
  
  Future<List<SessionModel>> get sessions => _repository.getSessions();

  String get activeSessionId => _activeSessionId;

  Future<int> getUniqueFarmerCountForSession(String sessionId) {
    return _repository.getUniqueFarmerCountForSession(sessionId);
  }
}
