import 'package:flutter/material.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';

class EditOptions extends StatelessWidget {
  final String text;
  final String header;
  final Function()? onTap;
  final Icon? icon;

  const EditOptions(
      {super.key,
      required this.text,
      required this.header,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final bool showEditIcon = header == AppLocalizations.of(context)!.name ||
        header == AppLocalizations.of(context)!.gender ||
        header == AppLocalizations.of(context)!.email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: header,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      text: text,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              color: Theme.of(context).disabledColor,
                              fontSize: 14),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              (showEditIcon)
                  ? Icon(
                      Icons.edit,
                      size: 15,
                      color: Theme.of(context).disabledColor,
                    )
                  : const SizedBox()
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(
          height: 1,
          color: Color(0xFFD9D9D9),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
