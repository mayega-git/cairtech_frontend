import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/api_exception.dart';
import 'auth_repository.dart';
import 'current_user.dart';

// ─── Events ───────────────────────────────────────────────────────────
sealed class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => const [];
}

class AuthBootstrapRequested extends AuthEvent {
  const AuthBootstrapRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthSessionAvailable extends AuthEvent {
  final CurrentUser user;
  const AuthSessionAvailable(this.user);
  @override
  List<Object?> get props => [user];
}

// ─── State ────────────────────────────────────────────────────────────
sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => const [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthInProgress extends AuthState {
  const AuthInProgress();
}

class AuthAuthenticated extends AuthState {
  final CurrentUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? message;
  const AuthUnauthenticated([this.message]);
  @override
  List<Object?> get props => [message];
}

// ─── Bloc ─────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<AuthBootstrapRequested>(_onBootstrap);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionAvailable>((e, emit) => emit(AuthAuthenticated(e.user)));
  }

  Future<void> _onBootstrap(
      AuthBootstrapRequested event, Emitter<AuthState> emit) async {
    emit(const AuthInProgress());
    final user = await repository.restoreSession();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthInProgress());
    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on ApiException catch (e) {
      emit(AuthUnauthenticated(e.message));
    } catch (e) {
      // Couvre les DioException qui ne sont pas (encore) mappées par l'interceptor
      // ainsi que les erreurs réseau bas-niveau.
      final dynamic err = e;
      try {
        final inner = err.error;
        if (inner is ApiException) {
          emit(AuthUnauthenticated(inner.message));
          return;
        }
      } catch (_) {}
      emit(const AuthUnauthenticated('Connexion impossible — vérifie le réseau.'));
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthUnauthenticated());
  }
}
