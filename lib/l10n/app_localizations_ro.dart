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
  String get dosage => 'Dozaj *';

  @override
  String get dosageHint => 'de ex., 5mg, 1 tabletă, 2ml';

  @override
  String get pleaseEnterDosage => 'Vă rugăm să introduceți dozajul';

  @override
  String get frequency => 'Frecvență *';

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
  String get administrationTimes => 'Orele de Administrare';

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
      'Adăugați notițe, instrucțiuni sau mementouri suplimentare...';

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
}
