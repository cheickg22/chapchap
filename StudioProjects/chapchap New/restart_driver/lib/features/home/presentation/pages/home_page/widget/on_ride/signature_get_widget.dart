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
                  titleFontSize: 18,
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
                      textSize: 18,
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
