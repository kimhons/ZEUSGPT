import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/semantic_icon_button.dart';
import '../../../../core/utils/accessibility_helpers.dart';
import '../../../../core/responsive.dart';

/// Voice message data model
class VoiceMessage {
  const VoiceMessage({
    required this.id,
    required this.url,
    required this.duration,
    this.transcript,
    this.senderName,
    this.timestamp,
    this.fileSize,
  });

  final String id;
  final String url;
  final Duration duration;
  final String? transcript;
  final String? senderName;
  final DateTime? timestamp;
  final int? fileSize;

  String get formattedSize {
    if (fileSize == null) return 'Unknown';
    const kb = 1024;
    const mb = kb * 1024;

    if (fileSize! >= mb) {
      return '${(fileSize! / mb).toStringAsFixed(2)} MB';
    } else {
      return '${(fileSize! / kb).toStringAsFixed(2)} KB';
    }
  }
}

/// Playback state
enum PlaybackState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Screen for playing voice messages with waveform visualization
class VoicePlaybackScreen extends ConsumerStatefulWidget {
  const VoicePlaybackScreen({
    required this.voiceMessage,
    super.key,
  });

  final VoiceMessage voiceMessage;

  @override
  ConsumerState<VoicePlaybackScreen> createState() =>
      _VoicePlaybackScreenState();
}

class _VoicePlaybackScreenState extends ConsumerState<VoicePlaybackScreen>
    with SingleTickerProviderStateMixin {
  PlaybackState _state = PlaybackState.idle;
  Duration _currentPosition = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;
  bool _showTranscript = false;
  Timer? _playbackTimer;
  late AnimationController _waveformController;
  final List<double> _waveformData = List.generate(
    60,
    (index) => 0.2 + Random().nextDouble() * 0.8,
  );

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Auto-start playback and announce page change for accessibility
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announcePageChange('Voice Message Playback');
      _loadAudio();
    });
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _waveformController.dispose();
    super.dispose();
  }

  Future<void> _loadAudio() async {
    setState(() => _state = PlaybackState.loading);

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _state = PlaybackState.idle;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_state == PlaybackState.playing) {
      _pausePlayback();
    } else if (_state == PlaybackState.paused || _state == PlaybackState.idle) {
      _startPlayback();
    } else if (_state == PlaybackState.completed) {
      _restartPlayback();
    }
  }

  void _startPlayback() {
    setState(() => _state = PlaybackState.playing);
    _waveformController.repeat(reverse: true);

    _playbackTimer = Timer.periodic(
      Duration(milliseconds: (100 / _playbackSpeed).round()),
      (timer) {
        if (_state != PlaybackState.playing) {
          timer.cancel();
          return;
        }

        setState(() {
          _currentPosition += Duration(milliseconds: (100 * _playbackSpeed).round());

          if (_currentPosition >= widget.voiceMessage.duration) {
            if (_isLooping) {
              _currentPosition = Duration.zero;
            } else {
              _currentPosition = widget.voiceMessage.duration;
              _state = PlaybackState.completed;
              _waveformController.stop();
              timer.cancel();
            }
          }
        });
      },
    );
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
    _waveformController.stop();
    setState(() => _state = PlaybackState.paused);
  }

  void _restartPlayback() {
    setState(() {
      _currentPosition = Duration.zero;
      _state = PlaybackState.idle;
    });
    _startPlayback();
  }

  void _seekTo(Duration position) {
    setState(() {
      _currentPosition = position;
    });

    // If playing, continue from new position
    if (_state == PlaybackState.playing) {
      _pausePlayback();
      Future.delayed(const Duration(milliseconds: 100), _startPlayback);
    }
  }

  void _skipBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    _seekTo(newPosition.isNegative ? Duration.zero : newPosition);
  }

  void _skipForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    _seekTo(newPosition > widget.voiceMessage.duration
        ? widget.voiceMessage.duration
        : newPosition);
  }

  void _changePlaybackSpeed(double speed) {
    setState(() => _playbackSpeed = speed);

    // If playing, restart timer with new speed
    if (_state == PlaybackState.playing) {
      _pausePlayback();
      Future.delayed(const Duration(milliseconds: 100), _startPlayback);
    }

    showAccessibleSnackBar(
      context,
      'Playback speed: ${speed}x',
    );
  }

  Future<void> _downloadAudio() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Audio'),
        content: const Text('Voice message will be saved to your device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showAccessibleSuccessSnackBar(
                context,
                'Audio downloaded successfully',
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareAudio() async {
    // In a real implementation, use share_plus package
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Audio'),
        content: const Text('Share functionality will be implemented with share_plus package.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SpeedOptionsSheet(
        currentSpeed: _playbackSpeed,
        onSpeedSelected: (speed) {
          _changePlaybackSpeed(speed);
          Navigator.pop(context);
        },
      ),
    );
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
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      appBar: AppBar(
        title: const Text('Voice Message'),
        actions: [
          SemanticIconButton(
            icon: Icons.download,
            label: 'Download audio',
            onPressed: _downloadAudio,
          ),
          SemanticIconButton(
            icon: Icons.share,
            label: 'Share audio',
            onPressed: _shareAudio,
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: context.isDesktop ? 1200 : double.infinity,
          child: _state == PlaybackState.loading
              ? const Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
                    Text('Loading audio...'),
                  ],
                ),
              )
            : _state == PlaybackState.error
                ? _buildErrorState()
                : _buildPlayerInterface(isDark),
        ),  // Close ResponsiveCenter
      ),  // Close SafeArea
    );  // Close Scaffold
  }

  Widget _buildPlayerInterface(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),

          // Sender info
          if (widget.voiceMessage.senderName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.voiceMessage.senderName![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.voiceMessage.senderName!,
                          style: AppTextStyles.bodyLarge().copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.voiceMessage.timestamp != null)
                          Text(
                            _formatTimestamp(widget.voiceMessage.timestamp!),
                            style: AppTextStyles.bodySmall().copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.xl * 2),

          // Waveform visualization
          _buildWaveform(),

          const SizedBox(height: AppSpacing.xl),

          // Duration display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: AppTextStyles.bodyMedium().copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  _formatDuration(widget.voiceMessage.duration),
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: Colors.grey.shade600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Seek slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _currentPosition.inMilliseconds.toDouble(),
                max: widget.voiceMessage.duration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  _seekTo(Duration(milliseconds: value.toInt()));
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Playback controls
          _buildPlaybackControls(),

          const SizedBox(height: AppSpacing.xl),

          // Additional options
          _buildOptionsRow(),

          const SizedBox(height: AppSpacing.xl),

          // Transcript section
          if (widget.voiceMessage.transcript != null)
            _buildTranscriptSection(),

          const SizedBox(height: AppSpacing.xl),

          // Audio info card
          _buildInfoCard(isDark),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SizedBox(
        height: 120,
        child: AnimatedBuilder(
          animation: _waveformController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(_waveformData.length, (index) {
                final progress = _currentPosition.inMilliseconds /
                    widget.voiceMessage.duration.inMilliseconds;
                final waveProgress = index / _waveformData.length;
                final isPassed = waveProgress <= progress;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 3,
                  height: _waveformData[index] * 120 *
                      (_state == PlaybackState.playing && isPassed
                          ? 1.0 + (_waveformController.value * 0.2)
                          : 1.0),
                  decoration: BoxDecoration(
                    gradient: isPassed
                        ? LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          )
                        : null,
                    color: isPassed ? null : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        SemanticIconButton(
          icon: Icons.replay_10,
          label: 'Skip 10 seconds backward',
          onPressed: _skipBackward,
          iconSize: 36,
          color: AppColors.primary,
        ),

        const SizedBox(width: AppSpacing.lg),

        // Main play/pause button
        Semantics(
          label: _state == PlaybackState.playing
              ? 'Pause playback'
              : _state == PlaybackState.completed
                  ? 'Replay audio'
                  : 'Play audio',
          button: true,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.zeusGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              onPressed: _togglePlayback,
              icon: ExcludeSemantics(
                child: Icon(
                  _state == PlaybackState.playing
                      ? Icons.pause
                      : _state == PlaybackState.completed
                          ? Icons.replay
                          : Icons.play_arrow,
                ),
              ),
              iconSize: 40,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.lg),

        // Skip forward
        SemanticIconButton(
          icon: Icons.forward_10,
          label: 'Skip 10 seconds forward',
          onPressed: _skipForward,
          iconSize: 36,
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Playback speed
          OutlinedButton.icon(
            onPressed: _showSpeedOptions,
            icon: const Icon(Icons.speed, size: 18),
            label: Text('${_playbackSpeed}x'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),

          // Loop toggle
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _isLooping = !_isLooping);
              showAccessibleSnackBar(
                context,
                _isLooping ? 'Loop enabled' : 'Loop disabled',
              );
            },
            icon: Icon(
              _isLooping ? Icons.repeat_on : Icons.repeat,
              size: 18,
            ),
            label: const Text('Loop'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _isLooping ? AppColors.primary : Colors.grey,
              side: BorderSide(
                color: _isLooping ? AppColors.primary : Colors.grey,
              ),
            ),
          ),

          // Transcript toggle
          if (widget.voiceMessage.transcript != null)
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _showTranscript = !_showTranscript);
              },
              icon: Icon(
                _showTranscript ? Icons.subtitles : Icons.subtitles_off,
                size: 18,
              ),
              label: const Text('Transcript'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _showTranscript ? AppColors.primary : Colors.grey,
                side: BorderSide(
                  color: _showTranscript ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection() {
    if (!_showTranscript) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.subtitles,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Transcript',
                    style: AppTextStyles.bodyLarge().copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.voiceMessage.transcript!,
                style: AppTextStyles.bodyMedium(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audio Information',
                style: AppTextStyles.bodyLarge().copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInfoRow(Icons.timer, 'Duration', _formatDuration(widget.voiceMessage.duration)),
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.storage, 'File Size', widget.voiceMessage.formattedSize),
              const SizedBox(height: AppSpacing.sm),
              _buildInfoRow(Icons.audio_file, 'Format', 'M4A Audio'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall().copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall().copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Failed to Load Audio',
              style: AppTextStyles.h4().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'There was an error loading the voice message. Please try again.',
              style: AppTextStyles.bodyMedium().copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadAudio,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Speed options bottom sheet
class _SpeedOptionsSheet extends StatelessWidget {
  const _SpeedOptionsSheet({
    required this.currentSpeed,
    required this.onSpeedSelected,
  });

  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: AppColors.zeusGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.speed,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Playback Speed',
                style: AppTextStyles.h4().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._speeds.map(
            (speed) => RadioListTile<double>(
              title: Text(
                '${speed}x',
                style: AppTextStyles.bodyMedium().copyWith(
                  fontWeight: speed == currentSpeed ? FontWeight.w600 : null,
                ),
              ),
              value: speed,
              groupValue: currentSpeed,
              onChanged: (value) {
                if (value != null) {
                  onSpeedSelected(value);
                }
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
