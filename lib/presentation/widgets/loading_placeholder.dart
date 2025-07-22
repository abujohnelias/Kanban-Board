import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingPlaceholder extends StatelessWidget {
  const LoadingPlaceholder({super.key});

  Widget _buildShimmerColumn(Color color) {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildShimmerColumn(const Color(0xFFbfdbfe)),
        const SizedBox(width: 10),
        _buildShimmerColumn(const Color(0xFFfef08a)),
        const SizedBox(width: 10),
        _buildShimmerColumn(const Color(0xFFdcfce7)),
      ],
    );
  }
}
