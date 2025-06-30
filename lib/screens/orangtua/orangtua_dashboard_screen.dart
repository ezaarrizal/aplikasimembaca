// lib/screens/orangtua/orangtua_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feedback_provider.dart';

class OrangtuaDashboardScreen extends StatefulWidget {
  const OrangtuaDashboardScreen({super.key});

  @override
  State<OrangtuaDashboardScreen> createState() =>
      _OrangtuaDashboardScreenState();
}

class _OrangtuaDashboardScreenState extends State<OrangtuaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: OrangtuaDashboard initState');

    // Load feedback untuk get unread count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔍 DEBUG: About to load feedbacks for parent');
      try {
        final feedbackProvider =
            Provider.of<FeedbackProvider>(context, listen: false);
        feedbackProvider.loadFeedbacksForParent(refresh: true);
        print('✅ DEBUG: loadFeedbacksForParent called successfully');
      } catch (e) {
        print('💥 DEBUG: Error in loadFeedbacksForParent: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Dashboard Orangtua'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug button di AppBar
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              print('🔍 DEBUG: AppBar test button pressed');
              try {
                Navigator.pushNamed(context, '/orangtua/feedback');
                print('✅ DEBUG: AppBar navigation success');
              } catch (e) {
                print('💥 DEBUG: AppBar navigation failed: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigation Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                print('💥 DEBUG: Logout error: $e');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.nama ?? 'Orangtua',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pantau perkembangan belajar anak Anda',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Section
            const Text(
              'Menu Utama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),

            const SizedBox(height: 16),
            // Feedback Menu Card dengan Consumer
            Consumer<FeedbackProvider>(
              builder: (context, feedbackProvider, child) {
                print(
                    '🔍 DEBUG: Consumer rebuild - Unread count: ${feedbackProvider.unreadCount}');
                print(
                    '🔍 DEBUG: Consumer rebuild - Loading: ${feedbackProvider.isLoading}');
                print(
                    '🔍 DEBUG: Consumer rebuild - Error: ${feedbackProvider.errorMessage}');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      print('🔍 DEBUG: Feedback card tapped!');
                      try {
                        print('🔍 DEBUG: About to call Navigator.pushNamed');
                        Navigator.pushNamed(context, '/orangtua/feedback');
                        print('✅ DEBUG: Navigation called successfully');
                      } catch (e) {
                        print('💥 DEBUG: Navigation error: $e');
                        print('💥 DEBUG: Error type: ${e.runtimeType}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error navigation: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    const Color(0xFFE17055).withOpacity(0.2),
                                radius: 24,
                                child: const Icon(
                                  Icons.feedback,
                                  color: Color(0xFFE17055),
                                  size: 28,
                                ),
                              ),
                              // Unread badge
                              if (feedbackProvider.unreadCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE17055),
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    child: Text(
                                      feedbackProvider.unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Feedback Dari Guru',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  feedbackProvider.isLoading
                                      ? 'Loading...'
                                      : feedbackProvider.errorMessage != null
                                          ? 'Error: ${feedbackProvider.errorMessage}'
                                          : feedbackProvider.unreadCount > 0
                                              ? '${feedbackProvider.unreadCount} feedback baru'
                                              : 'Lihat semua feedback dari guru',
                                  style: TextStyle(
                                    color: feedbackProvider.errorMessage != null
                                        ? Colors.red.shade600
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF636E72),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),           
            const SizedBox(height: 32),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Melalui aplikasi ini, Anda dapat memantau perkembangan belajar anak dan berkomunikasi dengan guru secara langsung.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
