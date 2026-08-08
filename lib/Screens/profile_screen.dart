import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'my_reports_screen.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String _name = '';
  String _phone = '';
  int _reportCount = 0;
  String _lastUpdateText = 'No updates yet';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profileResult = await ApiService.getProfile();
    final reportsResult = await ApiService.getMyReports();

    if (!mounted) return;

    if (profileResult["success"] == true) {
      final user = profileResult["data"]["user"];
      setState(() {
        _name = (user["name"] != null && user["name"].toString().isNotEmpty)
            ? user["name"]
            : 'Aruvix User';
        _phone = user["phone"] ?? '';
      });
    }

    if (reportsResult["success"] == true) {
      final reports = reportsResult["data"]["reports"] ?? [];
      setState(() {
        _reportCount = reports.length;
        if (reports.isNotEmpty) {
          final latest = reports[0]; // already sorted newest-first by backend
          final dateStr = latest['updatedAt'] ?? latest['createdAt'];
          _lastUpdateText = _formatLastUpdate(dateStr);
        } else {
          _lastUpdateText = 'No updates yet';
        }
      });
    }

    setState(() => _isLoading = false);
  }

  String _formatLastUpdate(String? isoDate) {
    if (isoDate == null) return 'No updates yet';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return 'No updates yet';
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Last update: just now';
    if (diff.inMinutes < 60) return 'Last update: ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last update: ${diff.inHours}h ago';
    if (diff.inDays < 30) return 'Last update: ${diff.inDays}d ago';
    return 'Last update: ${(diff.inDays / 30).floor()}mo ago';
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(feature, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text(
          'This feature is coming soon in a future update.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ApiService.logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3A8F), Color(0xFF2563EB)],
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_name,
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700)),
                            Text('+91 $_phone',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _stat('$_reportCount', 'Reports')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _section('MY ACTIVITY', [
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.description_rounded,
                        color: Color(0xFF2563EB), size: 20),
                  ),
                  title: Text('My Reports',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF1E293B))),
                  subtitle: Text(
                    _reportCount == 0
                        ? 'No updates yet'
                        : '$_reportCount submitted · $_lastUpdateText',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: Color(0xFF94A3B8), size: 20),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyReportsScreen()),
                    );
                    _loadData(); // refresh counts after coming back
                  },
                ),
                _menuItem(context, Icons.location_on_rounded, 'Saved Locations',
                    '3 saved areas', const Color(0xFF10B981)),
              ]),
              const SizedBox(height: 12),
              _section('PREFERENCES', [
                _menuItem(context, Icons.notifications_rounded,
                    'Notification Settings',
                    'Alerts and updates', const Color(0xFFF97316)),
                _menuItem(context, Icons.language_rounded, 'Language',
                    'English (India)', const Color(0xFF8B5CF6)),
              ]),
              const SizedBox(height: 12),
              _section('SUPPORT', [
                _menuItem(context, Icons.help_rounded, 'Help & Support',
                    'FAQs and contact', const Color(0xFF22C55E)),
                _menuItem(context, Icons.policy_rounded, 'Privacy Policy',
                    'Data usage policy', const Color(0xFF64748B)),
              ]),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFECEC)),
                ),
                child: ListTile(
                  onTap: () => _confirmSignOut(context),
                  leading: const Icon(Icons.logout_rounded,
                      color: Color(0xFFEF4444)),
                  title: Text('Sign Out',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFEF4444),
                          fontSize: 14)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _section(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 1.5)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      String subtitle, Color iconColor) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: const Color(0xFF1E293B))),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(
              fontSize: 11, color: const Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right,
          color: Color(0xFF94A3B8), size: 20),
      onTap: () => _showComingSoon(context, title),
    );
  }
}