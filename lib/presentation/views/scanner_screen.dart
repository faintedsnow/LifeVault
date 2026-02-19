import 'package:flutter/material.dart';
import 'package:lifevault/main.dart';

/// Professional scanner UI with framing and technical mode selector.
/// Implements the redesign requirements for a clean, non-playful interface.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _activeMode = 'Document';
  bool _isFlashOn = false;
  bool _isAutoCropOn = true;

  final List<String> _modes = [
    'Card',
    'Receipt',
    'Document',
    'Medical',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CAMERA FEED PLACEHOLDER
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.white24,
                  size: 48,
                ),
              ),
            ),
          ),

          // 2. SCANNING OVERLAY (FRAMING)
          Center(
            child: AspectRatio(
              aspectRatio: _getAspectRatioForMode(_activeMode),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    // Corner marks
                    _buildCornerMark(Alignment.topLeft),
                    _buildCornerMark(Alignment.topRight),
                    _buildCornerMark(Alignment.bottomLeft),
                    _buildCornerMark(Alignment.bottomRight),

                    // Technical scan line (static for now)
                    Center(
                      child: Container(
                        height: 1,
                        color: LVColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildTopAction(Icons.close, () => Navigator.pop(context)),
                  const Spacer(),
                  _buildTopAction(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    () => setState(() => _isFlashOn = !_isFlashOn),
                  ),
                  const SizedBox(width: 12),
                  _buildTopAction(Icons.flip_camera_ios_outlined, () {}),
                  const SizedBox(width: 12),
                  _buildTopAction(
                    _isAutoCropOn ? Icons.crop_free : Icons.crop,
                    () => setState(() => _isAutoCropOn = !_isAutoCropOn),
                    isActive: _isAutoCropOn,
                  ),
                ],
              ),
            ),
          ),

          // 4. BOTTOM MODE SELECTOR & SHUTTER
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Selector
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _modes.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        final mode = _modes[index];
                        final isActive = mode == _activeMode;
                        return GestureDetector(
                          onTap: () => setState(() => _activeMode = mode),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Text(
                                mode.toUpperCase(),
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Shutter Button
                  GestureDetector(
                    onTap: () {}, // Trigger Scan
                    child: Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ALIGN ${_activeMode.toUpperCase()} IN FRAME',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAction(
    IconData icon,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? LVColors.primary : Colors.black26,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCornerMark(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.topRight
                ? const BorderSide(color: LVColors.primary, width: 3)
                : BorderSide.none,
            bottom:
                alignment == Alignment.bottomLeft ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: LVColors.primary, width: 3)
                : BorderSide.none,
            left:
                alignment == Alignment.topLeft ||
                    alignment == Alignment.bottomLeft
                ? const BorderSide(color: LVColors.primary, width: 3)
                : BorderSide.none,
            right:
                alignment == Alignment.topRight ||
                    alignment == Alignment.bottomRight
                ? const BorderSide(color: LVColors.primary, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  double _getAspectRatioForMode(String mode) {
    switch (mode) {
      case 'Card':
        return 1.58; // ID Card ratio
      case 'Receipt':
        return 0.5; // Long receipt
      case 'Medical':
        return 0.75; // Prescription
      case 'Document':
        return 0.707; // A4 ratio
      default:
        return 0.707;
    }
  }
}
