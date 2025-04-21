import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lets_brew/constants/theme_constants.dart';
import 'package:lets_brew/models/coffee_model.dart';
import 'package:lets_brew/services/timer_service.dart';

class BrewingTimerWidget extends StatelessWidget {
  final Coffee coffee;
  final VoidCallback onClose;

  const BrewingTimerWidget({
    super.key,
    required this.coffee,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<BrewTimerService>(
      builder: (context, timerService, child) {
        return Container(
          color: ThemeConstants.darkGrey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Header with close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Brewing ${coffee.name}',
                        style: TextStyle(
                          color: ThemeConstants.cream,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: ThemeConstants.cream),
                        onPressed: () {
                          timerService.stopTimer();
                          onClose();
                        },
                      ),
                    ],
                  ),

                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Coffee icon
                          Icon(
                            Icons.coffee,
                            size: 60,
                            color: ThemeConstants.brown,
                          ),
                          const SizedBox(height: 40),

                          // Timer display
                          _buildTimerDisplay(timerService),
                          const SizedBox(height: 40),

                          // Progress bar
                          _buildProgressBar(timerService),
                          const SizedBox(height: 40),

                          // Current brewing step
                          _buildCurrentStep(timerService),
                          const SizedBox(height: 60),

                          // Timer controls
                          _buildTimerControls(timerService),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Build timer display
  Widget _buildTimerDisplay(BrewTimerService timerService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Elapsed time
        Column(
          children: [
            Text(
              'Elapsed',
              style: TextStyle(color: ThemeConstants.lightBrown, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timerService.totalTime - timerService.remainingTime),
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        // Main timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: ThemeConstants.darkPurple,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            timerService.formattedRemainingTime,
            style: TextStyle(
              color: ThemeConstants.cream,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Total time
        Column(
          children: [
            Text(
              'Total',
              style: TextStyle(color: ThemeConstants.lightBrown, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              timerService.formattedTotalTime,
              style: TextStyle(
                color: ThemeConstants.cream,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build progress bar
  Widget _buildProgressBar(BrewTimerService timerService) {
    final double progress = timerService.progress / 100;

    return Column(
      children: [
        // Progress percentage
        Text(
          '${timerService.progress.toStringAsFixed(0)}%',
          style: TextStyle(
            color: ThemeConstants.cream,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Actual progress bar
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: ThemeConstants.darkGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemeConstants.darkPurple.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.brown),
            ),
          ),
        ),
      ],
    );
  }

  // Build current brewing step
  Widget _buildCurrentStep(BrewTimerService timerService) {
    final currentStepIndex = timerService.currentStep;
    final steps = timerService.brewingSteps;

    if (steps.isEmpty) return const SizedBox();

    return Column(
      children: [
        Text(
          'Current Step',
          style: TextStyle(color: ThemeConstants.lightBrown, fontSize: 16),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeConstants.darkPurple.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Animated coffee icon
              SpinKitPulse(color: ThemeConstants.brown, size: 30),
              const SizedBox(width: 16),

              // Step text
              Expanded(
                child: Text(
                  steps[currentStepIndex],
                  style: TextStyle(
                    color: ThemeConstants.cream,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Step indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(steps.length, (index) {
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    index == currentStepIndex
                        ? ThemeConstants.brown
                        : index < currentStepIndex
                        ? ThemeConstants.lightBrown
                        : ThemeConstants.darkGrey.withOpacity(0.5),
                border: Border.all(
                  color:
                      index <= currentStepIndex
                          ? Colors.transparent
                          : ThemeConstants.darkPurple,
                  width: 1,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Build timer controls
  Widget _buildTimerControls(BrewTimerService timerService) {
    final bool isActive = timerService.isActive;
    final bool isPaused = timerService.isPaused;

    // Extract brewing step descriptions for the timer service
    List<String> getBrewingStepDescriptions() {
      if (coffee.brewingSteps.isEmpty) {
        return [];
      }
      return coffee.brewingSteps.map((step) => step.description).toList();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reset button
        if (isActive)
          ElevatedButton.icon(
            onPressed: timerService.resetTimer,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.darkPurple,
              foregroundColor: ThemeConstants.cream,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),

        const SizedBox(width: 16),

        // Play/Pause button
        ElevatedButton.icon(
          onPressed:
              isActive
                  ? (isPaused
                      ? timerService.resumeTimer
                      : timerService.pauseTimer)
                  : () => timerService.startTimer(
                    coffee.brewTime,
                    steps: getBrewingStepDescriptions(),
                  ),
          icon: Icon(
            isActive
                ? (isPaused ? Icons.play_arrow : Icons.pause)
                : Icons.play_arrow,
          ),
          label: Text(isActive ? (isPaused ? 'Resume' : 'Pause') : 'Start'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConstants.brown,
            foregroundColor: ThemeConstants.cream,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),

        const SizedBox(width: 16),

        // Finish button
        ElevatedButton.icon(
          onPressed: () {
            timerService.stopTimer();
            onClose();
          },
          icon: const Icon(Icons.done),
          label: const Text('Finish'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: ThemeConstants.cream,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Format time in seconds to MM:SS
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;

    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }
}
