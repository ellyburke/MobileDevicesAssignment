import 'package:flutter/material.dart';
import 'package:dnd_app/userDatabase.dart';

class RegistrationForm extends StatefulWidget {
  final VoidCallback onRegistrationComplete;

  const RegistrationForm({super.key, required this.onRegistrationComplete});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _birthdayCtrl = TextEditingController();
  final TextEditingController _pronounsCtrl = TextEditingController();
  final TextEditingController _displayNameCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();

  bool _isLoading = false;

  // Regex for date validation (YYYY-MM-DD)
  final RegExp _dateRegex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$');

  // Regex for email validation
  final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  void _showSnack(String text, [Color? bg]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: bg));
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your birthday';
    }
    if (!_dateRegex.hasMatch(value)) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    
    // Additional validation for actual date validity
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      final date = DateTime(year, month, day);
      
      // Check if the parsed date matches the input (catches invalid dates like 2023-02-30)
      if (date.year != year || date.month != month || date.day != day) {
        return 'Please enter a valid date';
      }
      
      // Check if date is in the future
      if (date.isAfter(DateTime.now())) {
        return 'Birthday cannot be in the future';
      }
      
      // Check if user is at least 5 years old
      final minAge = DateTime.now().subtract(Duration(days: 5 * 365));
      if (date.isAfter(minAge)) {
        return 'You must be at least 5 years old';
      }
      
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordCtrl.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final username = _usernameCtrl.text.trim();
      
      // Check if username already exists
      final existingUser = await UserDatabase.instance.getUserByUsername(username);
      if (existingUser != null) {
        _showSnack('That username already exists.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // Parse the birthday
      final birthdayParts = _birthdayCtrl.text.split('-');
      final birthday = DateTime(
        int.parse(birthdayParts[0]),
        int.parse(birthdayParts[1]),
        int.parse(birthdayParts[2]),
      );

      // Create new user
      final newUser = User(
        id: null,
        username: username,
        password: _passwordCtrl.text,
        friends: [],
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        birthday: birthday,
        email: _emailCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim().isEmpty ? null : _displayNameCtrl.text.trim(),
        pronouns: _pronounsCtrl.text.trim().isEmpty ? null : _pronounsCtrl.text.trim(),
        profileImage: null,
      );
      
      await UserDatabase.instance.insertUser(newUser);
      _showSnack('Account created successfully! You can now log in.', Colors.green);
      
      // Clear form and return to login
      widget.onRegistrationComplete();
      
    } catch (e) {
      _showSnack('Registration failed: $e', Colors.red);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Create Your Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          
          // Required Fields
          TextFormField(
            controller: _usernameCtrl,
            decoration: InputDecoration(
              labelText: 'Username *',
              hintText: 'Choose a unique username'
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => _validateRequired(value, 'username'),
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _emailCtrl,
            decoration: InputDecoration(
              labelText: 'Email *',
              hintText: 'your.email@example.com'
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _firstNameCtrl,
            decoration: InputDecoration(
              labelText: 'First Name *',
              hintText: 'Your first name'
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => _validateRequired(value, 'first name'),
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _lastNameCtrl,
            decoration: InputDecoration(
              labelText: 'Last Name *',
              hintText: 'Your last name'
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => _validateRequired(value, 'last name'),
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _birthdayCtrl,
            decoration: InputDecoration(
              labelText: 'Birthday *',
              hintText: 'YYYY-MM-DD (e.g., 1990-05-15)',
              helperText: 'Format: YYYY-MM-DD'
            ),
            textInputAction: TextInputAction.next,
            validator: _validateDate,
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _passwordCtrl,
            decoration: InputDecoration(
              labelText: 'Password *',
              hintText: 'At least 6 characters'
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: _validatePassword,
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _confirmPasswordCtrl,
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              hintText: 'Re-enter your password'
            ),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: _validateConfirmPassword,
          ),
          SizedBox(height: 20),
          
          // Optional Fields
          Text('Optional Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _displayNameCtrl,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'What should we call you?'
            ),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _pronounsCtrl,
            decoration: InputDecoration(
              labelText: 'Pronouns',
              hintText: 'e.g., they/them, he/him, she/her'
            ),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 12),
          
          TextFormField(
            controller: _bioCtrl,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us about yourself...'
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 20),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRegistration,
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(48)),
              child: _isLoading
                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Create Account'),
            ),
          ),
          SizedBox(height: 8),
          
          Text(
            '* indicates required field',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthdayCtrl.dispose();
    _pronounsCtrl.dispose();
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }
}