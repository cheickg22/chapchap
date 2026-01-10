import 'package:flutter/material.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';

class FareBreakup extends StatelessWidget {
  final String text;
  final String price;
  final dynamic textcolor;
  final dynamic pricecolor;
  final dynamic fntweight;
  final dynamic showBorder;
  final dynamic padding;

  const FareBreakup(
      {super.key,
      required this.text,
      required this.price,
      this.textcolor,
      this.pricecolor,
      this.fntweight,
      this.showBorder,
      this.padding});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding: EdgeInsets.only(
          top: padding ?? size.width * 0.025,
          bottom: padding ?? size.width * 0.025),
      decoration: BoxDecoration(
          border: (showBorder == null || showBorder == true)
              ? Border(
                  bottom: BorderSide(
                      color: AppColors.textSelectionColor
                          .withAlpha((0.5 * 255).toInt())))
              : (showBorder == 'top')
                  ? Border(
                      top: BorderSide(
                          color: AppColors.textSelectionColor
                              .withAlpha((0.5 * 255).toInt())))
                  : const Border()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.6,
            child: MyText(
              text: text,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: size.width * 0.04,
                  fontWeight: fntweight ?? FontWeight.w400,
                  color: textcolor ?? Theme.of(context).primaryColorDark),
              maxLines: 2,
            ),
          ),
          SizedBox(
            width: size.width * 0.2,
            child: MyText(
              text: price,
              textAlign: TextAlign.end,
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: size.width * 0.04,
                  fontWeight: fntweight ?? FontWeight.w400,
                  color: pricecolor ?? Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }
}
