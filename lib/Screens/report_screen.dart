import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _selectedIssue = -1;
  String? _customIssueLabel;
  Uint8List? _photoBytes;
  bool _isSubmitting = false;
  String _location = 'MG Road, Bengaluru';
  String _locationDetail = 'Zone 3A · 12.9716°N, 77.5946°E';
  final _descController = TextEditingController();
  final _contactController = TextEditingController();
  final _locationController = TextEditingController();

  final List<Map<String, dynamic>> _issueTypes = [
    {'icon': Icons.water_drop_rounded, 'label': 'Water\nLeakage', 'color': const Color(0xFF0EA5E9)},
    {'icon': Icons.warning_rounded, 'label': 'Water\nContamination', 'color': const Color(0xFFEF4444)},
    {'icon': Icons.block_rounded, 'label': 'No Water\nSupply', 'color': const Color(0xFF6366F1)},
  ];

  final List<String> _allIssueTypes = [
    'Water Leakage',
    'Water Contamination',
    'No Water Supply',
    'Pipeline Burst',
    'Low Water Pressure',
    'Billing Issue',
    'Meter Malfunction',
    'Other',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _photoBytes = bytes;
      });
    }
  }

  void _openIssueTypeSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Issue Type',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ..._allIssueTypes.map((type) {
                  return ListTile(
                    title: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
                    trailing: _customIssueLabel == type
                        ? const Icon(Icons.check_circle, color: Color(0xFF2563EB))
                        : null,
                    onTap: () {
                      setState(() {
                        _customIssueLabel = type;
                        _selectedIssue = -1;
                      });
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editLocation() {
    _locationController.text = _location;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Location',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: _locationController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your location',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_locationController.text.trim().isNotEmpty) {
                setState(() {
                  _location = _locationController.text.trim();
                  _locationDetail = 'Updated location';
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport() async {
    final hasIssueSelected = _selectedIssue != -1 || _customIssueLabel != null;

    if (!hasIssueSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an issue type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final issueType = _customIssueLabel ??
        (_issueTypes[_selectedIssue]['label'] as String).replaceAll('\n', ' ');

    setState(() => _isSubmitting = true);

    final result = await ApiService.submitReport(
      issueType: issueType,
      description: _descController.text.trim(),
      location: _location,
      contactNumber: _contactController.text.trim(),
      photoBase64: _photoBytes != null ? base64Encode(_photoBytes!) : null,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text('Report submitted successfully!',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ],
          ),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      setState(() {
        _selectedIssue = -1;
        _customIssueLabel = null;
        _photoBytes = null;
        _descController.clear();
        _contactController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 18,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3A8F), Color(0xFF2563EB)],
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Report Water Issue',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text('Help us fix problems faster',
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('ISSUE TYPE'),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      _issueTypes.length,
                      (i) => Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedIssue = i;
                            _customIssueLabel = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin:
                                EdgeInsets.only(right: i < 2 ? 10 : 0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            decoration: BoxDecoration(
                              color: _selectedIssue == i
                                  ? (_issueTypes[i]['color'] as Color)
                                      .withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _selectedIssue == i
                                    ? _issueTypes[i]['color'] as Color
                                    : const Color(0xFFE2E8F0),
                                width: _selectedIssue == i ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                    _issueTypes[i]['icon'] as IconData,
                                    color:
                                        _issueTypes[i]['color'] as Color,
                                    size: 28),
                                const SizedBox(height: 6),
                                Text(
                                  _issueTypes[i]['label'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _openIssueTypeSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _customIssueLabel ??
                                'Select from all issue types...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _customIssueLabel != null
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF94A3B8),
                              fontWeight: _customIssueLabel != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right,
                              color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('DESCRIPTION'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Describe the issue in detail — what you see, when it started, and severity...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('LOCATION'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_location,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B))),
                              Text(_locationDetail,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _editLocation,
                          child: Text('Change',
                              style: GoogleFonts.poppins(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('PHOTO EVIDENCE'),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: _photoBytes == null
                          ? Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.camera_alt_outlined,
                                      color: Color(0xFF64748B), size: 26),
                                ),
                                const SizedBox(height: 10),
                                Text('Upload Photo',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2563EB))),
                                Text('Tap to capture or choose from gallery',
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8))),
                              ],
                            )
                          : Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _photoBytes!,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: Text('Change Photo',
                                      style: GoogleFonts.poppins(fontSize: 12)),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('CONTACT NUMBER'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+91 98765 43210',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.phone_outlined,
                            color: Color(0xFF64748B), size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 14),
                      ),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3A8F),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Submit Report',
                              style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 1.5));
  }
}