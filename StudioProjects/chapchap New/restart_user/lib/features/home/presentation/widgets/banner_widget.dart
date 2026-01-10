import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/home_bloc.dart';

class BannerWidget extends StatelessWidget {
  final BuildContext cont;
  const BannerWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: cont.read<HomeBloc>(),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.width * 0.01),
                CarouselSlider(
                  items: List.generate(
                    context.read<HomeBloc>().userData!.bannerImage.data.length,
                    (index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: CachedNetworkImage(
                          imageUrl: context
                              .read<HomeBloc>()
                              .userData!
                              .bannerImage
                              .data[index]
                              .image,
                          // height: size.width * 0.2,
                          width: size.width,
                          fit: BoxFit.fill,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Center(
                            child: Text(
                              "",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  options: CarouselOptions(
                    height: size.width * 0.2,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.95,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 2),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 300),
                    autoPlayCurve: Curves.easeInOut,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      context.read<HomeBloc>().bannerIndex = index;
                      context.read<HomeBloc>().add(UpdateEvent());
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.025),
                if (context.read<HomeBloc>().userData!.bannerImage.data.length >
                    1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      context
                          .read<HomeBloc>()
                          .userData!
                          .bannerImage
                          .data
                          .length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            height: size.width * 0.02,
                            width: size.width * 0.02,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.read<HomeBloc>().bannerIndex ==
                                        index
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).primaryColorLight),
                          ),
                        );
                      },
                    ),
                  )
              ],
            );
          },
        ));
  }
}
