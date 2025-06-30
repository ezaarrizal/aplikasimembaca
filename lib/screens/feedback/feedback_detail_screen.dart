// lib/screens/feedback/feedback_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../widgets/custom_button.dart';
import 'create_feedback_screen.dart';

class FeedbackDetailScreen extends StatefulWidget {
  final FeedbackModel.Feedback feedback;
  final bool isParentMode;

  const FeedbackDetailScreen({
    super.key,
    required this.feedback,
    this.isParentMode = false,
  });

  @override
  State<FeedbackDetailScreen> createState() => _FeedbackDetailScreenState();
}

class _FeedbackDetailScreenState extends State<FeedbackDetailScreen> {
  late FeedbackModel.Feedback _currentFeedback;
  bool _isMarkingAsRead = false;

  @override
  void initState() {
    super.initState();
    _currentFeedback = widget.feedback;

    // Auto mark as read untuk orangtua jika belum dibaca
    if (widget.isParentMode && !_currentFeedback.isReadByParent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _markAsRead();
      });
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarkingAsRead) return;

    setState(() => _isMarkingAsRead = true);

    final provider = Provider.of<FeedbackProvider>(context, listen: false);
    final success = await provider.markAsRead(_currentFeedback.id.toString());

    if (success) {
      setState(() {
        _currentFeedback = FeedbackModel.Feedback(
          id: _currentFeedback.id,
          guruId: _currentFeedback.guruId,
          siswaId: _currentFeedback.siswaId,
          judul: _currentFeedback.judul,
          isiFeedback: _currentFeedback.isiFeedback,
          kategori: _currentFeedback.kategori,
          tingkat: _currentFeedback.tingkat,
          isReadByParent: true,
          readAt: DateTime.now().toIso8601String(),
          createdAt: _currentFeedback.createdAt,
          updatedAt: _currentFeedback.updatedAt,
          formattedDate: _currentFeedback.formattedDate,
          guru: _currentFeedback.guru,
          siswa: _currentFeedback.siswa,
        );
      });
    }

    setState(() => _isMarkingAsRead = false);
  }

  @override
  Widget build(BuildContext context) {
    Color tingkatColor;
    IconData tingkatIcon;
    String tingkatDescription;

    switch (_currentFeedback.tingkat) {
      case 'positif':
        tingkatColor = const Color(0xFF00B894);
        tingkatIcon = Icons.thumb_up;
        tingkatDescription =
            'Feedback positif menunjukkan pencapaian yang baik';
        break;
      case 'netral':
        tingkatColor = const Color(0xFF6C63FF);
        tingkatIcon = Icons.info;
        tingkatDescription = 'Feedback netral untuk informasi umum';
        break;
      case 'perlu_perhatian':
        tingkatColor = const Color(0xFFE17055);
        tingkatIcon = Icons.warning;
        tingkatDescription = 'Feedback yang memerlukan perhatian khusus';
        break;
      default:
        tingkatColor = const Color(0xFF6C63FF);
        tingkatIcon = Icons.info;
        tingkatDescription = 'Feedback umum';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Detail Feedback'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: widget.isParentMode
            ? null
            : [
                PopupMenuButton(
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
                  onSelected: _handleAction,
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  // Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tingkatColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tingkatIcon, color: tingkatColor, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _currentFeedback.tingkatDisplayName,
                              style: TextStyle(
                                color: tingkatColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (widget.isParentMode)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _currentFeedback.isReadByParent
                                ? const Color(0xFF00B894).withOpacity(0.1)
                                : const Color(0xFFE17055).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _currentFeedback.isReadByParent
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: _currentFeedback.isReadByParent
                                    ? const Color(0xFF00B894)
                                    : const Color(0xFFE17055),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _currentFeedback.statusDisplayName,
                                style: TextStyle(
                                  color: _currentFeedback.isReadByParent
                                      ? const Color(0xFF00B894)
                                      : const Color(0xFFE17055),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _currentFeedback.judul,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Kategori
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _currentFeedback.kategoriDisplayName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Participants Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    'Informasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Guru Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color(0xFF6C63FF).withOpacity(0.2),
                        child: const Icon(
                          Icons.school,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dari Guru',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF636E72),
                              ),
                            ),
                            Text(
                              _currentFeedback.guruName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Siswa Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            const Color(0xFF00B894).withOpacity(0.2),
                        child: const Icon(
                          Icons.face,
                          color: Color(0xFF00B894),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isParentMode
                                  ? 'Untuk Siswa'
                                  : 'Untuk Siswa',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF636E72),
                              ),
                            ),
                            Text(
                              _currentFeedback.siswaName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          Icons.schedule,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tanggal Dibuat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF636E72),
                              ),
                            ),
                            Text(
                              _currentFeedback.formattedDate ??
                                  _currentFeedback.createdAt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

            const SizedBox(height: 16),

            // Content Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    'Isi Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentFeedback.isiFeedback,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF636E72),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tingkat Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tingkatColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: tingkatColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    tingkatIcon,
                    color: tingkatColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tingkatDescription,
                      style: TextStyle(
                        color: tingkatColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons untuk Guru
            if (!widget.isParentMode) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit Feedback',
                      onPressed: () => _navigateToEdit(),
                      backgroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Hapus',
                      onPressed: () => _confirmDelete(),
                      backgroundColor: const Color(0xFFE17055),
                    ),
                  ),
                ],
              ),
            ],

            // Mark as Read Button untuk Orangtua (jika belum dibaca)
            if (widget.isParentMode && !_currentFeedback.isReadByParent) ...[
              CustomButton(
                text: 'Tandai Sudah Dibaca',
                onPressed: _isMarkingAsRead ? null : _markAsRead,
                isLoading: _isMarkingAsRead,
                width: double.infinity,
                backgroundColor: const Color(0xFF00B894),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'edit':
        _navigateToEdit();
        break;
      case 'delete':
        _confirmDelete();
        break;
    }
  }

  void _navigateToEdit() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => CreateFeedbackScreen(feedback: _currentFeedback),
      ),
    )
        .then((_) {
      // Refresh data jika ada perubahan
      Navigator.of(context).pop();
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Feedback'),
        content: Text(
          'Apakah Anda yakin ingin menghapus feedback "${_currentFeedback.judul}"?\n\nFeedback yang sudah dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              final provider =
                  Provider.of<FeedbackProvider>(context, listen: false);
              final success =
                  await provider.deleteFeedback(_currentFeedback.id.toString());

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Feedback berhasil dihapus'
                          : provider.errorMessage ?? 'Gagal menghapus feedback',
                    ),
                    backgroundColor: success
                        ? const Color(0xFF00B894)
                        : const Color(0xFFE17055),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );

                if (success) {
                  Navigator.of(context).pop(); // Go back to list
                }
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
