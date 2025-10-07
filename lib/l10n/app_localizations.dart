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
  /// **'Frequency *'**
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
