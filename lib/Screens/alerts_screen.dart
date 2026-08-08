import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Emergency', 'Warning', 'Info'];
  bool _isLoading = true;
  List<dynamic> _alerts = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.getAlerts();

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        _alerts = result["data"]["alerts"] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result["message"];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredAlerts {
    if (_selectedFilter == 0) return _alerts;
    final filterType = _filters[_selectedFilter].toUpperCase();
    return _alerts.where((a) => a['type'] == filterType).toList();
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'EMERGENCY':
        return const Color(0xFFEF4444);
      case 'WARNING':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF2563EB);
    }
  }

  Color _typeBg(String type) {
    switch (type) {
      case 'EMERGENCY':
        return const Color(0xFFFEF2F2);
      case 'WARNING':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFEFF6FF);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'EMERGENCY':
        return Icons.emergency_rounded;
      case 'WARNING':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
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

  Future<void> _dismissAlert(String alertId) async {
    final result = await ApiService.dismissAlert(alertId);

    if (!mounted) return;

    if (result["success"] == true) {
      setState(() {
        _alerts.removeWhere((a) => a['_id'] == alertId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alert dismissed', style: GoogleFonts.poppins()),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"])),
      );
    }
  }

  void _showAlertDetails(Map alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_typeIcon(alert['type']), color: _typeColor(alert['type'])),
            const SizedBox(width: 8),
            Expanded(
              child: Text(alert['title'] ?? '',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((alert['location'] ?? '').toString().isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(alert['location'],
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B))),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Text(alert['description'] ?? '',
                style: GoogleFonts.poppins(fontSize: 13, height: 1.5)),
            const SizedBox(height: 10),
            Text(_timeAgo(alert['createdAt']),
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alerts & Notifications',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          Text('${_alerts.length} active alerts',
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _loadAlerts,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      _filters.length,
                      (i) => GestureDetector(
                        onTap: () => setState(() => _selectedFilter = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: _selectedFilter == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _filters[i],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedFilter == i
                                  ? const Color(0xFF1A3A8F)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                    : _filteredAlerts.isEmpty
                        ? Center(
                            child: Text('No alerts here',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF94A3B8), fontSize: 14)),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAlerts,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredAlerts.length,
                              itemBuilder: (context, i) =>
                                  _alertCard(_filteredAlerts[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard(Map alert) {
    final type = alert['type'] ?? 'INFO';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _typeBg(type),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(_typeIcon(type), color: _typeColor(type), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      type == 'INFO' ? 'INFORMATION' : type,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _typeColor(type)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(_timeAgo(alert['createdAt']),
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 10),
          Text(alert['title'] ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B))),
          if ((alert['location'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF94A3B8), size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(alert['location'],
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: const Color(0xFF64748B))),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(alert['description'] ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: const Color(0xFF374151), height: 1.5)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAlertDetails(alert),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _typeColor(type),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text('View Details',
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _dismissAlert(alert['_id']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Dismiss',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}