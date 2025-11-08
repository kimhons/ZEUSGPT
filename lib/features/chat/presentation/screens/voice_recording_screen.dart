import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/responsive.dart';

/// Recording state
enum RecordingState {
  idle,
  recording,
  paused,
  completed,
}

/// Voice recording result
class VoiceRecordingResult {
  const VoiceRecordingResult({
    required this.filePath,
    required this.duration,
    this.fileSize,
  });

  final String filePath;
  final Duration duration;
  final int? fileSize;
}

/// Screen for recording voice messages with waveform visualization
class VoiceRecordingScreen extends ConsumerStatefulWidget {
  const VoiceRecordingScreen({
    required this.conversationId,
    this.maxDuration = const Duration(minutes: 5),
    super.key,
  });

  final String conversationId;
  final Duration maxDuration;

  @override
  ConsumerState<VoiceRecordingScreen> createState() =>
      _VoiceRecordingScreenState();
}

class _VoiceRecordingScreenState extends ConsumerState<VoiceRecordingScreen>
    with SingleTickerProviderStateMixin {
  RecordingState _state = RecordingState.idle;
  Duration _currentDuration = Duration.zero;
  Timer? _durationTimer;
  late AnimationController _pulseController;
  final List<double> _waveformData = List.filled(50, 0.1);
  Timer? _waveformTimer;
  String? _recordedFilePath;
  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start recording automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _waveformTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // In a real implementation, this would request microphone permission
    // and start audio recording using audio recording packages like:
    // - record package
    // - flutter_sound
    // - audio_waveforms

    setState(() {
      _state = RecordingState.recording;
      _currentDuration = Duration.zero;
    });

    // Announce recording start for screen readers
    SemanticsService.announce(
      'Recording started',
      TextDirection.ltr,
    );

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state != RecordingState.recording) return;

      setState(() {
        _currentDuration += const Duration(milliseconds: 100);
      });

      // Check max duration
      if (_currentDuration >= widget.maxDuration) {
        _stopRecording();
      }
    });

    // Start waveform animation
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state != RecordingState.recording) return;

      setState(() {
        _waveformData.removeAt(0);
        _waveformData.add(0.2 + Random().nextDouble() * 0.8);
      });
    });
  }

  Future<void> _pauseRecording() async {
    // In a real implementation, pause the audio recording
    _durationTimer?.cancel();
    _waveformTimer?.cancel();

    setState(() {
      _state = RecordingState.paused;
    });
  }

  Future<void> _resumeRecording() async {
    // In a real implementation, resume the audio recording
    _startRecording();
  }

  Future<void> _stopRecording() async {
    // In a real implementation, stop the audio recording and get file path
    _durationTimer?.cancel();
    _waveformTimer?.cancel();

    // Simulate recorded file path
    final filePath = '/path/to/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    setState(() {
      _state = RecordingState.completed;
      _recordedFilePath = filePath;
    });

    // Announce recording completion for screen readers
    SemanticsService.announce(
      'Recording completed. Duration: ${_formatDuration(_currentDuration)}',
      TextDirection.ltr,
    );
  }

  Future<void> _deleteRecording() async {
    // In a real implementation, delete the recorded file
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text(
          'Are you sure you want to delete this recording? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _state = RecordingState.idle;
        _currentDuration = Duration.zero;
        _recordedFilePath = null;
        _playbackPosition = Duration.zero;
        _isPlaying = false;
      });

      _startRecording();
    }
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      // Pause playback
      _playbackTimer?.cancel();
      setState(() => _isPlaying = false);
    } else {
      // Start playback
      setState(() => _isPlaying = true);

      _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isPlaying) {
          timer.cancel();
          return;
        }

        setState(() {
          _playbackPosition += const Duration(milliseconds: 100);

          if (_playbackPosition >= _currentDuration) {
            _playbackPosition = Duration.zero;
            _isPlaying = false;
            timer.cancel();
          }
        });
      });
    }
  }

  void _sendRecording() {
    if (_recordedFilePath == null) return;

    final result = VoiceRecordingResult(
      filePath: _recordedFilePath!,
      duration: _currentDuration,
      fileSize: 1024 * 256, // Simulated file size
    );

    context.pop(result);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () async {
            if (_state == RecordingState.recording || _state == RecordingState.paused) {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Discard Recording'),
                  content: const Text(
                    'Are you sure you want to discard this recording?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );

              if (shouldClose == true && mounted) {
                context.pop();
              }
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _state == RecordingState.completed ? 'Voice Message' : 'Recording...',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1200 : double.infinity,
          child: Column(
            children: [
              Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording indicator or completed badge
                  if (_state == RecordingState.recording ||
                      _state == RecordingState.paused)
                    _buildRecordingIndicator()
                  else
                    _buildCompletedBadge(),

                  const SizedBox(height: AppSpacing.xl * 2),

                  // Duration display
                  Text(
                    _formatDuration(_currentDuration),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Max duration indicator
                  if (_state != RecordingState.completed)
                    Text(
                      'Max ${_formatDuration(widget.maxDuration)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xl * 2),

                  // Waveform visualization
                  _buildWaveform(),

                  const SizedBox(height: AppSpacing.xl),

                  // Playback progress (only when completed)
                  if (_state == RecordingState.completed)
                    _buildPlaybackControls(),
                ],
              ),
            ),

            // Control buttons
            _buildControlButtons(),
            ],
          ),  // Close Column
        ),  // Close ResponsiveCenter
      ),  // Close SafeArea
    );  // Close Scaffold
  }

  Widget _buildRecordingIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.zeusGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5 * _pulseController.value),
                blurRadius: 30 + (20 * _pulseController.value),
                spreadRadius: 10 * _pulseController.value,
              ),
            ],
          ),
          child: Icon(
            _state == RecordingState.recording ? Icons.mic : Icons.pause,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.zeusGradient,
      ),
      child: const Icon(
        Icons.check_circle,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildWaveform() {
    if (_state == RecordingState.completed) {
      // Show static waveform
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _waveformData.map((amplitude) {
              return Container(
                width: 3,
                height: amplitude * 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    // Show animated waveform during recording
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _waveformData.map((amplitude) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 3,
              height: amplitude * 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // Playback slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: _playbackPosition.inMilliseconds.toDouble(),
              max: _currentDuration.inMilliseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _playbackPosition = Duration(milliseconds: value.toInt());
                });
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Play/pause button
          Semantics(
            label: _isPlaying ? 'Pause playback' : 'Play recording',
            button: true,
            child: ElevatedButton.icon(
              onPressed: _togglePlayback,
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(_isPlaying ? 'Pause' : 'Play'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    if (_state == RecordingState.completed) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Delete button
            Expanded(
              child: Semantics(
                label: 'Delete recording',
                button: true,
                child: OutlinedButton.icon(
                  onPressed: _deleteRecording,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Send button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _sendRecording,
                icon: const Icon(Icons.send),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Delete/Cancel button
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close, color: Colors.red, size: 32),
            tooltip: 'Cancel',
          ),

          const SizedBox(width: AppSpacing.lg),

          // Pause/Resume button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              onPressed: _state == RecordingState.recording
                  ? _pauseRecording
                  : _resumeRecording,
              icon: Icon(
                _state == RecordingState.recording ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 32,
              ),
              tooltip: _state == RecordingState.recording ? 'Pause' : 'Resume',
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Stop/Complete button
          Semantics(
            label: _state == RecordingState.recording
                ? 'Stop recording. Duration: ${_formatDuration(_currentDuration)}'
                : 'Complete recording',
            button: true,
            enabled: true,
            child: IconButton(
              onPressed: _stopRecording,
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: 'Complete',
            ),
          ),
        ],
      ),
    );
  }
}
