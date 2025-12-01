import 'package:flutter/material.dart';
import 'package:dnd_app/databases/user_database.dart';
import 'package:dnd_app/main.dart';
import 'registration.dart'; // Import the new registration form

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _showRegistration = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String text, [Color? bg]) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
  }

  Future<void> _attemptLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Please enter both username and password.', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await UserDatabase.instance.getUserByUsername(username);

      if (user != null) {
        if (user.password == password) {
          // Successful login - navigate to HomePage with username
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(username: username),
            ),
          );
        } else {
          _showSnack('Incorrect password.', Colors.red);
        }
      } else {
        _showSnack('User not found. Please create an account.', Colors.orange);
      }
    } catch (e) {
      _showSnack('Login failed: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  void _toggleRegistration() {
    setState(() {
      _showRegistration = !_showRegistration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showRegistration ? 'Create Account' : 'Sign in'),
        backgroundColor: Color(0xFFA23E2E),
        leading: _showRegistration
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _toggleRegistration,
              )
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _showRegistration
                  ? RegistrationForm(
                      onRegistrationComplete: _toggleRegistration,
                    )
                  : LoginForm(
                      formKey: _formKey,
                      usernameCtrl: _usernameCtrl,
                      passwordCtrl: _passwordCtrl,
                      isLoading: _isLoading,
                      onLogin: _attemptLogin,
                      onToggleRegistration: _toggleRegistration,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onToggleRegistration;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.onLogin,
    required this.onToggleRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Welcome to D&D Companion', style: TextStyle(fontSize: 20)),
          SizedBox(height: 16),
          TextFormField(
            controller: usernameCtrl,
            decoration: InputDecoration(labelText: 'Username'),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: passwordCtrl,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            onFieldSubmitted: (_) => onLogin(),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
              child: isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Log in'),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggleRegistration,
                  child: Text('Create account'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Create an account or log in with existing credentials',
            ),
          ),
        ],
      ),
    );
  }
}
