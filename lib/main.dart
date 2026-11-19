import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const MinuteTimerApp());

class MinuteTimerApp extends StatelessWidget {
  const MinuteTimerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PULSE / 60',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFFF789E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF4FCB),
            brightness: Brightness.light,
          ),
        ),
        home: const TimerPage(),
      );
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const _duration = Duration(minutes: 1);
  static const _pink = Color(0xFFFF4FCB);
  static const _hotPink = Color(0xFFFF83DE);
  Timer? _ticker;
  Duration _remaining = _duration;
  DateTime? _deadline;
  bool _running = false;
  bool _complete = false;

  double get _progress => 1 - _remaining.inMilliseconds / _duration.inMilliseconds;

  void _startOrPause() {
    if (_running) {
      _ticker?.cancel();
      setState(() {
        _remaining = _timeLeft();
        _running = false;
        _deadline = null;
      });
      return;
    }
    if (_remaining == Duration.zero) _remaining = _duration;
    setState(() {
      _complete = false;
      _running = true;
      _deadline = DateTime.now().add(_remaining);
    });
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  Duration _timeLeft() {
    final deadline = _deadline;
    if (deadline == null) return _remaining;
    final difference = deadline.difference(DateTime.now());
    return difference.isNegative ? Duration.zero : difference;
  }

  void _tick() {
    final left = _timeLeft();
    if (left == Duration.zero) {
      _ticker?.cancel();
      setState(() {
        _remaining = Duration.zero;
        _running = false;
        _complete = true;
        _deadline = null;
      });
    } else {
      setState(() => _remaining = left);
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = _duration;
      _running = false;
      _complete = false;
      _deadline = null;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = (_remaining.inMilliseconds / 1000).ceil();
    final time = '01:${(seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _BubblegumBackdrop()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                  child: Column(
                    children: [
                      _topBar(),
                      const Spacer(),
                      Text(
                        _complete ? 'CYCLE COMPLETE' : _running ? 'TIME IN MOTION' : 'READY WHEN YOU ARE',
                        style: const TextStyle(color: Color(0xFF171014), letterSpacing: 4, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 310,
                        height: 310,
                        child: CustomPaint(
                          painter: _TimerRingPainter(progress: _progress, running: _running),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), transform: Matrix4.rotationZ(-.025), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF171014), width: 2), boxShadow: const [BoxShadow(color: Color(0xFF171014), offset: Offset(5, 5))]), child: Text(time, style: const TextStyle(color: Color(0xFF171014), fontSize: 66, height: 1, fontWeight: FontWeight.w900, letterSpacing: -4, fontFeatures: [FontFeature.tabularFigures()]))),
                                const SizedBox(height: 14),
                                Text(_complete ? '00:00 ELAPSED' : 'MINUTES  :  SECONDS', style: const TextStyle(color: Color(0xFF24151C), fontSize: 9, letterSpacing: 2.2, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _statusChip(),
                      const Spacer(),
                      _controls(),
                      const SizedBox(height: 27),
                      const Text('ONE MINUTE  ·  ONE MOMENT  ·  RIGHT NOW', style: TextStyle(color: Color(0xFF24151C), fontSize: 9, letterSpacing: 1.7, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 9),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() => Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF171014), width: 2), boxShadow: const [BoxShadow(color: Color(0xFF171014), offset: Offset(3, 3))]),
            child: const Icon(Icons.bolt_rounded, color: Color(0xFF171014), size: 23),
          ),
          const SizedBox(width: 11),
          const Text('ONE', style: TextStyle(fontSize: 13, letterSpacing: 3, fontWeight: FontWeight.w900, color: Color(0xFF171014))),
          const Text(' MINUTE', style: TextStyle(fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w900, color: Color(0xFF171014))),
          const Spacer(),
          Transform.rotate(angle: .055, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF171014), border: Border.all(color: Colors.white, width: 2)), child: const Text('60 SEC', style: TextStyle(fontSize: 9, letterSpacing: 1.4, fontWeight: FontWeight.w900, color: Colors.white)))),
        ],
      );

  Widget _statusChip() {
    final label = _complete ? 'WELL DONE' : _running ? 'COUNTDOWN ACTIVE' : '60 SECOND SESSION';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      transform: Matrix4.rotationZ(-.025),
      decoration: BoxDecoration(color: const Color(0xFF171014), border: Border.all(color: Colors.white, width: 2), boxShadow: const [BoxShadow(color: Color(0xFF171014), offset: Offset(4, 4))]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_complete ? Icons.check_rounded : Icons.auto_awesome, color: const Color(0xFFFFA2BF), size: 14), const SizedBox(width: 8), Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, letterSpacing: 1.8, fontWeight: FontWeight.w900))]),
    );
  }

  Widget _controls() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF171014), width: 2), color: const Color(0xFF171014), boxShadow: const [BoxShadow(color: Colors.white, offset: Offset(5, 5))]),
              child: ElevatedButton.icon(
                onPressed: _startOrPause,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: const RoundedRectangleBorder()),
                icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 23),
                label: Text(_running ? 'PAUSE TIMER' : _complete ? 'RUN IT AGAIN' : 'START TIMER', style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 58,
            height: 58,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF171014), side: const BorderSide(color: Color(0xFF171014), width: 2), backgroundColor: Colors.white, shape: const RoundedRectangleBorder(), padding: EdgeInsets.zero),
              child: const Icon(Icons.refresh_rounded, size: 21),
            ),
          ),
        ],
      );
}

class _TimerRingPainter extends CustomPainter {
  const _TimerRingPainter({required this.progress, required this.running});
  final double progress;
  final bool running;
  static const pink = Color(0xFF171014);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 18;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius + 2, Paint()..color = Colors.white.withValues(alpha: .36)..style = PaintingStyle.stroke..strokeWidth = 28..maskFilter = const MaskFilter.blur(BlurStyle.normal, 17));
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF171014)..style = PaintingStyle.stroke..strokeWidth = 2);
    final tick = Paint()..color = const Color(0xFF171014)..strokeWidth = 1.4..strokeCap = StrokeCap.round;
    for (var i = 0; i < 60; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 60);
      final major = i % 5 == 0;
      final inner = radius - (major ? 10 : 5);
      final outer = radius - 1;
      canvas.drawLine(Offset(center.dx + math.cos(angle) * inner, center.dy + math.sin(angle) * inner), Offset(center.dx + math.cos(angle) * outer, center.dy + math.sin(angle) * outer), tick..color = const Color(0xFF171014).withValues(alpha: major ? .8 : .45));
    }
    if (progress > 0) {
      final arcPaint = Paint()..shader = const SweepGradient(startAngle: -math.pi / 2, endAngle: math.pi * 3 / 2, colors: [Color(0xFF171014), Color(0xFFD62458), Color(0xFF171014)]).createShader(rect)..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawArc(rect.deflate(5), -math.pi / 2, 2 * math.pi * progress, false, arcPaint);
      final angle = -math.pi / 2 + 2 * math.pi * progress;
      final dot = Offset(center.dx + math.cos(angle) * (radius - 5), center.dy + math.sin(angle) * (radius - 5));
      canvas.drawCircle(dot, 8, Paint()..color = const Color(0xFFD62458).withValues(alpha: .35)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
      canvas.drawCircle(dot, 3, Paint()..color = const Color(0xFF171014));
    }
    if (running) {
      final pulse = Paint()..color = const Color(0xFF171014).withValues(alpha: .08)..style = PaintingStyle.stroke..strokeWidth = 1;
      canvas.drawCircle(center, radius - 25, pulse);
    }
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter oldDelegate) => progress != oldDelegate.progress || running != oldDelegate.running;
}

class _BubblegumBackdrop extends StatelessWidget {
  const _BubblegumBackdrop();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DoodlePainter());
}

class _DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF88AA), Color(0xFFF76F98), Color(0xFFFC86A6)]).createShader(rect));
    final grain = Paint()..color = const Color(0xFF68162C).withValues(alpha: .11)..strokeWidth = 1;
    for (var i = 0; i < 460; i++) {
      final x = ((i * 73) % 997) / 997 * size.width;
      final y = ((i * 137) % 991) / 991 * size.height;
      canvas.drawLine(Offset(x, y), Offset(x + 1.5, y + ((i % 3) + 1)), grain);
    }
    final doodle = Paint()..color = const Color(0xFF130D11)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    for (var side = 0; side < 2; side++) {
      final x = side == 0 ? 10.0 : size.width - 24;
      final path = Path()..moveTo(x, size.height * .17);
      for (var i = 0; i < 11; i++) {
        path.lineTo(x + (side == 0 ? 10 : -10) * (i.isEven ? 1 : -1), size.height * (.17 + i * .037));
      }
      canvas.drawPath(path, doodle);
      canvas.drawCircle(Offset(x + (side == 0 ? 16 : -16), size.height * .66), 8, doodle);
      final star = Path()..moveTo(x, size.height * .75)..lineTo(x + (side == 0 ? 8 : -8), size.height * .77)..lineTo(x, size.height * .79)..lineTo(x + (side == 0 ? 8 : -8), size.height * .81)..lineTo(x, size.height * .83)..lineTo(x + (side == 0 ? 8 : -8), size.height * .81)..lineTo(x, size.height * .79)..lineTo(x + (side == 0 ? 8 : -8), size.height * .77)..close();
      canvas.drawPath(star, doodle);
    }
    for (var i = 0; i < 9; i++) {
      final x = size.width * (.12 + i * .095);
      final y = i.isEven ? size.height * .09 : size.height * .92;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 11, height: 15), doodle);
      canvas.drawLine(Offset(x - 6, y + 13), Offset(x + 8, y + 13), doodle);
    }
    for (var i = 0; i < 22; i++) {
      final x = size.width * ((i * 17 % 100) / 100);
      final y = size.height * ((i * 29 % 100) / 100);
      if ((x > size.width * .22 && x < size.width * .78) && (y > size.height * .2 && y < size.height * .82)) continue;
      canvas.drawCircle(Offset(x, y), 2 + (i % 3).toDouble(), doodle);
    }
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter oldDelegate) => false;
}
