import 'package:riverpod/riverpod.dart';

import '../screens/screens.dart';

final tokenProvider =
    StateNotifierProvider<TokenNotifier, String?>((ref) => TokenNotifier());

class TokenNotifier extends StateNotifier<String?> {
  TokenNotifier() : super(null) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    state = await getToken();
  }

  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
    state = null;
  }

  Future<void> setToken(String token) async {
    await storage.write(key: 'token', value: token);
    state = token;
  }
}
