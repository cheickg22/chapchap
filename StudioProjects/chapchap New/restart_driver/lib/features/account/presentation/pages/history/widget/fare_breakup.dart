import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

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
    final paddingValue = EdgeInsets.only(
        top: padding ?? size.width * 0.025,
        bottom: padding ?? size.width * 0.025);

    AppColors.textSelectionColor.withAlpha((0.5 * 255).toInt());

    Widget content = Padding(
      padding: paddingValue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.6,
            child: MyText(
              text: text,
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 16,
                  fontWeight: fntweight ?? FontWeight.w200,
                  color: textcolor ?? Theme.of(context).primaryColorDark),
              maxLines: 2,
            ),
          ),
          SizedBox(
            width: size.width * 0.2,
            child: MyText(
              text: price,
              textAlign: TextAlign.end,
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: 16,
                  fontWeight: fntweight ?? FontWeight.w200,
                  color: pricecolor ?? Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );

    if (showBorder == null || showBorder == true) {
      return DottedBorder(
        color: AppColors.borderColors,
        strokeWidth: 1,
        dashPattern: const [4, 2],
        padding: EdgeInsets.zero,
        customPath: (size) {
          final path = Path();
          path.moveTo(0, size.height);
          path.lineTo(size.width, size.height);
          return path;
        },
        child: content,
      );
    } else if (showBorder == 'top') {
      return DottedBorder(
        color: AppColors.borderColors,
        strokeWidth: 1,
        dashPattern: const [4, 2],
        padding: EdgeInsets.zero,
        customPath: (size) {
          final path = Path();
          path.moveTo(0, 0);
          path.lineTo(size.width, 0);
          return path;
        },
        child: content,
      );
    } else {
      return content;
    }
  }
}
