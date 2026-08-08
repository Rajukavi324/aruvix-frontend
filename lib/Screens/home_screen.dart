import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _name = 'Aruvix User';
  String _location = 'Location not set';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await ApiService.getProfile();

    if (!mounted) return;

    if (result["success"] == true) {
      final user = result["data"]["user"];
      setState(() {
        _name = (user["name"] != null && user["name"].toString().isNotEmpty)
            ? user["name"]
            : 'Aruvix User';
        _location = (user["location"] != null &&
                user["location"].toString().isNotEmpty)
            ? user["location"]
            : 'Location not set';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callEmergency(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emergency Call'),
        content: const Text('Call emergency water services at 1916?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uri = Uri(scheme: 'tel', path: '1916');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch phone dialer')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A8F), Color(0xFF2563EB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Morning 🌤',
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 12)),
                        Text(_name,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 13),
                            Text(' $_location',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Next Water Supply',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text('Today 4:30 PM · Zone 5B',
                              style: GoogleFonts.poppins(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('On Time',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
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
                  _sectionTitle('LIVE STATUS'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _statusCard(
                          'Water Level', 'Safe',
                          const Color(0xFF22C55E), '78%',
                          'Kongari Reservoir',
                          const Color(0xFFEFF9F0),
                          const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statusCard(
                          'Water Quality', 'Safe',
                          const Color(0xFF22C55E), 'Grade A',
                          'pH 7.2 · TDS 180',
                          const Color(0xFFEFF9F0),
                          const Color(0xFF0EA5E9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statusCard(
                          'Reservoir', 'Moderate',
                          const Color(0xFFF97316), 'Active',
                          '3 of 4 online',
                          const Color(0xFFFFF7ED),
                          const Color(0xFFF97316),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statusCard(
                          'Safety Alerts', 'Critical',
                          const Color(0xFFEF4444), '2 Active',
                          '1 critical zone',
                          const Color(0xFFFEF2F2),
                          const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('QUICK ACTIONS'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _quickAction(
                        Icons.flag_rounded,
                        'Report\nIssue',
                        const Color(0xFF2563EB),
                        onTap: () => widget.onNavigate(2),
                      ),
                      _quickAction(
                        Icons.water_drop_rounded,
                        'Water\nSupply',
                        const Color(0xFF0EA5E9),
                        onTap: () => widget.onNavigate(0),
                      ),
                      _quickAction(
                        Icons.location_on_rounded,
                        'Nearby\nSources',
                        const Color(0xFF10B981),
                        onTap: () => widget.onNavigate(1),
                      ),
                      _quickAction(
                        Icons.emergency_rounded,
                        'Emergency',
                        const Color(0xFFEF4444),
                        onTap: () => _callEmergency(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('RECENT REPORTS'),
                  const SizedBox(height: 10),
                  _reportCard(
                    'Water Leakage',
                    'MG Road, Zone 3A',
                    'In Progress',
                    const Color(0xFFF97316),
                    '2h ago',
                  ),
                  const SizedBox(height: 10),
                  _reportCard(
                    'No Water Supply',
                    'Whitefield, Zone 7C',
                    'Resolved',
                    const Color(0xFF22C55E),
                    '5h ago',
                  ),
                  const SizedBox(height: 10),
                  _reportCard(
                    'Pipeline Burst',
                    'Koramangala 4th Blk',
                    'Closed',
                    const Color(0xFF64748B),
                    '1d ago',
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

  Widget _sectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF64748B),
            letterSpacing: 1.5));
  }

  Widget _statusCard(String title, String badge, Color badgeColor,
      String value, String subtitle, Color bgColor, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151))),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge,
                    style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: badgeColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _reportCard(String title, String subtitle, String status,
      Color statusColor, String time) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF1E293B))),
                Text(subtitle,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
              Text(time,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }
}