import '../../domain/models/session_model.dart';
import '../../domain/repositories/session_repository.dart';
import '../../../../data/demo_catalog.dart';

class DemoSessionRepository implements SessionRepository {
  @override
  Future<SessionModel?> getActiveSession() async {
    return DemoCatalog.activeSession();
  }

  @override
  Future<List<SessionModel>> getSessions() async {
    return DemoCatalog.sessions;
  }

  @override
  Future<String> getActiveSessionId() async {
    return DemoCatalog.activeSessionId;
  }

  @override
  Future<int> getUniqueFarmerCountForSession(String sessionId) async {
    return DemoCatalog.uniqueFarmerCountForSession(sessionId);
  }
}
