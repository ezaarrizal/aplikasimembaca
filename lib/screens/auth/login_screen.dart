import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        // Navigate based on user role
        final user = authProvider.user!;
        String routeName;

        switch (user.role) {
          case 'guru':
            routeName = '/guru/dashboard';
            break;
          case 'siswa':
            routeName = '/siswa/dashboard';
            break;
          case 'orangtua':
            routeName = '/orangtua/dashboard';
            break;
          default:
            routeName = '/login';
        }

        Navigator.of(context).pushReplacementNamed(routeName);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Login gagal'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo/Icon
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'ACADEMIA (Aplikasi Membaca Dengan Media Interaktif Adaptif)',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              const Text(
                'Masuk untuk melanjutkan pembelajaran',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF636E72),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username Field
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Masukkan username',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Masukkan password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    CustomButton(
                      text: 'Masuk',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoAccount(String role, String username, String password) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$role:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$username / $password',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
