import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_appbar.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class SignatureGetWidget extends StatefulWidget {
  final BuildContext cont;

  const SignatureGetWidget({
    super.key,
    required this.cont,
  });

  @override
  State<SignatureGetWidget> createState() => _SignatureGetWidgetState();
}

class _SignatureGetWidgetState extends State<SignatureGetWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    exportBackgroundColor: Colors.transparent,
    onDrawStart: () => debugPrint('onDrawStart called!'),
    onDrawEnd: () => debugPrint('onDrawEnd called!'),
  );

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            height: size.height,
            width: size.width,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                CustomAppBar(
                  title: AppLocalizations.of(context)!.getUserSignature,
                  automaticallyImplyLeading: true,
                  onBackTap: () {
                    context.read<HomeBloc>().add(ShowSignatureEvent());
                  },
                ),
                SizedBox(height: size.width * 0.1),
                SizedBox(
                  width: size.width * 0.8,
                  child: MyText(
                    text: AppLocalizations.of(context)!.drawSignature,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: size.width * 0.05),
                SizedBox(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  child: DottedBorder(
                    color: Theme.of(context).primaryColorDark,
                    strokeWidth: 1,
                    dashPattern: const [6, 3],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(5),
                    child: Signature(
                      key: const Key('signature'),
                      controller: _controller,
                      height: 300,
                      backgroundColor: Colors.grey[300]!,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      width: size.width * 0.7,
                      buttonName:
                          AppLocalizations.of(context)!.confirmSignature,
                      onTap: () async =>
                          _exportSignatureAndUpdateProof(context),
                    ),
                    SizedBox(
                      width: size.width * 0.01,
                    ),
                    IconButton(
                        onPressed: () => _controller.clear(),
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          size: 30,
                        ))
                  ],
                ),

                // CustomButton(
                //     width: size.width * 0.7,
                //     buttonName: AppLocalizations.of(context)!.clearSignature,
                //     onTap: () => _controller.clear()),

                SizedBox(
                  height: size.width * 0.2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportSignatureAndUpdateProof(
    BuildContext context,
  ) async {
    if (_controller.isEmpty) {
      return;
    }

    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    Directory tempDirectory = await getTemporaryDirectory();
    var directoryPath = tempDirectory.path;
    var temporarySignImgName = DateTime.now();
    var signatureImage = File('$directoryPath/$temporarySignImgName.png');

    signatureImage.writeAsBytesSync(data);
    if (context.mounted) {
      context.read<HomeBloc>().signatureImage = signatureImage.path;
      context.read<HomeBloc>().add(UploadProofEvent(
          image: context.read<HomeBloc>().signatureImage!,
          isBefore: false,
          id: userData!.onTripRequest!.id));
    }
  }
}

/*
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/presentation/widgets/top_bar.dart';
import 'package:restart_user/features/home/application/home_bloc.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dotted_border/dotted_border.dart';

class SignatureGetWidget extends StatefulWidget {
  final BuildContext cont;
  const SignatureGetWidget({
    super.key,
    required this.cont,
  });

  @override
  State<SignatureGetWidget> createState() => _SignatureGetWidgetState();
}

class _SignatureGetWidgetState extends State<SignatureGetWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1,
    exportBackgroundColor: Colors.transparent,
    onDrawStart: () => debugPrint('onDrawStart called!'),
    onDrawEnd: () => debugPrint('onDrawEnd called!'),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return _buildSignatureUI(context, size);
        },
      ),
    );
  }

  Widget _buildSignatureUI(BuildContext context, Size size) {
    return Container(
      height: size.height,
      width: size.width,
      color: Colors.transparent.withAlpha((0.4 * 255).toInt()),
      child: TopBarDesign(
        isHistoryPage: false,
        isOngoingPage: false,
        title: AppLocalizations.of(context)!.getUserSignature,
        onTap: () => context.read<HomeBloc>().add(ShowSignatureEvent()),
        child: Column(
          children: [
            SizedBox(height: size.width * 0.1),
            _buildInstructionText(context, size),
            SizedBox(height: size.width * 0.05),
            _buildSignaturePad(context, size),
            const Spacer(),
            _buildConfirmButton(context, size),
            SizedBox(height: size.width * 0.05),
            _buildClearButton(context, size),
            SizedBox(height: size.width * 0.2),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context, Size size) {
    return SizedBox(
      width: size.width * 0.8,
      child: MyText(
        text: AppLocalizations.of(context)!.drawSignature,
        textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSignaturePad(BuildContext context, Size size) {
    return SizedBox(
      width: size.width * 0.8,
      height: size.width * 0.8,
      child: DottedBorder(
        color: Theme.of(context).primaryColorDark,
        strokeWidth: 1,
        dashPattern: const [6, 3],
        borderType: BorderType.RRect,
        radius: const Radius.circular(5),
        child: Signature(
          key: const Key('signature'),
          controller: _controller,
          height: 300,
          backgroundColor: Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, Size size) {
    return CustomButton(
      width: size.width * 0.7,
      buttonName: AppLocalizations.of(context)!.confirmSignature,
      onTap: () async => _exportSignatureAndUpdateProof(context),
    );
  }

  Widget _buildClearButton(BuildContext context, Size size) {
    return CustomButton(
      width: size.width * 0.7,
      buttonName: AppLocalizations.of(context)!.clearSignature,
      onTap: () => _controller.clear(),
    );
  }

  Future<void> _exportSignatureAndUpdateProof(BuildContext context) async {
    if (_controller.isEmpty) return;

    final Uint8List? data = await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) return;

    final Directory tempDirectory = await getTemporaryDirectory();
    final String directoryPath = tempDirectory.path;
    final String temporarySignImgName = DateTime.now().toString();
    final File signatureImage = File('$directoryPath/$temporarySignImgName.png');

    signatureImage.writeAsBytesSync(data);

    if (context.mounted) {
      context.read<HomeBloc>().signatureImage = signatureImage.path;
      context.read<HomeBloc>().add(UploadProofEvent(
            image: context.read<HomeBloc>().signatureImage!,
            isBefore: false,
            id: userData!.onTripRequest!.id,
          ));
    }
  }
}
*/

/*
import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../account/presentation/widgets/top_bar.dart';
import '../../../../../application/home_bloc.dart';
import 'signature_painter_widget.dart';

class SignatureGetWidget extends StatelessWidget {
  final BuildContext cont;
  const SignatureGetWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            height: size.height,
            width: size.width,
            color: Colors.transparent.withAlpha((0.4 * 255).toInt()),
            child: TopBarDesign(
              isHistoryPage: false,
              isOngoingPage: false,
              title: AppLocalizations.of(context)!.getUserSignature,
              onTap: () {
                context.read<HomeBloc>().add(ShowSignatureEvent());
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.width * 0.1),
                          SizedBox(
                            width: size.width * 0.8,
                            child: MyText(
                              text: AppLocalizations.of(context)!.drawSignature,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: size.width * 0.05),
                          Stack(
                            children: [
                              SizedBox(
                                width: size.width * 0.8,
                                height: size.width * 0.8,
                                child: DottedBorder(
                                    color: Theme.of(context).primaryColorDark,
                                    strokeWidth: 1,
                                    dashPattern: const [6, 3],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(5),
                                    child: Container()),
                              ),
                              Positioned(
                                top: 0,
                                child: SizedBox(
                                  width: size.width * 0.8,
                                  height: size.width * 0.8,
                                  child: RepaintBoundary(
                                    key: context
                                              .read<HomeBloc>()
                                              .screenshotImage,
                                    child: CustomPaint(
                                      painter: SignaturePainterWidget(
                                          pointlist: context
                                              .read<HomeBloc>()
                                              .signaturePoints,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: GestureDetector(
                                  onTapDown: (val) {
                                    final box =
                                        context.findRenderObject() as RenderBox;
                                    final point =
                                        box.globalToLocal(val.globalPosition);
                                    context
                                        .read<HomeBloc>()
                                        .add(UpdateSignEvent(points: {
                                          'point': Offset(
                                              point.dx - size.width * 0.15,
                                              point.dy -
                                                  (((size.height -
                                                          size.width * 1.65)) /
                                                      2) -
                                                  size.width * 0.425),
                                          'action': 'dot to'
                                        }));
                                  },
                                  onTapUp: (val) {
                                    final box =
                                        context.findRenderObject() as RenderBox;
                                    final point =
                                        box.globalToLocal(val.globalPosition);

                                    context
                                        .read<HomeBloc>()
                                        .add(UpdateSignEvent(points: {
                                          'point': Offset(
                                              point.dx - size.width * 0.15,
                                              point.dy -
                                                  (((size.height -
                                                          size.width * 1.65)) /
                                                      2) -
                                                  size.width * 0.425),
                                          'action': 'setstate'
                                        }));
                                  },
                                  onPanStart: (val) {
                                    final box =
                                        context.findRenderObject() as RenderBox;
                                    final point =
                                        box.globalToLocal(val.globalPosition);

                                    context
                                        .read<HomeBloc>()
                                        .add(UpdateSignEvent(points: {
                                          'point': Offset(
                                              point.dx - size.width * 0.15,
                                              point.dy -
                                                  (((size.height -
                                                          size.width * 1.65)) /
                                                      2) -
                                                  size.width * 0.425),
                                          'action': 'move to'
                                        }));
                                  },
                                  onPanUpdate: (val) {
                                    final box =
                                        context.findRenderObject() as RenderBox;
                                    final point =
                                        box.globalToLocal(val.globalPosition);
                                    if (point.dx < size.width * 0.85 &&
                                        point.dx > size.width * 0.15 &&
                                        point.dy >
                                            (((size.height -
                                                        size.width * 1.65)) /
                                                    2) +
                                                size.width * 0.425 &&
                                        point.dy <
                                            (((size.height -
                                                        size.width * 1.65)) /
                                                    2) +
                                                size.width * 1.125) {
                                      context
                                          .read<HomeBloc>()
                                          .add(UpdateSignEvent(points: {
                                            'point': Offset(
                                                point.dx - size.width * 0.15,
                                                point.dy -
                                                    (((size.height -
                                                            size.width *
                                                                1.65)) /
                                                        2) -
                                                    size.width * 0.425),
                                            'action': 'line to'
                                          }));
                                    }
                                  },
                                  onPanEnd: (val) {
                                    context.read<HomeBloc>().add(
                                            UpdateSignEvent(points: {
                                          'point': 'point',
                                          'action': 'setstate'
                                        }));
                                  },
                                  child: Container(
                                    width: size.width * 0.8,
                                    height: size.width * 0.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      CustomButton(
                          width: size.width * 0.7,
                          buttonName:
                              AppLocalizations.of(context)!.confirmSignature,
                          onTap: () async {
                            if (context
                                .read<HomeBloc>()
                                .signaturePoints
                                .isNotEmpty) {
                              RenderRepaintBoundary boundary = context
                                              .read<HomeBloc>()
                                              .screenshotImage
                                  .currentContext!
                                  .findRenderObject() as RenderRepaintBoundary;
                              var image = await boundary.toImage(pixelRatio: 2);
                              var file = await image.toByteData(
                                  format: ImageByteFormat.png);
                              var uintImage = file!.buffer.asUint8List();
                              Directory paths = await getTemporaryDirectory();
                              var path = paths.path;
                              var name = DateTime.now();
                              var signatureImage = File('$path/$name.png');

                              signatureImage.writeAsBytesSync(uintImage);
                              if (!context.mounted) return;
                              context.read<HomeBloc>().signatureImage =
                                  signatureImage.path;
                              context.read<HomeBloc>().add(UploadProofEvent(
                                  image:
                                      context.read<HomeBloc>().signatureImage!,
                                  isBefore: false,
                                  id: userData!.onTripRequest!.id));
                            } else {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .getSignatureError);
                            }
                          }),
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                      CustomButton(
                          width: size.width * 0.7,
                          buttonName:
                              AppLocalizations.of(context)!.clearSignature,
                          onTap: () {
                            context
                                .read<HomeBloc>()
                                .add(UpdateSignEvent(points: null));
                          }),
                      SizedBox(
                        height: size.width * 0.05,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
*/
