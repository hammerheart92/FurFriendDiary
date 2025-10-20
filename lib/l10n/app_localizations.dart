import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ro')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FurFriendDiary'**
  String get appTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, furry friend!'**
  String get homeGreeting;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @searchMedications.
  ///
  /// In en, this message translates to:
  /// **'Search medications...'**
  String get searchMedications;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @noPetSelected.
  ///
  /// In en, this message translates to:
  /// **'No pet selected'**
  String get noPetSelected;

  /// No description provided for @pleaseSetupPetFirst.
  ///
  /// In en, this message translates to:
  /// **'Please set up a pet profile first'**
  String get pleaseSetupPetFirst;

  /// No description provided for @noActiveMedications.
  ///
  /// In en, this message translates to:
  /// **'No active medications'**
  String get noActiveMedications;

  /// No description provided for @noMedicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No medications found'**
  String get noMedicationsFound;

  /// No description provided for @noInactiveMedications.
  ///
  /// In en, this message translates to:
  /// **'No inactive medications'**
  String get noInactiveMedications;

  /// No description provided for @noMedicationsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No medications match your search'**
  String get noMedicationsMatchSearch;

  /// No description provided for @tryAdjustingSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get tryAdjustingSearchTerms;

  /// No description provided for @errorLoadingMedications.
  ///
  /// In en, this message translates to:
  /// **'Error loading medications'**
  String get errorLoadingMedications;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @medicationMarkedInactive.
  ///
  /// In en, this message translates to:
  /// **'Medication marked as inactive'**
  String get medicationMarkedInactive;

  /// No description provided for @medicationMarkedActive.
  ///
  /// In en, this message translates to:
  /// **'Medication marked as active'**
  String get medicationMarkedActive;

  /// No description provided for @failedToUpdateMedication.
  ///
  /// In en, this message translates to:
  /// **'Failed to update medication'**
  String get failedToUpdateMedication;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get deleteMedication;

  /// No description provided for @deleteMedicationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{medicationName}\"? This action cannot be undone.'**
  String deleteMedicationConfirm(String medicationName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @medicationDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medication deleted successfully'**
  String get medicationDeletedSuccessfully;

  /// No description provided for @failedToDeleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete medication'**
  String get failedToDeleteMedication;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @searchAppointments.
  ///
  /// In en, this message translates to:
  /// **'Search appointments...'**
  String get searchAppointments;

  /// No description provided for @addAppointment.
  ///
  /// In en, this message translates to:
  /// **'Add Appointment'**
  String get addAppointment;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get editAppointment;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No description provided for @noCompletedAppointments.
  ///
  /// In en, this message translates to:
  /// **'No completed appointments'**
  String get noCompletedAppointments;

  /// No description provided for @noAppointmentsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No appointments match your search'**
  String get noAppointmentsMatchSearch;

  /// No description provided for @errorLoadingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Error loading appointments'**
  String get errorLoadingAppointments;

  /// No description provided for @feedings.
  ///
  /// In en, this message translates to:
  /// **'Feedings'**
  String get feedings;

  /// No description provided for @petFeedings.
  ///
  /// In en, this message translates to:
  /// **'{petName} - Feedings'**
  String petFeedings(String petName);

  /// No description provided for @noFeedingsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No feedings recorded for {petName} yet'**
  String noFeedingsRecorded(String petName);

  /// No description provided for @noFeedingsRecordedGeneric.
  ///
  /// In en, this message translates to:
  /// **'No feedings recorded yet'**
  String get noFeedingsRecordedGeneric;

  /// No description provided for @addFirstFeeding.
  ///
  /// In en, this message translates to:
  /// **'Add first feeding'**
  String get addFirstFeeding;

  /// No description provided for @errorLoadingFeedings.
  ///
  /// In en, this message translates to:
  /// **'Error loading feedings'**
  String get errorLoadingFeedings;

  /// No description provided for @addNewFeeding.
  ///
  /// In en, this message translates to:
  /// **'Add a new feeding'**
  String get addNewFeeding;

  /// No description provided for @foodType.
  ///
  /// In en, this message translates to:
  /// **'Food type'**
  String get foodType;

  /// No description provided for @foodTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dry Food, Wet Food, Treats'**
  String get foodTypeHint;

  /// No description provided for @pleaseEnterFoodType.
  ///
  /// In en, this message translates to:
  /// **'Please enter a food type'**
  String get pleaseEnterFoodType;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @feedingAdded.
  ///
  /// In en, this message translates to:
  /// **'Feeding \"{foodType}\" added'**
  String feedingAdded(String foodType);

  /// No description provided for @failedToSaveFeeding.
  ///
  /// In en, this message translates to:
  /// **'Failed to save feeding'**
  String get failedToSaveFeeding;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @medicationInformation.
  ///
  /// In en, this message translates to:
  /// **'Medication Information'**
  String get medicationInformation;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name *'**
  String get medicationName;

  /// No description provided for @medicationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Apoquel, Heartgard'**
  String get medicationNameHint;

  /// No description provided for @pleaseEnterMedicationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medication name'**
  String get pleaseEnterMedicationName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @dosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5mg, 1 tablet, 2ml'**
  String get dosageHint;

  /// No description provided for @pleaseEnterDosage.
  ///
  /// In en, this message translates to:
  /// **'Please enter dosage'**
  String get pleaseEnterDosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @frequencyOnceDaily.
  ///
  /// In en, this message translates to:
  /// **'Once daily'**
  String get frequencyOnceDaily;

  /// No description provided for @frequencyTwiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice daily'**
  String get frequencyTwiceDaily;

  /// No description provided for @frequencyThreeTimesDaily.
  ///
  /// In en, this message translates to:
  /// **'Three times daily'**
  String get frequencyThreeTimesDaily;

  /// No description provided for @frequencyFourTimesDaily.
  ///
  /// In en, this message translates to:
  /// **'Four times daily'**
  String get frequencyFourTimesDaily;

  /// No description provided for @frequencyEveryOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get frequencyEveryOtherDay;

  /// No description provided for @frequencyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// No description provided for @frequencyAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As needed'**
  String get frequencyAsNeeded;

  /// No description provided for @frequencyCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get frequencyCustom;

  /// No description provided for @administrationMethod.
  ///
  /// In en, this message translates to:
  /// **'Administration Method *'**
  String get administrationMethod;

  /// No description provided for @administrationMethodOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get administrationMethodOral;

  /// No description provided for @administrationMethodTopical.
  ///
  /// In en, this message translates to:
  /// **'Topical'**
  String get administrationMethodTopical;

  /// No description provided for @administrationMethodInjection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get administrationMethodInjection;

  /// No description provided for @administrationMethodEyeDrops.
  ///
  /// In en, this message translates to:
  /// **'Eye drops'**
  String get administrationMethodEyeDrops;

  /// No description provided for @administrationMethodEarDrops.
  ///
  /// In en, this message translates to:
  /// **'Ear drops'**
  String get administrationMethodEarDrops;

  /// No description provided for @administrationMethodInhaled.
  ///
  /// In en, this message translates to:
  /// **'Inhaled'**
  String get administrationMethodInhaled;

  /// No description provided for @administrationMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get administrationMethodOther;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @hasEndDate.
  ///
  /// In en, this message translates to:
  /// **'Has End Date'**
  String get hasEndDate;

  /// No description provided for @ongoingMedication.
  ///
  /// In en, this message translates to:
  /// **'Ongoing medication'**
  String get ongoingMedication;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select end date'**
  String get selectEndDate;

  /// No description provided for @administrationTimes.
  ///
  /// In en, this message translates to:
  /// **'Administration Times'**
  String get administrationTimes;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time {number}'**
  String time(int number);

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @additionalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes, special instructions, or reminders...'**
  String get additionalNotesHint;

  /// No description provided for @saveMedication.
  ///
  /// In en, this message translates to:
  /// **'Save Medication'**
  String get saveMedication;

  /// No description provided for @noActivePetFound.
  ///
  /// In en, this message translates to:
  /// **'No active pet found. Please select a pet first.'**
  String get noActivePetFound;

  /// No description provided for @medicationAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medication added successfully!'**
  String get medicationAddedSuccessfully;

  /// No description provided for @failedToAddMedication.
  ///
  /// In en, this message translates to:
  /// **'Failed to add medication: {error}'**
  String failedToAddMedication(String error);

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Medication Details'**
  String get medicationDetails;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @markInactive.
  ///
  /// In en, this message translates to:
  /// **'Mark Inactive'**
  String get markInactive;

  /// No description provided for @markActive.
  ///
  /// In en, this message translates to:
  /// **'Mark Active'**
  String get markActive;

  /// No description provided for @appointmentInformation.
  ///
  /// In en, this message translates to:
  /// **'Appointment Information'**
  String get appointmentInformation;

  /// No description provided for @veterinarian.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian'**
  String get veterinarian;

  /// No description provided for @veterinarianHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Dr. Smith, Dr. Johnson'**
  String get veterinarianHint;

  /// No description provided for @pleaseEnterVeterinarian.
  ///
  /// In en, this message translates to:
  /// **'Please enter veterinarian name'**
  String get pleaseEnterVeterinarian;

  /// No description provided for @clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinic;

  /// No description provided for @clinicHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Animal Hospital, Vet Clinic'**
  String get clinicHint;

  /// No description provided for @pleaseEnterClinic.
  ///
  /// In en, this message translates to:
  /// **'Please enter clinic name'**
  String get pleaseEnterClinic;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Checkup, Vaccination, Surgery'**
  String get reasonHint;

  /// No description provided for @pleaseEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter reason for appointment'**
  String get pleaseEnterReason;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment Date'**
  String get appointmentDate;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment Time'**
  String get appointmentTime;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @appointmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Appointment completed'**
  String get appointmentCompleted;

  /// No description provided for @appointmentPending.
  ///
  /// In en, this message translates to:
  /// **'Appointment pending'**
  String get appointmentPending;

  /// No description provided for @updateAppointment.
  ///
  /// In en, this message translates to:
  /// **'Update Appointment'**
  String get updateAppointment;

  /// No description provided for @saveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get saveAppointment;

  /// No description provided for @appointmentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Appointment updated successfully!'**
  String get appointmentUpdatedSuccessfully;

  /// No description provided for @appointmentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Appointment added successfully!'**
  String get appointmentAddedSuccessfully;

  /// No description provided for @failedToSaveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Failed to save appointment: {error}'**
  String failedToSaveAppointment(String error);

  /// No description provided for @walks.
  ///
  /// In en, this message translates to:
  /// **'Walks'**
  String get walks;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @addWalk.
  ///
  /// In en, this message translates to:
  /// **'Add walk'**
  String get addWalk;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @durationMin.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationMin;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @surfaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surfaceLabel;

  /// No description provided for @surfacePaved.
  ///
  /// In en, this message translates to:
  /// **'paved'**
  String get surfacePaved;

  /// No description provided for @surfaceGravel.
  ///
  /// In en, this message translates to:
  /// **'gravel'**
  String get surfaceGravel;

  /// No description provided for @surfaceMixed.
  ///
  /// In en, this message translates to:
  /// **'mixed'**
  String get surfaceMixed;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @noWalksYet.
  ///
  /// In en, this message translates to:
  /// **'No walks yet'**
  String get noWalksYet;

  /// No description provided for @trackFirstWalk.
  ///
  /// In en, this message translates to:
  /// **'Track your first walk to see distance and duration here.'**
  String get trackFirstWalk;

  /// No description provided for @addFirstWalk.
  ///
  /// In en, this message translates to:
  /// **'Add first walk'**
  String get addFirstWalk;

  /// No description provided for @walkDetails.
  ///
  /// In en, this message translates to:
  /// **'Walk details'**
  String get walkDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes'**
  String get noNotes;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @enterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get enterPositiveNumber;

  /// No description provided for @walkAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Walk added successfully!'**
  String get walkAddedSuccessfully;

  /// No description provided for @walkDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Walk details for {walkInfo}'**
  String walkDetailsFor(String walkInfo);

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports...'**
  String get searchReports;

  /// No description provided for @generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get generateReport;

  /// No description provided for @healthSummary.
  ///
  /// In en, this message translates to:
  /// **'Health Summary'**
  String get healthSummary;

  /// No description provided for @activityReport.
  ///
  /// In en, this message translates to:
  /// **'Activity Report'**
  String get activityReport;

  /// No description provided for @veterinaryRecords.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Records'**
  String get veterinaryRecords;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get generated;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @feeds.
  ///
  /// In en, this message translates to:
  /// **'feeds'**
  String get feeds;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'visits'**
  String get visits;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get avg;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get generatedOn;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @totalFeedings.
  ///
  /// In en, this message translates to:
  /// **'Total Feedings'**
  String get totalFeedings;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAverage;

  /// No description provided for @inPeriod.
  ///
  /// In en, this message translates to:
  /// **'In period'**
  String get inPeriod;

  /// No description provided for @feedingHistory.
  ///
  /// In en, this message translates to:
  /// **'Feeding History'**
  String get feedingHistory;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @dryFood.
  ///
  /// In en, this message translates to:
  /// **'Dry Food'**
  String get dryFood;

  /// No description provided for @wetFood.
  ///
  /// In en, this message translates to:
  /// **'Wet Food'**
  String get wetFood;

  /// No description provided for @treats.
  ///
  /// In en, this message translates to:
  /// **'Treats'**
  String get treats;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @appointmentHistory.
  ///
  /// In en, this message translates to:
  /// **'Appointment History'**
  String get appointmentHistory;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @completedTotal.
  ///
  /// In en, this message translates to:
  /// **'Completed/Total'**
  String get completedTotal;

  /// No description provided for @activeTotal.
  ///
  /// In en, this message translates to:
  /// **'Active/Total'**
  String get activeTotal;

  /// No description provided for @noMedicationsFoundPeriod.
  ///
  /// In en, this message translates to:
  /// **'No medications found for this period'**
  String get noMedicationsFoundPeriod;

  /// No description provided for @noFeedingDataFoundPeriod.
  ///
  /// In en, this message translates to:
  /// **'No feeding data found for this period'**
  String get noFeedingDataFoundPeriod;

  /// No description provided for @noVeterinaryAppointmentsFoundPeriod.
  ///
  /// In en, this message translates to:
  /// **'No veterinary appointments found for this period'**
  String get noVeterinaryAppointmentsFoundPeriod;

  /// No description provided for @shareFunctionalityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Share functionality would be implemented here'**
  String get shareFunctionalityPlaceholder;

  /// No description provided for @reportConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Report Configuration'**
  String get reportConfiguration;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// No description provided for @pleaseSelectReportType.
  ///
  /// In en, this message translates to:
  /// **'Please select a report type'**
  String get pleaseSelectReportType;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @quickRanges.
  ///
  /// In en, this message translates to:
  /// **'Quick Ranges'**
  String get quickRanges;

  /// No description provided for @healthSummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive overview including recent medications, appointments, and activities for the selected period.'**
  String get healthSummaryDescription;

  /// No description provided for @medicationHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Detailed list of all medications with dates, dosages, and completion status for the selected period.'**
  String get medicationHistoryDescription;

  /// No description provided for @activityReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Analysis of walks, exercise patterns, and activity trends over the selected time frame.'**
  String get activityReportDescription;

  /// No description provided for @veterinaryRecordsDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete record of all veterinary appointments with outcomes and notes for the selected period.'**
  String get veterinaryRecordsDescription;

  /// No description provided for @selectReportTypeDescription.
  ///
  /// In en, this message translates to:
  /// **'Select a report type to see its description.'**
  String get selectReportTypeDescription;

  /// No description provided for @endDateMustBeAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get endDateMustBeAfterStartDate;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get last3Months;

  /// No description provided for @last6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get last6Months;

  /// No description provided for @lastYear.
  ///
  /// In en, this message translates to:
  /// **'Last year'**
  String get lastYear;

  /// No description provided for @reportGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully!'**
  String get reportGeneratedSuccessfully;

  /// No description provided for @failedToGenerateReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report: {error}'**
  String failedToGenerateReport(String error);

  /// No description provided for @medicationHistory.
  ///
  /// In en, this message translates to:
  /// **'Medication History'**
  String get medicationHistory;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this feeding?'**
  String get deleteConfirmationMessage;

  /// No description provided for @feedingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Feeding deleted successfully'**
  String get feedingDeleted;

  /// No description provided for @pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet;

  /// No description provided for @pleaseSelectPet.
  ///
  /// In en, this message translates to:
  /// **'Please select a pet'**
  String get pleaseSelectPet;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get pleaseEnterAmount;

  /// No description provided for @addNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Add notes (optional)'**
  String get addNotesOptional;

  /// No description provided for @feedingTime.
  ///
  /// In en, this message translates to:
  /// **'Feeding Time'**
  String get feedingTime;

  /// No description provided for @editFeeding.
  ///
  /// In en, this message translates to:
  /// **'Edit Feeding'**
  String get editFeeding;

  /// No description provided for @petProfiles.
  ///
  /// In en, this message translates to:
  /// **'Pet Profiles'**
  String get petProfiles;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @allProfiles.
  ///
  /// In en, this message translates to:
  /// **'All Profiles'**
  String get allProfiles;

  /// No description provided for @activeProfile.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeProfile;

  /// No description provided for @noPetsYet.
  ///
  /// In en, this message translates to:
  /// **'No pets yet!'**
  String get noPetsYet;

  /// No description provided for @addYourFirstPet.
  ///
  /// In en, this message translates to:
  /// **'Add your first pet to get started'**
  String get addYourFirstPet;

  /// No description provided for @makeActive.
  ///
  /// In en, this message translates to:
  /// **'Make Active'**
  String get makeActive;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {petName}\'s profile? This action cannot be undone.'**
  String deleteProfileConfirm(String petName);

  /// No description provided for @profileDeleted.
  ///
  /// In en, this message translates to:
  /// **'{petName}\'s profile deleted'**
  String profileDeleted(String petName);

  /// No description provided for @failedToDeleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile'**
  String get failedToDeleteProfile;

  /// No description provided for @nowActive.
  ///
  /// In en, this message translates to:
  /// **'{petName} is now your active pet'**
  String nowActive(String petName);

  /// No description provided for @failedToActivateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to activate profile: {error}'**
  String failedToActivateProfile(String error);

  /// No description provided for @errorLoadingProfiles.
  ///
  /// In en, this message translates to:
  /// **'Error loading profiles'**
  String get errorLoadingProfiles;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} year{plural} old'**
  String yearsOld(int age, String plural);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @upgradeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock advanced features'**
  String get upgradeToUnlock;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @romanian.
  ///
  /// In en, this message translates to:
  /// **'Română'**
  String get romanian;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable app notifications'**
  String get enableNotifications;

  /// No description provided for @enableAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Enable analytics'**
  String get enableAnalytics;

  /// No description provided for @helpImproveApp.
  ///
  /// In en, this message translates to:
  /// **'Help improve the app'**
  String get helpImproveApp;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// No description provided for @downloadYourData.
  ///
  /// In en, this message translates to:
  /// **'Download your data'**
  String get downloadYourData;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @freeUpSpace.
  ///
  /// In en, this message translates to:
  /// **'Free up storage space'**
  String get freeUpSpace;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountPermanently;

  /// No description provided for @privacyAndLegal.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Legal'**
  String get privacyAndLegal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @petOwner.
  ///
  /// In en, this message translates to:
  /// **'Pet Owner'**
  String get petOwner;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cache? This action cannot be undone.'**
  String get clearCacheConfirm;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data will be lost.'**
  String get deleteAccountConfirm;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @noHealthReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No health reports found'**
  String get noHealthReportsFound;

  /// No description provided for @noMedicationReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No medication reports found'**
  String get noMedicationReportsFound;

  /// No description provided for @noActivityReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No activity reports found'**
  String get noActivityReportsFound;

  /// No description provided for @noReportsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No reports match your search'**
  String get noReportsMatchSearch;

  /// No description provided for @errorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get errorLoadingReports;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(int count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @markPending.
  ///
  /// In en, this message translates to:
  /// **'Mark Pending'**
  String get markPending;

  /// No description provided for @markCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark Completed'**
  String get markCompleted;

  /// No description provided for @daysUntil.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get daysUntil;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminder;

  /// No description provided for @reminderType.
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reminderTitle;

  /// No description provided for @reminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reminderDescription;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get scheduledTime;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @twiceDaily.
  ///
  /// In en, this message translates to:
  /// **'Twice Daily'**
  String get twiceDaily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @activeReminders.
  ///
  /// In en, this message translates to:
  /// **'Active Reminders'**
  String get activeReminders;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders set'**
  String get noReminders;

  /// No description provided for @noRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Add reminders to never forget important care tasks'**
  String get noRemindersDescription;

  /// No description provided for @setReminder.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder'**
  String get setReminder;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set successfully'**
  String get reminderSet;

  /// No description provided for @remindersCreated.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Created 1 reminder} other{Created {count} reminders}}'**
  String remindersCreated(int count);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @reminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted'**
  String get reminderDeleted;

  /// No description provided for @nextReminder.
  ///
  /// In en, this message translates to:
  /// **'Next: {time}'**
  String nextReminder(String time);

  /// No description provided for @medicationReminder.
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medicationReminder;

  /// No description provided for @appointmentReminder.
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointmentReminder;

  /// No description provided for @feedingReminder.
  ///
  /// In en, this message translates to:
  /// **'Feeding Reminder'**
  String get feedingReminder;

  /// No description provided for @walkReminder.
  ///
  /// In en, this message translates to:
  /// **'Walk Reminder'**
  String get walkReminder;

  /// No description provided for @remindMeAt.
  ///
  /// In en, this message translates to:
  /// **'Remind me at'**
  String get remindMeAt;

  /// No description provided for @remind1DayBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind 1 day before'**
  String get remind1DayBefore;

  /// No description provided for @remind1HourBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind 1 hour before'**
  String get remind1HourBefore;

  /// No description provided for @selectDays.
  ///
  /// In en, this message translates to:
  /// **'Select Days'**
  String get selectDays;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated successfully'**
  String get reminderUpdated;

  /// No description provided for @reminderAdded.
  ///
  /// In en, this message translates to:
  /// **'Reminder added successfully'**
  String get reminderAdded;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @failedToCreateReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to create reminder'**
  String get failedToCreateReminder;

  /// No description provided for @failedToUpdateReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to update reminder'**
  String get failedToUpdateReminder;

  /// No description provided for @failedToDeleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete reminder'**
  String get failedToDeleteReminder;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminder;

  /// No description provided for @deleteReminderConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder?'**
  String get deleteReminderConfirm;

  /// No description provided for @noActiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No active reminders'**
  String get noActiveReminders;

  /// No description provided for @noInactiveReminders.
  ///
  /// In en, this message translates to:
  /// **'No inactive reminders'**
  String get noInactiveReminders;

  /// No description provided for @linkToEntity.
  ///
  /// In en, this message translates to:
  /// **'Link to existing item'**
  String get linkToEntity;

  /// No description provided for @customSchedule.
  ///
  /// In en, this message translates to:
  /// **'Custom Schedule'**
  String get customSchedule;

  /// No description provided for @repeatOn.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOn;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @weightTracking.
  ///
  /// In en, this message translates to:
  /// **'Weight Tracking'**
  String get weightTracking;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add Weight'**
  String get addWeight;

  /// No description provided for @editWeight.
  ///
  /// In en, this message translates to:
  /// **'Edit Weight'**
  String get editWeight;

  /// No description provided for @deleteWeight.
  ///
  /// In en, this message translates to:
  /// **'Delete Weight'**
  String get deleteWeight;

  /// No description provided for @deleteWeightConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this weight entry?'**
  String get deleteWeightConfirm;

  /// No description provided for @weightDeleted.
  ///
  /// In en, this message translates to:
  /// **'Weight entry deleted'**
  String get weightDeleted;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get weightTrend;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noWeightEntries.
  ///
  /// In en, this message translates to:
  /// **'No weight entries yet'**
  String get noWeightEntries;

  /// No description provided for @addWeightToTrack.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your pet\'s weight to monitor their health over time'**
  String get addWeightToTrack;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a weight'**
  String get pleaseEnterWeight;

  /// No description provided for @pleaseEnterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get pleaseEnterValidWeight;

  /// No description provided for @weightAdded.
  ///
  /// In en, this message translates to:
  /// **'Weight entry added'**
  String get weightAdded;

  /// No description provided for @weightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Weight entry updated'**
  String get weightUpdated;

  /// No description provided for @aboutWeightTracking.
  ///
  /// In en, this message translates to:
  /// **'About Weight Tracking'**
  String get aboutWeightTracking;

  /// No description provided for @weightTrackingInfo.
  ///
  /// In en, this message translates to:
  /// **'Regular weight monitoring helps detect health issues early. Track your pet\'s weight at consistent times (like weekly weigh-ins) for the most accurate trends.'**
  String get weightTrackingInfo;

  /// No description provided for @optionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional: Add notes about diet, activity, or health'**
  String get optionalNotes;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get photoGallery;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseMultiplePhotos.
  ///
  /// In en, this message translates to:
  /// **'Choose Multiple Photos'**
  String get chooseMultiplePhotos;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get deletePhoto;

  /// No description provided for @deletePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo? This action cannot be undone.'**
  String get deletePhotoConfirm;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted'**
  String get photoDeleted;

  /// No description provided for @editCaption.
  ///
  /// In en, this message translates to:
  /// **'Edit Caption'**
  String get editCaption;

  /// No description provided for @caption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get caption;

  /// No description provided for @addCaption.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get addCaption;

  /// No description provided for @noCaption.
  ///
  /// In en, this message translates to:
  /// **'No caption'**
  String get noCaption;

  /// No description provided for @captionSaved.
  ///
  /// In en, this message translates to:
  /// **'Caption saved'**
  String get captionSaved;

  /// No description provided for @noPhotos.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotos;

  /// No description provided for @addFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add your first photo to create memories'**
  String get addFirstPhoto;

  /// No description provided for @photoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added successfully'**
  String get photoAdded;

  /// No description provided for @photosAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo added} other{{count} photos added}}'**
  String photosAdded(int count);

  /// No description provided for @processingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Processing photos...'**
  String get processingPhotos;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get cameraPermissionDenied;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to access photos'**
  String get storagePermissionDenied;

  /// No description provided for @galleryPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission is required to select photos'**
  String get galleryPermissionDenied;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @storageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get storageUsed;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @dateTaken.
  ///
  /// In en, this message translates to:
  /// **'Date Taken'**
  String get dateTaken;

  /// No description provided for @dateAdded.
  ///
  /// In en, this message translates to:
  /// **'Date Added'**
  String get dateAdded;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @photoDetails.
  ///
  /// In en, this message translates to:
  /// **'Photo Details'**
  String get photoDetails;

  /// No description provided for @medicationInventory.
  ///
  /// In en, this message translates to:
  /// **'Medication Inventory'**
  String get medicationInventory;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @allMedications.
  ///
  /// In en, this message translates to:
  /// **'All Medications'**
  String get allMedications;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @stockUnit.
  ///
  /// In en, this message translates to:
  /// **'Stock Unit'**
  String get stockUnit;

  /// No description provided for @lowStockThreshold.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockThreshold;

  /// No description provided for @costPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Cost per Unit'**
  String get costPerUnit;

  /// No description provided for @addRefill.
  ///
  /// In en, this message translates to:
  /// **'Add Refill'**
  String get addRefill;

  /// No description provided for @recordPurchase.
  ///
  /// In en, this message translates to:
  /// **'Record Purchase'**
  String get recordPurchase;

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistory;

  /// No description provided for @quantityPurchased.
  ///
  /// In en, this message translates to:
  /// **'Quantity Purchased'**
  String get quantityPurchased;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @totalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get totalSpent;

  /// No description provided for @averageCostPerUnit.
  ///
  /// In en, this message translates to:
  /// **'Average Cost per Unit'**
  String get averageCostPerUnit;

  /// No description provided for @daysUntilEmpty.
  ///
  /// In en, this message translates to:
  /// **'Days Until Empty'**
  String get daysUntilEmpty;

  /// No description provided for @pillsLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} {unit} left'**
  String pillsLeft(String count, String unit);

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @refillReminder.
  ///
  /// In en, this message translates to:
  /// **'Time to refill {medication}'**
  String refillReminder(String medication);

  /// No description provided for @markAsGiven.
  ///
  /// In en, this message translates to:
  /// **'Mark as Given'**
  String get markAsGiven;

  /// No description provided for @addStock.
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// No description provided for @noPurchases.
  ///
  /// In en, this message translates to:
  /// **'No purchases recorded'**
  String get noPurchases;

  /// No description provided for @purchaseAdded.
  ///
  /// In en, this message translates to:
  /// **'Purchase recorded'**
  String get purchaseAdded;

  /// No description provided for @stockUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stock updated'**
  String get stockUpdated;

  /// No description provided for @costPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Cost per Month'**
  String get costPerMonth;

  /// No description provided for @lastPurchase.
  ///
  /// In en, this message translates to:
  /// **'Last Purchase'**
  String get lastPurchase;

  /// No description provided for @inventoryTracking.
  ///
  /// In en, this message translates to:
  /// **'Inventory Tracking'**
  String get inventoryTracking;

  /// No description provided for @enableRefillReminders.
  ///
  /// In en, this message translates to:
  /// **'Enable Refill Reminders'**
  String get enableRefillReminders;

  /// No description provided for @refillReminderDays.
  ///
  /// In en, this message translates to:
  /// **'Remind me X days before empty'**
  String get refillReminderDays;

  /// No description provided for @pills.
  ///
  /// In en, this message translates to:
  /// **'pills'**
  String get pills;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @doses.
  ///
  /// In en, this message translates to:
  /// **'doses'**
  String get doses;

  /// No description provided for @tablets.
  ///
  /// In en, this message translates to:
  /// **'tablets'**
  String get tablets;

  /// No description provided for @lowStockAlertBody.
  ///
  /// In en, this message translates to:
  /// **'Only {count} {unit} left for {medication}'**
  String lowStockAlertBody(String count, String unit, String medication);

  /// No description provided for @refillSoon.
  ///
  /// In en, this message translates to:
  /// **'Refill Soon'**
  String get refillSoon;

  /// No description provided for @notTracked.
  ///
  /// In en, this message translates to:
  /// **'Not tracked'**
  String get notTracked;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @daysBeforeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Days before empty'**
  String get daysBeforeEmpty;

  /// No description provided for @inventoryOverview.
  ///
  /// In en, this message translates to:
  /// **'Inventory Overview'**
  String get inventoryOverview;

  /// No description provided for @totalCost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get totalCost;

  /// No description provided for @averageMonthlyCost.
  ///
  /// In en, this message translates to:
  /// **'Average Monthly Cost'**
  String get averageMonthlyCost;

  /// No description provided for @medicationsTracked.
  ///
  /// In en, this message translates to:
  /// **'Medications Tracked'**
  String get medicationsTracked;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @editPurchase.
  ///
  /// In en, this message translates to:
  /// **'Edit Purchase'**
  String get editPurchase;

  /// No description provided for @deletePurchase.
  ///
  /// In en, this message translates to:
  /// **'Delete Purchase'**
  String get deletePurchase;

  /// No description provided for @deletePurchaseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this purchase record?'**
  String get deletePurchaseConfirm;

  /// No description provided for @purchaseDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Purchase deleted successfully'**
  String get purchaseDeletedSuccessfully;

  /// No description provided for @failedToDeletePurchase.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete purchase'**
  String get failedToDeletePurchase;

  /// No description provided for @invalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get invalidQuantity;

  /// No description provided for @invalidCost.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid cost'**
  String get invalidCost;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @sufficient.
  ///
  /// In en, this message translates to:
  /// **'Sufficient'**
  String get sufficient;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @refillNow.
  ///
  /// In en, this message translates to:
  /// **'Refill Now'**
  String get refillNow;

  /// No description provided for @viewInventory.
  ///
  /// In en, this message translates to:
  /// **'View Inventory'**
  String get viewInventory;

  /// No description provided for @noMedicationsTracked.
  ///
  /// In en, this message translates to:
  /// **'No medications tracked'**
  String get noMedicationsTracked;

  /// No description provided for @noLowStockMedications.
  ///
  /// In en, this message translates to:
  /// **'No low stock medications'**
  String get noLowStockMedications;

  /// No description provided for @totalSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total Spent This Month'**
  String get totalSpentThisMonth;

  /// No description provided for @totalSpentAllTime.
  ///
  /// In en, this message translates to:
  /// **'Total Spent All Time'**
  String get totalSpentAllTime;

  /// No description provided for @allPurchases.
  ///
  /// In en, this message translates to:
  /// **'All purchases'**
  String get allPurchases;

  /// No description provided for @averageCostPerMedication.
  ///
  /// In en, this message translates to:
  /// **'Average Cost per Medication'**
  String get averageCostPerMedication;

  /// No description provided for @perMedication.
  ///
  /// In en, this message translates to:
  /// **'Per medication'**
  String get perMedication;

  /// No description provided for @topExpensiveMedications.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Most Expensive Medications'**
  String get topExpensiveMedications;

  /// No description provided for @stockNotTracked.
  ///
  /// In en, this message translates to:
  /// **'Stock not tracked'**
  String get stockNotTracked;

  /// No description provided for @refill.
  ///
  /// In en, this message translates to:
  /// **'Refill'**
  String get refill;

  /// No description provided for @notTrackedEnum.
  ///
  /// In en, this message translates to:
  /// **'Not tracked'**
  String get notTrackedEnum;

  /// No description provided for @veterinarians.
  ///
  /// In en, this message translates to:
  /// **'Veterinarians'**
  String get veterinarians;

  /// No description provided for @addVet.
  ///
  /// In en, this message translates to:
  /// **'Add Veterinarian'**
  String get addVet;

  /// No description provided for @editVet.
  ///
  /// In en, this message translates to:
  /// **'Edit Veterinarian'**
  String get editVet;

  /// No description provided for @vetDetails.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Details'**
  String get vetDetails;

  /// No description provided for @vetName.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian Name'**
  String get vetName;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic Name'**
  String get clinicName;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @setAsPreferred.
  ///
  /// In en, this message translates to:
  /// **'Set as Preferred Vet'**
  String get setAsPreferred;

  /// No description provided for @preferredVet.
  ///
  /// In en, this message translates to:
  /// **'Preferred Vet'**
  String get preferredVet;

  /// No description provided for @generalPractice.
  ///
  /// In en, this message translates to:
  /// **'General Practice'**
  String get generalPractice;

  /// No description provided for @emergencyMedicine.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get emergencyMedicine;

  /// No description provided for @cardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get cardiology;

  /// No description provided for @dermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get dermatology;

  /// No description provided for @surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get surgery;

  /// No description provided for @orthopedics.
  ///
  /// In en, this message translates to:
  /// **'Orthopedics'**
  String get orthopedics;

  /// No description provided for @oncology.
  ///
  /// In en, this message translates to:
  /// **'Oncology'**
  String get oncology;

  /// No description provided for @ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get ophthalmology;

  /// No description provided for @callVet.
  ///
  /// In en, this message translates to:
  /// **'Call Veterinarian'**
  String get callVet;

  /// No description provided for @emailVet.
  ///
  /// In en, this message translates to:
  /// **'Email Veterinarian'**
  String get emailVet;

  /// No description provided for @openWebsite.
  ///
  /// In en, this message translates to:
  /// **'Open Website'**
  String get openWebsite;

  /// No description provided for @lastVisit.
  ///
  /// In en, this message translates to:
  /// **'Last Visit'**
  String get lastVisit;

  /// No description provided for @totalAppointments.
  ///
  /// In en, this message translates to:
  /// **'Total Appointments'**
  String get totalAppointments;

  /// No description provided for @recentAppointments.
  ///
  /// In en, this message translates to:
  /// **'Recent Appointments'**
  String get recentAppointments;

  /// No description provided for @noVetsAdded.
  ///
  /// In en, this message translates to:
  /// **'No veterinarians added'**
  String get noVetsAdded;

  /// No description provided for @addFirstVet.
  ///
  /// In en, this message translates to:
  /// **'Add your pet\'s veterinarian to keep track of visits and contact information'**
  String get addFirstVet;

  /// No description provided for @deleteVet.
  ///
  /// In en, this message translates to:
  /// **'Delete Veterinarian'**
  String get deleteVet;

  /// No description provided for @deleteVetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this veterinarian? This will not affect existing appointments.'**
  String get deleteVetConfirm;

  /// No description provided for @vetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian deleted'**
  String get vetDeleted;

  /// No description provided for @vetAdded.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian added'**
  String get vetAdded;

  /// No description provided for @vetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian updated'**
  String get vetUpdated;

  /// No description provided for @selectVet.
  ///
  /// In en, this message translates to:
  /// **'Select Veterinarian'**
  String get selectVet;

  /// No description provided for @addNewVet.
  ///
  /// In en, this message translates to:
  /// **'Add New Veterinarian'**
  String get addNewVet;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhone;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidWebsite.
  ///
  /// In en, this message translates to:
  /// **'Invalid website URL'**
  String get invalidWebsite;

  /// No description provided for @vetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Veterinarian name is required'**
  String get vetNameRequired;

  /// No description provided for @clinicNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Clinic name is required'**
  String get clinicNameRequired;

  /// No description provided for @searchVets.
  ///
  /// In en, this message translates to:
  /// **'Search veterinarians...'**
  String get searchVets;

  /// No description provided for @noVetsFound.
  ///
  /// In en, this message translates to:
  /// **'No veterinarians found'**
  String get noVetsFound;

  /// No description provided for @noVetsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No veterinarians match your search'**
  String get noVetsMatchSearch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
