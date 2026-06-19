import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw 'Impossible de se connecter pour le moment.';
      }

      final user = await _getUserData(credential.user!.uid);
      if (user == null) {
        throw 'Aucun profil utilisateur trouvé.';
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AppUser> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw 'Impossible de créer le compte.';
      }

      final uid = credential.user!.uid;
      await _createUserData(uid, email, name, 'client');
      final createdUser = await _getUserData(uid);

      if (createdUser == null) {
        throw 'Erreur lors de la création du profil utilisateur.';
      }

      return createdUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AppUser> createCashier(String email, String password, String name) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw 'Impossible de créer le caissier.';
      }

      final uid = credential.user!.uid;
      await _createUserData(uid, email, name, 'cashier');
      final createdUser = await _getUserData(uid);
      if (createdUser == null) {
        throw 'Erreur lors de la création du profil du caissier.';
      }
      return createdUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUserData(String uid) => _getUserData(uid);

  Future<AppUser?> updateUserProfile({
    required String uid,
    String? name,
    String? phone,
    String? address,
    String? role,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (phone != null) updateData['phone'] = phone;
    if (address != null) updateData['address'] = address;
    if (role != null) updateData['role'] = role;

    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updateData);
    }

    return getUserData(uid);
  }

  Future<AppUser?> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> _createUserData(String uid, String email, String name, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'name': name,
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'weak-password':
        return 'Le mot de passe doit contenir au moins 6 caractères';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect';
      default:
        return 'Une erreur s\'est produite: ${e.message}';
    }
  }
}
