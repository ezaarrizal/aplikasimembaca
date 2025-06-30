// lib/screens/guru/guru_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart'; // 👈 NEW
import '../../widgets/role_card.dart';

class GuruDashboard extends StatefulWidget {
  // 👈 CHANGED to StatefulWidget
  const GuruDashboard({super.key});

  @override
  State<GuruDashboard> createState() => _GuruDashboardState();
}

class _GuruDashboardState extends State<GuruDashboard> {
  @override
  void initState() {
    super.initState();
    // 👈 NEW: Load feedback stats when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedbackProvider =
          Provider.of<FeedbackProvider>(context, listen: false);
      feedbackProvider.loadFeedbacks(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.user?.nama ?? 'Guru',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kelola pembelajaran siswa dengan mudah',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 16),

            // Menu Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                RoleCard(
                  title: 'Kelola Akun',
                  subtitle: 'Tambah & edit akun siswa/orangtua',
                  icon: Icons.group,
                  color: const Color(0xFF00B894),
                  onTap: () {
                    Navigator.pushNamed(context, '/guru/manage-users');
                  },
                ),

                // 👈 ENHANCED: Feedback card with counter
                Consumer<FeedbackProvider>(
                  builder: (context, feedbackProvider, child) {
                    return RoleCard(
                      title: 'Feedback',
                      subtitle: feedbackProvider.feedbacks.isNotEmpty
                          ? '${feedbackProvider.feedbacks.length} feedback dibuat'
                          : 'Berikan feedback ke siswa',
                      icon: Icons.feedback,
                      color: const Color(0xFFE17055),
                      badge: feedbackProvider.feedbacks.isNotEmpty
                          ? feedbackProvider.feedbacks.length.toString()
                          : null, // 👈 NEW: Badge for feedback count
                      onTap: () {
                        Navigator.pushNamed(context, '/guru/feedback');
                      },
                    );
                  },
                ),
              ],
            ),

            // 👈 NEW: Quick Stats Section (Optional)
            const SizedBox(height: 24),

            Consumer<FeedbackProvider>(
              builder: (context, feedbackProvider, child) {
                if (feedbackProvider.feedbacks.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
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
                        'Statistik Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              'Total',
                              feedbackProvider.feedbacks.length.toString(),
                              const Color(0xFF6C63FF),
                              Icons.feedback,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Positif',
                              feedbackProvider.feedbacks
                                  .where((f) => f.tingkat == 'positif')
                                  .length
                                  .toString(),
                              const Color(0xFF00B894),
                              Icons.thumb_up,
                            ),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              'Perlu Perhatian',
                              feedbackProvider.feedbacks
                                  .where((f) => f.tingkat == 'perlu_perhatian')
                                  .length
                                  .toString(),
                              const Color(0xFFE17055),
                              Icons.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 👈 NEW: Helper method for statistics
  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
