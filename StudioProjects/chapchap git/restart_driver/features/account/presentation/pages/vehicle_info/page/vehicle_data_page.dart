import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_user/common/app_arguments.dart';
import 'package:restart_user/common/app_colors.dart';
import 'package:restart_user/common/app_images.dart';
import 'package:restart_user/core/model/user_detail_model.dart';
import 'package:restart_user/core/utils/custom_button.dart';
import 'package:restart_user/core/utils/custom_loader.dart';
import 'package:restart_user/core/utils/custom_text.dart';
import 'package:restart_user/features/account/application/acc_bloc.dart';
import 'package:restart_user/features/account/presentation/pages/vehicle_info/widget/vehicle_owner_shimmer.dart';
import 'package:restart_user/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_user/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_appbar.dart';
import '../widget/assigned_drivers_widget.dart';
import '../../../widgets/edit_options.dart';
import '../widget/fleet_vehicle_details.dart';

class VehicleDataPage extends StatefulWidget {
  static const String routeName = '/vehicleInformation';
  final VehicleDataArguments? args;

  const VehicleDataPage({super.key, this.args});

  @override
  State<VehicleDataPage> createState() => _VehicleDataPageState();
}

class _VehicleDataPageState extends State<VehicleDataPage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()..add(GetVehiclesEvent()),
        child: BlocListener<AccBloc, AccState>(listener: (context, state) {
          if (state is VehiclesLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is VehiclesLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is ShowAssignDriverState) {
            if (context.read<AccBloc>().driverData.isNotEmpty) {
              showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (_) {
                    return AssignedDriversWidget(cont: context);
                  });
            } else {
              showModalBottomSheet(
                  backgroundColor: AppColors.white,
                  context: context,
                  builder: (builder) {
                    return Container(
                        height: size.height * 0.3,
                        width: size.width,
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white,
                        ),
                        child: Center(
                          child: MyText(
                            text:
                                AppLocalizations.of(context)!.noDriverAvailable,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.red),
                            maxLines: 5,
                          ),
                        ));
                  });
            }
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.vehicleInfo,
                automaticallyImplyLeading: true,
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: size.width * 0.03),
                            (userData!.role == 'driver')
                                ? (userData!.vehicleTypeName != '')
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Column(
                                          children: [
                                            EditOptions(
                                              text: userData!.vehicleTypeName,
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .vehicleType,
                                              onTap: () {},
                                            ),
                                            EditOptions(
                                              text: userData!.carMake,
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .vehicleMake,
                                              onTap: () {},
                                            ),
                                            EditOptions(
                                              text: userData!.carModel,
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .vehicleModel,
                                              onTap: () {},
                                            ),
                                            EditOptions(
                                              text: userData!.carNumber
                                                  .toString(),
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .vehicleNumber,
                                              onTap: () {},
                                            ),
                                            EditOptions(
                                              text:
                                                  userData!.carColor.toString(),
                                              header:
                                                  AppLocalizations.of(context)!
                                                      .vehicleColor,
                                              onTap: () {},
                                            ),
                                            SizedBox(
                                                height: size.height * 0.05),
                                            if (userData!.ownerId == null ||
                                                userData!.ownerId == '')
                                              CustomButton(
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .edit,
                                                  onTap: () async {
                                                    await Navigator.pushNamed(
                                                      context,
                                                      DriverProfilePage
                                                          .routeName,
                                                      arguments:
                                                          VehicleUpdateArguments(
                                                              from: 'vehicle'),
                                                    ).then((_) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      context
                                                          .read<AccBloc>()
                                                          .add(UpdateEvent());
                                                    });
                                                  })
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          Image.asset(AppImages.historyNoData),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .vehicleNotAssigned,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      )
                                : (context.read<AccBloc>().vehicleData.isEmpty)
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.noVehicleInfo,
                                            width: 300,
                                          ),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .noVehicleCreated,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      )
                                    : FleetVehicleDetailsWidget(cont: context)
                          ],
                        ),
                      ),
                    ),
                    if (userData!.role == 'owner')
                      Column(
                        children: [
                          SizedBox(height: size.width * 0.05),
                          if (context.read<AccBloc>().isLoading)
                            VehicleOwnerShimmerWidget.circular(
                                width: size.width, height: size.height),
                          if (!context.read<AccBloc>().isLoading)
                            SizedBox(
                              width: size.width * 0.9,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      var nav = await Navigator.pushNamed(
                                          context, DriverProfilePage.routeName,
                                          arguments: VehicleUpdateArguments(
                                              from: 'owner'));
                                      if (nav != null && nav == true) {
                                        if (!context.mounted) return;
                                        context
                                            .read<AccBloc>()
                                            .add(GetVehiclesEvent());
                                      }
                                    },
                                    child: Container(
                                      width: size.width * 0.128,
                                      height: size.width * 0.128,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppColors.darkGrey),
                                          color: AppColors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Theme.of(context)
                                                    .shadowColor,
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: Icon(
                                        Icons.add,
                                        size: size.width * 0.1,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    SizedBox(height: size.width * 0.05)
                  ],
                ),
              ),
            ),
          );
        })));
  }
}
