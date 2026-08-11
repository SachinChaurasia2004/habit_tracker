import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/features/profile/presentation/bloc/profile_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/update_name.dart';
import '../../domain/usecases/toggle_notifications.dart';
import '../../domain/usecases/toggle_dark_mode.dart';
import 'profile_event.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;
  final UpdateName updateName;
  final ToggleNotifications toggleNotifications;
  final ToggleDarkMode toggleDarkMode;
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.getProfile,
    required this.updateProfile,
    required this.updateName,
    required this.toggleNotifications,
    required this.toggleDarkMode,
    required this.profileRepository,
  }) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateNameEvent>(_onUpdateName);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<ToggleDarkModeEvent>(_onToggleDarkMode);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
    on<ResetProfileEvent>(_onResetProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getProfile();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final result = await updateProfile(
      UpdateProfileParams(profile: event.profile),
    );

    result.fold(
      (failure) {
        emit(ProfileError(failure.message, profile: currentState.profile));
        // Restore previous state
        emit(currentState);
      },
      (_) => emit(ProfileLoaded(event.profile)),
    );
  }

  Future<void> _onUpdateName(
    UpdateNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final trimmedName = event.name.trim();
    if (trimmedName.isEmpty) return;

    final result = await updateName(trimmedName);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message, profile: currentState.profile));
        emit(currentState);
      },
      (_) {
        final updatedProfile = currentState.profile.copyWith(name: trimmedName);
        emit(ProfileLoaded(updatedProfile));
      },
    );
  }

  Future<void> _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final result = await toggleNotifications(event.enabled);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message, profile: currentState.profile));
        emit(currentState);
      },
      (_) {
        final updatedProfile = currentState.profile.copyWith(
          notificationsEnabled: event.enabled,
        );
        emit(ProfileLoaded(updatedProfile));
      },
    );
  }

  Future<void> _onToggleDarkMode(
    ToggleDarkModeEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final result = await toggleDarkMode(event.enabled);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message, profile: currentState.profile));
        emit(currentState);
      },
      (_) {
        final updatedProfile = currentState.profile.copyWith(
          darkModeEnabled: event.enabled,
        );
        emit(ProfileLoaded(updatedProfile));
      },
    );
  }

  Future<void> _onUpdateAvatar(
    UpdateAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) return;

    emit(ProfileUpdating(currentState.profile));

    final result = await profileRepository.updateAvatar(event.avatarPath);

    result.fold(
      (failure) {
        emit(ProfileError(failure.message, profile: currentState.profile));
        emit(currentState);
      },
      (_) {
        final updatedProfile = currentState.profile.copyWith(
          avatarPath: event.avatarPath,
        );
        emit(ProfileLoaded(updatedProfile));
      },
    );
  }

  Future<void> _onResetProfile(
    ResetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await profileRepository.resetProfile();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) async {
        // Load the new default profile
        final profileResult = await getProfile();
        profileResult.fold(
          (failure) => emit(ProfileError(failure.message)),
          (profile) => emit(ProfileLoaded(profile)),
        );
      },
    );
  }
}
