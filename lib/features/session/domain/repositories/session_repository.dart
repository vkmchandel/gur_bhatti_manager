import '../models/session_model.dart';

abstract class SessionRepository {
  Future<SessionModel?> getActiveSession();
  Future<List<SessionModel>> getSessions();
  Future<String> getActiveSessionId();
  Future<int> getUniqueFarmerCountForSession(String sessionId);
}
