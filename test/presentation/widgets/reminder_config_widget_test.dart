// File: test/presentation/widgets/reminder_config_widget_test.dart
// Coverage: 25+ tests, 90+ assertions
// Focus Areas:
// - Rendering (master toggle, filter chips, summary card)
// - Interaction (toggle on/off, chip selection/deselection)
// - Callback verification (onChanged with correct ReminderConfig)
// - State management (enabled/disabled states)
// - Display (summary descriptions, chip labels, localization)
// - Edge cases (empty, all selected, duplicates, single selection)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fur_friend_diary/src/presentation/widgets/reminder_config_widget.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('ReminderConfigWidget', () {
    /// Helper to create test config with default values
    ReminderConfig createTestConfig({
      List<int>? reminderDays,
      bool isEnabled = true,
      String eventType = 'vaccination',
    }) {
      return ReminderConfig(
        id: 'test-config-1',
        petId: 'pet-1',
        eventType: eventType,
        reminderDays: reminderDays ?? [1, 7],
        isEnabled: isEnabled,
        createdAt: DateTime(2025, 1, 1),
      );
    }

    /// Helper to pump widget with MaterialApp and localization
    Future<void> pumpWidgetUnderTest(
      WidgetTester tester,
      ReminderConfig config,
      ValueChanged<ReminderConfig> onChanged, {
      bool enabled = true,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SingleChildScrollView(
              child: ReminderConfigWidget(
                config: config,
                onChanged: onChanged,
                enabled: enabled,
              ),
            ),
          ),
        ),
      );
    }

    /// Helper to find FilterChip by label text
    Finder findChipByLabel(String labelSubstring) {
      return find.ancestor(
        of: find.textContaining(labelSubstring),
        matching: find.byType(FilterChip),
      );
    }

    group('Rendering Tests', () {
      testWidgets('renders widget without errors', (tester) async {
        final config = createTestConfig();
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.byType(ReminderConfigWidget), findsOneWidget);
      });

      testWidgets('displays master toggle with correct title', (tester) async {
        final config = createTestConfig();
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.byType(SwitchListTile), findsOneWidget);
        expect(find.text('Enable Reminders'), findsOneWidget);
      });

      testWidgets('displays all filter chip options when enabled',
          (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Should show 4 chips: Day of, 1 day before, 1 week before, 2 weeks before
        expect(find.byType(FilterChip), findsNWidgets(4));

        // Verify labels exist
        expect(find.text('Day of'), findsOneWidget);
        expect(find.text('1 day before'), findsOneWidget);
        expect(find.text('1 week before'), findsOneWidget);
        expect(find.text('2 weeks before'), findsOneWidget);
      });

      testWidgets('hides filter chips when master toggle is disabled',
          (tester) async {
        final config = createTestConfig(isEnabled: false);
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Filter chips should not be visible when disabled
        expect(find.byType(FilterChip), findsNothing);
      });

      testWidgets('shows summary card when reminders are selected',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [1, 7],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Summary card should display with info icon
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.text('Active Reminders'), findsOneWidget);
      });

      testWidgets('displays notification active icon when enabled',
          (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      });

      testWidgets('displays notification off icon when disabled',
          (tester) async {
        final config = createTestConfig(isEnabled: false);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.byIcon(Icons.notifications_off), findsOneWidget);
      });

      testWidgets('displays "Remind me:" section header when enabled',
          (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Remind me:'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('master toggle triggers onChanged callback', (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(isEnabled: true);

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Tap the switch
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(updatedConfig, isNotNull);
        expect(updatedConfig!.isEnabled, isFalse);
        expect(updatedConfig!.id, equals(config.id));
        expect(updatedConfig!.petId, equals(config.petId));
      });

      testWidgets('toggling off then on updates state correctly',
          (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(isEnabled: true);

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Toggle off
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(updatedConfig!.isEnabled, isFalse);

        // Pump with updated config, then toggle back on
        await pumpWidgetUnderTest(tester, updatedConfig!, (newConfig) {
          updatedConfig = newConfig;
        });
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(updatedConfig!.isEnabled, isTrue);
      });

      testWidgets('selecting unselected chip adds reminder day',
          (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(reminderDays: [1]); // Only 1 day selected

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Tap "1 week before" chip (7 days)
        final weekChipFinder = findChipByLabel('1 week');
        await tester.tap(weekChipFinder);
        await tester.pumpAndSettle();

        expect(updatedConfig, isNotNull);
        expect(updatedConfig!.reminderDays, contains(7));
        expect(updatedConfig!.reminderDays, contains(1));
        expect(updatedConfig!.reminderDays.length, equals(2));
      });

      testWidgets('deselecting selected chip removes reminder day',
          (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(reminderDays: [1, 7]); // Both selected

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Tap "1 day before" chip to deselect
        final dayChipFinder = findChipByLabel('1 day');
        await tester.tap(dayChipFinder);
        await tester.pumpAndSettle();

        expect(updatedConfig, isNotNull);
        expect(updatedConfig!.reminderDays, isNot(contains(1)));
        expect(updatedConfig!.reminderDays, contains(7));
        expect(updatedConfig!.reminderDays.length, equals(1));
      });

      testWidgets('multiple chips can be selected sequentially',
          (tester) async {
        ReminderConfig? updatedConfig;
        var config = createTestConfig(reminderDays: [1]); // Start with one selected

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Select "Day of" chip (0 days)
        final dayOfChipFinder = findChipByLabel('Day of');
        await tester.tap(dayOfChipFinder);
        await tester.pumpAndSettle();

        expect(updatedConfig!.reminderDays, contains(0));
        expect(updatedConfig!.reminderDays, contains(1));

        // Update config and pump again
        config = updatedConfig!;
        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Select "1 week before" chip (7 days)
        final weekChipFinder = findChipByLabel('1 week');
        await tester.tap(weekChipFinder);
        await tester.pumpAndSettle();

        expect(updatedConfig!.reminderDays, containsAll([0, 1, 7]));
        expect(updatedConfig!.reminderDays.length, equals(3));
      });

      testWidgets('selecting all chips works correctly', (tester) async {
        ReminderConfig? updatedConfig;
        var config = createTestConfig(reminderDays: [1]); // Start with one selected

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Select remaining 3 chips sequentially (skip '1 day' since already selected)
        final chipLabels = ['Day of', '1 week', '2 weeks'];

        for (final label in chipLabels) {
          await pumpWidgetUnderTest(tester, config, (newConfig) {
            updatedConfig = newConfig;
          });

          final chipFinder = findChipByLabel(label);
          await tester.tap(chipFinder);
          await tester.pumpAndSettle();

          config = updatedConfig!;
        }

        expect(updatedConfig!.reminderDays, containsAll([0, 1, 7, 14]));
        expect(updatedConfig!.reminderDays.length, equals(4));
      });

      testWidgets('updatedAt timestamp changes on modification',
          (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(reminderDays: [1]);
        final originalUpdatedAt = config.updatedAt;

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Wait a moment to ensure timestamp difference
        await tester.pump(const Duration(milliseconds: 10));

        // Toggle the switch
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(updatedConfig!.updatedAt, isNotNull);
        expect(updatedConfig!.updatedAt, isNot(equals(originalUpdatedAt)));
      });
    });

    group('State Tests', () {
      testWidgets('disabled config makes filter chips non-interactive',
          (tester) async {
        final config = createTestConfig(
          isEnabled: false,
          reminderDays: [1],
        );
        ReminderConfig? updatedConfig;

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Filter chips should not be visible when master toggle is off
        expect(find.byType(FilterChip), findsNothing);
      });

      testWidgets('widget enabled=false disables master toggle',
          (tester) async {
        final config = createTestConfig(isEnabled: true);
        ReminderConfig? updatedConfig;

        await pumpWidgetUnderTest(
          tester,
          config,
          (newConfig) {
            updatedConfig = newConfig;
          },
          enabled: false,
        );

        // Try to toggle switch
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Should not trigger callback
        expect(updatedConfig, isNull);
      });

      testWidgets('widget enabled=false disables all chip interactions',
          (tester) async {
        final config = createTestConfig(
          isEnabled: true,
          reminderDays: [1],
        );
        ReminderConfig? updatedConfig;

        await pumpWidgetUnderTest(
          tester,
          config,
          (newConfig) {
            updatedConfig = newConfig;
          },
          enabled: false,
        );

        // Chips should still be visible but disabled
        final dayChipFinder = findChipByLabel('1 week');
        await tester.tap(dayChipFinder);
        await tester.pumpAndSettle();

        // Should not trigger callback
        expect(updatedConfig, isNull);
      });

      testWidgets('enabled config allows all interactions', (tester) async {
        final config = createTestConfig(isEnabled: true);
        ReminderConfig? updatedConfig;

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Tap a chip
        final dayOfChipFinder = findChipByLabel('Day of');
        await tester.tap(dayOfChipFinder);
        await tester.pumpAndSettle();

        expect(updatedConfig, isNotNull);
        expect(updatedConfig!.reminderDays, contains(0));
      });
    });

    group('Display Tests', () {
      testWidgets('summary card shows human-readable description',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [1, 7],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Should display description from config.reminderDescription
        // Expected: "1 day before and 1 week before"
        final summaryText =
            tester.widget<Text>(find.textContaining('day before').last);
        expect(summaryText.data, contains('1 day before'));
        expect(summaryText.data, contains('1 week before'));
        expect(summaryText.data, contains('and'));
      });

      testWidgets('summary card shows single selection correctly',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [7],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.textContaining('1 week before'), findsWidgets);
      });

      testWidgets('summary card shows "on the day" for day 0',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [0],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.textContaining('on the day'), findsOneWidget);
      });

      testWidgets('toggle subtitle shows "active" when enabled',
          (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Notifications are active'), findsOneWidget);
      });

      testWidgets('toggle subtitle shows "disabled" when off', (tester) async {
        final config = createTestConfig(isEnabled: false);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Notifications are disabled'), findsOneWidget);
      });

      testWidgets('chips reflect initial selected state correctly',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [0, 7],
          isEnabled: true,
        ); // Day of and 1 week

        await pumpWidgetUnderTest(tester, config, (_) {});

        // Find the FilterChip widgets and check their selected property
        final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));

        // Count selected chips
        final selectedCount = chips.where((chip) => chip.selected).length;
        expect(selectedCount, equals(2)); // 2 chips selected
      });

      testWidgets('unselected chips have correct visual state', (tester) async {
        final config = createTestConfig(
          reminderDays: [1],
          isEnabled: true,
        ); // Only 1 day selected

        await pumpWidgetUnderTest(tester, config, (_) {});

        final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));

        // Should have 3 unselected chips (Day of, 1 week, 2 weeks)
        final unselectedCount = chips.where((chip) => !chip.selected).length;
        expect(unselectedCount, equals(3));
      });
    });

    group('Edge Cases', () {
      testWidgets('widget handles model validation when deselecting chips',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [1, 7], // Two selected
          isEnabled: true,
        );
        ReminderConfig? updatedConfig;

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Deselect one chip - should work fine with 2 chips selected
        final dayChipFinder = findChipByLabel('1 day');
        await tester.tap(dayChipFinder);
        await tester.pumpAndSettle();

        // Verify chip was deselected
        expect(updatedConfig, isNotNull);
        expect(updatedConfig!.reminderDays, isNot(contains(1)));
        expect(updatedConfig!.reminderDays, contains(7));
        expect(updatedConfig!.reminderDays.length, equals(1));

        // NOTE: Widget does not prevent deselecting the last chip at UI level.
        // Model validation will fail if parent tries to create config with empty list.
        // This is expected behavior - validation happens in the domain layer.
      });

      testWidgets('handles all options selected', (tester) async {
        final config = createTestConfig(
          reminderDays: [0, 1, 7, 14],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        // All 4 chips should be selected
        final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
        final selectedCount = chips.where((chip) => chip.selected).length;
        expect(selectedCount, equals(4));

        // Summary should display all options
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('prevents duplicate additions', (tester) async {
        ReminderConfig? updatedConfig;
        final config = createTestConfig(
          reminderDays: [1, 7],
          isEnabled: true,
        ); // Multiple options already selected

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Try to select "1 day before" again (should deselect instead)
        final dayChipFinder = findChipByLabel('1 day');
        await tester.tap(dayChipFinder);
        await tester.pumpAndSettle();

        // Should remove it, not add duplicate
        expect(updatedConfig!.reminderDays, isNot(contains(1)));
        expect(updatedConfig!.reminderDays, contains(7));
        expect(updatedConfig!.reminderDays.length, equals(1));
      });

      testWidgets('handles initial config with pre-selected options',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [1, 7, 14],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        // All 3 specified chips should be selected
        final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
        final selectedCount = chips.where((chip) => chip.selected).length;
        expect(selectedCount, equals(3));
      });

      testWidgets('summary card uses reminderDescription getter',
          (tester) async {
        final config = createTestConfig(
          reminderDays: [0, 1, 7, 14],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Verify the description matches the getter's format
        final description = config.reminderDescription;
        expect(
            description,
            equals(
                'on the day, 1 day before, 1 week before, and 2 weeks before'));

        // Find the summary text widget
        final summaryTextFinder = find.textContaining('on the day');
        expect(summaryTextFinder, findsOneWidget);
      });

      testWidgets('maintains reminderDays order in config', (tester) async {
        ReminderConfig? updatedConfig;
        var config = createTestConfig(reminderDays: [7]); // Start with one

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          updatedConfig = newConfig;
        });

        // Add in non-sorted order: 1, 14, 0
        final selections = [
          ('1 day', 1),
          ('2 weeks', 14),
          ('Day of', 0),
        ];

        for (final (label, expectedDay) in selections) {
          await pumpWidgetUnderTest(tester, config, (newConfig) {
            updatedConfig = newConfig;
          });

          final chipFinder = findChipByLabel(label);
          await tester.tap(chipFinder);
          await tester.pumpAndSettle();

          expect(updatedConfig!.reminderDays, contains(expectedDay));
          config = updatedConfig!;
        }

        // All values should be present (order doesn't matter in config)
        expect(updatedConfig!.reminderDays, containsAll([0, 1, 7, 14]));
      });
    });

    group('Localization Tests', () {
      testWidgets('uses localized labels for toggle', (tester) async {
        final config = createTestConfig();
        await pumpWidgetUnderTest(tester, config, (_) {});

        // Check for localized strings
        expect(find.text('Enable Reminders'), findsOneWidget);
        expect(find.text('Notifications are active'), findsOneWidget);
      });

      testWidgets('uses localized labels for chips', (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Day of'), findsOneWidget);
        expect(find.text('1 day before'), findsOneWidget);
        expect(find.text('1 week before'), findsOneWidget);
        expect(find.text('2 weeks before'), findsOneWidget);
      });

      testWidgets('uses localized section header', (tester) async {
        final config = createTestConfig(isEnabled: true);
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Remind me:'), findsOneWidget);
      });

      testWidgets('uses localized summary card header', (tester) async {
        final config = createTestConfig(
          reminderDays: [1],
          isEnabled: true,
        );
        await pumpWidgetUnderTest(tester, config, (_) {});

        expect(find.text('Active Reminders'), findsOneWidget);
      });
    });

    group('Callback Verification Tests', () {
      testWidgets('onChanged receives correct ReminderConfig instance',
          (tester) async {
        ReminderConfig? receivedConfig;
        final originalConfig = createTestConfig(reminderDays: [1]);

        await pumpWidgetUnderTest(tester, originalConfig, (newConfig) {
          receivedConfig = newConfig;
        });

        // Tap to add a chip
        final weekChipFinder = findChipByLabel('1 week');
        await tester.tap(weekChipFinder);
        await tester.pumpAndSettle();

        // Verify callback received correct type
        expect(receivedConfig, isA<ReminderConfig>());
        expect(receivedConfig!.id, equals(originalConfig.id));
        expect(receivedConfig!.petId, equals(originalConfig.petId));
        expect(receivedConfig!.eventType, equals(originalConfig.eventType));
      });

      testWidgets('onChanged preserves unmodified fields', (tester) async {
        ReminderConfig? receivedConfig;
        final originalConfig = createTestConfig(
          reminderDays: [1],
          eventType: 'medication',
        );

        await pumpWidgetUnderTest(tester, originalConfig, (newConfig) {
          receivedConfig = newConfig;
        });

        // Toggle the switch
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Verify unmodified fields are preserved
        expect(receivedConfig!.id, equals(originalConfig.id));
        expect(receivedConfig!.petId, equals(originalConfig.petId));
        expect(receivedConfig!.eventType, equals(originalConfig.eventType));
        expect(receivedConfig!.reminderDays, equals(originalConfig.reminderDays));
        expect(receivedConfig!.createdAt, equals(originalConfig.createdAt));
      });

      testWidgets('onChanged called exactly once per interaction',
          (tester) async {
        int callCount = 0;
        final config = createTestConfig(reminderDays: [1]);

        await pumpWidgetUnderTest(tester, config, (newConfig) {
          callCount++;
        });

        // Single tap should trigger single callback
        final weekChipFinder = findChipByLabel('1 week');
        await tester.tap(weekChipFinder);
        await tester.pumpAndSettle();

        expect(callCount, equals(1));
      });
    });
  });
}
