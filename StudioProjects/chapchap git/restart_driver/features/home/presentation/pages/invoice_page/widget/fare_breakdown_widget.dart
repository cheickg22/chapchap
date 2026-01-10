import 'package:flutter/material.dart';
import 'package:restart_user/core/utils/custom_text.dart';

class FareBreakdownWidget extends StatelessWidget {
  final BuildContext cont;
  final String name;
  final String price;
  final Color? textColor;
  const FareBreakdownWidget(
      {super.key,
      required this.cont,
      required this.name,
      required this.price,
      this.textColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding:
          EdgeInsets.only(top: size.width * 0.025, bottom: size.width * 0.025),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: Theme.of(context)
                  .dividerColor
                  .withAlpha((0.2 * 255).toInt())),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.6,
            child: MyText(
              text: name,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.04,
                  color: textColor ?? Theme.of(context).primaryColorDark),
              maxLines: 5,
            ),
          ),
          SizedBox(
            width: size.width * 0.25,
            child: MyText(
              text: price,
              maxLines: 2,
              textAlign: TextAlign.right,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: textColor ?? Theme.of(context).primaryColorDark),
            ),
          ),
        ],
      ),
    );
  }
}
