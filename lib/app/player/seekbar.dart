import 'dart:math';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final bool buffering;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    required this.buffering,
  });

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: Theme.of(context).sliderTheme.copyWith(
                thumbShape: HiddenThumbComponentShape(),
                activeTrackColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.35),
                trackHeight: 2,
              ),
          child: Slider(
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(
              widget.duration.inMilliseconds,
              widget.buffering ? 0 : widget.bufferedPosition.inMilliseconds,
            ).toDouble(),
            onChanged: (_) {},
          ),
        ),
        Slider(
          inactiveColor: Colors.transparent,
          max: widget.duration.inMilliseconds.toDouble(),
          value: max(
            _dragValue ??
                min(
                  widget.position.inMilliseconds,
                  widget.duration.inMilliseconds,
                ).toDouble(),
            Duration.zero.inMilliseconds.toDouble(),
          ),
          onChanged: (value) {
            setState(() => _dragValue = value);
            widget.onChanged?.call(Duration(milliseconds: value.round()));
          },
          onChangeEnd: (value) {
            widget.onChangeEnd?.call(Duration(milliseconds: value.round()));
            _dragValue = null;
          },
        ),
      ],
    );
  }
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
