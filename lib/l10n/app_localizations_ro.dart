// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'FurFriendDiary';

  @override
  String get homeGreeting => 'Salut, prieten blănos!';

  @override
  String get medications => 'Medicamente';

  @override
  String get active => 'Active';

  @override
  String get all => 'Toate';

  @override
  String get inactive => 'Inactive';

  @override
  String get searchMedications => 'Caută medicamente...';

  @override
  String get addMedication => 'Adaugă Medicament';

  @override
  String get noPetSelected => 'Niciun animal selectat';

  @override
  String get pleaseSetupPetFirst =>
      'Vă rugăm să configurați mai întâi un profil de animal';

  @override
  String get noActiveMedications => 'Niciun medicament activ';

  @override
  String get noMedicationsFound => 'Nu s-au găsit medicamente';

  @override
  String get noInactiveMedications => 'Niciun medicament inactiv';

  @override
  String get noMedicationsMatchSearch =>
      'Niciun medicament nu corespunde căutării';

  @override
  String get tryAdjustingSearchTerms =>
      'Încercați să ajustați termenii de căutare';

  @override
  String get errorLoadingMedications => 'Eroare la încărcarea medicamentelor';

  @override
  String get retry => 'Reîncercare';

  @override
  String get medicationMarkedInactive => 'Medicament marcat ca inactiv';

  @override
  String get medicationMarkedActive => 'Medicament marcat ca activ';

  @override
  String get failedToUpdateMedication => 'Actualizarea medicamentului a eșuat';

  @override
  String get deleteMedication => 'Șterge Medicament';

  @override
  String deleteMedicationConfirm(String medicationName) {
    return 'Sigur doriți să ștergeți \"$medicationName\"? Această acțiune nu poate fi anulată.';
  }

  @override
  String get cancel => 'Anulare';

  @override
  String get delete => 'Șterge';

  @override
  String get medicationDeletedSuccessfully => 'Medicament șters cu succes';

  @override
  String get failedToDeleteMedication => 'Ștergerea medicamentului a eșuat';

  @override
  String get appointments => 'Programări';

  @override
  String get upcoming => 'Viitoare';

  @override
  String get completed => 'Finalizate';

  @override
  String get searchAppointments => 'Caută programări...';

  @override
  String get addAppointment => 'Adaugă Programare';

  @override
  String get editAppointment => 'Editează Programare';

  @override
  String get noUpcomingAppointments => 'Nicio programare viitoare';

  @override
  String get noAppointmentsFound => 'Nu s-au găsit programări';

  @override
  String get noCompletedAppointments => 'Nicio programare finalizată';

  @override
  String get noAppointmentsMatchSearch =>
      'Nicio programare nu corespunde căutării';

  @override
  String get errorLoadingAppointments => 'Eroare la încărcarea programărilor';

  @override
  String get feedings => 'Hrăniri';

  @override
  String petFeedings(String petName) {
    return '$petName - Hrăniri';
  }

  @override
  String noFeedingsRecorded(String petName) {
    return 'Nicio hrănire înregistrată pentru $petName încă';
  }

  @override
  String get noFeedingsRecordedGeneric => 'Nicio hrănire înregistrată încă';

  @override
  String get addFirstFeeding => 'Adaugă prima hrănire';

  @override
  String get errorLoadingFeedings => 'Eroare la încărcarea hrănirilor';

  @override
  String get addNewFeeding => 'Adaugă o hrănire nouă';

  @override
  String get foodType => 'Tip de mâncare';

  @override
  String get foodTypeHint =>
      'de ex., Mâncare uscată, Mâncare umedă, Recompense';

  @override
  String get pleaseEnterFoodType => 'Vă rugăm să introduceți un tip de mâncare';

  @override
  String get foodTypeDryFood => 'Mâncare Uscată';

  @override
  String get foodTypeWetFood => 'Mâncare Umedă';

  @override
  String get foodTypeTreats => 'Recompense';

  @override
  String get foodTypeRawFood => 'Mâncare Crudă';

  @override
  String get foodTypeChicken => 'Pui';

  @override
  String get foodTypeFish => 'Pește';

  @override
  String get foodTypeTurkey => 'Curcan';

  @override
  String get foodTypeBeef => 'Vită';

  @override
  String get foodTypeVegetables => 'Legume';

  @override
  String get foodTypeOther => 'Altele (Personalizat)';

  @override
  String get foodTypeCustomPlaceholder =>
      'Introduceți un tip de mâncare personalizat';

  @override
  String get clear => 'Curăță';

  @override
  String get add => 'Adaugă';

  @override
  String feedingAdded(String foodType) {
    return 'Hrănire \"$foodType\" adăugată';
  }

  @override
  String get failedToSaveFeeding => 'Salvarea hrănirii a eșuat';

  @override
  String get mixed => 'Mixt';

  @override
  String get save => 'Salvează';

  @override
  String get medicationInformation => 'Informații Medicament';

  @override
  String get medicationName => 'Nume Medicament *';

  @override
  String get medicationNameHint => 'de ex., Apoquel, Heartgard';

  @override
  String get pleaseEnterMedicationName =>
      'Vă rugăm să introduceți numele medicamentului';

  @override
  String get dosage => 'Dozaj';

  @override
  String get dosageHint => 'de ex., 5mg, 1 tabletă, 2ml';

  @override
  String get pleaseEnterDosage => 'Vă rugăm să introduceți dozajul';

  @override
  String get frequency => 'Frecvență';

  @override
  String get frequencyOnceDaily => 'O dată pe zi';

  @override
  String get frequencyTwiceDaily => 'De două ori pe zi';

  @override
  String get frequencyThreeTimesDaily => 'De trei ori pe zi';

  @override
  String get frequencyFourTimesDaily => 'De patru ori pe zi';

  @override
  String get frequencyEveryOtherDay => 'Din două în două zile';

  @override
  String get frequencyWeekly => 'Săptămânal';

  @override
  String get frequencyAsNeeded => 'La nevoie';

  @override
  String get frequencyCustom => 'Personalizat';

  @override
  String get administrationMethod => 'Metodă de Administrare *';

  @override
  String get administrationMethodOral => 'Oral';

  @override
  String get administrationMethodTopical => 'Topic';

  @override
  String get administrationMethodInjection => 'Injecție';

  @override
  String get administrationMethodEyeDrops => 'Picături pentru ochi';

  @override
  String get administrationMethodEarDrops => 'Picături pentru urechi';

  @override
  String get administrationMethodInhaled => 'Inhalat';

  @override
  String get administrationMethodOther => 'Altele';

  @override
  String get schedule => 'Program';

  @override
  String get startDate => 'Data de Început';

  @override
  String get hasEndDate => 'Are Dată de Încheiere';

  @override
  String get ongoingMedication => 'Medicament în curs';

  @override
  String get endDate => 'Data de Încheiere';

  @override
  String get selectEndDate => 'Selectați data de încheiere';

  @override
  String get administrationTimes => 'Timp de administrare';

  @override
  String get addTime => 'Adaugă oră';

  @override
  String time(int number) {
    return 'Ora $number';
  }

  @override
  String get additionalNotes => 'Notițe Suplimentare';

  @override
  String get additionalNotesHint =>
      'Adăugați notițe, instrucțiuni speciale sau mementouri...';

  @override
  String get saveMedication => 'Salvează Medicament';

  @override
  String get noActivePetFound =>
      'Niciun animal activ găsit. Vă rugăm să selectați mai întâi un animal.';

  @override
  String get medicationAddedSuccessfully => 'Medicament adăugat cu succes!';

  @override
  String failedToAddMedication(String error) {
    return 'Adăugarea medicamentului a eșuat: $error';
  }

  @override
  String get medicationDetails => 'Detalii Medicament';

  @override
  String get basicInformation => 'Informații de Bază';

  @override
  String get editMedication => 'Editează Medicament';

  @override
  String get ongoing => 'În curs';

  @override
  String get duration => 'Durată';

  @override
  String get notes => 'Notițe';

  @override
  String get saveChanges => 'Salvează Modificările';

  @override
  String get markInactive => 'Marchează ca Inactiv';

  @override
  String get markActive => 'Marchează ca Activ';

  @override
  String get appointmentInformation => 'Informații despre Programare';

  @override
  String get veterinarian => 'Veterinar';

  @override
  String get veterinarianHint => 'de ex., Dr. Popescu, Dr. Ionescu';

  @override
  String get pleaseEnterVeterinarian =>
      'Vă rugăm să introduceți numele veterinarului';

  @override
  String get clinic => 'Clinică';

  @override
  String get clinicHint => 'de ex., Spital Veterinar, Clinică Veterinară';

  @override
  String get pleaseEnterClinic => 'Vă rugăm să introduceți numele clinicii';

  @override
  String get enterManually => 'Adaugă manual';

  @override
  String get reason => 'Motiv';

  @override
  String get reasonHint => 'de ex., Control, Vaccinare, Operație';

  @override
  String get pleaseEnterReason => 'Vă rugăm să introduceți motivul programării';

  @override
  String get appointmentReasonCheckup => 'Control de Rutină';

  @override
  String get appointmentReasonVaccination => 'Vaccinare';

  @override
  String get appointmentReasonSurgery => 'Operație';

  @override
  String get appointmentReasonEmergency => 'Urgență';

  @override
  String get appointmentReasonFollowUp => 'Control Post-Procedură';

  @override
  String get appointmentReasonDentalCleaning => 'Curățare Dentară';

  @override
  String get appointmentReasonGrooming => 'Îngrijire';

  @override
  String get appointmentReasonBloodTest => 'Analize de Sânge';

  @override
  String get appointmentReasonXRay => 'Radiografie';

  @override
  String get appointmentReasonSpayingNeutering => 'Sterilizare';

  @override
  String get appointmentReasonOther => 'Altele (Personalizat)';

  @override
  String get appointmentReasonCustomPlaceholder =>
      'Introduceți un motiv personalizat';

  @override
  String get appointmentDate => 'Data Programării';

  @override
  String get appointmentTime => 'Ora Programării';

  @override
  String get status => 'Stare';

  @override
  String get markAsCompleted => 'Marchează ca Finalizat';

  @override
  String get appointmentCompleted => 'Programare finalizată';

  @override
  String get appointmentPending => 'Programare în așteptare';

  @override
  String get updateAppointment => 'Actualizează Programare';

  @override
  String get saveAppointment => 'Salvează Programare';

  @override
  String get appointmentUpdatedSuccessfully =>
      'Programare actualizată cu succes!';

  @override
  String get appointmentAddedSuccessfully => 'Programare adăugată cu succes!';

  @override
  String failedToSaveAppointment(String error) {
    return 'Salvarea programării a eșuat: $error';
  }

  @override
  String get walks => 'Plimbări';

  @override
  String get today => 'Astăzi';

  @override
  String get tomorrow => 'Mâine';

  @override
  String get yesterday => 'Ieri';

  @override
  String get thisWeek => 'Săptămâna Aceasta';

  @override
  String get addWalk => 'Adaugă plimbare';

  @override
  String get start => 'Început';

  @override
  String get durationMin => 'Durată';

  @override
  String get distance => 'Distanță';

  @override
  String get surfaceLabel => 'Suprafață';

  @override
  String get surfacePaved => 'pavat';

  @override
  String get surfaceGravel => 'pietriș';

  @override
  String get surfaceMixed => 'mixt';

  @override
  String get pace => 'Ritm';

  @override
  String get min => 'min';

  @override
  String get km => 'km';

  @override
  String get noWalksYet => 'Nicio plimbare încă';

  @override
  String get trackFirstWalk =>
      'Înregistrați prima plimbare pentru a vedea distanța și durata aici.';

  @override
  String get addFirstWalk => 'Adaugă prima plimbare';

  @override
  String get walkDetails => 'Detalii plimbare';

  @override
  String get close => 'Închide';

  @override
  String get noNotes => 'Nicio notiță';

  @override
  String get optional => 'Opțional';

  @override
  String get required => 'Obligatoriu';

  @override
  String get enterPositiveNumber => 'Introduceți un număr pozitiv';

  @override
  String get walkAddedSuccessfully => 'Plimbare adăugată cu succes!';

  @override
  String walkDetailsFor(String walkInfo) {
    return 'Detalii plimbare pentru $walkInfo';
  }

  @override
  String get reports => 'Rapoarte';

  @override
  String get health => 'Sănătate';

  @override
  String get activity => 'Activitate';

  @override
  String get searchReports => 'Caută rapoarte...';

  @override
  String get generateReport => 'Generează Raport';

  @override
  String get healthSummary => 'Rezumat Sănătate';

  @override
  String get activityReport => 'Raport Activitate';

  @override
  String get veterinaryRecords => 'Înregistrări Veterinare';

  @override
  String get generated => 'Generat';

  @override
  String get period => 'Perioadă';

  @override
  String get data => 'Date';

  @override
  String get summary => 'Rezumat';

  @override
  String get items => 'articole';

  @override
  String get feeds => 'hrăniri';

  @override
  String get visits => 'vizite';

  @override
  String get outOf => 'din';

  @override
  String get total => 'Total';

  @override
  String get avg => 'medie';

  @override
  String get perDay => 'pe zi';

  @override
  String get generatedOn => 'Generat pe';

  @override
  String get at => 'la';

  @override
  String get days => 'zile';

  @override
  String get totalFeedings => 'Hrăniri Totale';

  @override
  String get totalWalks => 'Plimbări Totale';

  @override
  String get dailyAverage => 'Medie Zilnică';

  @override
  String get inPeriod => 'În perioadă';

  @override
  String get feedingHistory => 'Istoric Hrănire';

  @override
  String get date => 'Data';

  @override
  String get type => 'Tip';

  @override
  String get amount => 'Cantitate';

  @override
  String get dryFood => 'Mâncare Uscată';

  @override
  String get wetFood => 'Mâncare Umedă';

  @override
  String get treats => 'Recompense';

  @override
  String get timeLabel => 'Ora';

  @override
  String get name => 'Nume';

  @override
  String get method => 'Metoda';

  @override
  String get appointmentHistory => 'Istoric Programări';

  @override
  String get pending => 'În așteptare';

  @override
  String get finished => 'Finalizat';

  @override
  String get completedTotal => 'Finalizate/Total';

  @override
  String get activeTotal => 'Active/Total';

  @override
  String get noMedicationsFoundPeriod =>
      'Nu s-au găsit medicamente pentru această perioadă';

  @override
  String get noFeedingDataFoundPeriod =>
      'Nu s-au găsit date de hrănire pentru această perioadă';

  @override
  String get noVeterinaryAppointmentsFoundPeriod =>
      'Nu s-au găsit programări veterinare pentru această perioadă';

  @override
  String get shareFunctionalityPlaceholder =>
      'Funcționalitatea de partajare ar fi implementată aici';

  @override
  String get deleteReport => 'Șterge Raport';

  @override
  String deleteReportConfirmation(String reportName, String date) {
    return 'Sigur doriți să ștergeți raportul \"$reportName\" din $date?';
  }

  @override
  String get reportDeletedSuccessfully => 'Raport șters cu succes';

  @override
  String get reportConfiguration => 'Configurare Raport';

  @override
  String get reportType => 'Tip Raport';

  @override
  String get pleaseSelectReportType => 'Vă rugăm să selectați un tip de raport';

  @override
  String get dateRange => 'Interval de Date';

  @override
  String get quickRanges => 'Intervale Rapide';

  @override
  String get healthSummaryDescription =>
      'Prezentare generală cuprinzătoare incluzând medicamente recente, programări și activități pentru perioada selectată.';

  @override
  String get medicationHistoryDescription =>
      'Lista detaliată a tuturor medicamentelor cu date, dozaje și stare de finalizare pentru perioada selectată.';

  @override
  String get activityReportDescription =>
      'Analiză a plimbărilor, tiparelor de exerciții și tendințelor de activitate pe parcursul perioadei selectate.';

  @override
  String get veterinaryRecordsDescription =>
      'Înregistrare completă a tuturor programărilor veterinare cu rezultate și notițe pentru perioada selectată.';

  @override
  String get selectReportTypeDescription =>
      'Selectați un tip de raport pentru a vedea descrierea acestuia.';

  @override
  String get endDateMustBeAfterStartDate =>
      'Data de încheiere trebuie să fie după data de început';

  @override
  String get last7Days => 'Ultimele 7 Zile';

  @override
  String get last30Days => 'Ultimele 30 Zile';

  @override
  String get last3Months => 'Ultimele 3 luni';

  @override
  String get last6Months => 'Ultimele 6 luni';

  @override
  String get lastYear => 'Anul trecut';

  @override
  String get reportGeneratedSuccessfully => 'Raport generat cu succes!';

  @override
  String failedToGenerateReport(String error) {
    return 'Generarea raportului a eșuat: $error';
  }

  @override
  String get medicationHistory => 'Istoric Medicamente';

  @override
  String get edit => 'Editează';

  @override
  String get confirmDelete => 'Confirmă Ștergerea';

  @override
  String get deleteConfirmationMessage =>
      'Sigur doriți să ștergeți această hrănire?';

  @override
  String get feedingDeleted => 'Hrănire ștearsă cu succes';

  @override
  String get pet => 'Animal';

  @override
  String get pleaseSelectPet => 'Selectați un animal';

  @override
  String get pleaseEnterAmount => 'Introduceți cantitatea';

  @override
  String get addNotesOptional => 'Adăugați notițe (opțional)';

  @override
  String get feedingTime => 'Ora Hrănirii';

  @override
  String get editFeeding => 'Editează Hrănire';

  @override
  String get petProfiles => 'Profile Animale';

  @override
  String get addPet => 'Adaugă Animal';

  @override
  String get setupPetProfile => 'Configurați profilul animalului';

  @override
  String get editPetProfile => 'Editați profilul animalului';

  @override
  String get petName => 'Numele animalului';

  @override
  String get pleaseEnterPetName => 'Vă rugăm să introduceți numele animalului';

  @override
  String get species => 'Specie';

  @override
  String get speciesHint => 'de ex., Câine, Pisică, Pasăre';

  @override
  String get pleaseEnterSpecies => 'Vă rugăm să introduceți specia animalului';

  @override
  String get breed => 'Rasă';

  @override
  String get breedOptional => 'Rasă (opțional)';

  @override
  String get breedHint => 'de ex., Golden Retriever, Persană';

  @override
  String get breedLabradorRetriever => 'Labrador Retriever';

  @override
  String get breedGoldenRetriever => 'Golden Retriever';

  @override
  String get breedGermanShepherd => 'Ciobănesc German';

  @override
  String get breedBulldog => 'Bulldog';

  @override
  String get breedBeagle => 'Beagle';

  @override
  String get breedPoodle => 'Pudel';

  @override
  String get breedRottweiler => 'Rottweiler';

  @override
  String get breedYorkshireTerrier => 'Yorkshire Terrier';

  @override
  String get breedBoxer => 'Boxer';

  @override
  String get breedDachshund => 'Dachshund';

  @override
  String get breedSiberianHusky => 'Husky Siberian';

  @override
  String get breedChihuahua => 'Chihuahua';

  @override
  String get breedShihTzu => 'Shih Tzu';

  @override
  String get breedDobermanPinscher => 'Doberman Pinscher';

  @override
  String get breedGreatDane => 'Dog German';

  @override
  String get breedPomeranian => 'Pomeranian';

  @override
  String get breedBorderCollie => 'Border Collie';

  @override
  String get breedCockerSpaniel => 'Cocker Spaniel';

  @override
  String get breedMaltese => 'Maltese';

  @override
  String get breedMixedBreed => 'Rasă Mixtă';

  @override
  String get breedPersian => 'Persan';

  @override
  String get breedMaineCoon => 'Maine Coon';

  @override
  String get breedSiamese => 'Siamez';

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
  String get breedAbyssinian => 'Abissinian';

  @override
  String get breedAmericanShorthair => 'American Shorthair';

  @override
  String get breedBirman => 'Birman';

  @override
  String get breedNorwegianForest => 'Pădure Norvegiană';

  @override
  String get breedDomesticShorthair => 'Domestic Shorthair';

  @override
  String get breedParakeet => 'Perușă';

  @override
  String get breedCockatiel => 'Nimfă';

  @override
  String get breedCanary => 'Canar';

  @override
  String get breedParrot => 'Papagal';

  @override
  String get breedLovebird => 'Agapornis';

  @override
  String get breedFinch => 'Pintene';

  @override
  String get breedCockatoo => 'Cacadu';

  @override
  String get breedMacaw => 'Ara';

  @override
  String get breedConure => 'Conure';

  @override
  String get breedAfricanGrey => 'Jako';

  @override
  String get breedHollandLop => 'Holland Lop';

  @override
  String get breedNetherlandDwarf => 'Pitic Olandez';

  @override
  String get breedMiniRex => 'Mini Rex';

  @override
  String get breedLionhead => 'Cap de Leu';

  @override
  String get breedFlemishGiant => 'Gigant Flamand';

  @override
  String get breedEnglishAngora => 'Angora Englezesc';

  @override
  String get breedDutch => 'Olandez';

  @override
  String get breedOther => 'Altul (Personalizat)';

  @override
  String get customBreed => 'Rasă Personalizată';

  @override
  String get enterCustomBreed => 'Introduceți rasa animalului';

  @override
  String get birthdayOptional => 'Zi de naștere (opțional)';

  @override
  String get tapToSelectBirthday => 'Atingeți pentru a selecta ziua de naștere';

  @override
  String get selectPetBirthday => 'Selectați ziua de naștere a animalului';

  @override
  String get notesOptional => 'Notițe (opțional)';

  @override
  String get petNotesHint => 'Notițe speciale despre animalul dumneavoastră';

  @override
  String get speciesDog => 'Câine';

  @override
  String get speciesCat => 'Pisică';

  @override
  String get speciesBird => 'Pasăre';

  @override
  String get speciesRabbit => 'Iepure';

  @override
  String get speciesHamster => 'Hamster';

  @override
  String get speciesGuineaPig => 'Cobai';

  @override
  String get speciesFish => 'Pește';

  @override
  String get speciesTurtle => 'Broască țestoasă';

  @override
  String get speciesLizard => 'Șopârlă';

  @override
  String get speciesSnake => 'Șarpe';

  @override
  String get speciesFerret => 'Dihor';

  @override
  String get speciesChinchilla => 'Chinchilla';

  @override
  String get speciesRat => 'Șobolan';

  @override
  String get speciesMouse => 'Șoarece';

  @override
  String get speciesGerbil => 'Gerbil';

  @override
  String get speciesHedgehog => 'Arici';

  @override
  String get speciesParrot => 'Papagal';

  @override
  String get speciesHorse => 'Cal';

  @override
  String get speciesChicken => 'Găină';

  @override
  String get speciesOther => 'Altul (Personalizat)';

  @override
  String get customSpecies => 'Specie Personalizată';

  @override
  String get enterCustomSpecies => 'Introduceți specia animalului';

  @override
  String get changePhoto => 'Schimbă fotografia';

  @override
  String get saveProfile => 'Salvează profilul';

  @override
  String get updateProfile => 'Actualizează profilul';

  @override
  String get allProfiles => 'Toate Profilele';

  @override
  String get activeProfile => 'ACTIV';

  @override
  String get noPetsYet => 'Niciun animal încă!';

  @override
  String get addYourFirstPet => 'Adaugă primul tău animal pentru a începe';

  @override
  String get makeActive => 'Marchează ca Activ';

  @override
  String get deleteProfile => 'Șterge Profil';

  @override
  String deleteProfileConfirm(String petName) {
    return 'Sigur doriți să ștergeți profilul lui $petName? Această acțiune nu poate fi anulată.';
  }

  @override
  String profileDeleted(String petName) {
    return 'Profilul lui $petName a fost șters';
  }

  @override
  String get failedToDeleteProfile => 'Ștergerea profilului a eșuat';

  @override
  String nowActive(String petName) {
    return '$petName este acum animalul tău activ';
  }

  @override
  String failedToActivateProfile(String error) {
    return 'Activarea profilului a eșuat: $error';
  }

  @override
  String get errorLoadingProfiles => 'Eroare la încărcarea profilelelor';

  @override
  String yearsOld(int age, String plural) {
    return '$age an$plural';
  }

  @override
  String get settings => 'Setări';

  @override
  String get accountSettings => 'Setări Cont';

  @override
  String get language => 'Limbă';

  @override
  String get english => 'English';

  @override
  String get romanian => 'Română';

  @override
  String get appPreferences => 'Preferințe Aplicație';

  @override
  String get theme => 'Temă';

  @override
  String get light => 'Luminos';

  @override
  String get dark => 'Întunecat';

  @override
  String get system => 'Sistem';

  @override
  String get notifications => 'Notificări';

  @override
  String get enableNotifications => 'Activează notificările aplicației';

  @override
  String get enableAnalytics => 'Activează analiza';

  @override
  String get helpImproveApp => 'Ajută la îmbunătățirea aplicației';

  @override
  String get dataManagement => 'Gestionare Date';

  @override
  String get exportData => 'Exportă datele';

  @override
  String get downloadYourData => 'Descarcă datele tale';

  @override
  String get clearCache => 'Șterge memoria cache';

  @override
  String get freeUpSpace => 'Eliberează spațiu de stocare';

  @override
  String get deleteAccount => 'Șterge contul';

  @override
  String get deleteAccountPermanently => 'Șterge definitiv contul tău';

  @override
  String get privacyAndLegal => 'Confidențialitate și Legal';

  @override
  String get privacyPolicy => 'Politica de confidențialitate';

  @override
  String get termsOfService => 'Termeni și condiții';

  @override
  String get openSourceLicenses => 'Licențe open source';

  @override
  String get couldNotOpenLink => 'Nu s-a putut deschide linkul';

  @override
  String get about => 'Despre';

  @override
  String get appVersion => 'Versiunea aplicației';

  @override
  String get petOwner => 'Proprietar Animal';

  @override
  String get selectLanguage => 'Selectează Limba';

  @override
  String get selectTheme => 'Selectează Tema';

  @override
  String get clearCacheConfirm =>
      'Sigur doriți să ștergeți memoria cache? Această acțiune nu poate fi anulată.';

  @override
  String get cacheCleared => 'Memoria cache a fost ștearsă cu succes';

  @override
  String get deleteAccountConfirm =>
      'Sigur doriți să ștergeți contul? Această acțiune este permanentă și nu poate fi anulată. Toate datele tale vor fi pierdute.';

  @override
  String get featureComingSoon => 'Funcționalitate în curând';

  @override
  String get noReportsFound => 'Niciun raport găsit';

  @override
  String get noHealthReportsFound => 'Niciun raport medical găsit';

  @override
  String get noMedicationReportsFound => 'Niciun raport de medicație găsit';

  @override
  String get noActivityReportsFound => 'Niciun raport de activitate găsit';

  @override
  String get noReportsMatchSearch => 'Niciun raport nu se potrivește căutării';

  @override
  String get errorLoadingReports => 'Eroare la încărcarea rapoartelor';

  @override
  String get overdue => 'Întârziat';

  @override
  String get justNow => 'Chiar acum';

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zile în urmă',
      one: '1 zi în urmă',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore în urmă',
      one: '1 oră în urmă',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minute în urmă',
      one: '1 minut în urmă',
    );
    return '$_temp0';
  }

  @override
  String get done => 'Terminat';

  @override
  String get markPending => 'Marchează ca În așteptare';

  @override
  String get markCompleted => 'Marchează ca Finalizat';

  @override
  String get daysUntil => 'În';

  @override
  String get started => 'A început';

  @override
  String get ends => 'Se termină';

  @override
  String get reminders => 'Memento-uri';

  @override
  String get addReminder => 'Adaugă Memento';

  @override
  String get editReminder => 'Editează Memento';

  @override
  String get reminderType => 'Tip Memento';

  @override
  String get reminderTitle => 'Titlu';

  @override
  String get reminderDescription => 'Descriere';

  @override
  String get scheduledTime => 'Ora Programată';

  @override
  String get once => 'O singură dată';

  @override
  String get daily => 'Zilnic';

  @override
  String get twiceDaily => 'De două ori pe zi';

  @override
  String get weekly => 'Săptămânal';

  @override
  String get custom => 'Personalizat';

  @override
  String get activeReminders => 'Memento-uri Active';

  @override
  String get noReminders => 'Niciun memento setat';

  @override
  String get noRemindersDescription =>
      'Adaugă memento-uri pentru a nu uita sarcini importante de îngrijire';

  @override
  String get setReminder => 'Setează Memento';

  @override
  String get oneDayBefore => 'Cu o zi înainte';

  @override
  String get oneHourBefore => 'Cu o oră înainte';

  @override
  String get thirtyMinutesBefore => 'Cu 30 de minute înainte';

  @override
  String get reminderSet => 'Memento setat cu succes';

  @override
  String get remindDaily => 'Reamintește zilnic';

  @override
  String get remindAllDoses => 'Reamintește toate dozele';

  @override
  String get remindOnce => 'Reamintește o dată';

  @override
  String get firstDose => 'Prima doză';

  @override
  String get customTime => 'Timp personalizat';

  @override
  String get timesDaily => 'ori pe zi';

  @override
  String remindersCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au creat $count memento-uri',
      one: 'S-a creat 1 memento',
    );
    return '$_temp0';
  }

  @override
  String get view => 'Vizualizare';

  @override
  String get reminderDeleted => 'Memento șters';

  @override
  String nextReminder(String time) {
    return 'Următor: $time';
  }

  @override
  String get medicationReminder => 'Memento Medicament';

  @override
  String get appointmentReminder => 'Memento Programare';

  @override
  String get feedingReminder => 'Memento Hrănire';

  @override
  String get walkReminder => 'Memento Plimbare';

  @override
  String get remindMeAt => 'Amintește-mi la';

  @override
  String get remind1DayBefore => 'Amintește cu 1 zi înainte';

  @override
  String get remind1HourBefore => 'Amintește cu 1 oră înainte';

  @override
  String get selectDays => 'Selectează Zilele';

  @override
  String get selectTime => 'Selectează Ora';

  @override
  String get reminderUpdated => 'Memento actualizat cu succes';

  @override
  String get reminderAdded => 'Memento adăugat cu succes';

  @override
  String get pleaseEnterTitle => 'Introduceți un titlu';

  @override
  String get failedToCreateReminder => 'Eroare la crearea memento-ului';

  @override
  String get failedToUpdateReminder => 'Eroare la actualizarea memento-ului';

  @override
  String get failedToDeleteReminder => 'Eroare la ștergerea memento-ului';

  @override
  String get deleteReminder => 'Șterge Memento';

  @override
  String get deleteReminderConfirm => 'Sigur doriți să ștergeți acest memento?';

  @override
  String get noActiveReminders => 'Niciun memento activ';

  @override
  String get noInactiveReminders => 'Niciun memento inactiv';

  @override
  String get linkToEntity => 'Leagă la element existent';

  @override
  String get customSchedule => 'Program Personalizat';

  @override
  String get repeatOn => 'Repetă în';

  @override
  String get monday => 'Luni';

  @override
  String get tuesday => 'Marți';

  @override
  String get wednesday => 'Miercuri';

  @override
  String get thursday => 'Joi';

  @override
  String get friday => 'Vineri';

  @override
  String get saturday => 'Sâmbătă';

  @override
  String get sunday => 'Duminică';

  @override
  String get weightTracking => 'Urmărirea Greutății';

  @override
  String get addWeight => 'Adaugă Greutate';

  @override
  String get editWeight => 'Editează Greutatea';

  @override
  String get deleteWeight => 'Șterge Greutatea';

  @override
  String get deleteWeightConfirm =>
      'Sigur doriți să ștergeți această înregistrare de greutate?';

  @override
  String get weightDeleted => 'Înregistrarea greutății a fost ștearsă';

  @override
  String get currentWeight => 'Greutatea Curentă';

  @override
  String get weight => 'Greutate';

  @override
  String get weightTrend => 'Tendință Greutate';

  @override
  String get history => 'Istoric';

  @override
  String get noWeightEntries => 'Nu există înregistrări de greutate';

  @override
  String get addWeightToTrack =>
      'Începeți să urmăriți greutatea animalului pentru a monitoriza sănătatea în timp';

  @override
  String get pleaseEnterWeight => 'Vă rugăm să introduceți greutatea';

  @override
  String get pleaseEnterValidWeight =>
      'Vă rugăm să introduceți o greutate validă';

  @override
  String get weightAdded => 'Înregistrarea greutății a fost adăugată';

  @override
  String get weightUpdated => 'Înregistrarea greutății a fost actualizată';

  @override
  String get aboutWeightTracking => 'Despre Urmărirea Greutății';

  @override
  String get weightTrackingInfo =>
      'Monitorizarea regulată a greutății ajută la detectarea problemelor de sănătate timpuriu. Urmăriți greutatea animalului în momente consistente (cum ar fi cântăriri săptămânale) pentru cele mai precise tendințe.';

  @override
  String get optionalNotes =>
      'Opțional: Adăugați notițe despre dietă, activitate sau sănătate';

  @override
  String get info => 'Info';

  @override
  String get photoGallery => 'Galerie Foto';

  @override
  String get addPhoto => 'Adaugă Fotografie';

  @override
  String get takePhoto => 'Fă o Poză';

  @override
  String get chooseFromGallery => 'Alege din Galerie';

  @override
  String get chooseMultiplePhotos => 'Selectează Mai Multe Fotografii';

  @override
  String get deletePhoto => 'Șterge Fotografia';

  @override
  String get deletePhotoConfirm =>
      'Sigur doriți să ștergeți această fotografie? Această acțiune nu poate fi anulată.';

  @override
  String get photoDeleted => 'Fotografia a fost ștearsă';

  @override
  String get editCaption => 'Editează Descrierea';

  @override
  String get caption => 'Descriere';

  @override
  String get addCaption => 'Adaugă o descriere...';

  @override
  String get noCaption => 'Fără descriere';

  @override
  String get captionSaved => 'Descrierea a fost salvată';

  @override
  String get noPhotos => 'Nu există fotografii';

  @override
  String get addFirstPhoto => 'Adaugă prima fotografie pentru a crea amintiri';

  @override
  String get photoAdded => 'Fotografia a fost adăugată cu succes';

  @override
  String photosAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotografii adăugate',
      one: '1 fotografie adăugată',
    );
    return '$_temp0';
  }

  @override
  String get processingPhotos => 'Se procesează fotografiile...';

  @override
  String get cameraPermissionDenied =>
      'Permisiunea camerei este necesară pentru a face fotografii';

  @override
  String get storagePermissionDenied =>
      'Permisiunea de stocare este necesară pentru a accesa fotografiile';

  @override
  String get galleryPermissionDenied =>
      'Permisiunea galeriei este necesară pentru a selecta fotografii';

  @override
  String get permissionDenied => 'Permisiune Refuzată';

  @override
  String get openSettings => 'Deschide Setările';

  @override
  String get storageUsed => 'Spațiu Utilizat';

  @override
  String get photos => 'Fotografii';

  @override
  String get dateTaken => 'Data Pozei';

  @override
  String get dateAdded => 'Data Adăugării';

  @override
  String get fileSize => 'Dimensiune Fișier';

  @override
  String get photoDetails => 'Detalii Fotografie';

  @override
  String get photo => 'Fotografie';

  @override
  String get share => 'Distribuie';

  @override
  String get setProfilePhoto => 'Setează ca Fotografie de Profil';

  @override
  String setProfilePhotoConfirm(String petName) {
    return 'Setezi această fotografie ca fotografie de profil pentru $petName?';
  }

  @override
  String get confirm => 'Confirmă';

  @override
  String get profilePhotoUpdated => 'Fotografia de profil a fost actualizată!';

  @override
  String get photoNotFound => 'Fotografia nu a fost găsită';

  @override
  String get medicationInventory => 'Inventar Medicamente';

  @override
  String get lowStock => 'Stoc Scăzut';

  @override
  String get allMedications => 'Toate Medicamentele';

  @override
  String get statistics => 'Statistici';

  @override
  String get stockQuantity => 'Cantitate Stoc';

  @override
  String get stockUnit => 'Unitate Stoc';

  @override
  String get lowStockThreshold => 'Alertă Stoc Scăzut';

  @override
  String get costPerUnit => 'Cost per Unitate';

  @override
  String get addRefill => 'Adaugă Reumplere';

  @override
  String get recordPurchase => 'Înregistrează Achiziție';

  @override
  String get purchaseHistory => 'Istoric Achiziții';

  @override
  String get quantityPurchased => 'Cantitate Achiziționată';

  @override
  String get purchaseDate => 'Data Achiziției';

  @override
  String get pharmacy => 'Farmacie';

  @override
  String get totalSpent => 'Total Cheltuit';

  @override
  String get averageCostPerUnit => 'Cost Mediu per Unitate';

  @override
  String get daysUntilEmpty => 'Zile Până la Epuizare';

  @override
  String pillsLeft(String count, String unit) {
    return '$count $unit rămase';
  }

  @override
  String get lowStockAlert => 'Alertă Stoc Scăzut';

  @override
  String refillReminder(String medication) {
    return 'Este timpul să reumpli $medication';
  }

  @override
  String get markAsGiven => 'Marchează ca Administrat';

  @override
  String get addStock => 'Adaugă Stoc';

  @override
  String get noPurchases => 'Nicio achiziție înregistrată';

  @override
  String get purchaseAdded => 'Achiziție înregistrată';

  @override
  String get stockUpdated => 'Stoc actualizat';

  @override
  String get costPerMonth => 'Cost pe Lună';

  @override
  String get lastPurchase => 'Ultima Achiziție';

  @override
  String get inventoryTracking => 'Urmărire Inventar';

  @override
  String get enableRefillReminders => 'Activează Mementouri Reumplere';

  @override
  String get refillReminderDays => 'Amintește-mi cu X zile înainte';

  @override
  String get pills => 'pastile';

  @override
  String get ml => 'ml';

  @override
  String get doses => 'doze';

  @override
  String get tablets => 'tablete';

  @override
  String lowStockAlertBody(String count, String unit, String medication) {
    return 'Doar $count $unit rămase pentru $medication';
  }

  @override
  String get refillSoon => 'Reumple Curând';

  @override
  String get notTracked => 'Neurmărit';

  @override
  String get initialStock => 'Stoc Inițial';

  @override
  String get daysBeforeEmpty => 'Zile înainte de epuizare';

  @override
  String get inventoryOverview => 'Privire de Ansamblu Inventar';

  @override
  String get totalCost => 'Cost Total';

  @override
  String get averageMonthlyCost => 'Cost Mediu Lunar';

  @override
  String get medicationsTracked => 'Medicamente Urmărite';

  @override
  String get totalPurchases => 'Total Achiziții';

  @override
  String get viewHistory => 'Vezi Istoric';

  @override
  String get editPurchase => 'Editează Achiziție';

  @override
  String get deletePurchase => 'Șterge Achiziție';

  @override
  String get deletePurchaseConfirm =>
      'Sigur doriți să ștergeți această înregistrare de achiziție?';

  @override
  String get purchaseDeletedSuccessfully => 'Achiziție ștearsă cu succes';

  @override
  String get failedToDeletePurchase => 'Eșec la ștergerea achiziției';

  @override
  String get invalidQuantity => 'Vă rugăm introduceți o cantitate validă';

  @override
  String get invalidCost => 'Vă rugăm introduceți un cost valid';

  @override
  String get cost => 'Cost';

  @override
  String get quantity => 'Cantitate';

  @override
  String get stockLevel => 'Nivel Stoc';

  @override
  String get sufficient => 'Suficient';

  @override
  String get critical => 'Critic';

  @override
  String get refillNow => 'Reumple Acum';

  @override
  String get viewInventory => 'Vezi Inventar';

  @override
  String get noMedicationsTracked => 'Niciun medicament urmărit';

  @override
  String get noLowStockMedications => 'Niciun medicament cu stoc scăzut';

  @override
  String get totalSpentThisMonth => 'Total Cheltuit Luna Aceasta';

  @override
  String get totalSpentAllTime => 'Total Cheltuit Vreodată';

  @override
  String get allPurchases => 'Toate achizițiile';

  @override
  String get averageCostPerMedication => 'Cost Mediu per Medicament';

  @override
  String get perMedication => 'Per medicament';

  @override
  String get topExpensiveMedications => 'Top 5 Cele Mai Scumpe Medicamente';

  @override
  String get stockNotTracked => 'Stoc neurmărit';

  @override
  String get refill => 'Reumple';

  @override
  String get notTrackedEnum => 'Neurmărit';

  @override
  String get veterinarians => 'Veterinari';

  @override
  String get addVet => 'Adaugă Veterinar';

  @override
  String get editVet => 'Editează Veterinar';

  @override
  String get vetDetails => 'Detalii Veterinar';

  @override
  String get vetName => 'Nume Veterinar';

  @override
  String get clinicName => 'Nume Clinică';

  @override
  String get specialty => 'Specialitate';

  @override
  String get phoneNumber => 'Număr Telefon';

  @override
  String get email => 'Email';

  @override
  String get address => 'Adresă';

  @override
  String get website => 'Website';

  @override
  String get setAsPreferred => 'Setează ca Veterinar Preferat';

  @override
  String get preferredVet => 'Veterinar Preferat';

  @override
  String get generalPractice => 'Medicină Generală';

  @override
  String get emergencyMedicine => 'Medicină de Urgență';

  @override
  String get cardiology => 'Cardiologie';

  @override
  String get dermatology => 'Dermatologie';

  @override
  String get surgery => 'Chirurgie';

  @override
  String get orthopedics => 'Ortopedie';

  @override
  String get oncology => 'Oncologie';

  @override
  String get ophthalmology => 'Oftalmologie';

  @override
  String get callVet => 'Sună Veterinarul';

  @override
  String get emailVet => 'Trimite Email Veterinarului';

  @override
  String get openWebsite => 'Deschide Website';

  @override
  String get lastVisit => 'Ultima Vizită';

  @override
  String get totalAppointments => 'Total Programări';

  @override
  String get recentAppointments => 'Programări Recente';

  @override
  String get noVetsAdded => 'Niciun veterinar adăugat';

  @override
  String get addFirstVet =>
      'Adaugă veterinarul animalului tău pentru a urmări vizitele și informațiile de contact';

  @override
  String get deleteVet => 'Șterge Veterinar';

  @override
  String get deleteVetConfirm =>
      'Sigur vrei să ștergi acest veterinar? Acest lucru nu va afecta programările existente.';

  @override
  String get vetDeleted => 'Veterinar șters';

  @override
  String get vetAdded => 'Veterinar adăugat';

  @override
  String get vetUpdated => 'Veterinar actualizat';

  @override
  String get selectVet => 'Selectează Veterinar';

  @override
  String get addNewVet => 'Adaugă Veterinar Nou';

  @override
  String get invalidPhone => 'Număr de telefon invalid';

  @override
  String get invalidEmail => 'Adresă de email invalidă';

  @override
  String get invalidWebsite => 'URL website invalid';

  @override
  String get vetNameRequired => 'Numele veterinarului este obligatoriu';

  @override
  String get clinicNameRequired => 'Numele clinicii este obligatoriu';

  @override
  String get searchVets => 'Caută veterinari...';

  @override
  String get noVetsFound => 'Niciun veterinar găsit';

  @override
  String get noVetsMatchSearch => 'Niciun veterinar nu corespunde căutării';

  @override
  String get contactInformation => 'Informații de Contact';

  @override
  String get vetNotFound => 'Veterinar negăsit';

  @override
  String get alreadyPreferred => 'Acesta este deja veterinarul preferat';

  @override
  String get errorOccurred => 'Eroare';

  @override
  String get petManagement => 'Gestionarea animalelor de companie';

  @override
  String get viewHealthScoresAndMetrics =>
      'Vizualizați scorurile de sănătate și indicatorii de activitate';

  @override
  String get manageVeterinariansAndClinics =>
      'Gestionarea medicilor veterinari și a clinicilor';

  @override
  String get viewAndManagePetPhotos =>
      'Vizualizați și gestionați fotografiile animalelor de companie';

  @override
  String get trackMedicationStockLevels =>
      'Urmăriți nivelurile stocurilor de medicamente';

  @override
  String get reportsAndAnalytics => 'Rapoarte & Analize';

  @override
  String get healthScore => 'Scor Sănătate';

  @override
  String get medicationAdherence => 'Respectarea Medicamentelor';

  @override
  String get activityLevels => 'Niveluri Activitate';

  @override
  String get expenseTracking => 'Urmărire Cheltuieli';

  @override
  String get stable => 'Stabil';

  @override
  String get gaining => 'Câștig';

  @override
  String get losing => 'Pierdere';

  @override
  String get totalExpenses => 'Cheltuieli Totale';

  @override
  String get averageWeeklyExpenses => 'Cheltuieli Medii Săptămânale';

  @override
  String get expenseBreakdown => 'Detaliere Cheltuieli';

  @override
  String get reportPeriod => 'Perioada Raport';

  @override
  String get last90Days => 'Ultimele 90 Zile';

  @override
  String get customRange => 'Interval Personalizat';

  @override
  String get healthMetrics => 'Metrici Sănătate';

  @override
  String get activityMetrics => 'Metrici Activitate';

  @override
  String get dailyActivityAverage => 'Media activităților zilnice';

  @override
  String get feedingsPerDay => 'Hrăniri/zi';

  @override
  String get walksPerDay => 'Plimbări/zi';

  @override
  String get expenseMetrics => 'Metrici Cheltuieli';

  @override
  String get overview => 'Prezentare Generală';

  @override
  String get activityHigh => 'Ridicat';

  @override
  String get activityMedium => 'Mediu';

  @override
  String get activityLow => 'Scăzut';

  @override
  String get exportToPDF => 'Exportă în PDF';

  @override
  String get shareReport => 'Partajează Raport';

  @override
  String get exportOptions => 'Opțiuni Export';

  @override
  String get fullReport => 'Raport Complet';

  @override
  String get fullReportDescription =>
      'Raport complet de sănătate cu toate metricile';

  @override
  String get vetSummary => 'Rezumat pentru Veterinar';

  @override
  String get vetSummaryDescription =>
      'Rezumat ultimele 30 zile pentru vizită veterinar';

  @override
  String get shareText => 'Partajează Rezumat Text';

  @override
  String get shareTextDescription => 'Partajează ca mesaj text';

  @override
  String get reportGenerated => 'Raport generat cu succes';

  @override
  String get reportExported => 'Raport salvat pe dispozitiv';

  @override
  String get generatingReport => 'Generare raport...';

  @override
  String get exportingReport => 'Exportare raport...';

  @override
  String get sharingReport => 'Partajare raport...';

  @override
  String reportSaved(String path) {
    return 'Raport salvat în: $path';
  }

  @override
  String failedToGeneratePDF(String error) {
    return 'Eroare la generarea PDF: $error';
  }

  @override
  String get failedToExportReport => 'Eroare la exportul raportului';

  @override
  String get failedToShareReport => 'Eroare la partajarea raportului';

  @override
  String get recommendations => 'Recomandări';

  @override
  String get noDataAvailable =>
      'Nu sunt date disponibile pentru această perioadă';

  @override
  String get insufficientData => 'Date insuficiente pentru analiză';

  @override
  String get expensesByCategory => 'Cheltuieli pe Categorii';

  @override
  String get averageMonthly => 'Medie Lunară';

  @override
  String get topCategories => 'Categorii Principale';

  @override
  String get dismissRecommendation => 'Respinge';

  @override
  String get reportingPeriod => 'Perioada Raportului';

  @override
  String get dataInsights => 'Informații din Date';

  @override
  String get noRecommendations => 'Nu sunt recomandări disponibile';

  @override
  String get healthScoreExcellent => 'Excelent';

  @override
  String get healthScoreGood => 'Bun';

  @override
  String get healthScoreFair => 'Satisfăcător';

  @override
  String get healthScoreLow => 'Scăzut';

  @override
  String get activityLevel => 'Nivel de Activitate';

  @override
  String get expenseTrend => 'Tendință Cheltuieli';

  @override
  String get trendIncreasing => 'În Creștere';

  @override
  String get trendDecreasing => 'În Scădere';

  @override
  String get trendStable => 'Stabil';

  @override
  String get monthlyExpenses => 'Cheltuieli lunare';

  @override
  String get average => 'Medie';

  @override
  String get highest => 'Cel mai înalt';

  @override
  String get excellentRange => 'Excelent (80+)';

  @override
  String get goodRange => 'Bun (60-79)';

  @override
  String get fairRange => 'Satisfăcător (40-59)';

  @override
  String get lowRange => 'Scăzut (<40)';

  @override
  String get recSetMedicationReminders =>
      'Setați mai multe mementouri pentru medicamente pentru a îmbunătăți respectarea';

  @override
  String get recConsiderVetWeightGain =>
      'Luați în considerare consultarea unui medic veterinar în legătură cu creșterea în greutate';

  @override
  String get recConsiderVetWeightLoss =>
      'Luați în considerare consultarea unui medic veterinar în legătură cu pierderea în greutate';

  @override
  String get recIncreaseDailyWalks =>
      'Creșteți numărul plimbărilor zilnice pentru o sănătate mai bună';

  @override
  String get recReviewMedicationCosts =>
      'Revedeți costurile medicamentelor cu medicul veterinar';

  @override
  String get recScheduleVetCheckup =>
      'Scorul de sănătate este scăzut - programați un control veterinar';

  @override
  String get healthScoreDescription =>
      'Pe baza stabilității greutății, a respectării tratamentului medicamentos și a nivelului de activitate';

  @override
  String get pdfPetHealthReport =>
      'Raport privind starea de sănătate a animalului de companie';

  @override
  String get pdfPetInformation => 'Informații despre animalul de companie';

  @override
  String get pdfName => 'Nume';

  @override
  String get pdfSpecies => 'Specie';

  @override
  String get pdfBreed => 'Rasă';

  @override
  String get pdfAge => 'Vârstă';

  @override
  String get pdfYears => 'ani';

  @override
  String get pdfCat => 'Pisică';

  @override
  String get pdfDog => 'Câine';

  @override
  String get pdfUnknown => 'Necunoscut';

  @override
  String get pdfReportPeriod => 'Perioada raportului';

  @override
  String get pdfFrom => 'De la';

  @override
  String get pdfTo => 'Până la';

  @override
  String get pdfHealthMetrics => 'Indicatori de sănătate';

  @override
  String get pdfOverallHealthScore => 'Scorul general de sănătate';

  @override
  String get pdfMedicationAdherence => 'Aderarea la medicație';

  @override
  String get pdfWeightTrend => 'Tendința greutății';

  @override
  String get pdfStable => 'Stabilă';

  @override
  String get pdfGaining => 'Câștig';

  @override
  String get pdfLosing => 'Pierdere';

  @override
  String get pdfActivitySummary => 'Rezumat activitate';

  @override
  String get pdfTotalFeedings => 'Total hrăniri';

  @override
  String get pdfTotalWalks => 'Total plimbări';

  @override
  String get pdfAvgFeedingsPerDay => 'Media hrăniri/zi';

  @override
  String get pdfAvgWalksPerDay => 'Media plimbări/zi';

  @override
  String get pdfExpenses => 'Cheltuieli';

  @override
  String get pdfTotalExpenses => 'Cheltuieli totale';

  @override
  String get pdfGeneratedOn => 'Generat la';

  @override
  String get pdfFooter =>
      'FurFriend Diary - Gestionarea sănătății animalului de companie';

  @override
  String get pdfVeterinarySummary => 'Rezumat veterinar';

  @override
  String get pdfLast30DaysSummary => 'Rezumat ultimele 30 de zile';

  @override
  String get pdfHealthStatus => 'Starea de sănătate';

  @override
  String get pdfHealthScore => 'Scorul de sănătate';

  @override
  String get pdfMedicationCompliance => 'Conformitatea cu medicația';

  @override
  String get pdfActivityOverview => 'Prezentare generală a activității';

  @override
  String get pdfDailyFeedingsAvg => 'Hrăniri zilnice (medie)';

  @override
  String get pdfDailyWalksAvg => 'Plimbări zilnice (medie)';

  @override
  String get pdfNotes => 'Note';

  @override
  String get pdfNotesText =>
      'Vă rugăm să revizuiți datele de sănătate atașate și să discutați orice preocupări în timpul programării.';

  @override
  String get emailSubject => 'Raport Sănătate Animale';

  @override
  String get emailBody =>
      'Acesta este raportul de sănătate pentru animalul meu.';

  @override
  String get vetSummaryEmailSubject => 'Rezumat Veterinar';

  @override
  String get vetSummaryEmailBody =>
      'Acesta este rezumatul veterinar pentru animalul meu.';

  @override
  String get textSummaryEmailSubject => 'Rezumat Sănătate Animale';

  @override
  String get navFeedings => 'Hrănire';

  @override
  String get navWalks => 'Plimbări';

  @override
  String get navMeds => 'Med.';

  @override
  String get navAppts => 'Prog.';

  @override
  String get navReports => 'Rapoarte';

  @override
  String get navSettings => 'Setări';

  @override
  String medicationReminderBody(String medication, String frequency) {
    return '$medication - $frequency';
  }

  @override
  String get criticalLowStockAlert => 'Critic: Alertă stoc redus';

  @override
  String lowStockBody(int count, String unit) {
    return 'Mai sunt doar $count $unit. E timpul să reumpleți stocul!';
  }

  @override
  String appointmentAt(String title, String location) {
    return '$title la $location';
  }
}
