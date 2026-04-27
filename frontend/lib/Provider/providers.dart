import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/api_service.dart';
import '../Models/models.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Auth Provider
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  AuthNotifier(this._api) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final response = await _api.login(email, password);
      final user = User.fromJson(response.data['user']);
      state = AuthState(user: user);
    } catch (e) {
      String message = 'Une erreur est survenue';
      if (e.toString().contains('401')) {
        message = 'Email ou mot de passe incorrect';
      } else if (e.toString().contains('connection error')) {
        message = 'Erreur de connexion au serveur';
      }
      state = AuthState(error: message);
    }
  }

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    state = AuthState(isLoading: true);
    try {
      final response = await _api.register(name, email, password, confirmPassword);
      final user = User.fromJson(response.data['user']);
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
      state = AuthState();
    } catch (e) {
      state = AuthState(); // Still logout locally
    }
  }

  Future<void> checkAuth() async {
    state = AuthState(isLoading: true);
    final userJson = await _api.getUser();
    if (userJson != null) {
      state = AuthState(user: User.fromJson(userJson));
    } else {
      state = AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

// Clocking Provider
class ClockNotifier extends StateNotifier<AsyncValue<List<Clocking>>> {
  final ApiService _api;
  ClockNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> clock(String type, String method) async {
    try {
      await _api.clock(type, method);
      fetchHistory();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchHistory() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getHistory();
      final list = (response.data as List).map((e) => Clocking.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final clockingProvider = StateNotifierProvider<ClockNotifier, AsyncValue<List<Clocking>>>((ref) {
  return ClockNotifier(ref.read(apiServiceProvider));
});

// Task Provider
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiService _api;
  TaskNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchTasks() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getTasks();
      final list = (response.data as List).map((e) => Task.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createTask(String title, String description) async {
    try {
      await _api.createTask(title, description);
      fetchTasks();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateStatus(String taskId, String status) async {
    try {
      await _api.updateTaskStatus(taskId, status);
      fetchTasks();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  return TaskNotifier(ref.read(apiServiceProvider));
});

// Schedule Provider
class ScheduleNotifier extends StateNotifier<AsyncValue<List<Schedule>>> {
  final ApiService _api;
  ScheduleNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchSchedules() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getSchedules();
      final list = (response.data as List).map((e) => Schedule.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, AsyncValue<List<Schedule>>>((ref) {
  return ScheduleNotifier(ref.read(apiServiceProvider));
});
// Stats Provider
class StatsNotifier extends StateNotifier<AsyncValue<UserStats>> {
  final ApiService _api;
  StatsNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchStats() async {
    try {
      final response = await _api.getMeStatus(); // I need to add this to ApiService
      state = AsyncValue.data(UserStats.fromJson(response.data));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final statsProvider = StateNotifierProvider<StatsNotifier, AsyncValue<UserStats>>((ref) {
  return StatsNotifier(ref.read(apiServiceProvider));
});

// Admin Providers
class AdminEmployeesNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final ApiService _api;
  AdminEmployeesNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchEmployees() async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getEmployees();
      final list = (response.data as List).map((e) => User.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final adminEmployeesProvider = StateNotifierProvider<AdminEmployeesNotifier, AsyncValue<List<User>>>((ref) {
  return AdminEmployeesNotifier(ref.read(apiServiceProvider));
});

class AdminStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ApiService _api;
  AdminStatsNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchGlobalStats() async {
    try {
      final response = await _api.getGlobalStats();
      state = AsyncValue.data(response.data);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final adminStatsProvider = StateNotifierProvider<AdminStatsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return AdminStatsNotifier(ref.read(apiServiceProvider));
});

class AdminUserHistoryNotifier extends StateNotifier<AsyncValue<List<Clocking>>> {
  final ApiService _api;
  AdminUserHistoryNotifier(this._api) : super(const AsyncValue.loading());

  Future<void> fetchUserHistory(String userId) async {
    state = const AsyncValue.loading();
    try {
      final response = await _api.getEmployeeHistory(userId);
      final list = (response.data as List).map((e) => Clocking.fromJson(e)).toList();
      state = AsyncValue.data(list);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final adminUserHistoryProvider = StateNotifierProvider<AdminUserHistoryNotifier, AsyncValue<List<Clocking>>>((ref) {
  return AdminUserHistoryNotifier(ref.read(apiServiceProvider));
});
