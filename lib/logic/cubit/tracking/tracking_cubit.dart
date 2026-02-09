import 'package:flutter_bloc/flutter_bloc.dart';
import 'tracking_state.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/dataproviders/exception.dart';

class TrackingCubit extends Cubit<TrackingState> {
  final LocationRepository _locationRepository;

  TrackingCubit(this._locationRepository) : super(TrackingInitial());

  /// Track a commande by tracking ID - IMPROVED ERROR HANDLING
  Future<void> trackCommande(String trackingId) async {
    if (isClosed) return;
    
    // Validate input
    final cleanTrackingId = trackingId.trim().toUpperCase();
    if (cleanTrackingId.isEmpty) {
      emit(const TrackingError('Veuillez entrer un numéro de suivi'));
      return;
    }

    emit(TrackingLoading());
    
    try {
      print('🔍 TrackingCubit: Tracking commande: $cleanTrackingId');
      
      final tracking = await _locationRepository.trackCommande(cleanTrackingId);
      
      print('✅ TrackingCubit: Tracking data loaded successfully');
      
      if (!isClosed) {
        emit(TrackingLoaded(tracking));
      }
      
    } on NotFoundException catch (e) {
      print('❌ TrackingCubit: Tracking not found - ${e.message}');
      if (!isClosed) emit(TrackingNotFound());
    } on InvalidInputException catch (e) {
      print('❌ TrackingCubit: Invalid input - ${e.message}');
      if (!isClosed) emit(TrackingError(e.message));
    } on NoInternetException catch (e) {
      print('❌ TrackingCubit: No internet - ${e.message}');
      if (!isClosed) emit(TrackingError(e.message));
    } on TimeoutException catch (e) {
      print('❌ TrackingCubit: Timeout - ${e.message}');
      if (!isClosed) emit(TrackingError(e.message));
    } on FetchDataException catch (e) {
      print('❌ TrackingCubit: Server error - ${e.message}');
      if (!isClosed) emit(TrackingError(e.message));
    } on BadRequestException catch (e) {
      print('❌ TrackingCubit: Bad request - ${e.message}');
      // Check if the error suggests tracking not found
      if (e.message.toLowerCase().contains('not found') || 
          e.message.toLowerCase().contains('introuvable')) {
        if (!isClosed) emit(TrackingNotFound());
      } else {
        if (!isClosed) emit(TrackingError(e.message));
      }
    } on CustomException catch (e) {
      print('❌ TrackingCubit: Custom error - ${e.message}');
      if (!isClosed) emit(TrackingError(e.message));
    } catch (e) {
      print('❌ TrackingCubit: Unexpected error - $e');
      if (!isClosed) emit(const TrackingError('Une erreur inattendue est survenue'));
    }
  }

  /// Clear tracking
  void clearTracking() {
    if (!isClosed) {
      emit(TrackingInitial());
    }
  }

  /// Refresh tracking (call again with same tracking ID)
  Future<void> refreshTracking(String trackingId) async {
    await trackCommande(trackingId);
  }
}