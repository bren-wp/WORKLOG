import 'package:flutter/material.dart';
import 'worklog_theme.dart';

class WorklogMark extends StatelessWidget {
  const WorklogMark({super.key, this.size = 42});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF08284C), Color(0xFF06111F)],
        ),
        border: Border.all(color: const Color(0xFF1687FF)),
        boxShadow: [
          BoxShadow(
            color: WorklogColors.primary.withValues(alpha: .22),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(painter: _WorklogMarkPainter()),
    );
  }
}

class WorklogWordmark extends StatelessWidget {
  const WorklogWordmark({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WorklogMark(size: compact ? 32 : 42),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 21 : 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -.8,
            ),
            children: const [
              TextSpan(text: "WORK", style: TextStyle(color: Colors.white)),
              TextSpan(text: "LOG", style: TextStyle(color: WorklogColors.primary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorklogMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF13C8FF), Color(0xFF1677FF), Color(0xFF5A72FF)],
      ).createShader(Offset.zero & size);

    final p = Path()
      ..moveTo(size.width * .16, size.height * .30)
      ..lineTo(size.width * .34, size.height * .30)
      ..lineTo(size.width * .50, size.height * .62)
      ..lineTo(size.width * .66, size.height * .30)
      ..lineTo(size.width * .84, size.height * .30)
      ..lineTo(size.width * .62, size.height * .72)
      ..quadraticBezierTo(
        size.width * .57,
        size.height * .80,
        size.width * .50,
        size.height * .72,
      )
      ..lineTo(size.width * .40, size.height * .54)
      ..lineTo(size.width * .32, size.height * .72)
      ..quadraticBezierTo(
        size.width * .27,
        size.height * .80,
        size.width * .22,
        size.height * .70,
      )
      ..close();
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
