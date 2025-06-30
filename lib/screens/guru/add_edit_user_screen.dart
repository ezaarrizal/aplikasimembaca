import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_management_provider.dart';
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddEditUserScreen extends StatefulWidget {
  final User? user; // null for add, User object for edit

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController = TextEditingController();

  String _selectedRole = 'siswa';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _populateFields();
    }
  }

  void _populateFields() {
    final user = widget.user!;
    _usernameController.text = user.username;
    _namaController.text = user.nama;
    _selectedRole = user.role;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit User' : 'Tambah User'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.person_add,
                            color: const Color(0xFF6C63FF),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit
                                    ? 'Edit Pengguna'
                                    : 'Tambah Pengguna Baru',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEdit
                                    ? 'Ubah informasi pengguna yang sudah ada'
                                    : 'Isi form dibawah untuk menambah pengguna baru',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF636E72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Pengguna',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nama
                    CustomTextField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Username
                    CustomTextField(
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Masukkan username',
                      prefixIcon: Icons.alternate_email,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }
                        if (value.trim().length < 3) {
                          return 'Username minimal 3 karakter';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$')
                            .hasMatch(value.trim())) {
                          return 'Username hanya boleh mengandung huruf, angka, dan underscore';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Role Selection
                    const Text(
                      'Role Pengguna',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDD6FE)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildRoleOption('guru', 'Guru', Icons.school,
                              const Color(0xFF6C63FF)),
                          const Divider(height: 1),
                          _buildRoleOption('siswa', 'Siswa', Icons.face,
                              const Color(0xFF00B894)),
                          const Divider(height: 1),
                          _buildRoleOption('orangtua', 'Orangtua',
                              Icons.family_restroom, const Color(0xFFE17055)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Password Section
                    Text(
                      isEdit
                          ? 'Ubah Password (Kosongkan jika tidak ingin mengubah)'
                          : 'Password',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomTextField(
                      controller: _passwordController,
                      label: isEdit ? 'Password Baru' : 'Password',
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
                        if (!isEdit && (value == null || value.isEmpty)) {
                          return 'Password wajib diisi';
                        }
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Masukkan ulang password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isPasswordVisible: _isConfirmPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (_passwordController.text.isNotEmpty) {
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Batal',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.grey.shade300,
                      textColor: const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: isEdit ? 'Simpan Perubahan' : 'Tambah User',
                      onPressed: _isLoading ? null : _handleSubmit,
                      isLoading: _isLoading,
                      backgroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(
      String role, String title, IconData icon, Color color) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? color : const Color(0xFF2D3436),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider =
        Provider.of<UserManagementProvider>(context, listen: false);
    bool success;

    try {
      if (isEdit) {
        success = await provider.updateUser(
          userId: widget.user!.id,
          username: _usernameController.text.trim(),
          password: _passwordController.text.isEmpty
              ? null
              : _passwordController.text,
          nama: _namaController.text.trim(),
          role: _selectedRole,
        );
      } else {
        success = await provider.createUser(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          nama: _namaController.text.trim(),
          role: _selectedRole,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit
                  ? 'User berhasil diupdate'
                  : 'User berhasil ditambahkan'),
              backgroundColor: const Color(0xFF00B894),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Terjadi kesalahan'),
              backgroundColor: const Color(0xFFE17055),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: const Color(0xFFE17055),
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}
