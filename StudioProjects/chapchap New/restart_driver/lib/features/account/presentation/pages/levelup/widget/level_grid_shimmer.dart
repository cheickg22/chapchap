import 'package:flutter/material.dart';
import 'package:restart_tagxi/features/account/presentation/pages/levelup/widget/custom_hexagon_clipper.dart';
import 'package:shimmer/shimmer.dart';

class LevelsGridShimmer extends StatelessWidget {
  final int itemCount;

  const LevelsGridShimmer({super.key, this.itemCount = 15});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GridView.builder(
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Shimmer for the circular/level image
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ClipPath(
                  clipper: HexagonClipper(),
                  child: Container(
                    height: size.width * 0.2,
                    width: size.width * 0.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Shimmer for the text
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: size.width * 0.15,
                  height: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
