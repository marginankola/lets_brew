import 'dart:async';
import 'package:flutter/foundation.dart';

class BrewTimerService extends ChangeNotifier {
  bool _isActive = false;
  bool _isPaused = false;
  int _totalTime = 0; // Total time in seconds
  int _remainingTime = 0; // Remaining time in seconds
  Timer? _timer;
  int _currentStep = 0;
  List<String> _brewingSteps = [];

  // Getters
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  int get totalTime => _totalTime;
  int get remainingTime => _remainingTime;
  int get currentStep => _currentStep;
  List<String> get brewingSteps => _brewingSteps;

  // Progress percentage (0-100)
  double get progress {
    if (_totalTime == 0) return 0;
    return ((_totalTime - _remainingTime) / _totalTime) * 100;
  }

  // Formatted remaining time (MM:SS)
  String get formattedRemainingTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Formatted total time (MM:SS)
  String get formattedTotalTime {
    final minutes = _totalTime ~/ 60;
    final seconds = _totalTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Default brewing steps
  List<String> _generateDefaultBrewingSteps(int totalTimeInSeconds) {
    final steps = <String>[];

    if (totalTimeInSeconds <= 120) {
      // 2 minutes or less
      steps.add('Prepare your equipment');
      steps.add('Start brewing');
      steps.add('Almost done!');
    } else if (totalTimeInSeconds <= 300) {
      // 5 minutes or less
      steps.add('Prepare your equipment');
      steps.add('Grind your coffee beans');
      steps.add('Start brewing');
      steps.add('Watch it bloom');
      steps.add('Finish brewing');
    } else {
      // Longer than 5 minutes
      steps.add('Prepare your equipment');
      steps.add('Grind your coffee beans');
      steps.add('Heat water to optimal temperature');
      steps.add('Start brewing');
      steps.add('Wait for blooming');
      steps.add('Continue brewing');
      steps.add('Almost done, get ready!');
    }

    return steps;
  }

  // Start the timer with a given duration in seconds
  void startTimer(int seconds, {List<String>? steps}) {
    // Stop any existing timer
    stopTimer();

    // Set initial values
    _totalTime = seconds;
    _remainingTime = seconds;
    _isActive = true;
    _isPaused = false;
    _currentStep = 0;

    // Set brewing steps (user provided or default)
    _brewingSteps = steps ?? _generateDefaultBrewingSteps(seconds);

    // Start the timer
    _startCountdown();

    notifyListeners();
  }

  // Pause the timer
  void pauseTimer() {
    if (_isActive && !_isPaused) {
      _timer?.cancel();
      _isPaused = true;
      notifyListeners();
    }
  }

  // Resume the timer
  void resumeTimer() {
    if (_isActive && _isPaused) {
      _isPaused = false;
      _startCountdown();
      notifyListeners();
    }
  }

  // Reset the timer to initial state
  void resetTimer() {
    if (_isActive) {
      _timer?.cancel();
      _remainingTime = _totalTime;
      _isPaused = false;
      _currentStep = 0;
      _startCountdown();
      notifyListeners();
    }
  }

  // Stop the timer completely
  void stopTimer() {
    _timer?.cancel();
    _isActive = false;
    _isPaused = false;
    _totalTime = 0;
    _remainingTime = 0;
    _currentStep = 0;
    _brewingSteps = [];
    notifyListeners();
  }

  // Internal method to start the countdown
  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;

        // Update the current step based on progress
        if (_brewingSteps.isNotEmpty) {
          final newStep =
              ((_totalTime - _remainingTime) /
                      _totalTime *
                      _brewingSteps.length)
                  .floor();
          if (newStep < _brewingSteps.length && newStep != _currentStep) {
            _currentStep = newStep;
          }
        }

        notifyListeners();
      } else {
        // Timer finished
        _timer?.cancel();
        _isActive = false;
        _isPaused = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
