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
  String get dosage => 'Dosage *';

  @override
  String get dosageHint => 'e.g., 5mg, 1 tablet, 2ml';

  @override
  String get pleaseEnterDosage => 'Please enter dosage';

  @override
  String get frequency => 'Frequency *';

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
      'Add any additional notes, instructions, or reminders...';

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
}
