import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restart_tagxi/core/network/failure.dart';
import 'package:restart_tagxi/features/loading/domain/repositories/loader_repo.dart';

class LoaderUsecase {
  final LoaderRepository _loaderRepository;

  const LoaderUsecase(this._loaderRepository);

  Future<Either<Failure, dynamic>> updateUserLocation(
      {required LatLng currentLocation}) async {
    return _loaderRepository.updateUserLocation(
        currentLocation: currentLocation);
  }
}
