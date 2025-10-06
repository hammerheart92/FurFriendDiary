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
  /// **'Dosage *'**
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
  /// **'Add any additional notes, instructions, or reminders...'**
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
