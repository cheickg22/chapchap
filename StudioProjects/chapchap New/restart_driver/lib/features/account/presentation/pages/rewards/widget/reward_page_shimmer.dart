import 'package:flutter/material.dart';
import 'package:restart_tagxi/core/utils/custom_divider.dart';
import 'package:shimmer/shimmer.dart';

class RewardsShimmer extends StatelessWidget {
  final int itemCount;
  const RewardsShimmer({super.key, this.itemCount = 15});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return ListView.separated(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(
              width: size.width * 0.04,
            ),
            // Shimmer for text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: size.width * 0.4,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: size.width * 0.3,
                    height: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: size.width * 0.10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: size.width * 0.2,
                    height: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      separatorBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: const HorizontalDotDividerWidget(),
          ),
        );
      },
    );
  }
}
