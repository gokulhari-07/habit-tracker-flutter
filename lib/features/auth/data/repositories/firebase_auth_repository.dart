import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onward/features/auth/domain/entities/user_entity.dart';
import 'package:onward/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;

      return UserEntity(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );
    });
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final user = userCredential.user;

    if (user == null) return null;

    return UserEntity(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}