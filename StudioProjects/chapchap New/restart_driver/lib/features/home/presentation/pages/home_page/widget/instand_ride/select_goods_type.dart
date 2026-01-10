import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class SelectGoodsTypeWidget extends StatelessWidget {
  const SelectGoodsTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height:
                          MediaQuery.paddingOf(context).top + size.width * 0.1,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                size: size.width * 0.07,
                                color: Theme.of(context).primaryColorDark,
                              )),
                          SizedBox(width: size.width * 0.05),
                          Expanded(
                              child: MyText(
                            text: AppLocalizations.of(context)!.chooseGoods,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                          ))
                        ],
                      ),
                    ),
                    SizedBox(height: size.width * 0.05),
                    Expanded(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            itemCount:
                                context.read<HomeBloc>().goodsList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, i) {
                              return InkWell(
                                onTap: () {
                                  context.read<HomeBloc>().add(ChangeGoodsEvent(
                                      id: context
                                          .read<HomeBloc>()
                                          .goodsList[i]
                                          .id));
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(
                                      0,
                                      size.width * 0.025,
                                      0,
                                      size.width * 0.025),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: size.width * 0.05,
                                        width: size.width * 0.05,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: (context
                                                            .read<HomeBloc>()
                                                            .choosenGoods ==
                                                        context
                                                            .read<HomeBloc>()
                                                            .goodsList[i]
                                                            .id)
                                                    ? Theme.of(context)
                                                        .primaryColorDark
                                                    : AppColors.darkGrey)),
                                        alignment: Alignment.center,
                                        child: Container(
                                          height: size.width * 0.03,
                                          width: size.width * 0.03,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: (context
                                                          .read<HomeBloc>()
                                                          .choosenGoods ==
                                                      context
                                                          .read<HomeBloc>()
                                                          .goodsList[i]
                                                          .id)
                                                  ? Theme.of(context)
                                                      .primaryColorDark
                                                  : Colors.transparent),
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 0.025,
                                      ),
                                      Expanded(
                                          child: MyText(
                                        text: context
                                            .read<HomeBloc>()
                                            .goodsList[i]
                                            .name,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                        maxLines: 2,
                                      ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    )),
                    SizedBox(
                      height: size.width * 0.03,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              context.read<HomeBloc>().goodsSize = 'Loose';
                              FocusScope.of(context).unfocus();
                              context.read<HomeBloc>().goodsSizeText.clear();
                              context.read<HomeBloc>().add(UpdateEvent());
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: size.width * 0.05,
                                  width: size.width * 0.05,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: (context
                                                    .read<HomeBloc>()
                                                    .goodsSize ==
                                                'Loose')
                                            ? Theme.of(context).primaryColorDark
                                            : AppColors.darkGrey),
                                  ),
                                  alignment: Alignment.center,
                                  child: Container(
                                    height: size.width * 0.03,
                                    width: size.width * 0.03,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: (context
                                                    .read<HomeBloc>()
                                                    .goodsSize ==
                                                'Loose')
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 0.025,
                                ),
                                MyText(
                                  text: AppLocalizations.of(context)!.loose,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 2,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          MyText(
                              text: AppLocalizations.of(context)!.or,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Expanded(
                              child: CustomTextField(
                            hintText: AppLocalizations.of(context)!.qtyWithUnit,
                            onChange: (v) {
                              if (v.isNotEmpty) {
                                context.read<HomeBloc>().goodsSize = v;
                              } else {
                                context.read<HomeBloc>().goodsSize = 'Loose';
                              }
                              context.read<HomeBloc>().add(UpdateEvent());
                            },
                            controller: context.read<HomeBloc>().goodsSizeText,
                            keyboardType: TextInputType.emailAddress,
                          ))
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.width * 0.03,
                    ),
                    CustomButton(
                        buttonName: AppLocalizations.of(context)!.createRequest,
                        onTap: () {
                          if (context.read<HomeBloc>().choosenGoods != null) {
                            context.read<HomeBloc>().add(ShowImagePickEvent());
                          }
                          Navigator.pop(context);
                        }),
                    SizedBox(height: size.width * 0.1),
                  ],
                ),
              )),
        );
      },
    );
  }
}
