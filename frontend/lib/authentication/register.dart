import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/apis/user_api.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback? onTap;
  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  bool    _obscurePassword = true;
  bool    _isLoading       = false;
  String? _errorMessage;
  String  _gender          = 'male';
  File?   _pickedImage;

  static const _darkGreen   = Color(0xFF2D4A2D);
  static const _cream       = Color(0xFFF5F0E8);
  static const _inputBg     = Color(0xFFFFFFFF);
  static const _inputBorder = Color(0xFFDDD8CC);
  static const _textDark    = Color(0xFF1C2B1C);
  static const _textMuted   = Color(0xFF888070);

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> _register() async {
    // Clear old error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      setState(() => _errorMessage = 'Please select a profile photo.');
      return;
    }

    setState(() => _isLoading = true);

    bool success = false;

    try {
      final photoBytes    = await _pickedImage!.readAsBytes();
      final photoFilename = _pickedImage!.path.split('/').last;

      await UserApi.instance.createUser(
        username:      _usernameCtrl.text.trim(),
        email:         _emailCtrl.text.trim().toLowerCase(),
        password:      _passwordCtrl.text,
        phone:         _phoneCtrl.text.trim(),
        gender:        _gender,
        photoBytes:    photoBytes,
        photoFilename: photoFilename,
      );

      success = true; // ✅ mark success before finally runs

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString()
              // clean up nested exception prefix
              .replaceAll('Exception: ', '');
        });
      }
    } finally {
      // ✅ ALWAYS stop loading — no matter what happens
      if (mounted) setState(() => _isLoading = false);
    }

    // ✅ Show success dialog AFTER finally (loading already stopped)
    if (success && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _darkGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: _darkGreen, size: 44),
              ),
              const SizedBox(height: 18),
              const Text(
                'Account Created!',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome, ${_usernameCtrl.text.trim()}!\nYour account is ready.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    widget.onTap?.call();   // go to login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Sign In Now',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black87),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('New Member',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            )),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Hero image ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/book_hero.jpg'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xFF3D2B00),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Join Our Community',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          )),
                      const SizedBox(height: 6),
                      const Text(
                        'Open the door to a million stories. Begin\nyour next chapter with us.',
                        style: TextStyle(
                            fontSize: 13, color: _textMuted, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // ── Photo picker ───────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: _inputBorder,
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage!)
                                    : null,
                                child: _pickedImage == null
                                    ? const Icon(Icons.person_outline,
                                        size: 40, color: _textMuted)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                      color: _darkGreen,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt,
                                      size: 14, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text('Tap to upload photo',
                            style:
                                TextStyle(fontSize: 11, color: _textMuted)),
                      ),
                      const SizedBox(height: 20),

                      // ── Full Name ──────────────────────────────────────────
                      _label('Full Name'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _usernameCtrl,
                        hint: 'John Doe',
                        icon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Name is required';
                          if (v.trim().length < 3)
                            return 'At least 3 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Email ──────────────────────────────────────────────
                      _label('Email Address'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _emailCtrl,
                        hint: 'reader@library.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Email is required';
                          if (!v.contains('@') || !v.contains('.'))
                            return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Phone ──────────────────────────────────────────────
                      _label('Phone Number'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _phoneCtrl,
                        hint: '012 345 6789',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Phone is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // ── Gender ─────────────────────────────────────────────
                      _label('Gender'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _genderChip('male',   '👨 Male'),
                          const SizedBox(width: 10),
                          _genderChip('female', '👩 Female'),
                          const SizedBox(width: 10),
                          _genderChip('other',  '🧑 Other'),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Password ───────────────────────────────────────────
                      _label('Password'),
                      const SizedBox(height: 6),
                      _buildField(
                        controller: _passwordCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: _textMuted,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Password is required';
                          if (v.length < 6) return 'At least 6 characters';
                          return null;
                        },
                      ),

                      // ── Error banner ───────────────────────────────────────
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade600, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                      height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Submit button ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _register,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('📚',
                                  style: TextStyle(fontSize: 18)),
                          label: Text(
                            _isLoading
                                ? 'Creating Account...'
                                : 'Create Account',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already a member? ',
                              style:
                                  TextStyle(color: _textMuted, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    color: _darkGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Center(
                        child: Icon(Icons.menu_book_outlined,
                            size: 28, color: _inputBorder),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: _textDark));

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: _textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _inputBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _inputBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _darkGreen, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade300)),
      ),
    );
  }

  Widget _genderChip(String value, String label) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _darkGreen : _inputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? _darkGreen : _inputBorder, width: 1.5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _textMuted)),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}