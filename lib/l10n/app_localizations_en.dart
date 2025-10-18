// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FurFriendDiary';

  @override
  String get homeGreeting => 'Hello, furry friend!';

  @override
  String get medications => 'Medications';

  @override
  String get active => 'Active';

  @override
  String get all => 'All';

  @override
  String get inactive => 'Inactive';

  @override
  String get searchMedications => 'Search medications...';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get noPetSelected => 'No pet selected';

  @override
  String get pleaseSetupPetFirst => 'Please set up a pet profile first';

  @override
  String get noActiveMedications => 'No active medications';

  @override
  String get noMedicationsFound => 'No medications found';

  @override
  String get noInactiveMedications => 'No inactive medications';

  @override
  String get noMedicationsMatchSearch => 'No medications match your search';

  @override
  String get tryAdjustingSearchTerms => 'Try adjusting your search terms';

  @override
  String get errorLoadingMedications => 'Error loading medications';

  @override
  String get retry => 'Retry';

  @override
  String get medicationMarkedInactive => 'Medication marked as inactive';

  @override
  String get medicationMarkedActive => 'Medication marked as active';

  @override
  String get failedToUpdateMedication => 'Failed to update medication';

  @override
  String get deleteMedication => 'Delete Medication';

  @override
  String deleteMedicationConfirm(String medicationName) {
    return 'Are you sure you want to delete \"$medicationName\"? This action cannot be undone.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get medicationDeletedSuccessfully => 'Medication deleted successfully';

  @override
  String get failedToDeleteMedication => 'Failed to delete medication';

  @override
  String get appointments => 'Appointments';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get completed => 'Completed';

  @override
  String get searchAppointments => 'Search appointments...';

  @override
  String get addAppointment => 'Add Appointment';

  @override
  String get editAppointment => 'Edit Appointment';

  @override
  String get noUpcomingAppointments => 'No upcoming appointments';

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get noCompletedAppointments => 'No completed appointments';

  @override
  String get noAppointmentsMatchSearch => 'No appointments match your search';

  @override
  String get errorLoadingAppointments => 'Error loading appointments';

  @override
  String get feedings => 'Feedings';

  @override
  String petFeedings(String petName) {
    return '$petName - Feedings';
  }

  @override
  String noFeedingsRecorded(String petName) {
    return 'No feedings recorded for $petName yet';
  }

  @override
  String get noFeedingsRecordedGeneric => 'No feedings recorded yet';

  @override
  String get addFirstFeeding => 'Add first feeding';

  @override
  String get errorLoadingFeedings => 'Error loading feedings';

  @override
  String get addNewFeeding => 'Add a new feeding';

  @override
  String get foodType => 'Food type';

  @override
  String get foodTypeHint => 'e.g., Dry Food, Wet Food, Treats';

  @override
  String get pleaseEnterFoodType => 'Please enter a food type';

  @override
  String get clear => 'Clear';

  @override
  String get add => 'Add';

  @override
  String feedingAdded(String foodType) {
    return 'Feeding \"$foodType\" added';
  }

  @override
  String get failedToSaveFeeding => 'Failed to save feeding';

  @override
  String get mixed => 'Mixed';

  @override
  String get save => 'Save';

  @override
  String get medicationInformation => 'Medication Information';

  @override
  String get medicationName => 'Medication Name *';

  @override
  String get medicationNameHint => 'e.g., Apoquel, Heartgard';

  @override
  String get pleaseEnterMedicationName => 'Please enter medication name';

  @override
  String get dosage => 'Dosage';

  @override
  String get dosageHint => 'e.g., 5mg, 1 tablet, 2ml';

  @override
  String get pleaseEnterDosage => 'Please enter dosage';

  @override
  String get frequency => 'Frequency';

  @override
  String get frequencyOnceDaily => 'Once daily';

  @override
  String get frequencyTwiceDaily => 'Twice daily';

  @override
  String get frequencyThreeTimesDaily => 'Three times daily';

  @override
  String get frequencyFourTimesDaily => 'Four times daily';

  @override
  String get frequencyEveryOtherDay => 'Every other day';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyAsNeeded => 'As needed';

  @override
  String get frequencyCustom => 'Custom';

  @override
  String get administrationMethod => 'Administration Method *';

  @override
  String get administrationMethodOral => 'Oral';

  @override
  String get administrationMethodTopical => 'Topical';

  @override
  String get administrationMethodInjection => 'Injection';

  @override
  String get administrationMethodEyeDrops => 'Eye drops';

  @override
  String get administrationMethodEarDrops => 'Ear drops';

  @override
  String get administrationMethodInhaled => 'Inhaled';

  @override
  String get administrationMethodOther => 'Other';

  @override
  String get schedule => 'Schedule';

  @override
  String get startDate => 'Start Date';

  @override
  String get hasEndDate => 'Has End Date';

  @override
  String get ongoingMedication => 'Ongoing medication';

  @override
  String get endDate => 'End Date';

  @override
  String get selectEndDate => 'Select end date';

  @override
  String get administrationTimes => 'Administration Times';

  @override
  String get addTime => 'Add time';

  @override
  String time(int number) {
    return 'Time $number';
  }

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get additionalNotesHint =>
      'Add any additional notes, special instructions, or reminders...';

  @override
  String get saveMedication => 'Save Medication';

  @override
  String get noActivePetFound =>
      'No active pet found. Please select a pet first.';

  @override
  String get medicationAddedSuccessfully => 'Medication added successfully!';

  @override
  String failedToAddMedication(String error) {
    return 'Failed to add medication: $error';
  }

  @override
  String get medicationDetails => 'Medication Details';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get duration => 'Duration';

  @override
  String get notes => 'Notes';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get markInactive => 'Mark Inactive';

  @override
  String get markActive => 'Mark Active';

  @override
  String get appointmentInformation => 'Appointment Information';

  @override
  String get veterinarian => 'Veterinarian';

  @override
  String get veterinarianHint => 'e.g., Dr. Smith, Dr. Johnson';

  @override
  String get pleaseEnterVeterinarian => 'Please enter veterinarian name';

  @override
  String get clinic => 'Clinic';

  @override
  String get clinicHint => 'e.g., Animal Hospital, Vet Clinic';

  @override
  String get pleaseEnterClinic => 'Please enter clinic name';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'e.g., Checkup, Vaccination, Surgery';

  @override
  String get pleaseEnterReason => 'Please enter reason for appointment';

  @override
  String get appointmentDate => 'Appointment Date';

  @override
  String get appointmentTime => 'Appointment Time';

  @override
  String get status => 'Status';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get appointmentCompleted => 'Appointment completed';

  @override
  String get appointmentPending => 'Appointment pending';

  @override
  String get updateAppointment => 'Update Appointment';

  @override
  String get saveAppointment => 'Save Appointment';

  @override
  String get appointmentUpdatedSuccessfully =>
      'Appointment updated successfully!';

  @override
  String get appointmentAddedSuccessfully => 'Appointment added successfully!';

  @override
  String failedToSaveAppointment(String error) {
    return 'Failed to save appointment: $error';
  }

  @override
  String get walks => 'Walks';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get addWalk => 'Add walk';

  @override
  String get start => 'Start';

  @override
  String get durationMin => 'Duration';

  @override
  String get distance => 'Distance';

  @override
  String get surfaceLabel => 'Surface';

  @override
  String get surfacePaved => 'paved';

  @override
  String get surfaceGravel => 'gravel';

  @override
  String get surfaceMixed => 'mixed';

  @override
  String get pace => 'Pace';

  @override
  String get min => 'min';

  @override
  String get km => 'km';

  @override
  String get noWalksYet => 'No walks yet';

  @override
  String get trackFirstWalk =>
      'Track your first walk to see distance and duration here.';

  @override
  String get addFirstWalk => 'Add first walk';

  @override
  String get walkDetails => 'Walk details';

  @override
  String get close => 'Close';

  @override
  String get noNotes => 'No notes';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Required';

  @override
  String get enterPositiveNumber => 'Enter a positive number';

  @override
  String get walkAddedSuccessfully => 'Walk added successfully!';

  @override
  String walkDetailsFor(String walkInfo) {
    return 'Walk details for $walkInfo';
  }

  @override
  String get reports => 'Reports';

  @override
  String get health => 'Health';

  @override
  String get activity => 'Activity';

  @override
  String get searchReports => 'Search reports...';

  @override
  String get generateReport => 'Generate Report';

  @override
  String get healthSummary => 'Health Summary';

  @override
  String get activityReport => 'Activity Report';

  @override
  String get veterinaryRecords => 'Veterinary Records';

  @override
  String get generated => 'Generated';

  @override
  String get period => 'Period';

  @override
  String get data => 'Data';

  @override
  String get summary => 'Summary';

  @override
  String get items => 'items';

  @override
  String get feeds => 'feeds';

  @override
  String get visits => 'visits';

  @override
  String get outOf => 'out of';

  @override
  String get total => 'total';

  @override
  String get avg => 'avg';

  @override
  String get perDay => 'per day';

  @override
  String get generatedOn => 'Generated on';

  @override
  String get at => 'at';

  @override
  String get days => 'days';

  @override
  String get totalFeedings => 'Total Feedings';

  @override
  String get dailyAverage => 'Daily Average';

  @override
  String get inPeriod => 'In period';

  @override
  String get feedingHistory => 'Feeding History';

  @override
  String get date => 'Date';

  @override
  String get type => 'Type';

  @override
  String get amount => 'Amount';

  @override
  String get dryFood => 'Dry Food';

  @override
  String get wetFood => 'Wet Food';

  @override
  String get treats => 'Treats';

  @override
  String get timeLabel => 'Time';

  @override
  String get name => 'Name';

  @override
  String get method => 'Method';

  @override
  String get appointmentHistory => 'Appointment History';

  @override
  String get pending => 'Pending';

  @override
  String get finished => 'Finished';

  @override
  String get completedTotal => 'Completed/Total';

  @override
  String get activeTotal => 'Active/Total';

  @override
  String get noMedicationsFoundPeriod => 'No medications found for this period';

  @override
  String get noFeedingDataFoundPeriod =>
      'No feeding data found for this period';

  @override
  String get noVeterinaryAppointmentsFoundPeriod =>
      'No veterinary appointments found for this period';

  @override
  String get shareFunctionalityPlaceholder =>
      'Share functionality would be implemented here';

  @override
  String get reportConfiguration => 'Report Configuration';

  @override
  String get reportType => 'Report Type';

  @override
  String get pleaseSelectReportType => 'Please select a report type';

  @override
  String get dateRange => 'Date Range';

  @override
  String get quickRanges => 'Quick Ranges';

  @override
  String get healthSummaryDescription =>
      'Comprehensive overview including recent medications, appointments, and activities for the selected period.';

  @override
  String get medicationHistoryDescription =>
      'Detailed list of all medications with dates, dosages, and completion status for the selected period.';

  @override
  String get activityReportDescription =>
      'Analysis of walks, exercise patterns, and activity trends over the selected time frame.';

  @override
  String get veterinaryRecordsDescription =>
      'Complete record of all veterinary appointments with outcomes and notes for the selected period.';

  @override
  String get selectReportTypeDescription =>
      'Select a report type to see its description.';

  @override
  String get endDateMustBeAfterStartDate => 'End date must be after start date';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last3Months => 'Last 3 months';

  @override
  String get last6Months => 'Last 6 months';

  @override
  String get lastYear => 'Last year';

  @override
  String get reportGeneratedSuccessfully => 'Report generated successfully!';

  @override
  String failedToGenerateReport(String error) {
    return 'Failed to generate report: $error';
  }

  @override
  String get medicationHistory => 'Medication History';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get deleteConfirmationMessage =>
      'Are you sure you want to delete this feeding?';

  @override
  String get feedingDeleted => 'Feeding deleted successfully';

  @override
  String get pet => 'Pet';

  @override
  String get pleaseSelectPet => 'Please select a pet';

  @override
  String get pleaseEnterAmount => 'Please enter amount';

  @override
  String get addNotesOptional => 'Add notes (optional)';

  @override
  String get feedingTime => 'Feeding Time';

  @override
  String get editFeeding => 'Edit Feeding';

  @override
  String get petProfiles => 'Pet Profiles';

  @override
  String get addPet => 'Add Pet';

  @override
  String get allProfiles => 'All Profiles';

  @override
  String get activeProfile => 'ACTIVE';

  @override
  String get noPetsYet => 'No pets yet!';

  @override
  String get addYourFirstPet => 'Add your first pet to get started';

  @override
  String get makeActive => 'Make Active';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String deleteProfileConfirm(String petName) {
    return 'Are you sure you want to delete $petName\'s profile? This action cannot be undone.';
  }

  @override
  String profileDeleted(String petName) {
    return '$petName\'s profile deleted';
  }

  @override
  String get failedToDeleteProfile => 'Failed to delete profile';

  @override
  String nowActive(String petName) {
    return '$petName is now your active pet';
  }

  @override
  String failedToActivateProfile(String error) {
    return 'Failed to activate profile: $error';
  }

  @override
  String get errorLoadingProfiles => 'Error loading profiles';

  @override
  String yearsOld(int age, String plural) {
    return '$age year$plural old';
  }

  @override
  String get settings => 'Settings';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeToUnlock => 'Upgrade to unlock advanced features';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Română';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable app notifications';

  @override
  String get enableAnalytics => 'Enable analytics';

  @override
  String get helpImproveApp => 'Help improve the app';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get exportData => 'Export data';

  @override
  String get downloadYourData => 'Download your data';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get freeUpSpace => 'Free up storage space';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountPermanently => 'Permanently delete your account';

  @override
  String get privacyAndLegal => 'Privacy & Legal';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App version';

  @override
  String get petOwner => 'Pet Owner';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get clearCacheConfirm =>
      'Are you sure you want to clear the cache? This action cannot be undone.';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get noReportsFound => 'No reports found';

  @override
  String get noHealthReportsFound => 'No health reports found';

  @override
  String get noMedicationReportsFound => 'No medication reports found';

  @override
  String get noActivityReportsFound => 'No activity reports found';

  @override
  String get noReportsMatchSearch => 'No reports match your search';

  @override
  String get errorLoadingReports => 'Error loading reports';

  @override
  String get overdue => 'Overdue';

  @override
  String get justNow => 'Just now';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Done';

  @override
  String get markPending => 'Mark Pending';

  @override
  String get markCompleted => 'Mark Completed';

  @override
  String get daysUntil => 'In';

  @override
  String get started => 'Started';

  @override
  String get ends => 'Ends';

  @override
  String get reminders => 'Reminders';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get editReminder => 'Edit Reminder';

  @override
  String get reminderType => 'Reminder Type';

  @override
  String get reminderTitle => 'Title';

  @override
  String get reminderDescription => 'Description';

  @override
  String get scheduledTime => 'Scheduled Time';

  @override
  String get once => 'Once';

  @override
  String get daily => 'Daily';

  @override
  String get twiceDaily => 'Twice Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get custom => 'Custom';

  @override
  String get activeReminders => 'Active Reminders';

  @override
  String get noReminders => 'No reminders set';

  @override
  String get noRemindersDescription =>
      'Add reminders to never forget important care tasks';

  @override
  String get setReminder => 'Set Reminder';

  @override
  String get reminderSet => 'Reminder set successfully';

  @override
  String remindersCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Created $count reminders',
      one: 'Created 1 reminder',
    );
    return '$_temp0';
  }

  @override
  String get view => 'View';

  @override
  String get reminderDeleted => 'Reminder deleted';

  @override
  String nextReminder(String time) {
    return 'Next: $time';
  }

  @override
  String get medicationReminder => 'Medication Reminder';

  @override
  String get appointmentReminder => 'Appointment Reminder';

  @override
  String get feedingReminder => 'Feeding Reminder';

  @override
  String get walkReminder => 'Walk Reminder';

  @override
  String get remindMeAt => 'Remind me at';

  @override
  String get remind1DayBefore => 'Remind 1 day before';

  @override
  String get remind1HourBefore => 'Remind 1 hour before';

  @override
  String get selectDays => 'Select Days';

  @override
  String get selectTime => 'Select Time';

  @override
  String get reminderUpdated => 'Reminder updated successfully';

  @override
  String get reminderAdded => 'Reminder added successfully';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get failedToCreateReminder => 'Failed to create reminder';

  @override
  String get failedToUpdateReminder => 'Failed to update reminder';

  @override
  String get failedToDeleteReminder => 'Failed to delete reminder';

  @override
  String get deleteReminder => 'Delete Reminder';

  @override
  String get deleteReminderConfirm =>
      'Are you sure you want to delete this reminder?';

  @override
  String get noActiveReminders => 'No active reminders';

  @override
  String get noInactiveReminders => 'No inactive reminders';

  @override
  String get linkToEntity => 'Link to existing item';

  @override
  String get customSchedule => 'Custom Schedule';

  @override
  String get repeatOn => 'Repeat on';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get weightTracking => 'Weight Tracking';

  @override
  String get addWeight => 'Add Weight';

  @override
  String get editWeight => 'Edit Weight';

  @override
  String get deleteWeight => 'Delete Weight';

  @override
  String get deleteWeightConfirm =>
      'Are you sure you want to delete this weight entry?';

  @override
  String get weightDeleted => 'Weight entry deleted';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get weight => 'Weight';

  @override
  String get weightTrend => 'Weight Trend';

  @override
  String get history => 'History';

  @override
  String get noWeightEntries => 'No weight entries yet';

  @override
  String get addWeightToTrack =>
      'Start tracking your pet\'s weight to monitor their health over time';

  @override
  String get pleaseEnterWeight => 'Please enter a weight';

  @override
  String get pleaseEnterValidWeight => 'Please enter a valid weight';

  @override
  String get weightAdded => 'Weight entry added';

  @override
  String get weightUpdated => 'Weight entry updated';

  @override
  String get aboutWeightTracking => 'About Weight Tracking';

  @override
  String get weightTrackingInfo =>
      'Regular weight monitoring helps detect health issues early. Track your pet\'s weight at consistent times (like weekly weigh-ins) for the most accurate trends.';

  @override
  String get optionalNotes =>
      'Optional: Add notes about diet, activity, or health';

  @override
  String get info => 'Info';

  @override
  String get photoGallery => 'Photo Gallery';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseMultiplePhotos => 'Choose Multiple Photos';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get deletePhotoConfirm =>
      'Are you sure you want to delete this photo? This action cannot be undone.';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String get editCaption => 'Edit Caption';

  @override
  String get caption => 'Caption';

  @override
  String get addCaption => 'Add a caption...';

  @override
  String get noCaption => 'No caption';

  @override
  String get captionSaved => 'Caption saved';

  @override
  String get noPhotos => 'No photos yet';

  @override
  String get addFirstPhoto => 'Add your first photo to create memories';

  @override
  String get photoAdded => 'Photo added successfully';

  @override
  String photosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos added',
      one: '1 photo added',
    );
    return '$_temp0';
  }

  @override
  String get processingPhotos => 'Processing photos...';

  @override
  String get cameraPermissionDenied =>
      'Camera permission is required to take photos';

  @override
  String get storagePermissionDenied =>
      'Storage permission is required to access photos';

  @override
  String get galleryPermissionDenied =>
      'Gallery permission is required to select photos';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get storageUsed => 'Storage Used';

  @override
  String get photos => 'Photos';

  @override
  String get dateTaken => 'Date Taken';

  @override
  String get dateAdded => 'Date Added';

  @override
  String get fileSize => 'File Size';

  @override
  String get photoDetails => 'Photo Details';
}
