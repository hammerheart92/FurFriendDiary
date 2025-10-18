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
  String get reason => 'Motiv';

  @override
  String get reasonHint => 'de ex., Control, Vaccinare, Operație';

  @override
  String get pleaseEnterReason => 'Vă rugăm să introduceți motivul programării';

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
  String get total => 'total';

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
  String get totalFeedings => 'Total Hrăniri';

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
  String get last7Days => 'Ultimele 7 zile';

  @override
  String get last30Days => 'Ultimele 30 zile';

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
  String get premium => 'Premium';

  @override
  String get upgradeToUnlock =>
      'Actualizează pentru a debloca funcțiile avansate';

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
  String get reminderSet => 'Memento setat cu succes';

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
  String get medicationReminder => 'Memento Medicație';

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
  String get weightTrend => 'Tendința Greutății';

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
}
