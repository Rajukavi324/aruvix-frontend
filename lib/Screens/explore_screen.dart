import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Hotels', 'Guides', 'Travelers'];
  final List<String> _categories = ['Hotel', 'Guide', 'Traveler'];

  bool _isLoading = true;
  List<dynamic> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getExploreItems(category: _categories[_selectedTab]);

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        _items = result["data"]["items"] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result["message"];
        _isLoading = false;
      });
    }
  }

  void _switchTab(int index) {
    setState(() => _selectedTab = index);
    _loadItems();
  }

  void _openAddSheet() {
    final category = _categories[_selectedTab];
    final nameCtrl = TextEditingController();
    final field1Ctrl = TextEditingController();
    final field2Ctrl = TextEditingController();
    final field3Ctrl = TextEditingController();

    String field1Label, field2Label, field3Label;
    String field1Hint, field2Hint, field3Hint;

    if (category == 'Hotel') {
      field1Label = 'Price';
      field1Hint = 'e.g. ₹2,200/night';
      field2Label = 'Distance';
      field2Hint = 'e.g. 1.2 km away';
      field3Label = 'Tag';
      field3Hint = 'e.g. Budget Friendly';
    } else if (category == 'Guide') {
      field1Label = 'Expertise';
      field1Hint = 'e.g. Local Water Sources Expert';
      field2Label = 'Experience';
      field2Hint = 'e.g. 5 years experience';
      field3Label = 'Languages';
      field3Hint = 'e.g. Kannada, English';
    } else {
      field1Label = 'Note';
      field1Hint = 'What do you want to share?';
      field2Label = '';
      field2Hint = '';
      field3Label = '';
      field3Hint = '';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New $category',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: category == 'Traveler' ? 'Your Name' : 'Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: field1Ctrl,
                      decoration: InputDecoration(
                        labelText: field1Label,
                        hintText: field1Hint,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      maxLines: category == 'Traveler' ? 3 : 1,
                    ),
                    if (field2Label.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: field2Ctrl,
                        decoration: InputDecoration(
                          labelText: field2Label,
                          hintText: field2Hint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                    if (field3Label.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: field3Ctrl,
                        decoration: InputDecoration(
                          labelText: field3Label,
                          hintText: field3Hint,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Name is required')),
                            );
                            return;
                          }

                          Map<String, dynamic> itemData = {
                            'category': category,
                            'name': nameCtrl.text.trim(),
                          };

                          if (category == 'Hotel') {
                            itemData['price'] = field1Ctrl.text.trim();
                            itemData['distance'] = field2Ctrl.text.trim();
                            itemData['tag'] = field3Ctrl.text.trim();
                          } else if (category == 'Guide') {
                            itemData['expertise'] = field1Ctrl.text.trim();
                            itemData['experience'] = field2Ctrl.text.trim();
                            itemData['languages'] = field3Ctrl.text.trim();
                          } else {
                            itemData['note'] = field1Ctrl.text.trim();
                          }

                          final result = await ApiService.createExploreItem(itemData);

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (result["success"] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$category added successfully!'),
                                backgroundColor: const Color(0xFF22C55E),
                              ),
                            );
                            _loadItems();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result["message"])),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3A8F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Add $category',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(String? isoDate) {
    if (isoDate == null) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSheet,
        backgroundColor: const Color(0xFF1A3A8F),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add', style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3A8F), Color(0xFF2563EB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Explore Nearby',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text('Hotels, guides & fellow travelers',
                    style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final isActive = _selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _switchTab(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _tabs[i],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? const Color(0xFF1A3A8F)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(_errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.red)),
                        ),
                      )
                    : _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.explore_off_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No ${_tabs[_selectedTab].toLowerCase()} added yet',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF64748B))),
                                const SizedBox(height: 4),
                                Text('Tap "Add" to be the first!',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF94A3B8))),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadItems,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                              itemCount: _items.length,
                              itemBuilder: (context, i) {
                                final item = _items[i];
                                if (_selectedTab == 0) return _hotelCard(item);
                                if (_selectedTab == 1) return _guideCard(item);
                                return _travelerCard(item);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _hotelCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.hotel_rounded, color: Color(0xFF2563EB), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
                if ((item['distance'] ?? '').toString().isNotEmpty)
                  Text(item['distance'],
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
                if ((item['tag'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item['tag'],
                        style: GoogleFonts.poppins(
                            fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB))),
                  ),
                ],
                const SizedBox(height: 2),
                Text(_timeAgo(item['createdAt']),
                    style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFFB0B8C4))),
              ],
            ),
          ),
          if ((item['price'] ?? '').toString().isNotEmpty)
            Text(item['price'],
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF1A3A8F))),
        ],
      ),
    );
  }

  Widget _guideCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2563EB).withOpacity(0.12),
            child: Text(
              (item['name'] ?? '?')[0].toUpperCase(),
              style: GoogleFonts.poppins(
                  color: const Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'] ?? '',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF1E293B))),
                if ((item['expertise'] ?? '').toString().isNotEmpty)
                  Text(item['expertise'],
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                if ((item['experience'] ?? '').toString().isNotEmpty)
                  Text(item['experience'],
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF374151))),
                if ((item['languages'] ?? '').toString().isNotEmpty)
                  Text(item['languages'],
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
                Text(_timeAgo(item['createdAt']),
                    style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFFB0B8C4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _travelerCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF10B981).withOpacity(0.12),
                child: Text(
                  (item['name'] ?? '?')[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF10B981), fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(item['name'] ?? '',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF1E293B))),
              ),
              Text(_timeAgo(item['createdAt']),
                  style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF94A3B8))),
            ],
          ),
          if ((item['note'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item['note'],
                style: GoogleFonts.poppins(
                    fontSize: 12, color: const Color(0xFF374151), height: 1.5)),
          ],
        ],
      ),
    );
  }
}