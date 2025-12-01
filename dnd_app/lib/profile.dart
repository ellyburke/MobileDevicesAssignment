// profile.dart
import 'package:flutter/material.dart';
import 'package:dnd_app/user_database.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  final VoidCallback onBack;

  const ProfileScreen({
    Key? key,
    required this.username,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  // Controllers for editable fields
  final TextEditingController _displayNameCtrl = TextEditingController();
  final TextEditingController _bioCtrl = TextEditingController();
  final TextEditingController _pronounsCtrl = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await UserDatabase.instance.getUserByUsername(widget.username);
      setState(() {
        _user = user;
        _isLoading = false;
        
        // Initialize controllers with current data
        if (user != null) {
          _displayNameCtrl.text = user.displayName ?? '';
          _bioCtrl.text = user.bio ?? '';
          _pronounsCtrl.text = user.pronouns ?? '';
        }
      });
    } catch (e) {
      _showSnack('Error loading profile: $e', Colors.red);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnack(String text, [Color? bg]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: bg,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_user == null || !_formKey.currentState!.validate()) return;

    try {
      // Update user object with new values
      final updatedUser = User(
        id: _user!.id,
        username: _user!.username,
        password: _user!.password,
        friends: _user!.friends,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        birthday: _user!.birthday,
        email: _user!.email,
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        displayName: _displayNameCtrl.text.trim().isEmpty ? null : _displayNameCtrl.text.trim(),
        pronouns: _pronounsCtrl.text.trim().isEmpty ? null : _pronounsCtrl.text.trim(),
        profileImage: _user!.profileImage,
      );

      await UserDatabase.instance.updateUser(updatedUser);
      
      setState(() {
        _user = updatedUser;
        _isEditing = false;
      });
      
      _showSnack('Profile updated successfully!', Colors.green);
    } catch (e) {
      _showSnack('Error saving profile: $e', Colors.red);
    }
  }

  void _toggleEditMode() {
    if (_isEditing) {
      // Cancel editing - reset to original values
      if (_user != null) {
        _displayNameCtrl.text = _user!.displayName ?? '';
        _bioCtrl.text = _user!.bio ?? '';
        _pronounsCtrl.text = _user!.pronouns ?? '';
      }
    }
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B4E24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          isMultiline
              ? Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(fontSize: 16),
                )
              : Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
          Divider(color: Color(0xFFC2A878), height: 20),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B4E24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: isMultiline ? 3 : 1,
            validator: validator,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFFA23E2E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_isEditing) {
              // Confirm if they want to discard changes
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Discard changes?'),
                  content: Text('Any unsaved changes will be lost.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleEditMode();
                        widget.onBack();
                      },
                      child: Text('Discard'),
                    ),
                  ],
                ),
              );
            } else {
              widget.onBack();
            }
          },
        ),
        actions: [
          if (!_isLoading && _user != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
              onPressed: _toggleEditMode,
              tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Text(
                    'User not found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Header
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xFFC2A878),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFF4EBD0),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                _user!.displayName ?? '${_user!.firstName} ${_user!.lastName}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA23E2E),
                                ),
                              ),
                              Text(
                                '@${_user!.username}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              if (_user!.pronouns != null && _user!.pronouns!.isNotEmpty)
                                Chip(
                                  label: Text(
                                    _user!.pronouns!,
                                    style: TextStyle(color: Color(0xFF6B4E24)),
                                  ),
                                  backgroundColor: Color(0xFFC2A878),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Profile Information
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA23E2E),
                          ),
                        ),
                        SizedBox(height: 16),

                        if (_isEditing) ...[
                          // Editable form
                          _buildEditableField(
                            label: 'Display Name',
                            controller: _displayNameCtrl,
                          ),
                          _buildEditableField(
                            label: 'Pronouns',
                            controller: _pronounsCtrl,
                          ),
                          _buildEditableField(
                            label: 'Bio',
                            controller: _bioCtrl,
                            isMultiline: true,
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFA23E2E),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ] else ...[
                          // Read-only view
                          _buildInfoRow('Display Name', _user!.displayName ?? 'Not set'),
                          _buildInfoRow('First Name', _user!.firstName),
                          _buildInfoRow('Last Name', _user!.lastName),
                          _buildInfoRow('Email', _user!.email),
                          _buildInfoRow(
                            'Birthday',
                            '${_user!.birthday.year}-${_user!.birthday.month.toString().padLeft(2, '0')}-${_user!.birthday.day.toString().padLeft(2, '0')}',
                          ),
                          _buildInfoRow('Pronouns', _user!.pronouns ?? 'Not specified'),
                          _buildInfoRow('Bio', _user!.bio ?? 'Not specified', isMultiline: true),
                          SizedBox(height: 20),
                          Divider(color: Color(0xFFC2A878), thickness: 2),
                          SizedBox(height: 20),

                          // Account Stats Section
                          Text(
                            'Account Stats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA23E2E),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // Friends count
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _user!.friends.length.toString(),
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B4E24),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Friends',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _bioCtrl.dispose();
    _pronounsCtrl.dispose();
    super.dispose();
  }
}