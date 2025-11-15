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

  /// No description provided for @foodTypeDryFood.
  ///
  /// In en, this message translates to:
  /// **'Dry Food'**
  String get foodTypeDryFood;

  /// No description provided for @foodTypeWetFood.
  ///
  /// In en, this message translates to:
  /// **'Wet Food'**
  String get foodTypeWetFood;

  /// No description provided for @foodTypeTreats.
  ///
  /// In en, this message translates to:
  /// **'Treats'**
  String get foodTypeTreats;

  /// No description provided for @foodTypeRawFood.
  ///
  /// In en, this message translates to:
  /// **'Raw Food'**
  String get foodTypeRawFood;

  /// No description provided for @foodTypeChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get foodTypeChicken;

  /// No description provided for @foodTypeFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get foodTypeFish;

  /// No description provided for @foodTypeTurkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get foodTypeTurkey;

  /// No description provided for @foodTypeBeef.
  ///
  /// In en, this message translates to:
  /// **'Beef'**
  String get foodTypeBeef;

  /// No description provided for @foodTypeVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get foodTypeVegetables;

  /// No description provided for @foodTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get foodTypeOther;

  /// No description provided for @foodTypeCustomPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter custom food type'**
  String get foodTypeCustomPlaceholder;

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

  /// Medication frequency: once per day
  ///
  /// In en, this message translates to:
  /// **'Once Daily'**
  String get frequencyOnceDaily;

  /// Medication frequency: twice per day
  ///
  /// In en, this message translates to:
  /// **'Twice Daily'**
  String get frequencyTwiceDaily;

  /// Medication frequency: three times per day
  ///
  /// In en, this message translates to:
  /// **'Three Times Daily'**
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

  /// Medication frequency: weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get frequencyWeekly;

  /// Medication frequency: as needed
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
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

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

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

  /// No description provided for @appointmentReasonCheckup.
  ///
  /// In en, this message translates to:
  /// **'Checkup'**
  String get appointmentReasonCheckup;

  /// No description provided for @appointmentReasonVaccination.
  ///
  /// In en, this message translates to:
  /// **'Vaccination'**
  String get appointmentReasonVaccination;

  /// No description provided for @appointmentReasonSurgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get appointmentReasonSurgery;

  /// No description provided for @appointmentReasonEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get appointmentReasonEmergency;

  /// No description provided for @appointmentReasonFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get appointmentReasonFollowUp;

  /// No description provided for @appointmentReasonDentalCleaning.
  ///
  /// In en, this message translates to:
  /// **'Dental Cleaning'**
  String get appointmentReasonDentalCleaning;

  /// No description provided for @appointmentReasonGrooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get appointmentReasonGrooming;

  /// No description provided for @appointmentReasonBloodTest.
  ///
  /// In en, this message translates to:
  /// **'Blood Test'**
  String get appointmentReasonBloodTest;

  /// No description provided for @appointmentReasonXRay.
  ///
  /// In en, this message translates to:
  /// **'X-Ray'**
  String get appointmentReasonXRay;

  /// No description provided for @appointmentReasonSpayingNeutering.
  ///
  /// In en, this message translates to:
  /// **'Spaying/Neutering'**
  String get appointmentReasonSpayingNeutering;

  /// No description provided for @appointmentReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get appointmentReasonOther;

  /// No description provided for @appointmentReasonCustomPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter custom reason'**
  String get appointmentReasonCustomPlaceholder;

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
  /// **'Total'**
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

  /// No description provided for @totalWalks.
  ///
  /// In en, this message translates to:
  /// **'Total Walks'**
  String get totalWalks;

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

  /// Delete report dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// Delete report confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the \"{reportName}\" report from {date}?'**
  String deleteReportConfirmation(String reportName, String date);

  /// Success message after deleting report
  ///
  /// In en, this message translates to:
  /// **'Report deleted successfully'**
  String get reportDeletedSuccessfully;

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
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
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

  /// Title for pet profile setup screen
  ///
  /// In en, this message translates to:
  /// **'Setup Pet Profile'**
  String get setupPetProfile;

  /// Title for pet profile edit screen
  ///
  /// In en, this message translates to:
  /// **'Edit Pet Profile'**
  String get editPetProfile;

  /// Label for pet name field
  ///
  /// In en, this message translates to:
  /// **'Pet Name'**
  String get petName;

  /// Validation message for pet name
  ///
  /// In en, this message translates to:
  /// **'Please enter your pet\'s name'**
  String get pleaseEnterPetName;

  /// Label for species field
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get species;

  /// Hint text for species field
  ///
  /// In en, this message translates to:
  /// **'e.g., Dog, Cat, Bird'**
  String get speciesHint;

  /// Validation message for species
  ///
  /// In en, this message translates to:
  /// **'Please enter your pet\'s species'**
  String get pleaseEnterSpecies;

  /// Label for breed field
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// Label for optional breed field
  ///
  /// In en, this message translates to:
  /// **'Breed (optional)'**
  String get breedOptional;

  /// Hint text for breed field
  ///
  /// In en, this message translates to:
  /// **'e.g., Golden Retriever, Persian'**
  String get breedHint;

  /// No description provided for @breedLabradorRetriever.
  ///
  /// In en, this message translates to:
  /// **'Labrador Retriever'**
  String get breedLabradorRetriever;

  /// No description provided for @breedGoldenRetriever.
  ///
  /// In en, this message translates to:
  /// **'Golden Retriever'**
  String get breedGoldenRetriever;

  /// No description provided for @breedGermanShepherd.
  ///
  /// In en, this message translates to:
  /// **'German Shepherd'**
  String get breedGermanShepherd;

  /// No description provided for @breedBulldog.
  ///
  /// In en, this message translates to:
  /// **'Bulldog'**
  String get breedBulldog;

  /// No description provided for @breedBeagle.
  ///
  /// In en, this message translates to:
  /// **'Beagle'**
  String get breedBeagle;

  /// No description provided for @breedPoodle.
  ///
  /// In en, this message translates to:
  /// **'Poodle'**
  String get breedPoodle;

  /// No description provided for @breedRottweiler.
  ///
  /// In en, this message translates to:
  /// **'Rottweiler'**
  String get breedRottweiler;

  /// No description provided for @breedYorkshireTerrier.
  ///
  /// In en, this message translates to:
  /// **'Yorkshire Terrier'**
  String get breedYorkshireTerrier;

  /// No description provided for @breedBoxer.
  ///
  /// In en, this message translates to:
  /// **'Boxer'**
  String get breedBoxer;

  /// No description provided for @breedDachshund.
  ///
  /// In en, this message translates to:
  /// **'Dachshund'**
  String get breedDachshund;

  /// No description provided for @breedSiberianHusky.
  ///
  /// In en, this message translates to:
  /// **'Siberian Husky'**
  String get breedSiberianHusky;

  /// No description provided for @breedChihuahua.
  ///
  /// In en, this message translates to:
  /// **'Chihuahua'**
  String get breedChihuahua;

  /// No description provided for @breedShihTzu.
  ///
  /// In en, this message translates to:
  /// **'Shih Tzu'**
  String get breedShihTzu;

  /// No description provided for @breedDobermanPinscher.
  ///
  /// In en, this message translates to:
  /// **'Doberman Pinscher'**
  String get breedDobermanPinscher;

  /// No description provided for @breedGreatDane.
  ///
  /// In en, this message translates to:
  /// **'Great Dane'**
  String get breedGreatDane;

  /// No description provided for @breedPomeranian.
  ///
  /// In en, this message translates to:
  /// **'Pomeranian'**
  String get breedPomeranian;

  /// No description provided for @breedBorderCollie.
  ///
  /// In en, this message translates to:
  /// **'Border Collie'**
  String get breedBorderCollie;

  /// No description provided for @breedCockerSpaniel.
  ///
  /// In en, this message translates to:
  /// **'Cocker Spaniel'**
  String get breedCockerSpaniel;

  /// No description provided for @breedMaltese.
  ///
  /// In en, this message translates to:
  /// **'Maltese'**
  String get breedMaltese;

  /// No description provided for @breedMixedBreed.
  ///
  /// In en, this message translates to:
  /// **'Mixed Breed'**
  String get breedMixedBreed;

  /// No description provided for @breedPersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get breedPersian;

  /// No description provided for @breedMaineCoon.
  ///
  /// In en, this message translates to:
  /// **'Maine Coon'**
  String get breedMaineCoon;

  /// No description provided for @breedSiamese.
  ///
  /// In en, this message translates to:
  /// **'Siamese'**
  String get breedSiamese;

  /// No description provided for @breedRagdoll.
  ///
  /// In en, this message translates to:
  /// **'Ragdoll'**
  String get breedRagdoll;

  /// No description provided for @breedBritishShorthair.
  ///
  /// In en, this message translates to:
  /// **'British Shorthair'**
  String get breedBritishShorthair;

  /// No description provided for @breedSphynx.
  ///
  /// In en, this message translates to:
  /// **'Sphynx'**
  String get breedSphynx;

  /// No description provided for @breedBengal.
  ///
  /// In en, this message translates to:
  /// **'Bengal'**
  String get breedBengal;

  /// No description provided for @breedScottishFold.
  ///
  /// In en, this message translates to:
  /// **'Scottish Fold'**
  String get breedScottishFold;

  /// No description provided for @breedRussianBlue.
  ///
  /// In en, this message translates to:
  /// **'Russian Blue'**
  String get breedRussianBlue;

  /// No description provided for @breedAbyssinian.
  ///
  /// In en, this message translates to:
  /// **'Abyssinian'**
  String get breedAbyssinian;

  /// No description provided for @breedAmericanShorthair.
  ///
  /// In en, this message translates to:
  /// **'American Shorthair'**
  String get breedAmericanShorthair;

  /// No description provided for @breedBirman.
  ///
  /// In en, this message translates to:
  /// **'Birman'**
  String get breedBirman;

  /// No description provided for @breedNorwegianForest.
  ///
  /// In en, this message translates to:
  /// **'Norwegian Forest'**
  String get breedNorwegianForest;

  /// No description provided for @breedDomesticShorthair.
  ///
  /// In en, this message translates to:
  /// **'Domestic Shorthair'**
  String get breedDomesticShorthair;

  /// No description provided for @breedParakeet.
  ///
  /// In en, this message translates to:
  /// **'Parakeet'**
  String get breedParakeet;

  /// No description provided for @breedCockatiel.
  ///
  /// In en, this message translates to:
  /// **'Cockatiel'**
  String get breedCockatiel;

  /// No description provided for @breedCanary.
  ///
  /// In en, this message translates to:
  /// **'Canary'**
  String get breedCanary;

  /// No description provided for @breedParrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get breedParrot;

  /// No description provided for @breedLovebird.
  ///
  /// In en, this message translates to:
  /// **'Lovebird'**
  String get breedLovebird;

  /// No description provided for @breedFinch.
  ///
  /// In en, this message translates to:
  /// **'Finch'**
  String get breedFinch;

  /// No description provided for @breedCockatoo.
  ///
  /// In en, this message translates to:
  /// **'Cockatoo'**
  String get breedCockatoo;

  /// No description provided for @breedMacaw.
  ///
  /// In en, this message translates to:
  /// **'Macaw'**
  String get breedMacaw;

  /// No description provided for @breedConure.
  ///
  /// In en, this message translates to:
  /// **'Conure'**
  String get breedConure;

  /// No description provided for @breedAfricanGrey.
  ///
  /// In en, this message translates to:
  /// **'African Grey'**
  String get breedAfricanGrey;

  /// No description provided for @breedHollandLop.
  ///
  /// In en, this message translates to:
  /// **'Holland Lop'**
  String get breedHollandLop;

  /// No description provided for @breedNetherlandDwarf.
  ///
  /// In en, this message translates to:
  /// **'Netherland Dwarf'**
  String get breedNetherlandDwarf;

  /// No description provided for @breedMiniRex.
  ///
  /// In en, this message translates to:
  /// **'Mini Rex'**
  String get breedMiniRex;

  /// No description provided for @breedLionhead.
  ///
  /// In en, this message translates to:
  /// **'Lionhead'**
  String get breedLionhead;

  /// No description provided for @breedFlemishGiant.
  ///
  /// In en, this message translates to:
  /// **'Flemish Giant'**
  String get breedFlemishGiant;

  /// No description provided for @breedEnglishAngora.
  ///
  /// In en, this message translates to:
  /// **'English Angora'**
  String get breedEnglishAngora;

  /// No description provided for @breedDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get breedDutch;

  /// No description provided for @breedOther.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get breedOther;

  /// No description provided for @customBreed.
  ///
  /// In en, this message translates to:
  /// **'Custom Breed'**
  String get customBreed;

  /// No description provided for @enterCustomBreed.
  ///
  /// In en, this message translates to:
  /// **'Enter your pet\'s breed'**
  String get enterCustomBreed;

  /// Label for optional birthday field
  ///
  /// In en, this message translates to:
  /// **'Birthday (optional)'**
  String get birthdayOptional;

  /// Placeholder text for birthday field
  ///
  /// In en, this message translates to:
  /// **'Tap to select birthday'**
  String get tapToSelectBirthday;

  /// Date picker title for birthday
  ///
  /// In en, this message translates to:
  /// **'Select pet birthday'**
  String get selectPetBirthday;

  /// Label for optional notes field
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Hint text for pet notes field
  ///
  /// In en, this message translates to:
  /// **'Any special notes about your pet'**
  String get petNotesHint;

  /// No description provided for @speciesDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get speciesDog;

  /// No description provided for @speciesCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get speciesCat;

  /// No description provided for @speciesBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get speciesBird;

  /// No description provided for @speciesRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get speciesRabbit;

  /// No description provided for @speciesHamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get speciesHamster;

  /// No description provided for @speciesGuineaPig.
  ///
  /// In en, this message translates to:
  /// **'Guinea Pig'**
  String get speciesGuineaPig;

  /// No description provided for @speciesFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get speciesFish;

  /// No description provided for @speciesTurtle.
  ///
  /// In en, this message translates to:
  /// **'Turtle'**
  String get speciesTurtle;

  /// No description provided for @speciesLizard.
  ///
  /// In en, this message translates to:
  /// **'Lizard'**
  String get speciesLizard;

  /// No description provided for @speciesSnake.
  ///
  /// In en, this message translates to:
  /// **'Snake'**
  String get speciesSnake;

  /// No description provided for @speciesFerret.
  ///
  /// In en, this message translates to:
  /// **'Ferret'**
  String get speciesFerret;

  /// No description provided for @speciesChinchilla.
  ///
  /// In en, this message translates to:
  /// **'Chinchilla'**
  String get speciesChinchilla;

  /// No description provided for @speciesRat.
  ///
  /// In en, this message translates to:
  /// **'Rat'**
  String get speciesRat;

  /// No description provided for @speciesMouse.
  ///
  /// In en, this message translates to:
  /// **'Mouse'**
  String get speciesMouse;

  /// No description provided for @speciesGerbil.
  ///
  /// In en, this message translates to:
  /// **'Gerbil'**
  String get speciesGerbil;

  /// No description provided for @speciesHedgehog.
  ///
  /// In en, this message translates to:
  /// **'Hedgehog'**
  String get speciesHedgehog;

  /// No description provided for @speciesParrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get speciesParrot;

  /// No description provided for @speciesHorse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get speciesHorse;

  /// No description provided for @speciesChicken.
  ///
  /// In en, this message translates to:
  /// **'Chicken'**
  String get speciesChicken;

  /// No description provided for @speciesOther.
  ///
  /// In en, this message translates to:
  /// **'Other (Custom)'**
  String get speciesOther;

  /// No description provided for @customSpecies.
  ///
  /// In en, this message translates to:
  /// **'Custom Species'**
  String get customSpecies;

  /// No description provided for @enterCustomSpecies.
  ///
  /// In en, this message translates to:
  /// **'Enter your pet\'s species'**
  String get enterCustomSpecies;

  /// Button text to change pet photo
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Button text to save pet profile
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// Button text to update pet profile
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

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

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

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

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'All data deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data. Please try again.'**
  String get accountDeletionFailed;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get featureComingSoon;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Profile Edit'**
  String get profileEdit;

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

  /// No description provided for @oneDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Day Before'**
  String get oneDayBefore;

  /// No description provided for @oneHourBefore.
  ///
  /// In en, this message translates to:
  /// **'1 Hour Before'**
  String get oneHourBefore;

  /// No description provided for @thirtyMinutesBefore.
  ///
  /// In en, this message translates to:
  /// **'30 Minutes Before'**
  String get thirtyMinutesBefore;

  /// No description provided for @reminderSet.
  ///
  /// In en, this message translates to:
  /// **'Reminder set successfully'**
  String get reminderSet;

  /// No description provided for @remindDaily.
  ///
  /// In en, this message translates to:
  /// **'Remind Daily'**
  String get remindDaily;

  /// No description provided for @remindAllDoses.
  ///
  /// In en, this message translates to:
  /// **'Remind All Doses'**
  String get remindAllDoses;

  /// No description provided for @remindOnce.
  ///
  /// In en, this message translates to:
  /// **'Remind Once'**
  String get remindOnce;

  /// No description provided for @firstDose.
  ///
  /// In en, this message translates to:
  /// **'First dose'**
  String get firstDose;

  /// No description provided for @customTime.
  ///
  /// In en, this message translates to:
  /// **'Custom time'**
  String get customTime;

  /// No description provided for @timesDaily.
  ///
  /// In en, this message translates to:
  /// **'times daily'**
  String get timesDaily;

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

  /// Notification title for medication reminders
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medicationReminder;

  /// Notification title for appointment reminders
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

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @setProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Set as Profile Photo'**
  String get setProfilePhoto;

  /// No description provided for @setProfilePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Set this photo as {petName}\'s profile photo?'**
  String setProfilePhotoConfirm(String petName);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated!'**
  String get profilePhotoUpdated;

  /// No description provided for @photoNotFound.
  ///
  /// In en, this message translates to:
  /// **'Photo not found'**
  String get photoNotFound;

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

  /// Unit name for pills
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

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @vetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Vet not found'**
  String get vetNotFound;

  /// No description provided for @alreadyPreferred.
  ///
  /// In en, this message translates to:
  /// **'This is already your preferred vet'**
  String get alreadyPreferred;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorOccurred;

  /// No description provided for @petManagement.
  ///
  /// In en, this message translates to:
  /// **'Pet Management'**
  String get petManagement;

  /// No description provided for @viewHealthScoresAndMetrics.
  ///
  /// In en, this message translates to:
  /// **'View health scores and activity metrics'**
  String get viewHealthScoresAndMetrics;

  /// No description provided for @manageVeterinariansAndClinics.
  ///
  /// In en, this message translates to:
  /// **'Manage veterinarians and clinics'**
  String get manageVeterinariansAndClinics;

  /// No description provided for @viewAndManagePetPhotos.
  ///
  /// In en, this message translates to:
  /// **'View and manage pet photos'**
  String get viewAndManagePetPhotos;

  /// No description provided for @trackMedicationStockLevels.
  ///
  /// In en, this message translates to:
  /// **'Track medication stock levels'**
  String get trackMedicationStockLevels;

  /// No description provided for @reportsAndAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get reportsAndAnalytics;

  /// No description provided for @healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get healthScore;

  /// No description provided for @medicationAdherence.
  ///
  /// In en, this message translates to:
  /// **'Medication Adherence'**
  String get medicationAdherence;

  /// No description provided for @activityLevels.
  ///
  /// In en, this message translates to:
  /// **'Activity Levels'**
  String get activityLevels;

  /// No description provided for @expenseTracking.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracking'**
  String get expenseTracking;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @gaining.
  ///
  /// In en, this message translates to:
  /// **'Gaining'**
  String get gaining;

  /// No description provided for @losing.
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get losing;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @averageWeeklyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Average Weekly Expenses'**
  String get averageWeeklyExpenses;

  /// No description provided for @expenseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Expense Breakdown'**
  String get expenseBreakdown;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get reportPeriod;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 Days'**
  String get last90Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get customRange;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @activityMetrics.
  ///
  /// In en, this message translates to:
  /// **'Activity Metrics'**
  String get activityMetrics;

  /// No description provided for @dailyActivityAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Activity Average'**
  String get dailyActivityAverage;

  /// No description provided for @feedingsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Feedings/day'**
  String get feedingsPerDay;

  /// No description provided for @walksPerDay.
  ///
  /// In en, this message translates to:
  /// **'Walks/day'**
  String get walksPerDay;

  /// No description provided for @expenseMetrics.
  ///
  /// In en, this message translates to:
  /// **'Expense Metrics'**
  String get expenseMetrics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get activityHigh;

  /// No description provided for @activityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get activityMedium;

  /// No description provided for @activityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get activityLow;

  /// No description provided for @exportToPDF.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get exportToPDF;

  /// No description provided for @shareReport.
  ///
  /// In en, this message translates to:
  /// **'Share Report'**
  String get shareReport;

  /// No description provided for @exportOptions.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  /// No description provided for @fullReport.
  ///
  /// In en, this message translates to:
  /// **'Full Report'**
  String get fullReport;

  /// No description provided for @fullReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete health report with all metrics'**
  String get fullReportDescription;

  /// No description provided for @vetSummary.
  ///
  /// In en, this message translates to:
  /// **'Vet Summary'**
  String get vetSummary;

  /// No description provided for @vetSummaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days summary for vet visit'**
  String get vetSummaryDescription;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'Share Text Summary'**
  String get shareText;

  /// No description provided for @shareTextDescription.
  ///
  /// In en, this message translates to:
  /// **'Share as text message'**
  String get shareTextDescription;

  /// No description provided for @reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get reportGenerated;

  /// No description provided for @reportExported.
  ///
  /// In en, this message translates to:
  /// **'Report saved to device'**
  String get reportExported;

  /// No description provided for @generatingReport.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// No description provided for @exportingReport.
  ///
  /// In en, this message translates to:
  /// **'Exporting report...'**
  String get exportingReport;

  /// No description provided for @sharingReport.
  ///
  /// In en, this message translates to:
  /// **'Sharing report...'**
  String get sharingReport;

  /// No description provided for @reportSaved.
  ///
  /// In en, this message translates to:
  /// **'Report saved to: {path}'**
  String reportSaved(String path);

  /// No description provided for @failedToGeneratePDF.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF: {error}'**
  String failedToGeneratePDF(String error);

  /// No description provided for @failedToExportReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export report'**
  String get failedToExportReport;

  /// No description provided for @failedToShareReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to share report'**
  String get failedToShareReport;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for this period'**
  String get noDataAvailable;

  /// No description provided for @insufficientData.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data for analysis'**
  String get insufficientData;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @averageMonthly.
  ///
  /// In en, this message translates to:
  /// **'Average Monthly'**
  String get averageMonthly;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @dismissRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissRecommendation;

  /// No description provided for @reportingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Reporting Period'**
  String get reportingPeriod;

  /// No description provided for @dataInsights.
  ///
  /// In en, this message translates to:
  /// **'Data Insights'**
  String get dataInsights;

  /// No description provided for @noRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get noRecommendations;

  /// No description provided for @healthScoreExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthScoreExcellent;

  /// No description provided for @healthScoreGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthScoreGood;

  /// No description provided for @healthScoreFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthScoreFair;

  /// No description provided for @healthScoreLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get healthScoreLow;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @expenseTrend.
  ///
  /// In en, this message translates to:
  /// **'Expense Trend'**
  String get expenseTrend;

  /// No description provided for @trendIncreasing.
  ///
  /// In en, this message translates to:
  /// **'Increasing'**
  String get trendIncreasing;

  /// No description provided for @trendDecreasing.
  ///
  /// In en, this message translates to:
  /// **'Decreasing'**
  String get trendDecreasing;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get trendStable;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @highest.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highest;

  /// No description provided for @excellentRange.
  ///
  /// In en, this message translates to:
  /// **'Excellent (80+)'**
  String get excellentRange;

  /// No description provided for @goodRange.
  ///
  /// In en, this message translates to:
  /// **'Good (60-79)'**
  String get goodRange;

  /// No description provided for @fairRange.
  ///
  /// In en, this message translates to:
  /// **'Fair (40-59)'**
  String get fairRange;

  /// No description provided for @lowRange.
  ///
  /// In en, this message translates to:
  /// **'Low (<40)'**
  String get lowRange;

  /// No description provided for @recSetMedicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Set more medication reminders to improve adherence'**
  String get recSetMedicationReminders;

  /// No description provided for @recConsiderVetWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Consider vet consultation about weight gain'**
  String get recConsiderVetWeightGain;

  /// No description provided for @recConsiderVetWeightLoss.
  ///
  /// In en, this message translates to:
  /// **'Consider vet consultation about weight loss'**
  String get recConsiderVetWeightLoss;

  /// No description provided for @recIncreaseDailyWalks.
  ///
  /// In en, this message translates to:
  /// **'Increase daily walks for better health'**
  String get recIncreaseDailyWalks;

  /// No description provided for @recReviewMedicationCosts.
  ///
  /// In en, this message translates to:
  /// **'Review medication costs with your vet'**
  String get recReviewMedicationCosts;

  /// No description provided for @recScheduleVetCheckup.
  ///
  /// In en, this message translates to:
  /// **'Health score is low - schedule a vet checkup'**
  String get recScheduleVetCheckup;

  /// No description provided for @healthScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Based on weight stability, medication adherence, and activity levels'**
  String get healthScoreDescription;

  /// No description provided for @pdfPetHealthReport.
  ///
  /// In en, this message translates to:
  /// **'Pet Health Report'**
  String get pdfPetHealthReport;

  /// No description provided for @pdfPetInformation.
  ///
  /// In en, this message translates to:
  /// **'Pet Information'**
  String get pdfPetInformation;

  /// No description provided for @pdfName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pdfName;

  /// No description provided for @pdfSpecies.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get pdfSpecies;

  /// No description provided for @pdfBreed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get pdfBreed;

  /// No description provided for @pdfAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get pdfAge;

  /// No description provided for @pdfYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get pdfYears;

  /// No description provided for @pdfCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get pdfCat;

  /// No description provided for @pdfDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get pdfDog;

  /// No description provided for @pdfUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pdfUnknown;

  /// No description provided for @pdfReportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get pdfReportPeriod;

  /// No description provided for @pdfFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get pdfFrom;

  /// No description provided for @pdfTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get pdfTo;

  /// No description provided for @pdfHealthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get pdfHealthMetrics;

  /// No description provided for @pdfOverallHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Health Score'**
  String get pdfOverallHealthScore;

  /// No description provided for @pdfMedicationAdherence.
  ///
  /// In en, this message translates to:
  /// **'Medication Adherence'**
  String get pdfMedicationAdherence;

  /// No description provided for @pdfWeightTrend.
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get pdfWeightTrend;

  /// No description provided for @pdfStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get pdfStable;

  /// No description provided for @pdfGaining.
  ///
  /// In en, this message translates to:
  /// **'Gaining'**
  String get pdfGaining;

  /// No description provided for @pdfLosing.
  ///
  /// In en, this message translates to:
  /// **'Losing'**
  String get pdfLosing;

  /// No description provided for @pdfActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'Activity Summary'**
  String get pdfActivitySummary;

  /// No description provided for @pdfTotalFeedings.
  ///
  /// In en, this message translates to:
  /// **'Total Feedings'**
  String get pdfTotalFeedings;

  /// No description provided for @pdfTotalWalks.
  ///
  /// In en, this message translates to:
  /// **'Total Walks'**
  String get pdfTotalWalks;

  /// No description provided for @pdfAvgFeedingsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg Feedings/Day'**
  String get pdfAvgFeedingsPerDay;

  /// No description provided for @pdfAvgWalksPerDay.
  ///
  /// In en, this message translates to:
  /// **'Avg Walks/Day'**
  String get pdfAvgWalksPerDay;

  /// No description provided for @pdfExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get pdfExpenses;

  /// No description provided for @pdfTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get pdfTotalExpenses;

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on'**
  String get pdfGeneratedOn;

  /// No description provided for @pdfFooter.
  ///
  /// In en, this message translates to:
  /// **'FurFriend Diary - Pet Health Management'**
  String get pdfFooter;

  /// No description provided for @pdfVeterinarySummary.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Summary'**
  String get pdfVeterinarySummary;

  /// No description provided for @pdfLast30DaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days Summary'**
  String get pdfLast30DaysSummary;

  /// No description provided for @pdfHealthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get pdfHealthStatus;

  /// No description provided for @pdfHealthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get pdfHealthScore;

  /// No description provided for @pdfMedicationCompliance.
  ///
  /// In en, this message translates to:
  /// **'Medication Compliance'**
  String get pdfMedicationCompliance;

  /// No description provided for @pdfActivityOverview.
  ///
  /// In en, this message translates to:
  /// **'Activity Overview'**
  String get pdfActivityOverview;

  /// No description provided for @pdfDailyFeedingsAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily Feedings (Avg)'**
  String get pdfDailyFeedingsAvg;

  /// No description provided for @pdfDailyWalksAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily Walks (Avg)'**
  String get pdfDailyWalksAvg;

  /// No description provided for @pdfNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get pdfNotes;

  /// No description provided for @pdfNotesText.
  ///
  /// In en, this message translates to:
  /// **'Please review the attached health data and discuss any concerns during the appointment.'**
  String get pdfNotesText;

  /// Email subject when sharing health report
  ///
  /// In en, this message translates to:
  /// **'Pet Health Report'**
  String get emailSubject;

  /// Email body text when sharing health report
  ///
  /// In en, this message translates to:
  /// **'Here is the health report for my pet.'**
  String get emailBody;

  /// Email subject when sharing vet summary
  ///
  /// In en, this message translates to:
  /// **'Veterinary Summary'**
  String get vetSummaryEmailSubject;

  /// Email body text when sharing vet summary
  ///
  /// In en, this message translates to:
  /// **'Here is the veterinary summary for my pet.'**
  String get vetSummaryEmailBody;

  /// Email subject when sharing text summary
  ///
  /// In en, this message translates to:
  /// **'Pet Health Summary'**
  String get textSummaryEmailSubject;

  /// Navigation label for Feedings tab
  ///
  /// In en, this message translates to:
  /// **'Feedings'**
  String get navFeedings;

  /// Navigation label for Walks tab
  ///
  /// In en, this message translates to:
  /// **'Walks'**
  String get navWalks;

  /// Navigation label for Medications tab
  ///
  /// In en, this message translates to:
  /// **'Meds'**
  String get navMeds;

  /// Navigation label for Appointments tab
  ///
  /// In en, this message translates to:
  /// **'Appts'**
  String get navAppts;

  /// Navigation label for Reports tab
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// Navigation label for Settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Notification body for medication reminders
  ///
  /// In en, this message translates to:
  /// **'{medication} - {frequency}'**
  String medicationReminderBody(String medication, String frequency);

  /// Critical low stock alert title
  ///
  /// In en, this message translates to:
  /// **'Critical: Low Stock Alert'**
  String get criticalLowStockAlert;

  /// Low stock alert body
  ///
  /// In en, this message translates to:
  /// **'Only {count} {unit} remaining. Time to refill!'**
  String lowStockBody(int count, String unit);

  /// Appointment notification body
  ///
  /// In en, this message translates to:
  /// **'{title} at {location}'**
  String appointmentAt(String title, String location);
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
