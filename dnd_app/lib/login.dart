import 'package:flutter/material.dart';
import 'package:dnd_app/userDatabase.dart'; 
import 'package:dnd_app/main.dart'; 

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

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String text, [Color? bg]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
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
        _showSnack('User not found. Create an account or try again.', Colors.orange);
      }
    } catch (e) {
      _showSnack('Login failed: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  void _createAccount() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Enter both username and password to create an account.', Colors.red);
      return;
    }

    try {
      final existingUser = await UserDatabase.instance.getUserByUsername(username);
      if (existingUser != null) {
        _showSnack('That username already exists.', const Color.fromARGB(255, 215, 36, 23));
        return;
      }

      final newUser = User(null, username, password, []);
      await UserDatabase.instance.insertUser(newUser);
      _showSnack('Account created for "$username". You can now log in.', Colors.green);
    } catch (e) {
      _showSnack('Account creation failed: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in'),
        backgroundColor: Color(0xFFA23E2E),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Welcome to D&D Companion', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: InputDecoration(labelText: 'Username'),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onFieldSubmitted: (_) => _attemptLogin(),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _attemptLogin,
                        style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
                        child: _isLoading
                            ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Log in'),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _createAccount,
                            child: Text('Create account'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 8),
                    // Removed the known users list since we're using database now
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Create an account or log in with existing credentials'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


