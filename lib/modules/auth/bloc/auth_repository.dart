part of 'auth_bloc.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  Future<AuthResult> register(AuthEventRegister event) async {
    try {
      final snapshotUsername = await _firestore
          .collection('users')
          .where('username', isEqualTo: event.username)
          .snapshots()
          .first;

      final snapshotEmail = await _firestore
          .collection('users')
          .where('email', isEqualTo: event.email)
          .snapshots()
          .first;

      final snapshotPhone = await _firestore
          .collection('users')
          .where('phone', isEqualTo: event.phone)
          .snapshots()
          .first;

      final username = snapshotUsername.documents.isNotEmpty;
      final email = snapshotEmail.documents.isNotEmpty;
      final phone = snapshotPhone.documents.isNotEmpty;

      if (username) {
        toastError(
            tr('auth_screen.msg_usr_error_registered', args: ['Username']));
        return null;
      } else if (email) {
        toastError(tr('auth_screen.msg_usr_error_registered', args: ['Email']));
        return null;
      } else if (phone) {
        toastError(tr('auth_screen.msg_usr_error_registered', args: ['Phone']));
        return null;
      }

      return await _registerUser2Firestore(event);
    } on SocketException {
      toastError(tr('error.no_connection'));
      return null;
    }
  }

  Future<AuthResult> _registerUser2Firestore(AuthEventRegister event) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: event.email, password: event.password);

      final doc = await _firestore.collection('users').add({
        'email': event.email,
        'phone': event.phone,
        'username': event.username,
        'credentials': ['owner']
      });

      toastSuccess(tr('auth_screen.msg_usr_success_registered',
          args: [event.username.capitalize()]));

      final storage = FlutterSecureStorage();
      await storage.write(key: kUserDocIdKey, value: doc.documentID);

      return result;
    } on PlatformException catch (err) {
      toastError(err.message);
      return null;
    }
  }

  Future<AuthResult> login(AuthEventLogin event) async {
    try {
      final snapshotEmail = await _firestore
          .collection('users')
          .where('username', isEqualTo: event.username)
          .getDocuments();

      final hasEmail = snapshotEmail.documents.isNotEmpty;

      if (!hasEmail) {
        toastError(tr('auth_screen.msg_username_error_login',
            args: [event.username.capitalize()]));
        return null;
      }

      return await _loginUser2Firestore(
          event,
          snapshotEmail.documents.first.data['email'],
          snapshotEmail.documents.first.documentID,
          snapshotEmail.documents.first.data['credentials'],
          snapshotEmail.documents.first.data['store']);
    } on SocketException {
      toastError(tr('error.no_connection'));
      return null;
    }
  }

  Future<AuthResult> _loginUser2Firestore(AuthEventLogin event, String email,
      String docId, List creds, String storeId) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: event.password);

      toastSuccess(tr('auth_screen.msg_usr_success_login',
          args: [event.username.capitalize()]));

      final storage = FlutterSecureStorage();
      await storage.write(key: kUserDocIdKey, value: docId);
      creds.forEach((element) async {
        await storage.write(key: element, value: element);
      });
      if (storeId != null) {
        await storage.write(key: kDefaultStore, value: storeId);
      }

      return result;
    } on PlatformException catch (err) {
      toastError(err.message);
      return null;
    }
  }
}
