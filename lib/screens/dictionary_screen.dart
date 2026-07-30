import 'package:flutter/material.dart';
import '../models/dictionary_entry.dart';
import '../services/dictionary_service.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final DictionaryService _service = DictionaryService();
  List<DictionaryEntry> _entries = [];
  List<DictionaryEntry> _filteredEntries = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.fetchDictionary();
      setState(() {
        _entries = data;
        _filteredEntries = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kamus: $e')),
        );
      }
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredEntries = _entries
          .where((e) => e.word.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _openAddWordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddWordForm(
        onSubmit: (entry) async {
          await _service.submitWord(entry);
          Navigator.pop(context);
          _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kosakata berhasil ditambahkan')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kamus Bahasa Isyarat')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: 'Cari kosakata...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEntries.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Belum ada kosakata'
                              : 'Kosakata "$_searchQuery" tidak ditemukan',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: Text(
                                    entry.word.isNotEmpty
                                        ? entry.word[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.word,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(entry.description),
                                trailing: Chip(
                                  label: Text(
                                    entry.category,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor: Colors.blue.shade50,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddWordSheet,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kosakata'),
      ),
    );
  }
}

class _AddWordForm extends StatefulWidget {
  final Function(DictionaryEntry) onSubmit;

  const _AddWordForm({required this.onSubmit});

  @override
  State<_AddWordForm> createState() => _AddWordFormState();
}

class _AddWordFormState extends State<_AddWordForm> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Salam';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Salam',
    'Kebutuhan',
    'Keluarga',
    'Angka',
    'Lainnya',
  ];

  @override
  void dispose() {
    _wordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await widget.onSubmit(
      DictionaryEntry(
        id: 0,
        word: _wordController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        submittedBy: 'Kamu',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Kosakata Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _wordController,
              decoration: InputDecoration(
                labelText: 'Kata',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Kata tidak boleh kosong'
                      : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi gerakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Deskripsi tidak boleh kosong'
                      : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}