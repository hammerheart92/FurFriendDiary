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
  String get noPetSelected => 'No Pet Selected';

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
  String get noProtocolSelected => 'No vaccination protocol selected';

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
  String get home => 'Home';

  @override
  String petHome(String petName) {
    return '$petName - Home';
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
  String get foodTypeDryFood => 'Dry Food';

  @override
  String get foodTypeWetFood => 'Wet Food';

  @override
  String get foodTypeTreats => 'Treats';

  @override
  String get foodTypeRawFood => 'Raw Food';

  @override
  String get foodTypeChicken => 'Chicken';

  @override
  String get foodTypeFish => 'Fish';

  @override
  String get foodTypeTurkey => 'Turkey';

  @override
  String get foodTypeBeef => 'Beef';

  @override
  String get foodTypeVegetables => 'Vegetables';

  @override
  String get foodTypeOther => 'Other (Custom)';

  @override
  String get foodTypeCustomPlaceholder => 'Enter custom food type';

  @override
  String get clear => 'Clear';

  @override
  String get comingSoon => 'Coming soon';

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
  String get frequencyOnceDaily => 'Once Daily';

  @override
  String get frequencyTwiceDaily => 'Twice Daily';

  @override
  String get frequencyThreeTimesDaily => 'Three Times Daily';

  @override
  String get frequencyFourTimesDaily => 'Four times daily';

  @override
  String get frequencyEveryOtherDay => 'Every other day';

  @override
  String get frequencyWeekly => 'Weekly';

  @override
  String get frequencyAsNeeded => 'As Needed';

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
  String get enterManually => 'Enter manually';

  @override
  String get reason => 'Reason';

  @override
  String get reasonHint => 'e.g., Checkup, Vaccination, Surgery';

  @override
  String get pleaseEnterReason => 'Please enter reason for appointment';

  @override
  String get appointmentReasonCheckup => 'Checkup';

  @override
  String get appointmentReasonVaccination => 'Vaccination';

  @override
  String get appointmentReasonSurgery => 'Surgery';

  @override
  String get appointmentReasonEmergency => 'Emergency';

  @override
  String get appointmentReasonFollowUp => 'Follow-up';

  @override
  String get appointmentReasonDentalCleaning => 'Dental Cleaning';

  @override
  String get appointmentReasonGrooming => 'Grooming';

  @override
  String get appointmentReasonBloodTest => 'Blood Test';

  @override
  String get appointmentReasonXRay => 'X-Ray';

  @override
  String get appointmentReasonSpayingNeutering => 'Spaying/Neutering';

  @override
  String get appointmentReasonOther => 'Other (Custom)';

  @override
  String get appointmentReasonCustomPlaceholder => 'Enter custom reason';

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
  String overdueByDays(int days) {
    return 'Overdue by $days days';
  }

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String get startsTomorrow => 'Starts Tomorrow';

  @override
  String startsInDays(int days) {
    return 'Starts in $days days';
  }

  @override
  String get treatmentCompleted => 'Completed';

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
  String get upcomingCare => 'Upcoming Care';

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
  String get total => 'Total';

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
  String get totalWalks => 'Total Walks';

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
  String get deleteReport => 'Delete Report';

  @override
  String deleteReportConfirmation(String reportName, String date) {
    return 'Are you sure you want to delete the \"$reportName\" report from $date?';
  }

  @override
  String get reportDeletedSuccessfully => 'Report deleted successfully';

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
  String get last7Days => 'Last 7 Days';

  @override
  String get last30Days => 'Last 30 Days';

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
  String get setupPetProfile => 'Setup Pet Profile';

  @override
  String get editPetProfile => 'Edit Pet Profile';

  @override
  String get petName => 'Pet Name';

  @override
  String get pleaseEnterPetName => 'Please enter your pet\'s name';

  @override
  String get species => 'Species';

  @override
  String get speciesHint => 'e.g., Dog, Cat, Bird';

  @override
  String get pleaseEnterSpecies => 'Please enter your pet\'s species';

  @override
  String get breed => 'Breed';

  @override
  String get breedOptional => 'Breed (optional)';

  @override
  String get breedHint => 'e.g., Golden Retriever, Persian';

  @override
  String get breedLabradorRetriever => 'Labrador Retriever';

  @override
  String get breedGoldenRetriever => 'Golden Retriever';

  @override
  String get breedGermanShepherd => 'German Shepherd';

  @override
  String get breedBulldog => 'Bulldog';

  @override
  String get breedBeagle => 'Beagle';

  @override
  String get breedPoodle => 'Poodle';

  @override
  String get breedRottweiler => 'Rottweiler';

  @override
  String get breedYorkshireTerrier => 'Yorkshire Terrier';

  @override
  String get breedBoxer => 'Boxer';

  @override
  String get breedDachshund => 'Dachshund';

  @override
  String get breedSiberianHusky => 'Siberian Husky';

  @override
  String get breedChihuahua => 'Chihuahua';

  @override
  String get breedShihTzu => 'Shih Tzu';

  @override
  String get breedDobermanPinscher => 'Doberman Pinscher';

  @override
  String get breedGreatDane => 'Great Dane';

  @override
  String get breedPomeranian => 'Pomeranian';

  @override
  String get breedBorderCollie => 'Border Collie';

  @override
  String get breedCockerSpaniel => 'Cocker Spaniel';

  @override
  String get breedMaltese => 'Maltese';

  @override
  String get breedMixedBreed => 'Mixed Breed';

  @override
  String get breedPersian => 'Persian';

  @override
  String get breedMaineCoon => 'Maine Coon';

  @override
  String get breedSiamese => 'Siamese';

  @override
  String get breedRagdoll => 'Ragdoll';

  @override
  String get breedBritishShorthair => 'British Shorthair';

  @override
  String get breedSphynx => 'Sphynx';

  @override
  String get breedBengal => 'Bengal';

  @override
  String get breedScottishFold => 'Scottish Fold';

  @override
  String get breedRussianBlue => 'Russian Blue';

  @override
  String get breedAbyssinian => 'Abyssinian';

  @override
  String get breedAmericanShorthair => 'American Shorthair';

  @override
  String get breedBirman => 'Birman';

  @override
  String get breedNorwegianForest => 'Norwegian Forest';

  @override
  String get breedDomesticShorthair => 'Domestic Shorthair';

  @override
  String get breedParakeet => 'Parakeet';

  @override
  String get breedCockatiel => 'Cockatiel';

  @override
  String get breedCanary => 'Canary';

  @override
  String get breedParrot => 'Parrot';

  @override
  String get breedLovebird => 'Lovebird';

  @override
  String get breedFinch => 'Finch';

  @override
  String get breedCockatoo => 'Cockatoo';

  @override
  String get breedMacaw => 'Macaw';

  @override
  String get breedConure => 'Conure';

  @override
  String get breedAfricanGrey => 'African Grey';

  @override
  String get breedHollandLop => 'Holland Lop';

  @override
  String get breedNetherlandDwarf => 'Netherland Dwarf';

  @override
  String get breedMiniRex => 'Mini Rex';

  @override
  String get breedLionhead => 'Lionhead';

  @override
  String get breedFlemishGiant => 'Flemish Giant';

  @override
  String get breedEnglishAngora => 'English Angora';

  @override
  String get breedDutch => 'Dutch';

  @override
  String get breedOther => 'Other (Custom)';

  @override
  String get customBreed => 'Custom Breed';

  @override
  String get enterCustomBreed => 'Enter your pet\'s breed';

  @override
  String get birthdayOptional => 'Birthday (optional)';

  @override
  String get tapToSelectBirthday => 'Tap to select birthday';

  @override
  String get selectPetBirthday => 'Select pet birthday';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get petNotesHint => 'Any special notes about your pet';

  @override
  String get speciesDog => 'Dog';

  @override
  String get speciesCat => 'Cat';

  @override
  String get speciesBird => 'Bird';

  @override
  String get speciesRabbit => 'Rabbit';

  @override
  String get speciesHamster => 'Hamster';

  @override
  String get speciesGuineaPig => 'Guinea Pig';

  @override
  String get speciesFish => 'Fish';

  @override
  String get speciesTurtle => 'Turtle';

  @override
  String get speciesLizard => 'Lizard';

  @override
  String get speciesSnake => 'Snake';

  @override
  String get speciesFerret => 'Ferret';

  @override
  String get speciesChinchilla => 'Chinchilla';

  @override
  String get speciesRat => 'Rat';

  @override
  String get speciesMouse => 'Mouse';

  @override
  String get speciesGerbil => 'Gerbil';

  @override
  String get speciesHedgehog => 'Hedgehog';

  @override
  String get speciesParrot => 'Parrot';

  @override
  String get speciesHorse => 'Horse';

  @override
  String get speciesChicken => 'Chicken';

  @override
  String get speciesOther => 'Other (Custom)';

  @override
  String get customSpecies => 'Custom Species';

  @override
  String get enterCustomSpecies => 'Enter your pet\'s species';

  @override
  String get gender => 'Gender';

  @override
  String get genderOptional => 'Gender (optional)';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderUnknown => 'Unknown';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get updateProfile => 'Update Profile';

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
  String get couldNotOpenLink => 'Could not open link';

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
  String get accountDeletedSuccessfully => 'All data deleted successfully';

  @override
  String get accountDeletionFailed =>
      'Failed to delete data. Please try again.';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileEdit => 'Profile Edit';

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
  String get errorLoadingSchedule => 'Error loading schedule';

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
  String get oneDayBefore => '1 day before';

  @override
  String get oneHourBefore => '1 Hour Before';

  @override
  String get thirtyMinutesBefore => '30 Minutes Before';

  @override
  String get reminderSet => 'Reminder set successfully';

  @override
  String get remindDaily => 'Remind Daily';

  @override
  String get remindAllDoses => 'Remind All Doses';

  @override
  String get remindOnce => 'Remind Once';

  @override
  String get firstDose => 'First dose';

  @override
  String get customTime => 'Custom time';

  @override
  String get timesDaily => 'times daily';

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
  String get viewAll => 'View All';

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

  @override
  String get photo => 'Photo';

  @override
  String get share => 'Share';

  @override
  String get setProfilePhoto => 'Set as Profile Photo';

  @override
  String setProfilePhotoConfirm(String petName) {
    return 'Set this photo as $petName\'s profile photo?';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get profilePhotoUpdated => 'Profile photo updated!';

  @override
  String get photoNotFound => 'Photo not found';

  @override
  String get qrCode => 'QR Code';

  @override
  String get qrCodeTitle => 'Pet QR Code';

  @override
  String get qrCodeDescription => 'Scan this code to view pet information';

  @override
  String get qrCodePrivacyNote =>
      'This QR code contains basic pet info only. Medical data is not included.';

  @override
  String get qrCodeSaved => 'QR code saved to device';

  @override
  String get qrCodeSaveFailed => 'Failed to save QR code';

  @override
  String qrCodeShareText(String petName) {
    return 'Here is $petName\'s QR code. Scan to see pet information.';
  }

  @override
  String get qrCodeShareFailed => 'Failed to share QR code';

  @override
  String get saveToDevice => 'Save';

  @override
  String get petInformation => 'Pet Information';

  @override
  String get ageLabel => 'Age';

  @override
  String get yearSingular => 'year';

  @override
  String get yearPlural => 'years';

  @override
  String get medicationInventory => 'Medication Inventory';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get allMedications => 'All Medications';

  @override
  String get statistics => 'Statistics';

  @override
  String get stockQuantity => 'Stock Quantity';

  @override
  String get stockUnit => 'Stock Unit';

  @override
  String get lowStockThreshold => 'Low Stock Alert';

  @override
  String get costPerUnit => 'Cost per Unit';

  @override
  String get addRefill => 'Add Refill';

  @override
  String get recordPurchase => 'Record Purchase';

  @override
  String get purchaseHistory => 'Purchase History';

  @override
  String get quantityPurchased => 'Quantity Purchased';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get pharmacy => 'Pharmacy';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get averageCostPerUnit => 'Average Cost per Unit';

  @override
  String get daysUntilEmpty => 'Days Until Empty';

  @override
  String pillsLeft(String count, String unit) {
    return '$count $unit left';
  }

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String refillReminder(String medication) {
    return 'Time to refill $medication';
  }

  @override
  String get markAsGiven => 'Mark as Given';

  @override
  String get addStock => 'Add Stock';

  @override
  String get noPurchases => 'No purchases recorded';

  @override
  String get purchaseAdded => 'Purchase recorded';

  @override
  String get stockUpdated => 'Stock updated';

  @override
  String get costPerMonth => 'Cost per Month';

  @override
  String get lastPurchase => 'Last Purchase';

  @override
  String get inventoryTracking => 'Inventory Tracking';

  @override
  String get enableRefillReminders => 'Enable Refill Reminders';

  @override
  String get refillReminderDays => 'Remind me X days before empty';

  @override
  String get pills => 'pills';

  @override
  String get ml => 'ml';

  @override
  String get doses => 'doses';

  @override
  String get tablets => 'tablets';

  @override
  String lowStockAlertBody(String count, String unit, String medication) {
    return 'Only $count $unit left for $medication';
  }

  @override
  String get refillSoon => 'Refill Soon';

  @override
  String get notTracked => 'Not tracked';

  @override
  String get initialStock => 'Initial Stock';

  @override
  String get daysBeforeEmpty => 'Days before empty';

  @override
  String get inventoryOverview => 'Inventory Overview';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get averageMonthlyCost => 'Average Monthly Cost';

  @override
  String get medicationsTracked => 'Medications Tracked';

  @override
  String get totalPurchases => 'Total Purchases';

  @override
  String get viewHistory => 'View History';

  @override
  String get editPurchase => 'Edit Purchase';

  @override
  String get deletePurchase => 'Delete Purchase';

  @override
  String get deletePurchaseConfirm =>
      'Are you sure you want to delete this purchase record?';

  @override
  String get purchaseDeletedSuccessfully => 'Purchase deleted successfully';

  @override
  String get failedToDeletePurchase => 'Failed to delete purchase';

  @override
  String get invalidQuantity => 'Please enter a valid quantity';

  @override
  String get invalidCost => 'Please enter a valid cost';

  @override
  String get cost => 'Cost';

  @override
  String get quantity => 'Quantity';

  @override
  String get stockLevel => 'Stock Level';

  @override
  String get sufficient => 'Sufficient';

  @override
  String get critical => 'Critical';

  @override
  String get refillNow => 'Refill Now';

  @override
  String get viewInventory => 'View Inventory';

  @override
  String get noMedicationsTracked => 'No medications tracked';

  @override
  String get noLowStockMedications => 'No low stock medications';

  @override
  String get totalSpentThisMonth => 'Total Spent This Month';

  @override
  String get totalSpentAllTime => 'Total Spent All Time';

  @override
  String get allPurchases => 'All purchases';

  @override
  String get averageCostPerMedication => 'Average Cost per Medication';

  @override
  String get perMedication => 'Per medication';

  @override
  String get topExpensiveMedications => 'Top 5 Most Expensive Medications';

  @override
  String get stockNotTracked => 'Stock not tracked';

  @override
  String get refill => 'Refill';

  @override
  String get notTrackedEnum => 'Not tracked';

  @override
  String get veterinarians => 'Veterinarians';

  @override
  String get addVet => 'Add Veterinarian';

  @override
  String get editVet => 'Edit Veterinarian';

  @override
  String get vetDetails => 'Veterinarian Details';

  @override
  String get vetName => 'Veterinarian Name';

  @override
  String get clinicName => 'Clinic Name';

  @override
  String get specialty => 'Specialty';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get website => 'Website';

  @override
  String get setAsPreferred => 'Set as Preferred Vet';

  @override
  String get preferredVet => 'Preferred Vet';

  @override
  String get generalPractice => 'General Practice';

  @override
  String get emergencyMedicine => 'Emergency Medicine';

  @override
  String get cardiology => 'Cardiology';

  @override
  String get dermatology => 'Dermatology';

  @override
  String get surgery => 'Surgery';

  @override
  String get orthopedics => 'Orthopedics';

  @override
  String get oncology => 'Oncology';

  @override
  String get ophthalmology => 'Ophthalmology';

  @override
  String get callVet => 'Call Veterinarian';

  @override
  String get emailVet => 'Email Veterinarian';

  @override
  String get openWebsite => 'Open Website';

  @override
  String get lastVisit => 'Last Visit';

  @override
  String get totalAppointments => 'Total Appointments';

  @override
  String get recentAppointments => 'Recent Appointments';

  @override
  String get noVetsAdded => 'No veterinarians added';

  @override
  String get addFirstVet =>
      'Add your pet\'s veterinarian to keep track of visits and contact information';

  @override
  String get deleteVet => 'Delete Veterinarian';

  @override
  String get deleteVetConfirm =>
      'Are you sure you want to delete this veterinarian? This will not affect existing appointments.';

  @override
  String get vetDeleted => 'Veterinarian deleted';

  @override
  String get vetAdded => 'Veterinarian added';

  @override
  String get vetUpdated => 'Veterinarian updated';

  @override
  String get selectVet => 'Select Veterinarian';

  @override
  String get addNewVet => 'Add New Veterinarian';

  @override
  String get invalidPhone => 'Invalid phone number';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidWebsite => 'Invalid website URL';

  @override
  String get vetNameRequired => 'Veterinarian name is required';

  @override
  String get clinicNameRequired => 'Clinic name is required';

  @override
  String get searchVets => 'Search veterinarians...';

  @override
  String get noVetsFound => 'No veterinarians found';

  @override
  String get noVetsMatchSearch => 'No veterinarians match your search';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get vetNotFound => 'Vet not found';

  @override
  String get alreadyPreferred => 'This is already your preferred vet';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get petManagement => 'Pet Management';

  @override
  String get viewHealthScoresAndMetrics =>
      'View health scores and activity metrics';

  @override
  String get manageVeterinariansAndClinics =>
      'Manage veterinarians and clinics';

  @override
  String get viewAndManagePetPhotos => 'View and manage pet photos';

  @override
  String get trackMedicationStockLevels => 'Track medication stock levels';

  @override
  String get reportsAndAnalytics => 'Reports & Analytics';

  @override
  String get healthScore => 'Health Score';

  @override
  String get medicationAdherence => 'Medication Adherence';

  @override
  String get activityLevels => 'Activity Levels';

  @override
  String get expenseTracking => 'Expense Tracking';

  @override
  String get stable => 'Stable';

  @override
  String get gaining => 'Gaining';

  @override
  String get losing => 'Losing';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get averageWeeklyExpenses => 'Average Weekly Expenses';

  @override
  String get expenseBreakdown => 'Expense Breakdown';

  @override
  String get reportPeriod => 'Report Period';

  @override
  String get last90Days => 'Last 90 Days';

  @override
  String get customRange => 'Custom Range';

  @override
  String get healthMetrics => 'Health Metrics';

  @override
  String get activityMetrics => 'Activity Metrics';

  @override
  String get dailyActivityAverage => 'Daily Activity Average';

  @override
  String get feedingsPerDay => 'Feedings/day';

  @override
  String get walksPerDay => 'Walks/day';

  @override
  String get expenseMetrics => 'Expense Metrics';

  @override
  String get overview => 'Overview';

  @override
  String get activityHigh => 'High';

  @override
  String get activityMedium => 'Medium';

  @override
  String get activityLow => 'Low';

  @override
  String get exportToPDF => 'Export to PDF';

  @override
  String get shareReport => 'Share Report';

  @override
  String get exportOptions => 'Export Options';

  @override
  String get fullReport => 'Full Report';

  @override
  String get fullReportDescription => 'Complete health report with all metrics';

  @override
  String get vetSummary => 'Vet Summary';

  @override
  String get vetSummaryDescription => 'Last 30 days summary for vet visit';

  @override
  String get shareText => 'Share Text Summary';

  @override
  String get shareTextDescription => 'Share as text message';

  @override
  String get reportGenerated => 'Report generated successfully';

  @override
  String get reportExported => 'Report saved to device';

  @override
  String get generatingReport => 'Generating report...';

  @override
  String get exportingReport => 'Exporting report...';

  @override
  String get sharingReport => 'Sharing report...';

  @override
  String reportSaved(String path) {
    return 'Report saved to: $path';
  }

  @override
  String failedToGeneratePDF(String error) {
    return 'Failed to generate PDF: $error';
  }

  @override
  String get failedToExportReport => 'Failed to export report';

  @override
  String get failedToShareReport => 'Failed to share report';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get noDataAvailable => 'No data available for this period';

  @override
  String get insufficientData => 'Insufficient data for analysis';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get averageMonthly => 'Average Monthly';

  @override
  String get topCategories => 'Top Categories';

  @override
  String get dismissRecommendation => 'Dismiss';

  @override
  String get reportingPeriod => 'Reporting Period';

  @override
  String get dataInsights => 'Data Insights';

  @override
  String get noRecommendations => 'No recommendations available';

  @override
  String get healthScoreExcellent => 'Excellent';

  @override
  String get healthScoreGood => 'Good';

  @override
  String get healthScoreFair => 'Fair';

  @override
  String get healthScoreLow => 'Low';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get expenseTrend => 'Expense Trend';

  @override
  String get trendIncreasing => 'Increasing';

  @override
  String get trendDecreasing => 'Decreasing';

  @override
  String get trendStable => 'Stable';

  @override
  String get monthlyExpenses => 'Monthly Expenses';

  @override
  String get average => 'Average';

  @override
  String get highest => 'Highest';

  @override
  String get excellentRange => 'Excellent (80+)';

  @override
  String get goodRange => 'Good (60-79)';

  @override
  String get fairRange => 'Fair (40-59)';

  @override
  String get lowRange => 'Low (<40)';

  @override
  String get recSetMedicationReminders =>
      'Set more medication reminders to improve adherence';

  @override
  String get recConsiderVetWeightGain =>
      'Consider vet consultation about weight gain';

  @override
  String get recConsiderVetWeightLoss =>
      'Consider vet consultation about weight loss';

  @override
  String get recIncreaseDailyWalks => 'Increase daily walks for better health';

  @override
  String get recReviewMedicationCosts =>
      'Review medication costs with your vet';

  @override
  String get recScheduleVetCheckup =>
      'Health score is low - schedule a vet checkup';

  @override
  String get healthScoreDescription =>
      'Based on weight stability, medication adherence, and activity levels';

  @override
  String get pdfPetHealthReport => 'Pet Health Report';

  @override
  String get pdfPetInformation => 'Pet Information';

  @override
  String get pdfName => 'Name';

  @override
  String get pdfSpecies => 'Species';

  @override
  String get pdfBreed => 'Breed';

  @override
  String get pdfAge => 'Age';

  @override
  String get pdfYears => 'years';

  @override
  String get pdfCat => 'Cat';

  @override
  String get pdfDog => 'Dog';

  @override
  String get pdfUnknown => 'Unknown';

  @override
  String get pdfReportPeriod => 'Report Period';

  @override
  String get pdfFrom => 'From';

  @override
  String get pdfTo => 'To';

  @override
  String get pdfHealthMetrics => 'Health Metrics';

  @override
  String get pdfOverallHealthScore => 'Overall Health Score';

  @override
  String get pdfMedicationAdherence => 'Medication Adherence';

  @override
  String get pdfWeightTrend => 'Weight Trend';

  @override
  String get pdfStable => 'Stable';

  @override
  String get pdfGaining => 'Gaining';

  @override
  String get pdfLosing => 'Losing';

  @override
  String get pdfActivitySummary => 'Activity Summary';

  @override
  String get pdfTotalFeedings => 'Total Feedings';

  @override
  String get pdfTotalWalks => 'Total Walks';

  @override
  String get pdfAvgFeedingsPerDay => 'Avg Feedings/Day';

  @override
  String get pdfAvgWalksPerDay => 'Avg Walks/Day';

  @override
  String get pdfExpenses => 'Expenses';

  @override
  String get pdfTotalExpenses => 'Total Expenses';

  @override
  String get pdfGeneratedOn => 'Generated on';

  @override
  String get pdfFooter => 'FurFriend Diary - Pet Health Management';

  @override
  String get pdfVeterinarySummary => 'Veterinary Summary';

  @override
  String get pdfLast30DaysSummary => 'Last 30 Days Summary';

  @override
  String get pdfHealthStatus => 'Health Status';

  @override
  String get pdfHealthScore => 'Health Score';

  @override
  String get pdfMedicationCompliance => 'Medication Compliance';

  @override
  String get pdfActivityOverview => 'Activity Overview';

  @override
  String get pdfDailyFeedingsAvg => 'Daily Feedings (Avg)';

  @override
  String get pdfDailyWalksAvg => 'Daily Walks (Avg)';

  @override
  String get pdfNotes => 'Notes';

  @override
  String get pdfNotesText =>
      'Please review the attached health data and discuss any concerns during the appointment.';

  @override
  String get emailSubject => 'Pet Health Report';

  @override
  String get emailBody => 'Here is the health report for my pet.';

  @override
  String get vetSummaryEmailSubject => 'Veterinary Summary';

  @override
  String get vetSummaryEmailBody =>
      'Here is the veterinary summary for my pet.';

  @override
  String get textSummaryEmailSubject => 'Pet Health Summary';

  @override
  String get navHome => 'Home';

  @override
  String get navFeedings => 'Feedings';

  @override
  String get navWalks => 'Walks';

  @override
  String get navMeds => 'Meds';

  @override
  String get navAppts => 'Appts';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get nextDue => 'Next due';

  @override
  String medicationReminderBody(String medication, String frequency) {
    return '$medication - $frequency';
  }

  @override
  String get criticalLowStockAlert => 'Critical: Low Stock Alert';

  @override
  String lowStockBody(int count, String unit) {
    return 'Only $count $unit remaining. Time to refill!';
  }

  @override
  String appointmentAt(String title, String location) {
    return '$title at $location';
  }

  @override
  String get selectVaccinationProtocol => 'Select Vaccination Protocol';

  @override
  String get selectProtocol => 'Select Protocol';

  @override
  String selectProtocolForPet(String petName) {
    return 'Select vaccination protocol for $petName';
  }

  @override
  String get chooseProtocolMatchingNeeds =>
      'Choose a protocol that matches your pet\'s vaccination needs';

  @override
  String get coreProtocol => 'Core';

  @override
  String get extendedProtocol => 'Extended';

  @override
  String get predefinedProtocol => 'Predefined';

  @override
  String get currentProtocol => 'Current protocol';

  @override
  String get customProtocol => 'Custom';

  @override
  String vaccinationsCount(int count) {
    return '$count vaccinations';
  }

  @override
  String get confirmProtocolSelection => 'Confirm Protocol Selection';

  @override
  String get applyProtocol => 'Apply Protocol';

  @override
  String applyProtocolToPet(String protocolName, String petName) {
    return 'Apply $protocolName to $petName';
  }

  @override
  String protocolAppliedSuccess(String petName) {
    return 'Vaccination protocol applied to $petName';
  }

  @override
  String get protocolApplyFailed => 'Failed to apply vaccination protocol';

  @override
  String get noProtocolsAvailable =>
      'No vaccination protocols available for this pet\'s species';

  @override
  String noProtocolsForSpecies(String species) {
    return 'No vaccination protocols found for $species. Contact your veterinarian for guidance.';
  }

  @override
  String get loadingProtocols => 'Loading vaccination protocols...';

  @override
  String get failedToLoadProtocols => 'Failed to load protocols';

  @override
  String andXMore(int count) {
    return '...and $count more';
  }

  @override
  String get requiredVaccine => 'Required';

  @override
  String get optionalVaccine => 'Optional';

  @override
  String atWeeksAge(int weeks) {
    return 'at $weeks weeks';
  }

  @override
  String get protocolDetails => 'Protocol Details';

  @override
  String get viewFullDetails => 'View Full Details';

  @override
  String get viewFullSchedule => 'View Full Schedule';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get configureReminders => 'Configure Reminders';

  @override
  String reminderSettingsFor(String eventType) {
    return 'Reminder Settings for $eventType';
  }

  @override
  String get enableReminders => 'Enable Reminders';

  @override
  String get disableReminders => 'Disable Reminders';

  @override
  String get notificationsActive => 'Notifications are active';

  @override
  String get notificationsDisabled => 'Notifications are disabled';

  @override
  String get remindMe => 'Remind me:';

  @override
  String get dayOf => 'Day of';

  @override
  String get dayBefore => '1 day before';

  @override
  String get remindersActive => 'Active Reminders';

  @override
  String get reminderTiming => 'Reminder Timing';

  @override
  String selectWhenToReceiveReminders(String eventType) {
    return 'Select when you\'d like to receive reminders before upcoming $eventType events';
  }

  @override
  String get threeDaysBefore => '3 days before';

  @override
  String get oneWeekBefore => '1 week before';

  @override
  String get twoWeeksBefore => '2 weeks before';

  @override
  String get saveReminderSettings => 'Save Reminder Settings';

  @override
  String get reminderSettingsSaved => 'Reminder settings saved successfully';

  @override
  String get reminderSettingsSaveFailed => 'Failed to save reminder settings';

  @override
  String get noRemindersSelected => 'No reminders selected';

  @override
  String get selectAtLeastOneReminder =>
      'Please select at least one reminder time';

  @override
  String get loadingReminderSettings => 'Loading reminder settings...';

  @override
  String get failedToLoadReminderSettings => 'Failed to load reminder settings';

  @override
  String get vaccinationReminders => 'Vaccination Reminders';

  @override
  String get dewormingReminders => 'Deworming Reminders';

  @override
  String get appointmentReminders => 'Appointment Reminders';

  @override
  String get medicationReminders => 'Medication Reminders';

  @override
  String get treatmentPlanViewer => 'Treatment Plans';

  @override
  String get activeTreatmentPlans => 'Active Treatment Plans';

  @override
  String get loadingTreatmentPlans => 'Loading treatment plans...';

  @override
  String get failedToLoadTreatmentPlans => 'Failed to load treatment plans';

  @override
  String get noActiveTreatmentPlans => 'No Active Treatment Plans';

  @override
  String get noActiveTreatmentPlansMessage =>
      'You don\'t have any active treatment plans for this pet.';

  @override
  String tasksComplete(int completed, int total) {
    return '$completed of $total tasks complete';
  }

  @override
  String get markPlanComplete => 'Mark Plan Complete';

  @override
  String get planMarkedComplete => 'Treatment plan marked as complete';

  @override
  String get failedToMarkPlanComplete => 'Failed to mark plan as complete';

  @override
  String get confirmMarkComplete => 'Confirm Mark Complete';

  @override
  String confirmMarkCompleteMessage(String planName) {
    return 'Are you sure you want to mark \"$planName\" as complete? This action cannot be easily undone.';
  }

  @override
  String get taskUpdated => 'Task updated successfully';

  @override
  String get taskCompletionFailed => 'Failed to update task';

  @override
  String get dueToday => 'Due Today';

  @override
  String prescribedBy(String veterinarian) {
    return 'Prescribed by $veterinarian';
  }

  @override
  String startedOn(String date) {
    return 'Started on $date';
  }

  @override
  String get calendarView => 'Calendar';

  @override
  String get vaccinations => 'Vaccinations';

  @override
  String get deworming => 'Deworming';

  @override
  String get noEventsOnThisDay => 'No Events on This Day';

  @override
  String get selectAnotherDay =>
      'Select another day to view scheduled care events';

  @override
  String get noUpcomingCareEvents => 'No Upcoming Care Events';

  @override
  String get setupProtocolsToSeeEvents =>
      'Set up vaccination protocols and appointments to see them here';

  @override
  String get setUpProtocols => 'Set Up Protocols';

  @override
  String get failedToLoadCalendar => 'Failed to load calendar events';

  @override
  String get loadingCalendar => 'Loading calendar...';

  @override
  String get eventSingular => 'event';

  @override
  String get eventPlural => 'events';

  @override
  String get vaccinationDetailsComingSoon => 'Vaccination details coming soon';

  @override
  String get dewormingDetailsComingSoon => 'Deworming details coming soon';

  @override
  String get appointmentDetailsComingSoon => 'Appointment details coming soon';

  @override
  String get tapToViewDetails => 'Tap to view details';

  @override
  String eventsOnDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'events',
      one: 'event',
    );
    return '$count $_temp0 on $date';
  }

  @override
  String get vaccinationStatus => 'Vaccination Status';

  @override
  String get dewormingStatus => 'Deworming Status';

  @override
  String get noDewormingProtocol => 'No deworming protocol selected';

  @override
  String get nextTreatment => 'Next treatment';

  @override
  String get selectDewormingProtocol => 'Select Protocol';

  @override
  String get dewormingProtocolDetails => 'Protocol details';

  @override
  String get viewDewormingSchedule => 'View deworming schedule';

  @override
  String get chooseDewormingProtocol =>
      'Choose a protocol that matches your pet\'s parasite prevention needs';

  @override
  String dewormingProtocolApplied(String petName) {
    return 'Deworming protocol applied to $petName';
  }

  @override
  String get dewormingProtocolApplyFailed =>
      'Failed to apply deworming protocol';

  @override
  String treatmentsCount(int count) {
    return '$count treatments';
  }

  @override
  String get internalDeworming => 'Internal';

  @override
  String get externalDeworming => 'External';

  @override
  String get vaccinationProtocol => 'Vaccination Protocol';

  @override
  String get isThisVaccination => 'Is this a vaccination?';

  @override
  String get regularMedication => 'Regular medication tracking';

  @override
  String get protocolBasedVaccination => 'Protocol-based vaccination';

  @override
  String get pleaseSelectVaccinationProtocol =>
      'Please select a vaccination protocol';

  @override
  String get nextDoseCalculation => 'Next Dose Calculation';

  @override
  String calculatedFromProtocol(int stepIndex) {
    return 'Calculated from protocol step $stepIndex';
  }

  @override
  String get fromProtocol => '(from protocol)';

  @override
  String get recommendedDose => '(recommended)';

  @override
  String get petNeedsBirthday =>
      'Pet needs a birthday to calculate vaccination dates';

  @override
  String get dose => 'Dose';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get taskCompleted => 'Task completed';

  @override
  String get dueDate => 'Due date';

  @override
  String get noTasksInPlan => 'No tasks in this treatment plan';

  @override
  String get loadingDewormingProtocols => 'Loading deworming protocols...';

  @override
  String get failedToLoadDewormingProtocols =>
      'Failed to load deworming protocols';

  @override
  String get noDewormingProtocolsAvailable =>
      'No deworming protocols available for this pet\'s species';

  @override
  String noDewormingProtocolsForSpecies(String species) {
    return 'No deworming protocols found for $species. Contact your veterinarian for guidance.';
  }

  @override
  String get goBack => 'Go back';

  @override
  String get noBirthdaySet => 'No birthday set';

  @override
  String get addBirthdayToViewSchedule =>
      'Add your pet\'s birthday to view their deworming schedule';

  @override
  String get noScheduleAvailable => 'No schedule available';

  @override
  String get protocolMayNotApplyYet =>
      'This protocol may not apply to your pet yet';

  @override
  String get allTreatmentsCompleted => 'All treatments completed!';

  @override
  String get completedAllScheduledTreatments =>
      'Your pet has completed all scheduled treatments in this protocol';

  @override
  String get treatmentHistory => 'Treatment History';

  @override
  String treatmentNumber(int number) {
    return 'Treatment $number';
  }

  @override
  String regionLabel(String region) {
    return 'Region: $region';
  }

  @override
  String birthDateLabel(String date) {
    return 'Birth date: $date';
  }

  @override
  String get dewormingTreatment => 'Deworming Treatment';

  @override
  String doseNumber(int number) {
    return 'Dose $number';
  }

  @override
  String get vaccination => 'Vaccination';

  @override
  String get veterinaryAppointment => 'Veterinary Appointment';

  @override
  String get medication => 'Medication';

  @override
  String ageMonthsShort(int count) {
    return '$count mos';
  }

  @override
  String ageYearsShort(int count) {
    return '$count yrs';
  }

  @override
  String ageWeeksShort(int count) {
    return '$count wks';
  }

  @override
  String get addVaccination => 'Add Vaccination';

  @override
  String get editVaccination => 'Edit Vaccination';

  @override
  String get vaccinationInformation => 'Vaccination Information';

  @override
  String get vaccineType => 'Vaccine Type';

  @override
  String get selectVaccineType => 'Select vaccine type';

  @override
  String get pleaseSelectVaccineType => 'Please select a vaccine type';

  @override
  String get petSpecies => 'Pet Species';

  @override
  String get vaccinesFor => 'Vaccines for';

  @override
  String get dates => 'Dates';

  @override
  String get administeredDate => 'Administered Date';

  @override
  String get nextDueDate => 'Next Due Date';

  @override
  String get veterinaryDetails => 'Veterinary Details';

  @override
  String get optionalFields => 'All fields below are optional';

  @override
  String get batchNumber => 'Batch Number';

  @override
  String get batchNumberHint => 'e.g., BN12345';

  @override
  String get veterinarianName => 'Veterinarian Name';

  @override
  String get veterinarianNameHint => 'e.g., Dr. Smith';

  @override
  String get clinicNameHint => 'e.g., City Vet Clinic';

  @override
  String get certificatePhotos => 'Vaccination Certificate';

  @override
  String get optionalCertificateHint =>
      'Upload photos of vaccination certificates for your records';

  @override
  String get vaccinationNotesHint =>
      'e.g., Pet tolerated vaccination well, no adverse reactions';

  @override
  String get saveVaccination => 'Save Vaccination';

  @override
  String get updateVaccination => 'Update Vaccination';

  @override
  String get vaccinationAddedSuccessfully => 'Vaccination added successfully';

  @override
  String get vaccinationUpdatedSuccessfully =>
      'Vaccination updated successfully';

  @override
  String failedToAddVaccination(String error) {
    return 'Failed to add vaccination: $error';
  }

  @override
  String failedToUpdateVaccination(String error) {
    return 'Failed to update vaccination: $error';
  }

  @override
  String get vaccinationDetails => 'Vaccination Details';

  @override
  String get deleteVaccination => 'Delete Vaccination';

  @override
  String deleteVaccinationConfirm(String vaccineType) {
    return 'Are you sure you want to delete this $vaccineType vaccination? This action cannot be undone.';
  }

  @override
  String get vaccinationDeletedSuccessfully =>
      'Vaccination deleted successfully';

  @override
  String get failedToDeleteVaccination => 'Failed to delete vaccination';

  @override
  String get vaccinationNotFound => 'Vaccination not found';

  @override
  String get generatedFromProtocol => 'Generated from Protocol';

  @override
  String get protocolInformation => 'Protocol Information';

  @override
  String get dueStatus => 'Due Status';

  @override
  String get administered => 'Administered';

  @override
  String get noVaccinations => 'No vaccinations yet';

  @override
  String get trackVaccinationRecords =>
      'Keep track of your pet\'s vaccination history and upcoming boosters';

  @override
  String get errorLoadingVaccinations => 'Error loading vaccinations';

  @override
  String get viewDetails => 'View details';
}
