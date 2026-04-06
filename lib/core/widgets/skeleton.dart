import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer placeholder matching the shape of a wiki article card.
class WikiCardSkeleton extends StatelessWidget {
  const WikiCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0DDD8);
    final highlight = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F3EE);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bar(width: 60, height: 18),
            const SizedBox(height: 10),
            _bar(width: double.infinity, height: 16),
            const SizedBox(height: 6),
            _bar(width: 200, height: 12),
            const SizedBox(height: 10),
            _bar(width: 120, height: 10),
          ],
        ),
      ),
    );
  }
}

/// A shimmer placeholder matching the shape of a Q&A question card.
class QuestionCardSkeleton extends StatelessWidget {
  const QuestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0DDD8);
    final highlight = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F3EE);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _bar(width: 60, height: 18),
              const Spacer(),
              _bar(width: 40, height: 14),
            ]),
            const SizedBox(height: 10),
            _bar(width: double.infinity, height: 14),
            const SizedBox(height: 4),
            _bar(width: 240, height: 14),
            const SizedBox(height: 10),
            Row(children: [
              _bar(width: 80, height: 10),
              const SizedBox(width: 12),
              _bar(width: 60, height: 10),
            ]),
          ],
        ),
      ),
    );
  }
}

Widget _bar({required double height, double? width}) => Container(
  width: width,
  height: height,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(height / 2),
  ),
);
