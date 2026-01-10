part of 'loading_bloc.dart';

abstract class LoaderEvent {}

class LoaderInitEvent extends LoaderEvent {}

class CheckPermissionEvent extends LoaderEvent {}

class LoaderGetLocalDataEvent extends LoaderEvent {}

class UpdateUserLocationEvent extends LoaderEvent {}
