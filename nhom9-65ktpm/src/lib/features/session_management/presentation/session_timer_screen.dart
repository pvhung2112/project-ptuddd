import 'dart:async';

import 'package:flutter/material.dart';

class SessionTimerScreen extends StatefulWidget {
  const SessionTimerScreen({super.key});

  @override
  State<SessionTimerScreen> createState() => _SessionTimerScreenState();
}

class _SessionTimerScreenState extends State<SessionTimerScreen> {
  static const _durationOptions = [15, 20, 25, 30];

  int _selectedMinutes = 20;
  late Duration _remaining = Duration(minutes: _selectedMinutes);
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _isRunning = false;
  bool _isCompleted = false;

  Duration get _sessionDuration => Duration(minutes: _selectedMinutes);

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;

    setState(() {
      _selectedMinutes = minutes;
      _remaining = _sessionDuration;
      _isCompleted = false;
      _stopwatch
        ..stop()
        ..reset();
    });
  }

  void _start() {
    if (_isCompleted) {
      _reset();
    }

    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _sessionDuration - _stopwatch.elapsed;
      if (remaining <= Duration.zero) {
        _ticker?.cancel();
        _stopwatch
          ..stop()
          ..reset();
        setState(() {
          _remaining = Duration.zero;
          _isRunning = false;
          _isCompleted = true;
        });
        return;
      }

      setState(() {
        _remaining = remaining;
      });
    });

    setState(() {
      _isRunning = true;
      _isCompleted = false;
    });
  }

  void _pause() {
    _ticker?.cancel();
    _stopwatch.stop();
    setState(() {
      _remaining = _sessionDuration - _stopwatch.elapsed;
      if (_remaining < Duration.zero) _remaining = Duration.zero;
      _isRunning = false;
    });
  }

  void _reset() {
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    setState(() {
      _remaining = _sessionDuration;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress =
        _remaining.inMilliseconds / _sessionDuration.inMilliseconds;
    final actionLabel = _isRunning
        ? 'Tạm dừng'
        : _isCompleted
            ? 'Bắt đầu lại'
            : _remaining == _sessionDuration
                ? 'Bắt đầu'
                : 'Tiếp tục';

    return Scaffold(
      appBar: AppBar(title: const Text('Đồng hồ buổi học')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.record_voice_over_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'Thời gian luyện tập',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn thời lượng và tập trung vào buổi luyện nói của bạn.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  for (final minutes in _durationOptions)
                    ChoiceChip(
                      label: Text('$minutes phút'),
                      selected: _selectedMinutes == minutes,
                      onSelected:
                          _isRunning ? null : (_) => _selectDuration(minutes),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox.square(
                dimension: 256,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDuration(_remaining),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isCompleted
                              ? 'Hoàn thành'
                              : _isRunning
                                  ? 'Đang tập trung'
                                  : 'Thời gian còn lại',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isRunning ? _pause : _start,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(actionLabel),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isRunning || _remaining == _sessionDuration
                      ? null
                      : _reset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Đặt lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
