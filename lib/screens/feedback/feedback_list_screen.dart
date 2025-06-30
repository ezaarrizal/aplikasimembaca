// lib/screens/feedback/feedback_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import 'create_feedback_screen.dart';
import 'feedback_detail_screen.dart';

class FeedbackListScreen extends StatefulWidget {
  final bool isParentMode;

  const FeedbackListScreen({
    super.key,
    this.isParentMode = false,
  });

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: FeedbackListScreen initState - isParentMode: ${widget.isParentMode}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FeedbackProvider>(context, listen: false);
      
      if (widget.isParentMode) {
        print('🔍 DEBUG: Loading feedbacks for parent');
        provider.loadFeedbacksForParent(refresh: true);
      } else {
        print('🔍 DEBUG: Loading feedbacks for guru');
        provider.loadFeedbacks(refresh: true);
        provider.loadSiswaList();
      }
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
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent) {
      Provider.of<FeedbackProvider>(context, listen: false)
          .loadNextPage(isParent: widget.isParentMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.isParentMode ? 'Semua Feedback Siswa' : 'Kelola Feedback'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: widget.isParentMode ? null : [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateFeedback,
          ),
        ],
      ),
      body: Consumer<FeedbackProvider>(
        builder: (context, provider, child) {
          print('🔍 DEBUG: FeedbackListScreen Consumer rebuild');
          print('🔍 DEBUG: Loading: ${provider.isLoading}, Feedbacks: ${provider.feedbacks.length}');
          print('🔍 DEBUG: Error: ${provider.errorMessage}');
          
          return Column(
            children: [
              // Unread Count (untuk orangtua)
              if (widget.isParentMode && provider.unreadCount > 0)
                _buildUnreadCountCard(provider.unreadCount),
              
              // Filters
              _buildFilters(provider),
              
              // Feedback List
              Expanded(
                child: _buildFeedbackList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: widget.isParentMode ? null : FloatingActionButton(
        onPressed: _navigateToCreateFeedback,
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUnreadCountCard(int unreadCount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE17055).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE17055).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: const Color(0xFFE17055),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$unreadCount feedback belum dibaca dari semua siswa',
              style: const TextStyle(
                color: Color(0xFFE17055),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(FeedbackProvider provider) {
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
          // Search Bar (hanya untuk guru)
          if (!widget.isParentMode) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari feedback...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, 
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
            ),
            const SizedBox(height: 12),
          ],
          
          // Filter Chips Row 1
          Row(
            children: [
              // Siswa/Anak Filter
              Expanded(
                flex: 2,
                child: _buildDropdownFilter(
                  label: widget.isParentMode ? 'Pilih Siswa' : 'Pilih Siswa',
                  value: provider.selectedSiswa,
                  items: _getSiswaDropdownItems(provider),
                  onChanged: (value) => provider.setSiswaFilter(value!),
                ),
              ),
              
              if (widget.isParentMode) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    'Belum Dibaca',
                    provider.unreadOnly,
                    () => provider.setUnreadFilter(!provider.unreadOnly),
                  ),
                ),
              ],
            ],
          ),
          
          if (!widget.isParentMode) ...[
            const SizedBox(height: 8),
            // Filter Chips Row 2 (hanya untuk guru)
            Row(
              children: [
                Expanded(
                  child: _buildDropdownFilter(
                    label: 'Kategori',
                    value: provider.selectedKategori,
                    items: _getKategoriDropdownItems(),
                    onChanged: (value) => provider.setKategoriFilter(value!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdownFilter(
                    label: 'Tingkat',
                    value: provider.selectedTingkat,
                    items: _getTingkatDropdownItems(),
                    onChanged: (value) => provider.setTingkatFilter(value!),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
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

  List<DropdownMenuItem<String>> _getSiswaDropdownItems(FeedbackProvider provider) {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
        value: 'all',
        child: Text('Semua'),
      ),
    ];

    List<User> userList = widget.isParentMode ? provider.children : provider.siswaList;
    
    items.addAll(
      userList.map((user) => DropdownMenuItem(
        value: user.id.toString(),
        child: Text(user.nama),
      )),
    );

    return items;
  }

  List<DropdownMenuItem<String>> _getKategoriDropdownItems() {
    return [
      const DropdownMenuItem(value: 'all', child: Text('Semua Kategori')),
      const DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
      const DropdownMenuItem(value: 'perilaku', child: Text('Perilaku')),
      const DropdownMenuItem(value: 'prestasi', child: Text('Prestasi')),
      const DropdownMenuItem(value: 'kehadiran', child: Text('Kehadiran')),
      const DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
    ];
  }

  List<DropdownMenuItem<String>> _getTingkatDropdownItems() {
    return [
      const DropdownMenuItem(value: 'all', child: Text('Semua Tingkat')),
      const DropdownMenuItem(value: 'positif', child: Text('Positif')),
      const DropdownMenuItem(value: 'netral', child: Text('Netral')),
      const DropdownMenuItem(value: 'perlu_perhatian', child: Text('Perlu Perhatian')),
    ];
  }

  Widget _buildFeedbackList(FeedbackProvider provider) {
    if (provider.isLoading && provider.feedbacks.isEmpty) {
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
              onPressed: () {
                if (widget.isParentMode) {
                  provider.loadFeedbacksForParent(refresh: true);
                } else {
                  provider.loadFeedbacks(refresh: true);
                }
              },
            ),
          ],
        ),
      );
    }

    if (provider.feedbacks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isParentMode 
                ? 'Belum ada feedback untuk semua siswa'
                : 'Belum ada feedback yang dibuat',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            if (!widget.isParentMode) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: 'Buat Feedback',
                onPressed: _navigateToCreateFeedback,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: provider.feedbacks.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.feedbacks.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final feedback = provider.feedbacks[index];
        return _buildFeedbackCard(feedback);
      },
    );
  }

  Widget _buildFeedbackCard(FeedbackModel.Feedback feedback) {
    Color tingkatColor;
    IconData tingkatIcon;

    switch (feedback.tingkat) {
      case 'positif':
        tingkatColor = const Color(0xFF00B894);
        tingkatIcon = Icons.thumb_up;
        break;
      case 'netral':
        tingkatColor = const Color(0xFF6C63FF);
        tingkatIcon = Icons.info;
        break;
      case 'perlu_perhatian':
        tingkatColor = const Color(0xFFE17055);
        tingkatIcon = Icons.warning;
        break;
      default:
        tingkatColor = const Color(0xFF6C63FF);
        tingkatIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToFeedbackDetail(feedback),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tingkatColor.withOpacity(0.2),
                    child: Icon(tingkatIcon, color: tingkatColor, size: 20),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.isParentMode 
                            ? 'Dari: ${feedback.guruName} → Untuk: ${feedback.siswaName}'
                            : 'Untuk: ${feedback.siswaName}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu (hanya untuk guru)
                  if (!widget.isParentMode)
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
                      onSelected: (value) => _handleFeedbackAction(value.toString(), feedback),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Content preview
              Text(
                feedback.isiFeedback,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Tags & Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tingkatColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feedback.tingkatDisplayName,
                      style: TextStyle(
                        color: tingkatColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      feedback.kategoriDisplayName,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  if (widget.isParentMode && !feedback.isReadByParent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE17055).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Belum Dibaca',
                        style: TextStyle(
                          color: Color(0xFFE17055),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Date
              Text(
                feedback.formattedDate ?? feedback.createdAt,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeedbackAction(String action, FeedbackModel.Feedback feedback) {
    final provider = Provider.of<FeedbackProvider>(context, listen: false);

    switch (action) {
      case 'edit':
        _navigateToEditFeedback(feedback);
        break;
      case 'delete':
        _confirmDelete(feedback, provider);
        break;
    }
  }

  void _navigateToCreateFeedback() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateFeedbackScreen(),
      ),
    );
  }

  void _navigateToEditFeedback(FeedbackModel.Feedback feedback) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateFeedbackScreen(feedback: feedback),
      ),
    );
  }

  void _navigateToFeedbackDetail(FeedbackModel.Feedback feedback) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedbackDetailScreen(
          feedback: feedback,
          isParentMode: widget.isParentMode,
        ),
      ),
    );
  }

  void _confirmDelete(FeedbackModel.Feedback feedback, FeedbackProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Feedback'),
        content: Text(
          'Apakah Anda yakin ingin menghapus feedback "${feedback.judul}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await provider.deleteFeedback(feedback.id.toString());
              
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