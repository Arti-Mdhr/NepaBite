import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

// Platform channel to play Android system alarm
const _alarmChannel = MethodChannel('com.arti.nepabite/alarm');

class RecipeProcedureScreen extends StatefulWidget {
  final dynamic recipe;

  const RecipeProcedureScreen({super.key, required this.recipe});

  @override
  State<RecipeProcedureScreen> createState() => _RecipeProcedureScreenState();
}

class _RecipeProcedureScreenState extends State<RecipeProcedureScreen> {
  static const _green = Color(0xFF1EB980);
  static const _greenLight = Color(0xFFE8F8F2);

  late List<bool> completedSteps;
  late List steps;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Timer state per step
  final Map<int, int> _timerSeconds = {};
  final Map<int, int> _timerDuration = {};
  final Map<int, Timer?> _timers = {};
  final Map<int, bool> _timerRunning = {};
  final Map<int, bool> _timerDone = {};

  @override
  void initState() {
    super.initState();
    steps = widget.recipe.instructions ?? [];
    completedSteps = List.generate(steps.length, (_) => false);
  }

  @override
  void dispose() {
    for (final t in _timers.values) { t?.cancel(); }
    _audioPlayer.dispose();
    super.dispose();
  }

  int get completedCount => completedSteps.where((s) => s).length;

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  void _showTimerPicker(int stepIndex) {
    int minutes = (_timerDuration[stepIndex] ?? 180) ~/ 60;
    int seconds = (_timerDuration[stepIndex] ?? 180) % 60;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.timer_rounded, color: _green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Set Timer — Step ${stepIndex + 1}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _timeColumn("Minutes", minutes, 99,
                    onDec: () { if (minutes > 0) setModal(() => minutes--); },
                    onInc: () { if (minutes < 99) setModal(() => minutes++); },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22, left: 12, right: 12),
                    child: Text(":", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                  ),
                  _timeColumn("Seconds", seconds, 59,
                    onDec: () { if (seconds > 0) setModal(() => seconds--); },
                    onInc: () { if (seconds < 59) setModal(() => seconds++); },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Quick presets
              Wrap(
                spacing: 8,
                children: [30, 60, 120, 180, 300].map((s) {
                  final label = s < 60 ? "${s}s" : "${s ~/ 60}m";
                  return GestureDetector(
                    onTap: () => setModal(() { minutes = s ~/ 60; seconds = s % 60; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(20)),
                      child: Text(label, style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  label: const Text("Start Timer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final total = minutes * 60 + seconds;
                    if (total <= 0) return;
                    Navigator.pop(ctx);
                    _startTimer(stepIndex, total);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeColumn(String label, int value, int max, {required VoidCallback onDec, required VoidCallback onInc}) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        Row(
          children: [
            _pickerBtn(Icons.remove_rounded, onDec),
            const SizedBox(width: 16),
            SizedBox(
              width: 48,
              child: Text(
                value.toString().padLeft(2, '0'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(width: 16),
            _pickerBtn(Icons.add_rounded, onInc),
          ],
        ),
      ],
    );
  }

  Widget _pickerBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: _green, size: 20),
      ),
    );
  }

  void _startTimer(int stepIndex, int totalSeconds) {
    _timers[stepIndex]?.cancel();
    setState(() {
      _timerDuration[stepIndex] = totalSeconds;
      _timerSeconds[stepIndex] = totalSeconds;
      _timerRunning[stepIndex] = true;
      _timerDone[stepIndex] = false;
    });
    _timers[stepIndex] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      final rem = (_timerSeconds[stepIndex] ?? 0) - 1;
      if (rem <= 0) {
        t.cancel();
        setState(() {
          _timerSeconds[stepIndex] = 0;
          _timerRunning[stepIndex] = false;
          _timerDone[stepIndex] = true;
        });
        _onTimerFinished(stepIndex);
      } else {
        setState(() => _timerSeconds[stepIndex] = rem);
      }
    });
  }

  void _pauseTimer(int stepIndex) {
    _timers[stepIndex]?.cancel();
    setState(() => _timerRunning[stepIndex] = false);
  }

  void _resumeTimer(int stepIndex) {
    final remaining = _timerSeconds[stepIndex] ?? 0;
    if (remaining <= 0) return;
    setState(() => _timerRunning[stepIndex] = true);
    _timers[stepIndex] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      final rem = (_timerSeconds[stepIndex] ?? 0) - 1;
      if (rem <= 0) {
        t.cancel();
        setState(() {
          _timerSeconds[stepIndex] = 0;
          _timerRunning[stepIndex] = false;
          _timerDone[stepIndex] = true;
        });
        _onTimerFinished(stepIndex);
      } else {
        setState(() => _timerSeconds[stepIndex] = rem);
      }
    });
  }

  void _resetTimer(int stepIndex) {
    _timers[stepIndex]?.cancel();
    setState(() {
      _timerSeconds[stepIndex] = _timerDuration[stepIndex] ?? 0;
      _timerRunning[stepIndex] = false;
      _timerDone[stepIndex] = false;
    });
  }

  Future<void> _onTimerFinished(int stepIndex) async {
    // 1. Vibrate
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
    }

    // 2. Play system alarm via platform channel
    try {
      await _alarmChannel.invokeMethod('playAlarm');
    } catch (e) {
      debugPrint("[Timer] Alarm channel error: $e");
      // Fallback: use audioplayers with notification URI
      try {
        await _audioPlayer.play(UrlSource("content://settings/system/notification_sound"));
      } catch (_) {}
    }

    // 3. Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Text("⏰", style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Step ${stepIndex + 1} timer done!",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          action: SnackBarAction(
            label: "Dismiss",
            textColor: Colors.white,
            onPressed: () async {
              try {
                await _alarmChannel.invokeMethod('stopAlarm');
              } catch (_) {
                await _audioPlayer.stop();
              }
            },
          ),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      // Auto stop after 6 seconds
      Future.delayed(const Duration(seconds: 6), () async {
        try { await _alarmChannel.invokeMethod('stopAlarm'); } catch (_) {}
        await _audioPlayer.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = steps.isEmpty ? 0.0 : completedCount / steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Procedure", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 17)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: steps.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(color: _greenLight, shape: BoxShape.circle),
                    child: const Icon(Icons.menu_book_rounded, size: 48, color: _green),
                  ),
                  const SizedBox(height: 20),
                  const Text("No steps found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                  child: Row(
                    children: [
                      Text("$completedCount of ${steps.length} steps done",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text("${(progress * 100).toInt()}%",
                          style: const TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: _green, minHeight: 6),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: steps.length,
                    itemBuilder: (context, index) => _stepCard(index, steps[index], completedSteps[index]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stepCard(int index, String step, bool isDone) {
    final hasTimer = _timerSeconds.containsKey(index);
    final remaining = _timerSeconds[index] ?? 0;
    final isRunning = _timerRunning[index] ?? false;
    final timerDone = _timerDone[index] ?? false;
    final duration = _timerDuration[index] ?? 1;
    final timerProgress = hasTimer ? (1 - remaining / duration) : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDone ? _greenLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (isDone || timerDone) ? _green : Colors.transparent, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDone ? 0.02 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: isDone ? _green : Colors.grey.shade100, shape: BoxShape.circle),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text("${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Step ${index + 1}", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: isDone ? const Color(0xFF0F7A52) : Colors.black87)),
                  const SizedBox(height: 6),
                  Text(
                    step,
                    style: TextStyle(
                      fontSize: 13, height: 1.6,
                      color: isDone ? const Color(0xFF0F7A52).withOpacity(0.8) : Colors.black87,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFF0F7A52).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── TIMER ──
                  if (!isDone) ...[
                    if (!hasTimer)
                      GestureDetector(
                        onTap: () => _showTimerPicker(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_outlined, size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text("Set Timer", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: timerProgress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade200,
                          color: timerDone ? Colors.orange : _green,
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: timerDone ? Colors.orange.shade50 : _greenLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(timerDone ? Icons.alarm_rounded : Icons.timer_rounded, size: 14, color: timerDone ? Colors.orange : _green),
                                const SizedBox(width: 5),
                                Text(
                                  timerDone ? "Done! ⏰" : _formatTime(remaining),
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: timerDone ? Colors.orange : _green),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!timerDone)
                            GestureDetector(
                              onTap: () => isRunning ? _pauseTimer(index) : _resumeTimer(index),
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(color: _greenLight, borderRadius: BorderRadius.circular(8)),
                                child: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 16, color: _green),
                              ),
                            ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _resetTimer(index),
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.replay_rounded, size: 16, color: Colors.grey.shade500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () { _resetTimer(index); _showTimerPicker(index); },
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.edit_rounded, size: 16, color: Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],

                  // Mark Done
                  Align(
                    alignment: Alignment.centerRight,
                    child: isDone
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 16, color: _green.withOpacity(0.8)),
                              const SizedBox(width: 4),
                              Text("Completed", style: TextStyle(fontSize: 12, color: _green.withOpacity(0.8), fontWeight: FontWeight.w600)),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              _timers[index]?.cancel();
                              setState(() => completedSteps[index] = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(10)),
                              child: const Text("Mark Done", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}