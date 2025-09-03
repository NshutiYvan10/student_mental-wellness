import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'firebase_service.dart';

class AuthService {
  static fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;

  static Stream<fb.User?> authStateChanges() {
    if (!FirebaseService.isInitialized) {
      return const Stream<fb.User?>.empty();
    }
    return _auth.authStateChanges();
  }

  static Future<void> signInWithEmail(String email, String password) async {
    if (!FirebaseService.isInitialized) return;
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signUpWithEmail(String email, String password) async {
    if (!FirebaseService.isInitialized) return;
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    if (!FirebaseService.isInitialized) return;
    await _auth.signOut();
  }
}



