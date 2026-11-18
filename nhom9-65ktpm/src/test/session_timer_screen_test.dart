import 'package:buddytalk/features/session_management/presentation/session_timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openTimer(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SessionTimerScreen()));
  }

  Future<void> tapVisible(WidgetTester tester, String label) async {
    final target = find.text(label);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pump();
  }

  testWidgets('shows session duration choices and starts the timer', (
    tester,
  ) async {
    await openTimer(tester);

    expect(find.text('Đồng hồ buổi học'), findsOneWidget);
    expect(find.text('15 phút'), findsOneWidget);
    expect(find.text('20 phút'), findsOneWidget);
    expect(find.text('25 phút'), findsOneWidget);
    expect(find.text('30 phút'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);

    await tester.tap(find.text('15 phút'));
    await tester.pumpAndSettle();
    expect(find.text('15:00'), findsOneWidget);

    await tapVisible(tester, 'Bắt đầu');
    expect(find.text('Tạm dừng'), findsOneWidget);
    expect(find.text('Đang tập trung'), findsOneWidget);
  });

  testWidgets('pauses, resumes, and resets the session timer', (tester) async {
    await openTimer(tester);
    await tapVisible(tester, 'Bắt đầu');

    await tapVisible(tester, 'Tạm dừng');
    expect(find.text('Tiếp tục'), findsOneWidget);
    expect(find.text('Đặt lại'), findsOneWidget);

    await tapVisible(tester, 'Tiếp tục');
    expect(find.text('Tạm dừng'), findsOneWidget);

    await tapVisible(tester, 'Tạm dừng');
    await tapVisible(tester, 'Đặt lại');

    expect(find.text('20:00'), findsOneWidget);
    expect(find.text('Bắt đầu'), findsOneWidget);
  });
}
