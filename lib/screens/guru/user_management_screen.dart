import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_management_provider.dart';
import '../../models/user.dart';
import '../../models/user_statistics.dart';
import '../../widgets/custom_button.dart';
import 'add_edit_user_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserManagementProvider>(context, listen: false);
      provider.loadUsers(refresh: true);
      provider.loadStatistics();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<UserManagementProvider>(context, listen: false).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kelola Akun'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddUser,
          ),
        ],
      ),
      body: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Statistics Card
              if (provider.statistics != null) _buildStatisticsCard(provider.statistics!),
              
              // Filters
              _buildFilters(provider),
              
              // User List
              Expanded(
                child: _buildUserList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUser,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatisticsCard(UserStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
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
            'Statistik Pengguna',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats.totalUsers.toString(),
                  const Color(0xFF6C63FF),
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Aktif',
                  stats.activeUsers.toString(),
                  const Color(0xFF00B894),
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Nonaktif',
                  stats.inactiveUsers.toString(),
                  const Color(0xFFE17055),
                  Icons.cancel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Guru',
                  stats.byRole['guru'].toString(),
                  const Color(0xFF6C63FF),
                  Icons.school,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Siswa',
                  stats.byRole['siswa'].toString(),
                  const Color(0xFF00B894),
                  Icons.face,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Orangtua',
                  stats.byRole['orangtua'].toString(),
                  const Color(0xFFE17055),
                  Icons.family_restroom,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(UserManagementProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFDDD6FE), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari berdasarkan nama atau username...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              provider.setSearchQuery(value);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  'Semua Role',
                  provider.selectedRole == 'all',
                  () => provider.setRoleFilter('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Guru',
                  provider.selectedRole == 'guru',
                  () => provider.setRoleFilter('guru'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Siswa',
                  provider.selectedRole == 'siswa',
                  () => provider.setRoleFilter('siswa'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  'Orangtua',
                  provider.selectedRole == 'orangtua',
                  () => provider.setRoleFilter('orangtua'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF636E72),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildUserList(UserManagementProvider provider) {
    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Coba Lagi',
              onPressed: () => provider.loadUsers(refresh: true),
            ),
          ],
        ),
      );
    }

    if (provider.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pengguna ditemukan',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.users.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.users.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = provider.users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    Color roleColor;
    IconData roleIcon;

    switch (user.role) {
      case 'guru':
        roleColor = const Color(0xFF6C63FF);
        roleIcon = Icons.school;
        break;
      case 'siswa':
        roleColor = const Color(0xFF00B894);
        roleIcon = Icons.face;
        break;
      case 'orangtua':
        roleColor = const Color(0xFFE17055);
        roleIcon = Icons.family_restroom;
        break;
      default:
        roleColor = const Color(0xFF6C63FF);
        roleIcon = Icons.person;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: roleColor.withOpacity(0.2),
          child: Icon(roleIcon, color: roleColor),
        ),
        title: Text(
          user.nama,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('@${user.username}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.roleDisplayName,
                    style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isActive ? const Color(0xFF00B894).withOpacity(0.1) : const Color(0xFFE17055).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.statusDisplayName,
                    style: TextStyle(
                      color: user.isActive ? const Color(0xFF00B894) : const Color(0xFFE17055),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'toggle_status',
              child: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleUserAction(value.toString(), user),
        ),
      ),
    );
  }

  void _handleUserAction(String action, User user) {
    final provider = Provider.of<UserManagementProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        _navigateToEditUser(user);
        break;
      case 'toggle_status':
        _confirmToggleStatus(user, provider);
        break;
      case 'delete':
        _confirmDelete(user, provider);
        break;
    }
  }

  void _navigateToAddUser() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditUserScreen(),
      ),
    );
  }

  void _navigateToEditUser(User user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditUserScreen(user: user),
      ),
    );
  }

  void _confirmToggleStatus(User user, UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.isActive ? 'Nonaktifkan' : 'Aktifkan'} User'),
        content: Text(
          'Apakah Anda yakin ingin ${user.isActive ? 'menonaktifkan' : 'mengaktifkan'} user ${user.nama}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog
              Navigator.pop(context);
              
              // Perform toggle operation
              final success = await provider.toggleUserStatus(user.id);
              
              // Show result only if widget is still mounted
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Status user berhasil diubah'
                          : provider.errorMessage ?? 'Gagal mengubah status user',
                    ),
                    backgroundColor: success ? const Color(0xFF00B894) : const Color(0xFFE17055),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(
              user.isActive ? 'Nonaktifkan' : 'Aktifkan',
              style: TextStyle(
                color: user.isActive ? const Color(0xFFE17055) : const Color(0xFF00B894),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(User user, UserManagementProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text(
          'Apakah Anda yakin ingin menghapus user ${user.nama}? User akan dinonaktifkan dan tidak dapat login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              // Close confirmation dialog
              Navigator.pop(context);
              
              // Perform delete operation
              final success = await provider.deleteUser(user.id);
              
              // Show result only if widget is still mounted
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'User berhasil dihapus'
                          : provider.errorMessage ?? 'Gagal menghapus user',
                    ),
                    backgroundColor: success ? const Color(0xFF00B894) : const Color(0xFFE17055),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFE17055)),
            ),
          ),
        ],
      ),
    );
  }
}