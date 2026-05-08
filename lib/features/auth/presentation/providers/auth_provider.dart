import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/auth/data/models/user_model.dart';

class AuthState {
  final bool isLoggedIn;
  final UserModel? user;

  const AuthState({this.isLoggedIn = false, this.user});

  AuthState copyWith({bool? isLoggedIn, UserModel? user}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void login(UserModel user) {
    state = state.copyWith(isLoggedIn: true, user: user);
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});
