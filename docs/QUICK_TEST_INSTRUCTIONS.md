# Quick Test Instructions - Notification Debugging

## ⚡ QUICK START (2 minutes)

### 1. Hot Restart App
```bash
flutter run
```

### 2. Test Immediate Notification (10 seconds)
1. Open app → Go to **Reminders** tab
2. Tap **bell icon** (top right of AppBar)
3. Pull down notification shade
4. ✅ **SUCCESS**: You see "Test Notification"
5. ❌ **FAIL**: Nothing appears → Check device notification settings

### 3. Test Scheduled Notification (2 minutes)
1. Go to **Medications** screen
2. Tap bell icon on any medication
3. Set time for **2 minutes from now**
4. Frequency: **Once**
5. Tap **Save**
6. Wait 2 minutes
7. ✅ **SUCCESS**: Notification appears
8. ❌ **FAIL**: Nothing appears → Copy console logs

## 📋 What Changed

### Files Modified:
1. ✅ `lib/main.dart` - Added NotificationService initialization
2. ✅ `lib/src/data/services/notification_service.dart` - Added extensive logging
3. ✅ `lib/src/ui/screens/reminders_screen.dart` - Added test button
4. ✅ `android/app/src/main/AndroidManifest.xml` - Enhanced permissions

### New Features:
- 🔔 **Test Notification Button** - Instant notification test
- 📝 **Debug Logging** - Every step logged to console
- ⏰ **Timezone Setup** - Explicit Europe/Bucharest timezone
- 🔐 **Permission Check** - Detects missing exact alarm permission

## 🔍 What to Check in Console

Look for these AFTER hot restart:
```
✅ DEBUG: Timezone set to: Europe/Bucharest
✅ DEBUG: flutter_local_notifications initialized
✅ DEBUG: NotificationService fully initialized
```

Look for these WHEN creating reminder:
```
🔔 DEBUG: scheduleReminder called for: [name]
🔔 DEBUG: Time until notification: [X] seconds
✅ DEBUG: Notification scheduled successfully!
🔔 DEBUG: Total pending notifications: [count]
```

## ⚠️ Common Issues

### "Can schedule exact alarms: false"
**Fix**: Settings → Apps → FurFriendDiary → Alarms & reminders → **Allow**

### Test notification doesn't appear
**Fix**: Settings → Apps → FurFriendDiary → Notifications → **Enable all**

### Battery optimization
**Fix**: Settings → Battery → FurFriendDiary → **Unrestricted**

## 📤 What to Send Back

1. ✅ Copy **entire console output** (from app start to after creating reminder)
2. ✅ Screenshot of notification settings
3. ✅ Did test notification work? **YES/NO**
4. ✅ Did scheduled notification work? **YES/NO**
5. ✅ Android version of device

## 🎯 Expected Results

### ✅ EVERYTHING WORKING:
- Test notification appears instantly
- Console shows: `✅ DEBUG: Notification scheduled successfully!`
- Console shows: `🔔 DEBUG: Total pending notifications: 1`
- Scheduled notification appears at correct time
- No error messages in console

### ❌ PERMISSION ISSUE:
- Console shows: `⚠️ WARNING: Exact alarm permission not granted!`
- Fix in device settings (see above)

### ❌ NOTIFICATION BLOCKED:
- Test notification doesn't appear
- Fix notification settings in device Settings

### ❌ OTHER ERROR:
- Console shows: `❌ DEBUG: Error scheduling notification:`
- Copy full error and send back

---

**Time Required**: 2-5 minutes total testing
**Result**: Clear debug logs showing exactly where problem is!

