import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  bool _isLoading = true;
  List<dynamic> _reports = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getMyReports();

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        _reports = result["data"]["reports"] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result["message"];
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF22C55E);
      case 'In Progress':
        return const Color(0xFFF97316);
      case 'Closed':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF2563EB);
    }
  }

  String _timeAgo(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Text('My Reports',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
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
                              style: GoogleFonts.poppins(
                                  color: Colors.red, fontSize: 13)),
                        ),
                      )
                    : _reports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.description_outlined,
                                    size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No reports yet',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF64748B))),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReports,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _reports.length,
                              itemBuilder: (context, i) {
                                final report = _reports[i];
                                final status =
                                    report['status'] ?? 'Pending';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.04),
                                          blurRadius: 8),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              report['issueType'] ?? 'Issue',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: const Color(
                                                      0xFF1E293B)),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _statusColor(status)
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(status,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color:
                                                        _statusColor(status))),
                                          ),
                                        ],
                                      ),
                                      if ((report['location'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 12,
                                                color: Color(0xFF94A3B8)),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                report['location'],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    color: const Color(
                                                        0xFF64748B)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if ((report['description'] ?? '')
                                          .toString()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          report['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color:
                                                  const Color(0xFF374151)),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        _timeAgo(report['updatedAt'] ??
                                            report['createdAt'] ??
                                            ''),
                                        style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: const Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}