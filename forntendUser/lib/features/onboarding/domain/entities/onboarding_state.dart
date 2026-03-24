import 'package:equatable/equatable.dart';

/// Represents the current state of the onboarding process
class OnboardingState extends Equatable {
  final int currentPage;
  final int totalPages;
  final bool isCompleted;
  final bool isLoading;
  final String? error;
  final OnboardingProgress progress;
  final List<OnboardingStep> steps;
  final Map<String, dynamic> userPreferences;
  final DateTime? startTime;
  final DateTime? completionTime;

  const OnboardingState({
    this.currentPage = 0,
    this.totalPages = 3,
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
    this.progress = const OnboardingProgress(),
    this.steps = const [],
    this.userPreferences = const {},
    this.startTime,
    this.completionTime,
  });

  /// Create a copy of this state with updated values
  OnboardingState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isCompleted,
    bool? isLoading,
    String? error,
    OnboardingProgress? progress,
    List<OnboardingStep>? steps,
    Map<String, dynamic>? userPreferences,
    DateTime? startTime,
    DateTime? completionTime,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      progress: progress ?? this.progress,
      steps: steps ?? this.steps,
      userPreferences: userPreferences ?? this.userPreferences,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
    );
  }

  /// Check if user can go to next page
  bool get canGoNext => currentPage < totalPages - 1;

  /// Check if user can go to previous page
  bool get canGoPrevious => currentPage > 0;

  /// Get current step
  OnboardingStep? get currentStep {
    if (steps.isNotEmpty && currentPage < steps.length) {
      return steps[currentPage];
    }
    return null;
  }

  /// Get progress percentage
  double get progressPercentage {
    if (totalPages <= 0) return 0.0;
    return (currentPage + 1) / totalPages;
  }

  /// Check if onboarding is in progress
  bool get isInProgress => !isCompleted && currentPage < totalPages;

  /// Get duration of onboarding
  Duration? get duration {
    if (startTime != null && completionTime != null) {
      return completionTime!.difference(startTime!);
    }
    return null;
  }

  @override
  List<Object?> get props => [
        currentPage,
        totalPages,
        isCompleted,
        isLoading,
        error,
        progress,
        steps,
        userPreferences,
        startTime,
        completionTime,
      ];
}

/// Represents the progress of onboarding
class OnboardingProgress extends Equatable {
  final int completedSteps;
  final int totalSteps;
  final List<int> seenScreens;
  final List<int> completedScreens;

  const OnboardingProgress({
    this.completedSteps = 0,
    this.totalSteps = 3,
    this.seenScreens = const [],
    this.completedScreens = const [],
  });

  /// Get progress percentage
  double get percentage {
    if (totalSteps <= 0) return 0.0;
    return completedSteps / totalSteps;
  }

  /// Check if all steps are completed
  bool get isCompleted => completedSteps >= totalSteps;

  /// Check if specific screen has been seen
  bool hasSeenScreen(int screenIndex) => seenScreens.contains(screenIndex);

  /// Check if specific screen has been completed
  bool hasCompletedScreen(int screenIndex) => completedScreens.contains(screenIndex);

  /// Create a copy with updated values
  OnboardingProgress copyWith({
    int? completedSteps,
    int? totalSteps,
    List<int>? seenScreens,
    List<int>? completedScreens,
  }) {
    return OnboardingProgress(
      completedSteps: completedSteps ?? this.completedSteps,
      totalSteps: totalSteps ?? this.totalSteps,
      seenScreens: seenScreens ?? this.seenScreens,
      completedScreens: completedScreens ?? this.completedScreens,
    );
  }

  @override
  List<Object?> get props => [
        completedSteps,
        totalSteps,
        seenScreens,
        completedScreens,
      ];
}

/// Represents a single onboarding step
class OnboardingStep extends Equatable {
  final int index;
  final String title;
  final String description;
  final String imagePath;
  final bool isRequired;
  final bool isCompleted;
  final Map<String, dynamic>? data;

  const OnboardingStep({
    required this.index,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isRequired = true,
    this.isCompleted = false,
    this.data,
  });

  /// Create a copy with updated values
  OnboardingStep copyWith({
    int? index,
    String? title,
    String? description,
    String? imagePath,
    bool? isRequired,
    bool? isCompleted,
    Map<String, dynamic>? data,
  }) {
    return OnboardingStep(
      index: index ?? this.index,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        index,
        title,
        description,
        imagePath,
        isRequired,
        isCompleted,
        data,
      ];
}

/// Represents onboarding events
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Event when user moves to next page
class OnboardingNextPageEvent extends OnboardingEvent {
  const OnboardingNextPageEvent();
}

/// Event when user moves to previous page
class OnboardingPreviousPageEvent extends OnboardingEvent {
  const OnboardingPreviousPageEvent();
}

/// Event when user skips onboarding
class OnboardingSkipEvent extends OnboardingEvent {
  const OnboardingSkipEvent();
}

/// Event when user completes onboarding
class OnboardingCompleteEvent extends OnboardingEvent {
  final Map<String, dynamic>? userPreferences;

  const OnboardingCompleteEvent({this.userPreferences});

  @override
  List<Object?> get props => [userPreferences];
}

/// Event when user marks a step as completed
class OnboardingStepCompletedEvent extends OnboardingEvent {
  final int stepIndex;
  final Map<String, dynamic>? stepData;

  const OnboardingStepCompletedEvent({
    required this.stepIndex,
    this.stepData,
  });

  @override
  List<Object?> get props => [stepIndex, stepData];
}

/// Event when user marks a screen as seen
class OnboardingScreenSeenEvent extends OnboardingEvent {
  final int screenIndex;

  const OnboardingScreenSeenEvent({required this.screenIndex});

  @override
  List<Object?> get props => [screenIndex];
}

/// Event to load onboarding data
class OnboardingLoadEvent extends OnboardingEvent {
  const OnboardingLoadEvent();
}

/// Event to reset onboarding
class OnboardingResetEvent extends OnboardingEvent {
  const OnboardingResetEvent();
}
