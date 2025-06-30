// lib/screens/feedback/create_feedback_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/feedback_provider.dart';
import '../../models/feedback.dart' as FeedbackModel;
import '../../models/user.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateFeedbackScreen extends StatefulWidget {
  final FeedbackModel.Feedback? feedback; // null untuk create, ada value untuk edit

  const CreateFeedbackScreen({
    super.key,
    this.feedback,
  });

  @override
  State<CreateFeedbackScreen> createState() => _CreateFeedbackScreenState();
}

class _CreateFeedbackScreenState extends State<CreateFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiFeedbackController = TextEditingController();
  
  String? _selectedSiswa;
  String _selectedKategori = 'akademik';
  String _selectedTingkat = 'netral';
  bool _isLoading = false;

  bool get isEditing => widget.feedback != null;

  @override
  void initState() {
    super.initState();
    print('🔍 DEBUG: CreateFeedbackScreen initState');
    
    // Populate fields for editing
    if (isEditing) {
      _judulController.text = widget.feedback!.judul;
      _isiFeedbackController.text = widget.feedback!.isiFeedback;
      _selectedSiswa = widget.feedback!.siswaId.toString();
      _selectedKategori = widget.feedback!.kategori;
      _selectedTingkat = widget.feedback!.tingkat;
      print('🔍 DEBUG: Editing mode - populated fields');
    }
    
    // Load siswa list ONLY for create mode and only once
    if (!isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🔍 DEBUG: PostFrameCallback - about to load siswa list');
        final provider = Provider.of<FeedbackProvider>(context, listen: false);
        
        // Only load if not already loaded or loading
        if (provider.siswaList.isEmpty && !provider.isLoadingSiswa) {
          print('🔍 DEBUG: Loading siswa list...');
          provider.loadSiswaList();
        } else {
          print('🔍 DEBUG: Siswa list already loaded or loading, skipping');
        }
      });
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiFeedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!isEditing && _selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih siswa'),
          backgroundColor: Color(0xFFE17055),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<FeedbackProvider>(context, listen: false);
    
    bool success;
    if (isEditing) {
      success = await provider.updateFeedback(
        feedbackId: widget.feedback!.id.toString(),
        judul: _judulController.text.trim(),
        isiFeedback: _isiFeedbackController.text.trim(),
        kategori: _selectedKategori,
        tingkat: _selectedTingkat,
      );
    } else {
      success = await provider.createFeedback(
        siswaId: _selectedSiswa!,
        judul: _judulController.text.trim(),
        isiFeedback: _isiFeedbackController.text.trim(),
        kategori: _selectedKategori,
        tingkat: _selectedTingkat,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing 
                ? 'Feedback berhasil diperbarui'
                : 'Feedback berhasil dibuat',
            ),
            backgroundColor: const Color(0xFF00B894),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ?? 
              (isEditing ? 'Gagal memperbarui feedback' : 'Gagal membuat feedback'),
            ),
            backgroundColor: const Color(0xFFE17055),
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Feedback' : 'Buat Feedback'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<FeedbackProvider>(
          builder: (context, provider, child) {
            print('🔍 DEBUG: Consumer builder called - Loading: ${provider.isLoadingSiswa}, Count: ${provider.siswaList.length}, Error: ${provider.errorMessage}');
            
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF6C63FF),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEditing ? 'Edit Feedback' : 'Buat Feedback Baru',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C63FF),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEditing 
                            ? 'Perbarui informasi feedback untuk siswa. Feedback akan langsung terlihat oleh orangtua siswa.'
                            : 'Berikan feedback kepada siswa mengenai perkembangan pembelajaran. Feedback akan langsung terlihat oleh orangtua siswa.',
                          style: TextStyle(
                            color: const Color(0xFF6C63FF).withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Pilih Siswa (hanya untuk create)
                  if (!isEditing) ...[
                    const Text(
                      'Pilih Siswa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Safe dropdown builder
                    Builder(
                      builder: (context) {
                        try {
                          return _buildSiswaDropdown(provider);
                        } catch (e) {
                          print('💥 DEBUG: Error in dropdown builder: $e');
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Column(
                              children: [
                                Text('Error loading dropdown: $e'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => provider.loadSiswaList(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                  
                  if (isEditing) ...[
                    // Info siswa untuk edit mode
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF00B894).withOpacity(0.2),
                            child: const Icon(
                              Icons.face,
                              color: Color(0xFF00B894),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Siswa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF636E72),
                                ),
                              ),
                              Text(
                                widget.feedback!.siswaName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Judul Feedback
                  const Text(
                    'Judul Feedback',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _judulController,
                    label: 'Judul Feedback',
                    hint: 'Masukkan judul feedback',
                    prefixIcon: Icons.title,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Judul feedback tidak boleh kosong';
                      }
                      if (value.trim().length < 5) {
                        return 'Judul feedback minimal 5 karakter';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Kategori dan Tingkat
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildKategoriDropdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tingkat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3436),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTingkatDropdown(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Isi Feedback
                  const Text(
                    'Isi Feedback',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _isiFeedbackController,
                    decoration: InputDecoration(
                      labelText: 'Isi Feedback',
                      hintText: 'Tuliskan feedback detail untuk siswa...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 6,
                    maxLength: 1000,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Isi feedback tidak boleh kosong';
                      }
                      if (value.trim().length < 10) {
                        return 'Isi feedback minimal 10 karakter';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  CustomButton(
                    text: isEditing ? 'Perbarui Feedback' : 'Buat Feedback',
                    onPressed: _isLoading ? null : _handleSubmit,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Cancel Button
                  CustomButton(
                    text: 'Batal',
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    width: double.infinity,
                    backgroundColor: Colors.grey.shade300,
                    textColor: Colors.grey.shade700,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSiswaDropdown(FeedbackProvider provider) {
    print('🔍 DEBUG: _buildSiswaDropdown called');
    print('🔍 DEBUG: Loading: ${provider.isLoadingSiswa}');
    print('🔍 DEBUG: Siswa count: ${provider.siswaList.length}');
    print('🔍 DEBUG: Error: ${provider.errorMessage}');
    print('🔍 DEBUG: Selected: $_selectedSiswa');
    
    // Show loading state
    if (provider.isLoadingSiswa) {
      return Container(
        height: 60,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDD6FE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading siswa...'),
          ],
        ),
      );
    }
    
    // Show error state
    if (provider.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Text('Error: ${provider.errorMessage}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                provider.loadSiswaList();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Show empty state
    if (provider.siswaList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Text('Tidak ada siswa ditemukan'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => provider.loadSiswaList(),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    // Validate selected value
    String? validatedSelectedValue = _selectedSiswa;
    if (_selectedSiswa != null) {
      bool isValid = provider.siswaList.any((siswa) => siswa.id.toString() == _selectedSiswa);
      if (!isValid) {
        print('⚠️ DEBUG: Selected value $_selectedSiswa not found in siswa list, resetting');
        validatedSelectedValue = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _selectedSiswa = null;
          });
        });
      }
    }

    // Build dropdown items safely
    List<DropdownMenuItem<String>> dropdownItems = [];
    
    try {
      for (User siswa in provider.siswaList) {
        print('🔍 DEBUG: Creating dropdown item - ID: ${siswa.id}, Name: ${siswa.nama}');
        
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: siswa.id.toString(),
            child: Text(
              siswa.nama,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
      
      print('✅ DEBUG: Created ${dropdownItems.length} dropdown items');
    } catch (e) {
      print('💥 DEBUG: Error creating dropdown items: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Error creating dropdown: $e'),
      );
    }

    // Normal dropdown
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Pilih Siswa',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.face),
      ),
      value: validatedSelectedValue,
      hint: const Text('Pilih siswa untuk feedback'),
      items: dropdownItems,
      onChanged: (String? newValue) {
        print('🔍 DEBUG: Dropdown onChanged called with value: $newValue');
        try {
          setState(() {
            _selectedSiswa = newValue;
          });
          print('✅ DEBUG: Selected siswa updated to: $newValue');
        } catch (e) {
          print('💥 DEBUG: Error in dropdown onChanged: $e');
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Silakan pilih siswa';
        }
        return null;
      },
      isExpanded: true,
      isDense: false,
    );
  }

  Widget _buildKategoriDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Kategori',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.category),
      ),
      value: _selectedKategori,
      items: const [
        DropdownMenuItem(value: 'akademik', child: Text('Akademik')),
        DropdownMenuItem(value: 'perilaku', child: Text('Perilaku')),
        DropdownMenuItem(value: 'prestasi', child: Text('Prestasi')),
        DropdownMenuItem(value: 'kehadiran', child: Text('Kehadiran')),
        DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedKategori = value!;
        });
      },
    );
  }

  Widget _buildTingkatDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Tingkat',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDD6FE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: const Icon(Icons.sentiment_satisfied),
      ),
      value: _selectedTingkat,
      items: const [
        DropdownMenuItem(
          value: 'positif',
          child: Row(
            children: [
              Icon(Icons.thumb_up, color: Color(0xFF00B894), size: 16),
              SizedBox(width: 8),
              Text('Positif'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'netral',
          child: Row(
            children: [
              Icon(Icons.info, color: Color(0xFF6C63FF), size: 16),
              SizedBox(width: 8),
              Text('Netral'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'perlu_perhatian',
          child: Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFE17055), size: 16),
              SizedBox(width: 8),
              Text('Perlu Perhatian'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTingkat = value!;
        });
      },
    );
  }
}