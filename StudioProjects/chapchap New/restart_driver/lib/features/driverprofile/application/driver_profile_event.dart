part of 'driver_profile_bloc.dart';

abstract class DriverProfileEvent {}

class OpenVehicleInformationEvent extends DriverProfileEvent {}

class GetServiceLocationEvent extends DriverProfileEvent {
  final String type;
  GetServiceLocationEvent({required this.type});
}

class GetVehicleTypeEvent extends DriverProfileEvent {
  final String id;
  final String type;
  final String from;
  GetVehicleTypeEvent(
      {required this.id, required this.type, required this.from});
}

class GetVehicleMakeEvent extends DriverProfileEvent {
  final String type;
  final String iconType;
  final String id;
  GetVehicleMakeEvent(
      {required this.type, required this.iconType, required this.id});
}

class GetVehicleModelEvent extends DriverProfileEvent {
  final String id;
  GetVehicleModelEvent({required this.id});
}

class UpdateVehicleTypeEvent extends DriverProfileEvent {
  final String id;
  UpdateVehicleTypeEvent({required this.id});
}

class UpdateVehicleEvent extends DriverProfileEvent {
  final String from;
  UpdateVehicleEvent({required this.from});
}

class DriverUpdateEvent extends DriverProfileEvent {}

class GetNeededDocumentsEvent extends DriverProfileEvent {
  final String? fleetId;
  final bool initialCall;
  GetNeededDocumentsEvent({required this.fleetId, required this.initialCall});
}

class GetInitialDataEvent extends DriverProfileEvent {
  final String? from;
  final String? fleetId;
  GetInitialDataEvent({this.from, this.fleetId});
}

class ChooseDocumentEvent extends DriverProfileEvent {
  final String? id;
  ChooseDocumentEvent({required this.id});
}

class PickImageEvent extends DriverProfileEvent {
  final ImageSource source;
  final bool isFront;
  PickImageEvent({required this.source, required this.isFront});
}

class ChooseDateEvent extends DriverProfileEvent {
  final BuildContext context;
  ChooseDateEvent({required this.context});
}

class UploadDocumentEvent extends DriverProfileEvent {
  final String id;
  final String? fleetId;
  UploadDocumentEvent({required this.id, required this.fleetId});
}

class ModifyDocEvent extends DriverProfileEvent {}

class EnableEditEvent extends DriverProfileEvent {
  final bool isEditable;

  EnableEditEvent({required this.isEditable});
}

class DriverGetUserDetailsEvent extends DriverProfileEvent {}
