# Notification Debugging Guide

## What Was Added

### 1. Comprehensive Debug Logging in NotificationService

Added extensive `print()` statements throughout the notification flow to track:

- ✅ **Initialization**: Timezone setup, plugin initialization, permission checks
- ✅ **Scheduling**: Every step of the notification scheduling process
- ✅ **Timing**: Current time vs scheduled time, time until notification
- ✅ **Errors**: Full stack traces for any failures
- ✅ **Verification**: List of all pending notifications after scheduling

### 2. Enhanced Timezone Setup

```dart
// Set specific timezone for Romania
final location = tz.getLocation('Europe/Bucharest');
tz.setLocalLocation(location);
```

### 3. Exact Alarm Permission Check (Android 12+)

New method `checkExactAlarmPermission()` that:
- Checks if the app can schedule exact alarms
- Logs warning if permission is not granted
- Called automatically during initialization

### 4. Test Notification Feature

**New method**: `showTestNotification()`
- Shows an immediate notification to verify notifications work
- Accessible via bell icon button in RemindersScreen AppBar
- Helps isolate scheduling issues vs notification system issues

### 5. Updated AndroidManifest.xml

Added both exact alarm permissions for maximum compatibility:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

## How to Test

### Step 1: Hot Restart the App

**IMPORTANT**: Must do full restart, not hot reload!

```bash
flutter run
```

Watch console for initialization logs:
```
🔔 DEBUG: Starting NotificationService initialization
🔔 DEBUG: Initializing timezones...
✅ DEBUG: Timezone set to: Europe/Bucharest
🔔 DEBUG: Initializing flutter_local_notifications...
✅ DEBUG: flutter_local_notifications initialized: true
🔔 DEBUG: Can schedule exact alarms: true/false
✅ DEBUG: NotificationService fully initialized
```

### Step 2: Test Immediate Notification

1. Navigate to **Reminders** screen
2. Tap the **bell icon** in the AppBar (top right)
3. Should see snackbar: "Test notification sent!"
4. **Pull down notification shade** - should see test notification immediately

**Expected Console Output:**
```
🧪 DEBUG: Test notification button pressed
🔔 DEBUG: Showing immediate test notification
✅ DEBUG: Test notification shown successfully
```

**If test notification appears** ✅ = Notification system works!
**If test notification does NOT appear** ❌ = Permission issue or notification blocked

### Step 3: Schedule a Real Reminder

1. Go to **Medications** or **Appointments** screen
2. Tap bell icon on any entry
3. Set reminder for **1-2 minutes from now**
4. Choose frequency: **Once**
5. Save

**Watch Console for Full Debug Flow:**
```
🔔 DEBUG: scheduleReminder called for: [Reminder Title]
🔔 DEBUG: Reminder ID: [UUID]
🔔 DEBUG: Scheduled time: 2025-10-16 14:30:00.000
🔔 DEBUG: Frequency: ReminderFrequency.once
🔔 DEBUG: Is active: true
🔔 DEBUG: Scheduling ONCE at 2025-10-16 14:30:00.000

🔔 DEBUG: _scheduleOnce called
🔔 DEBUG: Notification ID: [hashCode]
🔔 DEBUG: Current time (DateTime): 2025-10-16 14:28:00.000
🔔 DEBUG: Current time (TZDateTime): 2025-10-16 14:28:00.000 Europe/Bucharest
🔔 DEBUG: Time until notification: 120 seconds
🔔 DEBUG: Scheduled TZDateTime: 2025-10-16 14:30:00.000 Europe/Bucharest
🔔 DEBUG: TZ Location: Europe/Bucharest
🔔 DEBUG: Is scheduled time in past? false
🔔 DEBUG: Calling zonedSchedule...
✅ DEBUG: zonedSchedule completed successfully

✅ DEBUG: Notification scheduled successfully!
🔔 DEBUG: Total pending notifications: 1
   - ID: [id], Title: [title], Body: [body]
```

### Step 4: Wait for Notification

- Wait the scheduled amount of time
- Notification should appear in notification shade
- Check console for any errors

## Common Issues & Solutions

### Issue 1: "Can schedule exact alarms: false"

**Cause**: Android 12+ requires manual permission for exact alarms

**Solution**:
1. Go to device Settings
2. Apps → FurFriendDiary
3. Alarms & reminders → **Allow**

### Issue 2: Test notification doesn't appear

**Possible Causes**:
- Notifications disabled for app
- Do Not Disturb mode enabled
- Notification channel blocked

**Solution**:
1. Check notification settings in device Settings
2. Long-press on app icon → App info → Notifications → Enable
3. Disable Do Not Disturb temporarily

### Issue 3: "Scheduled time is in the past"

**Cause**: Timezone mismatch or time selected was before current time

**Check Console**:
```
🔔 DEBUG: Current time (TZDateTime): [current time]
🔔 DEBUG: Scheduled TZDateTime: [scheduled time]
🔔 DEBUG: Is scheduled time in past? true
```

**Solution**: Set reminder time to be in the future

### Issue 4: Notifications scheduled but never appear

**Possible Causes**:
1. Battery optimization killing background processes
2. App not allowed to run in background
3. Exact alarm permission not granted

**Solution**:
1. Device Settings → Battery → FurFriendDiary → **Unrestricted**
2. Check exact alarm permission (see Issue 1)

### Issue 5: "LateInitializationError" still appears

**Cause**: NotificationService not initialized before use

**Check Console**: Should see initialization logs at app startup

**Solution**: Ensure `main.dart` has:
```dart
await NotificationService().initialize();
```

## Debug Log Reference

### Emoji Legend
- 🔔 = Notification operation
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning
- 🧪 = Test operation

### Key Debug Points

1. **App Startup** (in main.dart):
   - `🔔 DEBUG: Initializing NotificationService`
   - `✅ DEBUG: NotificationService fully initialized`

2. **Creating Reminder** (in UI):
   - `🔔 DEBUG: scheduleReminder called for: [title]`
   - `🔔 DEBUG: Scheduling [FREQUENCY]`

3. **Scheduling Details** (_scheduleOnce):
   - `🔔 DEBUG: Time until notification: [X] seconds`
   - `🔔 DEBUG: Calling zonedSchedule...`
   - `✅ DEBUG: zonedSchedule completed successfully`

4. **Verification**:
   - `🔔 DEBUG: Total pending notifications: [count]`

5. **Errors**:
   - `❌ DEBUG: Error scheduling notification: [error]`
   - `❌ DEBUG: Stack trace: [trace]`

## What to Send Back

After testing, copy and send:

1. **Full console output** from app startup through reminder creation
2. **Notification settings screenshot** from device Settings
3. **Test result**: Did test notification appear? Yes/No
4. **Scheduled notification result**: Did it appear at scheduled time? Yes/No
5. **Android version** of test device
6. Any **error messages** from console

## Next Steps

Based on debug logs, we can:

1. **Identify permission issues** → Add permission request flow
2. **Find timing bugs** → Adjust timezone handling
3. **Detect scheduling failures** → Fix notification details
4. **Discover platform issues** → Add platform-specific workarounds

The comprehensive logging will show us exactly where in the flow things are failing!

