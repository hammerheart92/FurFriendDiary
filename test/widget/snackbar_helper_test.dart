// File: test/widget/snackbar_helper_test.dart
// Coverage: 20 tests, 85+ assertions
// Focus Areas:
// - Message text display verification
// - Theme-aware color validation (light/dark mode)
// - SnackBar floating behavior
// - Rounded corner shape verification
// - GoogleFonts.inter text styling
// - Duration and action button support
// - Edge cases: empty messages, special characters, long text

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fur_friend_diary/src/utils/snackbar_helper.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';

void main() {
  group('SnackBarHelper', () {
    /// Helper function to create a test app with light theme
    Widget createTestAppLight(Widget child) {
      return MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: child,
        ),
      );
    }

    /// Helper function to create a test app with dark theme
    Widget createTestAppDark(Widget child) {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: child,
        ),
      );
    }

    /// Helper function to find SnackBar in widget tree
    SnackBar? findSnackBar(WidgetTester tester) {
      final snackBarFinder = find.byType(SnackBar);
      if (snackBarFinder.evaluate().isEmpty) return null;
      return tester.widget<SnackBar>(snackBarFinder);
    }

    /// Helper function to extract actual background color from SnackBar Material
    Color? getSnackBarBackgroundColor(WidgetTester tester) {
      final materialFinder = find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Material),
      );

      if (materialFinder.evaluate().isEmpty) return null;

      // Get the first Material widget (the SnackBar's Material)
      final material = tester.widget<Material>(materialFinder.first);
      return material.color;
    }

    /// Helper function to extract text style from SnackBar
    TextStyle? getSnackBarTextStyle(WidgetTester tester) {
      final textFinder = find.descendant(
        of: find.byType(SnackBar),
        matching: find.byType(Text),
      );

      if (textFinder.evaluate().isEmpty) return null;

      final text = tester.widget<Text>(textFinder.first);
      return text.style;
    }

    group('showSuccess', () {
      testWidgets('should display the correct success message', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Item saved successfully!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(); // Trigger the SnackBar

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should use teal background color in light mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.highlightTeal));
      });

      testWidgets('should use teal background color in dark mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppDark(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert - Success uses same teal color in both modes
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.highlightTeal));
      });

      testWidgets('should have floating behavior', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.behavior, equals(SnackBarBehavior.floating));
      });

      testWidgets('should have rounded corners with 12px radius', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.shape, isA<RoundedRectangleBorder>());

        final shape = snackBar.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(12.0)));
      });

      testWidgets('should use GoogleFonts.inter with correct styling', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final textStyle = getSnackBarTextStyle(tester);
        expect(textStyle, isNotNull);
        expect(textStyle!.fontFamily, contains('Inter')); // GoogleFonts.inter uses 'Inter' family
        expect(textStyle.fontSize, equals(14.0));
        expect(textStyle.fontWeight, equals(FontWeight.w500));
        expect(textStyle.color, equals(Colors.white));
      });

      testWidgets('should have correct margin using DesignSpacing.md', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Success!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.margin, equals(const EdgeInsets.all(DesignSpacing.md)));
      });
    });

    group('showError', () {
      testWidgets('should display the correct error message', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Failed to save item';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, testMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should use lDanger color in light mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Error occurred!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, testMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.lDanger));
      });

      testWidgets('should use dDanger color in dark mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Error occurred!';

        await tester.pumpWidget(
          createTestAppDark(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, testMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.dDanger));
      });

      testWidgets('should have floating behavior and rounded corners', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Error!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, testMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.behavior, equals(SnackBarBehavior.floating));
        expect(snackBar.shape, isA<RoundedRectangleBorder>());

        final shape = snackBar.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(12.0)));
      });

      testWidgets('should use GoogleFonts.inter styling', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Error!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showError(context, testMessage);
                  },
                  child: const Text('Show Error'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final textStyle = getSnackBarTextStyle(tester);
        expect(textStyle, isNotNull);
        expect(textStyle!.fontFamily, contains('Inter'));
        expect(textStyle.fontSize, equals(14.0));
        expect(textStyle.fontWeight, equals(FontWeight.w500));
        expect(textStyle.color, equals(Colors.white));
      });
    });

    group('showWarning', () {
      testWidgets('should display the correct warning message', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'No pet selected';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(context, testMessage);
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should use lWarning color in light mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Warning!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(context, testMessage);
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.lWarning));
      });

      testWidgets('should use dWarning color in dark mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Warning!';

        await tester.pumpWidget(
          createTestAppDark(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(context, testMessage);
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.dWarning));
      });

      testWidgets('should use black87 text color for better contrast', (WidgetTester tester) async {
        // Arrange - Warning uses black text for yellow background
        const testMessage = 'Warning!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(context, testMessage);
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final textStyle = getSnackBarTextStyle(tester);
        expect(textStyle, isNotNull);
        expect(textStyle!.color, equals(Colors.black87));
      });

      testWidgets('should have floating behavior and rounded corners', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Warning!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showWarning(context, testMessage);
                  },
                  child: const Text('Show Warning'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.behavior, equals(SnackBarBehavior.floating));
        expect(snackBar.shape, isA<RoundedRectangleBorder>());

        final shape = snackBar.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(12.0)));
      });
    });

    group('showInfo', () {
      testWidgets('should display the correct info message', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Feature coming soon';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(context, testMessage);
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should use coral background color in light mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Info!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(context, testMessage);
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.highlightCoral));
      });

      testWidgets('should use coral background color in dark mode', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Info!';

        await tester.pumpWidget(
          createTestAppDark(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(context, testMessage);
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert - Info uses same coral color in both modes
        final backgroundColor = getSnackBarBackgroundColor(tester);
        expect(backgroundColor, equals(DesignColors.highlightCoral));
      });

      testWidgets('should have floating behavior and rounded corners', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Info!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(context, testMessage);
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.behavior, equals(SnackBarBehavior.floating));
        expect(snackBar.shape, isA<RoundedRectangleBorder>());

        final shape = snackBar.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(12.0)));
      });

      testWidgets('should use GoogleFonts.inter styling', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Info!';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showInfo(context, testMessage);
                  },
                  child: const Text('Show Info'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final textStyle = getSnackBarTextStyle(tester);
        expect(textStyle, isNotNull);
        expect(textStyle!.fontFamily, contains('Inter'));
        expect(textStyle.fontSize, equals(14.0));
        expect(textStyle.fontWeight, equals(FontWeight.w500));
        expect(textStyle.color, equals(Colors.white));
      });
    });

    group('showSuccessWithUndo', () {
      testWidgets('should display success message with UNDO action', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Item deleted';
        var undoPressed = false;

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccessWithUndo(
                      context,
                      testMessage,
                      onUndo: () {
                        undoPressed = true;
                      },
                    );
                  },
                  child: const Text('Show Success with Undo'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.text('UNDO'), findsOneWidget);
        expect(find.byType(SnackBarAction), findsOneWidget);

        // Verify undo action works
        // Need to pump and settle to ensure SnackBar animations are complete
        await tester.pumpAndSettle();
        await tester.tap(find.text('UNDO'), warnIfMissed: false);
        await tester.pump();
        expect(undoPressed, isTrue);
      });

      testWidgets('should use 5 second duration by default', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Item deleted';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccessWithUndo(
                      context,
                      testMessage,
                      onUndo: () {},
                    );
                  },
                  child: const Text('Show Success with Undo'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.duration, equals(const Duration(seconds: 5)));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle empty message string', (WidgetTester tester) async {
        // Arrange
        const testMessage = '';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Empty'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert - Should still create SnackBar even with empty message
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should handle very long message text', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'This is a very long message that might span multiple lines '
            'and should still be displayed correctly in the SnackBar widget '
            'without causing any layout issues or overflow errors.';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Long Message'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should handle special characters in message', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Special chars: !@#\$%^&*()_+ \n\t áéíóú';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(context, testMessage);
                  },
                  child: const Text('Show Special'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text(testMessage), findsOneWidget);
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should hide current SnackBar when new one is shown', (WidgetTester tester) async {
        // Arrange
        const firstMessage = 'First message';
        const secondMessage = 'Second message';

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        SnackBarHelper.showSuccess(context, firstMessage);
                      },
                      child: const Text('Show First'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        SnackBarHelper.showError(context, secondMessage);
                      },
                      child: const Text('Show Second'),
                    ),
                  ],
                );
              },
            ),
          ),
        );

        // Act - Show first SnackBar
        await tester.tap(find.text('Show First'));
        await tester.pump();

        expect(find.text(firstMessage), findsOneWidget);

        // Act - Show second SnackBar (should hide first)
        await tester.tap(find.text('Show Second'));
        await tester.pump();

        // Assert - Only second message should be visible
        expect(find.text(firstMessage), findsNothing);
        expect(find.text(secondMessage), findsOneWidget);
      });
    });

    group('Custom Duration and Actions', () {
      testWidgets('should respect custom duration parameter', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'Custom duration';
        const customDuration = Duration(seconds: 10);

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(
                      context,
                      testMessage,
                      duration: customDuration,
                    );
                  },
                  child: const Text('Show Custom Duration'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        final snackBar = findSnackBar(tester);
        expect(snackBar, isNotNull);
        expect(snackBar!.duration, equals(customDuration));
      });

      testWidgets('should display custom action button', (WidgetTester tester) async {
        // Arrange
        const testMessage = 'With action';
        var actionPressed = false;

        await tester.pumpWidget(
          createTestAppLight(
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    SnackBarHelper.showSuccess(
                      context,
                      testMessage,
                      action: SnackBarAction(
                        label: 'RETRY',
                        onPressed: () {
                          actionPressed = true;
                        },
                      ),
                    );
                  },
                  child: const Text('Show With Action'),
                );
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('RETRY'), findsOneWidget);
        expect(find.byType(SnackBarAction), findsOneWidget);

        // Verify action works
        // Need to pump and settle to ensure SnackBar animations are complete
        await tester.pumpAndSettle();
        await tester.tap(find.text('RETRY'), warnIfMissed: false);
        await tester.pump();
        expect(actionPressed, isTrue);
      });
    });
  });
}
