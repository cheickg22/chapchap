import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SubscriptionShimmer extends StatelessWidget {
  final Size size;

  const SubscriptionShimmer({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(size.width * 0.05, size.width * 0.03,
              size.width * 0.03, size.width * 0.03),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20.0,
              width: size.width * 0.5,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 4, // Display shimmer effect for 4 items as a placeholder
            padding: EdgeInsets.zero,
            itemBuilder: (_, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: size.width * 0.025),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: size.width * 0.9,
                    padding: EdgeInsets.all(size.width * 0.03),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 0.5, color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.05,
                          height: size.width * 0.05,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1.5, color: Colors.grey),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: size.width * 0.03,
                            height: size.width * 0.03,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: size.width * 0.15,
                                height: size.width * 0.05,
                                margin:
                                    EdgeInsets.only(left: size.width * 0.05),
                                color: Colors.grey,
                              ),
                              SizedBox(width: size.width * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 15.0,
                                    width: size.width * 0.4,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Container(
                                    height: 12.0,
                                    width: size.width * 0.3,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
