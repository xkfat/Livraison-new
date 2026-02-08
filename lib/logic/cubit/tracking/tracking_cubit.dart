import 'package:flutter_bloc/flutter_bloc.dart';
import 'tracking_state.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/dataproviders/exception.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final LocationRepository _locationRepository;

  TrackingCubit(this._locationRepository) : super(TrackingInitial());

  /// Track a commande by tracking ID
  Future<void> trackCommande(String trackingId) async {
    if (trackingId.trim().isEmpty) {
      emit(const TrackingError('Veuillez entrer un numéro de suivi'));
      return;
    }

    emit(TrackingLoading());
    
    try {
      final tracking = await _locationRepository.trackCommande(trackingId.trim().toUpperCase());
      emit(TrackingLoaded(tracking));
    } on NotFoundException catch (e) {
      emit(TrackingNotFound());
    } on InvalidInputException catch (e) {
      emit(TrackingError(e.message));
    } on NoInternetException catch (e) {
      emit(TrackingError(e.message));
    } on TimeoutException catch (e) {
      emit(TrackingError(e.message));
    } on CustomException catch (e) {
      emit(TrackingError(e.message));
    } catch (e) {
      emit(const TrackingError('Une erreur inattendue est survenue'));
    }
  }

  /// Clear tracking
  void clearTracking() {
    emit(TrackingInitial());
  }

  /// Refresh tracking (call again with same tracking ID)
  Future<void> refreshTracking(String trackingId) async {
    await trackCommande(trackingId);
  }
}