import 'package:flutter/material.dart';
import 'package:flutter_finger/user_data_base.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHomePage extends StatefulWidget {
  @override
  _AuthHomePageState createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final UserDatabaseHelper _dbHelper = UserDatabaseHelper();

  bool _isAuthenticated = false;
  String _dbStatusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    checkUserInDatabase();
  }

  Future<void> _checkBiometrics() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    final hasBiometrics = await _auth.isDeviceSupported();
    if (!canCheckBiometrics || !hasBiometrics) {
      setState(() {
        _dbStatusMessage = 'This device does not support biometrics.';
      });
    }
  }

  Future<void> checkUserInDatabase() async {
    String? userId = await _secureStorage.read(key: 'user_id');
    if (userId != null) {
      List<Map<String, dynamic>> result = await _dbHelper.getUser(userId);
      setState(() {
        _isAuthenticated = result.isNotEmpty;
        _dbStatusMessage = _isAuthenticated ? 'User ID found: $userId' : 'No user found';
      });
    } else {
      setState(() {
        _dbStatusMessage = 'No user ID stored';
      });
    }
  }

  Future<void> _signupWithFingerprint() async {
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to sign up',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        String userId = DateTime.now().millisecondsSinceEpoch.toString();
        await _dbHelper.insertUser(userId);
        await _secureStorage.write(key: 'user_id', value: userId);

        setState(() {
          _isAuthenticated = true;
          _dbStatusMessage = 'Signup successful. User ID stored: $userId';
        });
      }
    } catch (e) {
      setState(() {
        _dbStatusMessage = 'Error during signup: $e';
      });
    }
  }

  Future<void> _loginWithFingerprint() async {
    try {
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to log in',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        checkUserInDatabase();
      }
    } catch (e) {
      setState(() {
        _dbStatusMessage = 'Error during login: $e';
      });
    }
  }

  Future<void> _logout() async {
    await _secureStorage.delete(key: 'user_id');
    setState(() {
      _isAuthenticated = false;
      _dbStatusMessage = 'Logged out';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isAuthenticated ? 'Welcome' : 'Fingerprint Auth'),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout,
            )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isAuthenticated
                ? Text('You are authenticated!', style: TextStyle(fontSize: 24))
                : Column(
              children: [
                ElevatedButton(
                  onPressed: _signupWithFingerprint,
                  child: Text('Sign Up with Fingerprint'),
                ),
                ElevatedButton(
                  onPressed: _loginWithFingerprint,
                  child: Text('Login with Fingerprint'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkUserInDatabase,
              child: Text('Check User in Database'),
            ),
            if (_dbStatusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  _dbStatusMessage,
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
