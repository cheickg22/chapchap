import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/local_data.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_appbar.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/auth/presentation/pages/auth_page.dart';
import 'package:restart_user/l10n/app_localizations.dart';

import '../../../widgets/edit_options.dart';

class CompanyInformationPage extends StatefulWidget {
  static const String routeName = '/companyInformationPage';

  const CompanyInformationPage({super.key});

  @override
  State<CompanyInformationPage> createState() => _CompanyInformationPageState();
}

class _CompanyInformationPageState extends State<CompanyInformationPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocListener<AccBloc, AccState>(listener: (context, state) async {
      if (state is VehiclesLoadingStartState) {
        CustomLoader.loader(context);
      }

      if (state is VehiclesLoadingStopState) {
        CustomLoader.dismiss(context);
      }
      if (state is UserUnauthenticatedState) {
        final type = await AppSharedPreference.getUserType();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
            context, AuthPage.routeName, (route) => false,
            arguments: AuthPageArguments(type: type));
      }
    }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
      return Scaffold(
        appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.companyInfo,
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!
                            .registeredFor
                            .toString()
                            .replaceAll('1111', userData!.transportType),
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.width * 0.045,
                      ),
                      EditOptions(
                        text: userData!.serviceLocationName.toString(),
                        header: AppLocalizations.of(context)!.serviceLocation,
                        onTap: () {},
                      ),
                      EditOptions(
                        text: userData!.companyName.toString(),
                        header: AppLocalizations.of(context)!.comapnyName,
                        onTap: () {},
                      ),
                      EditOptions(
                        text: userData!.companyAddress.toString(),
                        header: AppLocalizations.of(context)!.companyAddress,
                        onTap: () {},
                      ),
                      EditOptions(
                        text: userData!.companyCity.toString(),
                        header: AppLocalizations.of(context)!.city,
                        onTap: () {},
                      ),
                      EditOptions(
                        text: userData!.companyPostalCode.toString(),
                        header: AppLocalizations.of(context)!.postalCode,
                        onTap: () {},
                      ),
                      EditOptions(
                        text: userData!.companyTaxNumber.toString(),
                        header: AppLocalizations.of(context)!.taxNumber,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.width * 0.05,
            )
          ],
        ),
      );
    }));
  }
}
