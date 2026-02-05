import 'package:flutter/material.dart';
import 'package:matem_appka/const/game.dart';

import '../../const/colors.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.mode,
    required this.timerStream,
    required this.secondsLeft,
    required this.remainingMistakes,
    required this.score,
    required this.onExit,
    required this.onTimeExpired,
  });

  final GameMode mode;
  final Stream<int> timerStream;
  final int secondsLeft;
  final int remainingMistakes;
  final int score;
  final VoidCallback onExit;
  final VoidCallback onTimeExpired;

  // Header styling
  static const double _headerHeight = 83;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isNarrow = width < 380;

    return Container(
      height: _headerHeight,
      color: Colors.deepPurple,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 6 : 12),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: StreamBuilder<int>(
            stream: mode == GameMode.practice ? Stream<int>.empty() : timerStream,
            builder: (context, snapshot) {
              // Timed modes: end game when timer ends
              if (mode != GameMode.practice &&
                  snapshot.hasData &&
                  snapshot.data == secondsLeft - 1) {
                Future.microtask(onTimeExpired);
              }

              final timeValue = mode == GameMode.practice
                  ? '∞'
                  : _formatRemainingTime(snapshot.data);

              final mistakesValue = mode == GameMode.play
                  ? remainingMistakes.toString()
                  : '∞';

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 26),
                    onPressed: onExit,
                    tooltip: 'Exit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 40, height: 36),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: _statChip(
                              context: context,
                              icon: Icons.timer,
                              value: timeValue,
                              iconColor: Colors.white70,
                            ),
                          ),
                          SizedBox(width: isNarrow ? 6 : 10),
                          Flexible(
                            child: _statChip(
                              context: context,
                              icon: Icons.error,
                              value: mistakesValue,
                              iconColor: Colors.redAccent,
                            ),
                          ),
                          if (mode != GameMode.practice) ...[
                            SizedBox(width: isNarrow ? 6 : 10),
                            Flexible(
                              child: _statChip(
                                context: context,
                                icon: Icons.star,
                                value: score.toString(),
                                iconColor: Colors.yellow,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Symmetry placeholder (same width as IconButton) so the wrap stays centered.
                  const SizedBox(width: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statChip({
    required BuildContext context,
    required IconData icon,
    required String value,
    required Color iconColor,
  }) {
    final isNarrow = MediaQuery.sizeOf(context).width < 380;
    // Slightly larger than before so it doesn't feel "too small",
    // but still compact enough to keep everything on one row.
    final horizontal = isNarrow ? 8.0 : 12.0;
    final vertical = isNarrow ? 7.0 : 9.0;
    final gap = isNarrow ? 7.0 : 10.0;
    final iconSize = isNarrow ? 22.0 : 24.0;
    final valueSize = isNarrow ? 22.0 : 26.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isNarrow ? 12 : 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(width: gap),
          // Keep value on a single line and shrink if needed.
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: whiteBoldedText.copyWith(fontSize: valueSize, height: 1.0),
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemainingTime(int? elapsedSeconds) {
    final remainingTime = 120 - (elapsedSeconds ?? 0);
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
