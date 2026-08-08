import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Map<String, dynamic>> _markers = [
    {'x': 0.42, 'y': 0.35, 'color': const Color(0xFF22C55E), 'name': 'Kongari Reservoir', 'level': '79% Full', 'status': 'Safe'},
    {'x': 0.68, 'y': 0.22, 'color': const Color(0xFFF97316), 'name': 'Hesaraghatta Lake', 'level': '53% Full', 'status': 'Moderate'},
    {'x': 0.22, 'y': 0.58, 'color': const Color(0xFFF97316), 'name': 'Varthur Lake', 'level': '41% Full', 'status': 'Moderate'},
    {'x': 0.60, 'y': 0.62, 'color': const Color(0xFFEF4444), 'name': 'Bellandur Lake', 'level': '22% Full', 'status': 'Critical'},
  ];

  int _selectedMarker = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Water Map',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                      Text('Bengaluru Metropolitan Area',
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('Live',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Map area
          Expanded(
            child: Stack(
              children: [
                // Map background
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFE8F4EA),
                  child: CustomPaint(painter: MapGridPainter()),
                ),

                // Legend
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LEGEND',
                            style: GoogleFonts.poppins(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: const Color(0xFF374151))),
                        const SizedBox(height: 6),
                        _legendItem(const Color(0xFF22C55E), 'Safe'),
                        _legendItem(const Color(0xFFF97316), 'Moderate'),
                        _legendItem(const Color(0xFFEF4444), 'Critical'),
                      ],
                    ),
                  ),
                ),

                // Markers
                ...List.generate(_markers.length, (i) {
                  final m = _markers[i];
                  return Positioned(
                    left: MediaQuery.of(context).size.width *
                            (m['x'] as double) -
                        20,
                    top: (MediaQuery.of(context).size.height * 0.45) *
                            (m['y'] as double) -
                        20,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMarker = i),
                      child: Column(
                        children: [
                          if (_selectedMarker == i)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Text(m['level'] as String,
                                  style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: m['color'] as Color,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (m['color'] as Color).withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.water_drop,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Refresh button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Bottom info cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _markers.length,
                  (i) => _infoCard(_markers[i], i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: const Color(0xFF374151))),
        ],
      ),
    );
  }

  Widget _infoCard(Map<String, dynamic> marker, int index) {
    final isSelected = index == _selectedMarker;
    return GestureDetector(
      onTap: () => setState(() => _selectedMarker = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1A3A8F)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1A3A8F)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marker['color'] as Color,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  marker['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: double.tryParse((marker['level'] as String)
                            .replaceAll('% Full', '')) !=
                        null
                    ? double.parse((marker['level'] as String)
                            .replaceAll('% Full', '')) /
                        100
                    : 0.5,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                    marker['color'] as Color),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              marker['level'] as String,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isSelected ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCCE5CC).withOpacity(0.5)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 3;

    canvas.drawLine(const Offset(0, 120), Offset(size.width, 100), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.4, size.height), roadPaint);
    canvas.drawLine(const Offset(0, 250), Offset(size.width, 280), roadPaint);

    final waterPaint = Paint()
      ..color = const Color(0xFF93C5FD).withOpacity(0.3);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.42, size.height * 0.35),
            width: 80,
            height: 50),
        waterPaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * 0.68, size.height * 0.22),
            width: 60,
            height: 40),
        waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}