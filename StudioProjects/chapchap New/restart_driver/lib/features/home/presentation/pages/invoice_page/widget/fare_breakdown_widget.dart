import 'package:flutter/material.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';

class FareBreakdownWidget extends StatelessWidget {
  final BuildContext cont;
  final String name;
  final String price;
  final Color? textColor;
  final bool? showBorder;
  const FareBreakdownWidget(
      {super.key,
      required this.cont,
      required this.name,
      required this.price,
      this.textColor,
      this.showBorder});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      padding:
          EdgeInsets.only(top: size.width * 0.025, bottom: size.width * 0.025),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.5,
                child: MyText(
                  text: name,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 14,
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
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: textColor ?? Theme.of(context).primaryColorDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (showBorder == true)
            const Divider(
              height: 1,
              color: Color(0xFFD9D9D9),
            ),
        ],
      ),
    );
  }
}
