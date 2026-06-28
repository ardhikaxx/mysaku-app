import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData icon;
  final Color iconColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya, Hapus',
    this.cancelText = 'Batal',
    this.confirmColor = const Color(0xFFEF4444),
    this.icon = Icons.delete_outline_rounded,
    this.iconColor = const Color(0xFFEF4444),
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya, Hapus',
    String cancelText = 'Batal',
    Color confirmColor = const Color(0xFFEF4444),
    IconData icon = Icons.delete_outline_rounded,
    Color iconColor = const Color(0xFFEF4444),
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
        iconColor: iconColor,
      ),
      transitionBuilder: (context, anim, secAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _confirmHovered = false;
  bool _cancelHovered = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top section: icon + text ──
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                child: Column(
                  children: [
                    // Icon with layered ring effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: widget.iconColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.iconColor,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Message
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Divider ──
              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // ── Buttons section ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    // Confirm button (full width, prominent)
                    GestureDetector(
                      onTapDown: (_) => setState(() => _confirmHovered = true),
                      onTapUp: (_) {
                        setState(() => _confirmHovered = false);
                        Navigator.of(context).pop(true);
                      },
                      onTapCancel: () => setState(() => _confirmHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _confirmHovered
                              ? widget.confirmColor.withValues(alpha: 0.88)
                              : widget.confirmColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: widget.confirmColor.withValues(alpha: 0.28),
                              blurRadius: _confirmHovered ? 6 : 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.confirmText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cancel button (subtle, text-like)
                    GestureDetector(
                      onTapDown: (_) => setState(() => _cancelHovered = true),
                      onTapUp: (_) {
                        setState(() => _cancelHovered = false);
                        Navigator.of(context).pop(false);
                      },
                      onTapCancel: () => setState(() => _cancelHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: double.infinity,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _cancelHovered
                              ? const Color(0xFFF1F5F9)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.cancelText,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: _cancelHovered
                                ? const Color(0xFF374151)
                                : const Color(0xFF9CA3AF),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
