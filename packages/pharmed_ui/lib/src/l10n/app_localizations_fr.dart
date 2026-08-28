// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get common_selectCellTitle => 'Sélectionner une case';

  @override
  String get common_noAssignmentBadge => 'Non attribué';

  @override
  String get common_drugAssignedBadge => 'Médicament attribué';

  @override
  String get common_patientAssignedBadge => 'Patient attribué';

  @override
  String get common_noCabinDataTitle => 'Aucune donnée de cabine trouvée';

  @override
  String get common_noCabinDataDescription =>
      'La cabine n\'est peut-être pas encore configurée\nou la connexion n\'a pas pu être établie.';

  @override
  String get common_noResultsTitle => 'Aucun résultat trouvé';

  @override
  String get common_noResultsDescription =>
      'Essayez de modifier vos critères de recherche.';

  @override
  String get common_retryButton => 'Réessayer';

  @override
  String get common_completeButton => 'Terminer';

  @override
  String get common_cancelButton => 'Annuler';

  @override
  String get common_barcodeLabel => 'Code-barres';

  @override
  String get common_pageNotFound => 'Page introuvable';

  @override
  String get common_minLabel => 'Min';

  @override
  String get common_maxLabel => 'Max';

  @override
  String get common_criticalLabel => 'Critique';

  @override
  String get common_boolYes => 'Oui';

  @override
  String get common_boolNo => 'Non';

  @override
  String get common_action_discharge => 'Sortie du patient';

  @override
  String get auth_loginSubtitle => 'Connectez-vous au système';

  @override
  String get auth_emailLabel => 'E-mail / Nom d\'utilisateur';

  @override
  String get auth_passwordLabel => 'Mot de passe';

  @override
  String get auth_loginButton => 'Se connecter';

  @override
  String get auth_genericError => 'Une erreur s\'est produite';

  @override
  String get dashboard_appBarTitle => 'GESTION DES ARMOIRES À MÉDICAMENTS';

  @override
  String get dashboard_logoutTooltip => 'Se déconnecter';

  @override
  String get dashboard_loginBarButton => 'Se connecter';

  @override
  String get dashboard_kpiActivePatients => 'Patients actifs';

  @override
  String get dashboard_kpiCompletedOps => 'Opérations terminées';

  @override
  String get dashboard_kpiPendingPrescriptions => 'Ordonnances en attente';

  @override
  String get dashboard_kpiCriticalAlerts => 'Alertes critiques';

  @override
  String get dashboard_cabinStatusHeader => 'ÉTAT DE LA CABINE';

  @override
  String get dashboard_cabinStatusLabel => 'État de la cabine';

  @override
  String get dashboard_kpiLoadError => 'Échec du chargement des données KPI';

  @override
  String get dashboard_cabinLoadError =>
      'Échec du chargement des données de la cabine';

  @override
  String get dashboard_treatmentsLoadError =>
      'Impossible de charger les traitements à venir';

  @override
  String get dashboard_sktLoadError =>
      'Échec du chargement des données de péremption';

  @override
  String get assignment_assignBedPlaceholder =>
      'Sélectionnez une case dans le\npanneau central pour attribuer un lit.';

  @override
  String get assignment_assignDrugPlaceholder =>
      'Sélectionnez une case dans le\npanneau central pour effectuer une attribution.';

  @override
  String get assignment_hospitalizationSectionLabel => 'PATIENT / ADMISSION';

  @override
  String get assignment_hospitalizationSelectorHint =>
      'Sélectionner une admission...';

  @override
  String get assignment_selectHospitalizationDialogTitle =>
      'Sélectionner une admission';

  @override
  String get assignment_drugSectionLabel => 'MÉDICAMENT';

  @override
  String get assignment_drugSelectorHint => 'Sélectionner un médicament...';

  @override
  String get assignment_selectDrugDialogTitle => 'Sélectionner un médicament';

  @override
  String get assignment_quantitySectionLabel => 'QUANTITÉ';

  @override
  String get assignment_saveAssignmentButton => 'Enregistrer l\'attribution';

  @override
  String get assignment_removeAssignmentButton => 'Supprimer l\'attribution';

  @override
  String get assignment_changeAssignmentButton => 'Modifier l\'attribution';

  @override
  String get assignment_roomBedLabel => 'Chambre / Lit';

  @override
  String get assignment_serviceLabel => 'Service';

  @override
  String get assignment_cellNotFoundError => 'Case sélectionnée introuvable';

  @override
  String get assignment_patientSavedSuccess =>
      'Attribution du patient enregistrée avec succès';

  @override
  String get assignment_patientRemovedSuccess =>
      'Attribution du patient supprimée';

  @override
  String get fault_selectCellPlaceholder =>
      'Sélectionnez une case dans le\npanneau central pour signaler une panne.';

  @override
  String get fault_descriptionSectionLabel => 'DESCRIPTION';

  @override
  String get fault_descriptionHint => 'Décrivez la panne...';

  @override
  String get fault_faultSegmentLabel => 'PANNE';

  @override
  String get fault_maintenanceSegmentLabel => 'MAINTENANCE';

  @override
  String get fault_historySectionLabel => 'HISTORIQUE';

  @override
  String get fault_historyStatusCompleted => 'Résolu';

  @override
  String get fault_historyStatusMaintenance => 'Maintenance';

  @override
  String get fault_historyStatusFault => 'Panne';

  @override
  String get fault_historyActiveBadge => 'Actif';

  @override
  String fault_activeFaultBanner(String label) {
    return 'Cette case a un enregistrement $label actif. La confirmation clôturera cet enregistrement.';
  }

  @override
  String get fault_reportFaultButton => 'Signaler une panne';

  @override
  String get fault_closeFaultButton => 'Clôturer l\'enregistrement';

  @override
  String get fault_recordCreatedSuccess => 'Enregistrement de panne créé.';

  @override
  String get fault_recordClosedSuccess => 'Enregistrement de panne clôturé.';

  @override
  String get cabin_mobileTypeLabel => 'MOBILE';

  @override
  String get cabin_mobileDrawerTitle => 'Tiroir mobile';

  @override
  String cabin_cellCountLabel(int count) {
    return '$count cases';
  }

  @override
  String get cabin_drawerStatsLabel => 'Tiroirs';

  @override
  String cabin_statsFullEmpty(int full, int empty) {
    return '$full pleins · $empty vides';
  }

  @override
  String get cabin_touchDrawerHint => 'Touchez un tiroir';

  @override
  String get cabin_mobileGridPlaceholder =>
      'La grille de cases de la cabine mobile sera affichée';

  @override
  String get cabin_masterGridPlaceholder =>
      'Les structures internes Cubique · Dose unitaire · Sérum seront affichées';

  @override
  String get cabin_kubikTypeLabel => 'CUBIQUE';

  @override
  String get cabin_serumDrawerName => 'Tiroir sérum';

  @override
  String get cabin_kubikDrawerName => 'Tiroir cubique';

  @override
  String get cabin_unitDoseDrawerName => 'Tiroir dose unitaire';

  @override
  String get cabin_serumRackView => 'Vue en rack';

  @override
  String get cabin_serumViewTitle => 'Vue sérum';

  @override
  String get cabin_serumViewTodo =>
      'À FAIRE : sera complété une fois la structure interne du sérum finalisée';

  @override
  String get cabin_openButton => 'Ouvrir';

  @override
  String get cabin_assignDrugButton => 'Attribuer un médicament';

  @override
  String get cabin_bannerPatientAssign =>
      'Attribution de patient — attribuez un patient / une admission aux cases.';

  @override
  String get cabin_bannerDrugAssign =>
      'Attribution de médicament — attribuez des médicaments aux cases, définissez les valeurs min/max/critique.';

  @override
  String get cabin_bannerDrugFill =>
      'Remplissage de médicament — touchez la case à remplir, saisissez la quantité.';

  @override
  String get cabin_bannerDrugCount =>
      'Comptage de stock — saisissez la quantité réelle, le système calculera la différence.';

  @override
  String get cabin_bannerFault =>
      'Panne — marquez la case défectueuse et saisissez une description.';

  @override
  String get cabin_statusWorking => 'Opérationnel';

  @override
  String get cabin_statusFaultRecord => 'Enregistrement de panne';

  @override
  String get cabin_statusMaintenanceRecord => 'Enregistrement de maintenance';

  @override
  String get cabin_modeAssignLabel => 'Attribution de médicament';

  @override
  String get cabin_modeFillLabel => 'Remplissage de médicament';

  @override
  String get cabin_modeCountLabel => 'Comptage de médicament';

  @override
  String get cabin_modeFaultLabel => 'Panne de tiroir';

  @override
  String get cabin_operationPanelAssign => 'ATTRIBUTION DE MÉDICAMENT';

  @override
  String get cabin_operationPanelFill => 'REMPLISSAGE DE MÉDICAMENT';

  @override
  String get cabin_operationPanelCount => 'COMPTAGE DE MÉDICAMENT';

  @override
  String get cabin_operationPanelFault => 'SIGNALER UNE PANNE';

  @override
  String get cabin_legendAssignEmpty => 'Case vide (attribuer)';

  @override
  String get cabin_legendAssignAssigned => 'Médicament attribué';

  @override
  String get cabin_legendAssignFault => 'En panne';

  @override
  String get cabin_legendAssignMaintenance => 'En maintenance';

  @override
  String get cabin_legendPatientAssigned => 'Patient attribué';

  @override
  String get cabin_legendFilled => 'Rempli';

  @override
  String get cabin_legendFillEmpty => 'Vide (aucun remplissage nécessaire)';

  @override
  String get cabin_legendCountAssigned => 'À compter (contient un médicament)';

  @override
  String get cabin_legendCountLow => 'Stock faible';

  @override
  String get cabin_legendCountEmpty => 'Vide (ignorer)';

  @override
  String get cabin_legendFaultNormal => 'Fonctionnement normal';

  @override
  String get cabin_legendFaultReported => 'Panne signalée';

  @override
  String get cabin_legendFaultEmpty => 'Case vide';

  @override
  String get wizard_sidebarTitle => 'Configuration de la cabine';

  @override
  String get wizard_sidebarSubtitle => 'Configuration d\'un nouvel appareil';

  @override
  String get wizard_step1SidebarTitle => 'Type de cabine';

  @override
  String get wizard_step1SidebarDesc => 'Standard ou mobile';

  @override
  String get wizard_step2SidebarTitle => 'Informations de base';

  @override
  String get wizard_step2SidebarDesc => 'Nom, emplacement, connexion';

  @override
  String get wizard_step3SidebarTitle => 'Périmètre de service';

  @override
  String get wizard_step3SidebarDesc => 'Définitions de service ou de chambre';

  @override
  String get wizard_step4SidebarTitle => 'Structure des tiroirs';

  @override
  String get wizard_step4SidebarDesc => 'Scan ou saisie manuelle';

  @override
  String get wizard_step5SidebarTitle => 'Résumé';

  @override
  String get wizard_step5SidebarDesc => 'Vérifier et terminer';

  @override
  String get wizard_step1Header => 'Sélectionner le type de cabine';

  @override
  String get wizard_step1Subtitle =>
      'Précisez le type de cabine que vous souhaitez gérer. Ce choix déterminera les étapes suivantes.';

  @override
  String get wizard_cabinTypeNote =>
      'Le type de cabine ne peut pas être modifié ultérieurement.';

  @override
  String get wizard_masterCabinSpec1 => 'Cubique / Dose unitaire';

  @override
  String get wizard_masterCabinSpec2 => 'Par service';

  @override
  String get wizard_masterCabinDescription =>
      'Cabine murale ou autoportante combinant des tiroirs cubiques et à dose unitaire.';

  @override
  String get wizard_mobileCabinSpec1 => 'Sur roulettes';

  @override
  String get wizard_mobileCabinSpec2 => 'Par chambre';

  @override
  String get wizard_mobileCabinDescription =>
      'Unité de médication portable à 4 rangées, montée sur roulettes, conçue pour les tournées de service.';

  @override
  String get wizard_step2Header => 'Informations de base';

  @override
  String get wizard_step2Subtitle =>
      'Saisissez le nom de la cabine, son emplacement et les paramètres de connexion de l\'appareil.';

  @override
  String get wizard_cabinNameLabel => 'Nom de la cabine';

  @override
  String get wizard_cabinNameHint => 'ex. CB-304';

  @override
  String get wizard_connectionSettingsLabel => 'PARAMÈTRES DE CONNEXION';

  @override
  String get wizard_noComPortWarning =>
      'Aucun port COM actif trouvé. Assurez-vous que les pilotes sont installés.';

  @override
  String get wizard_antennaSettingsLabel => 'PARAMÈTRES D\'ANTENNE';

  @override
  String get wizard_ipAddressLabel => 'Adresse IP';

  @override
  String get wizard_testConnectionButton => 'Tester la connexion';

  @override
  String get wizard_step3Header => 'Périmètre de service';

  @override
  String get wizard_step3Subtitle => 'Définitions de service ou de chambre.';

  @override
  String get wizard_roomBedSelectionLabel => 'SÉLECTION DE CHAMBRE ET DE LIT';

  @override
  String get wizard_scanTitle => 'Scanner l\'appareil';

  @override
  String get wizard_scanDescription =>
      'La structure des tiroirs de la cabine connectée sera lue automatiquement via le port série.';

  @override
  String get wizard_startScanButton => 'Démarrer le scan';

  @override
  String get wizard_scanningStatus => 'Scan de la cabine en cours...';

  @override
  String wizard_scanSuccessBanner(int count) {
    return 'Scan réussi — $count tiroirs trouvés';
  }

  @override
  String get wizard_scanSuccessDescription =>
      'La disposition interne de la cabine a été lue avec succès depuis l\'appareil. Confirmez la structure ci-dessous.';

  @override
  String get wizard_scanWrongStructure =>
      'Si la structure est incorrecte, revenez en arrière et vérifiez les détails de connexion.';

  @override
  String get wizard_rescanButton => 'Rescanner';

  @override
  String get wizard_scanErrorBanner =>
      'Échec du scan. Vérifiez la connexion du port COM et réessayez.';

  @override
  String get wizard_scanLogConnecting => 'Connexion au port série…';

  @override
  String get wizard_scanLogFetchingMetadata =>
      'Chargement des définitions de tiroirs…';

  @override
  String get wizard_scanLogSearchingManager =>
      'Recherche de la carte de gestion…';

  @override
  String get wizard_scanLogScanningCards => 'Scan des cartes de contrôle…';

  @override
  String get wizard_scanLogDrawerFound => 'Tiroir trouvé';

  @override
  String wizard_drawerLabel(int index) {
    return 'TIROIR $index';
  }

  @override
  String wizard_cellCountLabel(int count) {
    return '$count cases';
  }

  @override
  String wizard_rowCountLabel(int count) {
    return '$count rangées';
  }

  @override
  String get wizard_drawerCountLabel => 'Nombre de tiroirs';

  @override
  String get wizard_addRowButton => 'Ajouter une rangée';

  @override
  String get wizard_removeLastRowButton => 'Supprimer la dernière rangée';

  @override
  String get wizard_step5Header => 'Résumé et finalisation';

  @override
  String get wizard_step5Subtitle =>
      'Confirmez les informations saisies. La configuration sera finalisée après confirmation.';

  @override
  String get wizard_summaryCabinInfoTitle => 'INFORMATIONS SUR LA CABINE';

  @override
  String get wizard_summaryServiceScopeTitle => 'PÉRIMÈTRE DE SERVICE';

  @override
  String get wizard_summaryDrawerStructureTitle => 'STRUCTURE DES TIROIRS';

  @override
  String get wizard_summaryCabinPreviewTitle => 'APERÇU DE LA CABINE';

  @override
  String get wizard_summaryLabelType => 'Type';

  @override
  String get wizard_summaryLabelName => 'Nom';

  @override
  String get wizard_summaryLabelStation => 'Station';

  @override
  String get wizard_summaryLabelRoomCount => 'Nombre de chambres';

  @override
  String get wizard_summaryLabelRooms => 'Chambres';

  @override
  String get wizard_summaryLabelBeds => 'Lits';

  @override
  String get wizard_summaryLabelDrawerCount => 'Nombre de tiroirs';

  @override
  String get wizard_summaryLabelTotalDrawers => 'Total des tiroirs';

  @override
  String wizard_summaryLabelDrawerIndexed(int index) {
    return 'Tiroir $index';
  }

  @override
  String get wizard_summaryTypeMobile => 'Cabine mobile';

  @override
  String get wizard_summaryTypeStandard => 'Cabine standard';

  @override
  String get wizard_summaryLabelComPort => 'Port COM';

  @override
  String get wizard_summaryLabelDvrIp => 'IP DVR';

  @override
  String get wizard_summaryLabelRfidAddress => 'Adresse RFID';

  @override
  String get wizard_summaryLabelRfidPort => 'Port RFID';

  @override
  String get wizard_savingMessage => 'Enregistrement de la cabine…';

  @override
  String get wizard_successTitle => 'Configuration terminée !';

  @override
  String wizard_successMessage(String cabinName) {
    return '$cabinName a été ajouté avec succès au système.';
  }

  @override
  String wizard_successCabinId(int id) {
    return 'ID de la cabine : #$id';
  }

  @override
  String get wizard_successReloginPrompt =>
      'Vous devez vous connecter pour continuer.';

  @override
  String get wizard_successLoginButton => 'Se connecter';

  @override
  String get wizard_successDashboardButton => 'Aller au tableau de bord';

  @override
  String get wizard_errorTitle => 'Échec de l\'enregistrement';

  @override
  String get wizard_retryButton => 'Retour et réessayer';

  @override
  String get settings_title => 'Paramètres';

  @override
  String get settings_systemConfigTitle => 'CONFIGURATION SYSTÈME';

  @override
  String get settings_appearanceLabel => 'Apparence';

  @override
  String get settings_generalLabel => 'Général';

  @override
  String get assignment_patientUpdatedSuccess =>
      'Attribution du patient mise à jour avec succès';

  @override
  String get fault_selectSlotPlaceholder =>
      'Sélectionnez un tiroir dans le\npanneau de gauche pour signaler une panne.';

  @override
  String get assignment_bedSectionLabel => 'Sélection du lit';

  @override
  String get assignment_serviceSelectorHint => 'Sélectionner un service';

  @override
  String get assignment_roomSelectorHint => 'Sélectionner une chambre';

  @override
  String get assignment_bedSelectorHint => 'Sélectionner un lit';

  @override
  String get assignment_patientLabel => 'PATIENT';

  @override
  String get settings_languageTitle => 'LANGUE';

  @override
  String get settings_languageSubtitle => 'Langue de l\'interface';

  @override
  String get emptyState_cabinDataTitle => 'Données de la cabine introuvables';

  @override
  String get emptyState_cabinDataDescription =>
      'La cabine n\'est peut-être pas encore configurée\nou la connexion n\'a pas pu être établie.';

  @override
  String get emptyState_noResultsTitle => 'Aucun résultat trouvé';

  @override
  String get emptyState_noResultsDescription =>
      'Essayez de modifier vos critères de recherche.';

  @override
  String get emptyState_noCellSelectedTitle => 'Aucune case sélectionnée';

  @override
  String get emptyState_noCellSelectedDescription =>
      'Sélectionnez une case pour commencer le remplissage.';

  @override
  String get emptyState_noPatientTitle => 'Aucun patient attribué';

  @override
  String get emptyState_noPatientDescription =>
      'Aucun patient n\'a encore été attribué à cette case.';

  @override
  String get emptyState_noPrescriptionTitle => 'Aucune ordonnance trouvée';

  @override
  String get emptyState_noPrescriptionDescription =>
      'Il n\'y a aucune ordonnance active pour ce patient.';

  @override
  String get emptyState_noCabinTitle => 'Aucune cabine trouvée';

  @override
  String get emptyState_noCabinDescription =>
      'Aucune cabine n\'a encore été définie. Veuillez définir une cabine pour continuer.';

  @override
  String get emptyState_networkErrorTitle => 'Pas de connexion Internet';

  @override
  String get emptyState_networkErrorDescription =>
      'Veuillez vérifier votre connexion réseau et réessayer.';

  @override
  String get emptyState_serverErrorTitle => 'Serveur inaccessible';

  @override
  String get emptyState_serverErrorDescription =>
      'Le serveur n\'a pas pu être atteint. Veuillez réessayer plus tard.';

  @override
  String get emptyState_errorTitle => 'Une erreur s\'est produite';

  @override
  String get emptyState_errorDescription =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer ou contacter votre administrateur système.';

  @override
  String get emptyState_noDataTitle => 'Aucune donnée';

  @override
  String get emptyState_noDataDescription =>
      'Il n\'y a encore aucune donnée à afficher.';

  @override
  String get refund_noRefundableDrugs =>
      'Aucun médicament remboursable trouvé pour ce patient.';

  @override
  String get refund_selectPatient =>
      'Sélectionnez un patient dans la liste de gauche pour démarrer un retour.';

  @override
  String get waste_noWastableDrugs => 'Aucun médicament à éliminer trouvé.';

  @override
  String get waste_selectPatient => 'Sélectionnez un patient pour continuer.';

  @override
  String get common_confirmCancelButton => 'Annuler';

  @override
  String get common_dismissButton => 'Ignorer';

  @override
  String get common_action_saving => 'Enregistrement';

  @override
  String get common_action_drawerOpening => 'Ouverture du tiroir';

  @override
  String get common_action_connecting => 'Connexion en cours';

  @override
  String get common_action_processing => 'Traitement en cours...';

  @override
  String get common_cancelInfo_drawerClose =>
      'Pour annuler l\'opération, fermez le tiroir.';

  @override
  String get common_patientListTitle => 'Liste des patients';

  @override
  String common_patientCountSubtitle(int count) {
    return 'Total $count patients';
  }

  @override
  String get assignment_error_stationLoadFailed =>
      'Impossible de charger les informations de la station de la cabine';

  @override
  String get cabinStock_panel_title =>
      'Médicaments de la cabine attribués au patient';

  @override
  String get census_cancelDialog_title => 'Annuler le comptage';

  @override
  String get census_cancelDialog_message =>
      'Annuler l\'opération de comptage ?';

  @override
  String get census_action_start => 'Démarrer l\'inventaire';

  @override
  String get census_action_drawerOpen => 'Compter les médicaments';

  @override
  String get census_action_complete => 'Terminer le comptage';

  @override
  String get census_action_continue => 'Poursuivre le comptage';

  @override
  String get census_success_completed => 'Comptage terminé avec succès.';

  @override
  String get drugActivity_column_date => 'Date';

  @override
  String get drugActivity_column_time => 'Heure';

  @override
  String get drugActivity_column_patient => 'Patient';

  @override
  String get drugActivity_column_user => 'Utilisateur';

  @override
  String get drugActivity_column_material => 'Matériel';

  @override
  String get drugActivity_column_quantity => 'Quantité';

  @override
  String get drugActivity_column_movement => 'Mouvement';

  @override
  String get intake_cancelDialog_title => 'Annuler la prise';

  @override
  String get intake_cancelDialog_message =>
      'Aucun médicament pris pour l\'instant. Annuler la prise ?';

  @override
  String get intake_action_start => 'Démarrer la prise';

  @override
  String get intake_action_drawerOpen => 'Prendre les médicaments';

  @override
  String get intake_action_complete => 'Terminer la prise';

  @override
  String get intake_action_continue => 'Poursuivre la prise';

  @override
  String get intake_success_completed => 'Prise terminée avec succès.';

  @override
  String get intake_action_reportMissingStock => 'Signaler un stock manquant';

  @override
  String get myPatients_search_hint =>
      'Rechercher un patient, une chambre, un service...';

  @override
  String get refill_cancelDialog_title => 'Annuler le remplissage';

  @override
  String get refill_cancelDialog_message =>
      'Les médicaments seront considérés comme retirés du tiroir. Annuler le remplissage ?';

  @override
  String get refill_action_start => 'Démarrer le remplissage';

  @override
  String get refill_action_placeDrugs => 'Placer les médicaments';

  @override
  String get refill_action_complete => 'Terminer le remplissage';

  @override
  String get refill_action_continue => 'Poursuivre le remplissage';

  @override
  String get refill_success_completedMobile =>
      'Remplissage terminé avec succès.';

  @override
  String get refill_success_completedMaster =>
      'Remplissage terminé avec succès';

  @override
  String get refill_hint_selectDrawer =>
      'Sélectionnez un tiroir dans le panneau de gauche pour commencer le remplissage.';

  @override
  String get refill_hint_selectCell => 'Sélectionnez une case dans le tiroir.';

  @override
  String get refill_hint_cellError => 'Sélectionnez une case.';

  @override
  String get refill_label_countQty => 'Quantité comptée';

  @override
  String get refill_label_fillQty => 'Quantité de remplissage';

  @override
  String get refill_label_expiryDate => 'Péremption';

  @override
  String get refill_title_selectMedicines =>
      'Sélectionner les médicaments à remplir';

  @override
  String get refill_title_autoRefill => 'Remplissage automatique';

  @override
  String refill_label_selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String refill_label_cellCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases',
      one: '$count case',
    );
    return '$_temp0';
  }

  @override
  String refill_label_multiMedicine(int count) {
    return '$count médicaments';
  }

  @override
  String get refill_label_targetCells => 'Cases à remplir';

  @override
  String refill_label_queueProgress(int done, int total) {
    return '$done / $total tiroirs';
  }

  @override
  String refill_label_current(String qty) {
    return 'Actuel : $qty';
  }

  @override
  String refill_chip_drawer(String address) {
    return 'Tiroir $address';
  }

  @override
  String refill_chip_drawerCell(String address, String cell) {
    return 'Tiroir $address - Case $cell';
  }

  @override
  String refill_subtitle_kubikCells(String address, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cases',
      one: '$count case',
    );
    return 'Tiroir $address · $_temp0';
  }

  @override
  String get refill_status_done => 'Terminé';

  @override
  String get refill_status_open => 'Ouvert';

  @override
  String get refill_status_queued => 'En attente';

  @override
  String get refill_status_drawerOpen => 'Tiroir ouvert';

  @override
  String get refill_status_drawerOpening => 'Ouverture du tiroir';

  @override
  String get refill_hint_searchMedicine => 'Rechercher un médicament…';

  @override
  String get refill_hint_noMedicines =>
      'Aucun médicament attribué à cette cabine';

  @override
  String get refill_hint_autoQueueOrder =>
      'Les tiroirs sélectionnés s\'ouvrent un par un ; le suivant s\'ouvre une fois le tiroir actuel fermé.';

  @override
  String get refill_hint_confirmCloses =>
      'L\'enregistrement fermera le tiroir et ouvrira le suivant.';

  @override
  String get refill_action_startAuto => 'Démarrer le remplissage automatique';

  @override
  String get refill_action_completeFilling => 'Terminer le remplissage';

  @override
  String get refill_action_stop => 'Arrêter';

  @override
  String get refill_label_min => 'Min';

  @override
  String get refill_label_critical => 'Critique';

  @override
  String get refill_label_max => 'Max';

  @override
  String get refill_error_queueTitle =>
      'L\'opération n\'a pas pu être terminée';

  @override
  String get refill_error_queueMessage =>
      'Le remplissage de ce tiroir n\'a pas pu être enregistré. Veuillez reprendre les médicaments que vous avez placés.';

  @override
  String get refill_error_continueNext => 'Tiroir suivant';

  @override
  String get refill_error_endProcess => 'Terminer le processus';

  @override
  String get refill_status_failed => 'Échoué';

  @override
  String refill_label_cellProgress(int current, int total) {
    return 'Case $current/$total';
  }

  @override
  String refill_label_cellNo(int no) {
    return 'Case $no';
  }

  @override
  String get refill_action_nextCell => 'Case suivante';

  @override
  String get refill_hint_nextCellOpens =>
      'L\'enregistrement ferme cette case et ouvre la suivante.';

  @override
  String get refill_hint_selectionLocked =>
      'Remplissage en cours — sélection verrouillée.';

  @override
  String get refill_hint_idleExecution =>
      'Sélectionnez des médicaments à gauche pour démarrer le remplissage.';

  @override
  String get refund_success_title => 'Retour réussi';

  @override
  String get refund_success_message =>
      'Veuillez remettre le médicament retourné au pharmacien.';

  @override
  String get refund_panel_title => 'Médicaments remboursables';

  @override
  String get refund_action_checking => 'Vérification...';

  @override
  String get refund_action_refunding => 'Retour en cours...';

  @override
  String get refund_action_refund => 'Retourner';

  @override
  String get unappliedPrescription_panel_patientTitle => 'Patients';

  @override
  String get unload_cancelDialog_title => 'Annuler le déchargement';

  @override
  String get unload_cancelDialog_message =>
      'Aucun médicament retiré pour l\'instant. Annuler le déchargement ?';

  @override
  String get unload_action_start => 'Démarrer le déchargement';

  @override
  String get unload_action_drawerOpen => 'Retirer les médicaments';

  @override
  String get unload_action_complete => 'Terminer le déchargement';

  @override
  String get unload_action_continue => 'Poursuivre le déchargement';

  @override
  String get unload_success_completed => 'Déchargement terminé avec succès.';

  @override
  String get waste_panel_title => 'Médicaments à gaspiller/détruire';

  @override
  String get waste_action_wastage => 'Perte';

  @override
  String get waste_action_destruction => 'Destruction';

  @override
  String get wastage_success_title => 'Gaspillage enregistré';

  @override
  String get wastage_success_message =>
      'Veuillez placer le médicament gaspillé dans le bac de gaspillage.';

  @override
  String get destruction_success_title => 'Destruction enregistrée';

  @override
  String get destruction_success_message =>
      'Veuillez éliminer le médicament conformément à la procédure de destruction.';

  @override
  String get assignment_success_created =>
      'Attribution du lit enregistrée avec succès.';

  @override
  String get assignment_success_deleted => 'Attribution du lit supprimée.';

  @override
  String get cabin_bannerCensus =>
      'Une fois le tiroir ouvert, sélectionnez les médicaments présents dans la cabine et terminez le comptage. Les médicaments dont le statut est « En attente de prise » peuvent être comptés ; les médicaments non sélectionnés sont considérés comme ayant une quantité de 0.';

  @override
  String get cabin_bannerIntake => 'Prise de médicament';

  @override
  String get cabin_bannerUnload => 'Déchargement de médicament';

  @override
  String get operationPanel_title_assign => 'ATTRIBUTION DE MÉDICAMENT';

  @override
  String get operationPanel_badge_assign => 'ATTRIBUER';

  @override
  String get operationPanel_title_refill => 'REMPLISSAGE DE MÉDICAMENT';

  @override
  String get operationPanel_badge_refill => 'REMPLISSAGE';

  @override
  String get operationPanel_title_census => 'COMPTAGE DE MÉDICAMENT';

  @override
  String get operationPanel_badge_census => 'COMPTAGE';

  @override
  String get operationPanel_title_fault => 'SIGNALER UNE PANNE';

  @override
  String get operationPanel_badge_fault => 'PANNE';

  @override
  String get operationPanel_title_intake => 'PRISE DE MÉDICAMENT';

  @override
  String get operationPanel_badge_intake => 'PRISE';

  @override
  String get operationPanel_title_unload => 'DÉCHARGEMENT DE MÉDICAMENT';

  @override
  String get operationPanel_badge_unload => 'DÉCHARGEMENT';

  @override
  String get drugAssignment_panel_title => 'Sélectionner un médicament';

  @override
  String get session_timeout_warning =>
      'Votre session est sur le point d\'expirer.';

  @override
  String get session_timeout_continueButton => 'Continuer';

  @override
  String get session_timeout_prefix => 'Votre session se fermera dans ';

  @override
  String get session_timeout_suffix => ' secondes.';

  @override
  String get session_locked_prefix => 'Votre session ';

  @override
  String get session_locked_reason => 'a expiré';

  @override
  String get session_locked_suffix =>
      ' et a été fermée. Veuillez vous connecter pour continuer.';

  @override
  String get movement_noHistory => 'Aucun historique de mouvement trouvé.';

  @override
  String get movement_performedBy => 'Effectué par';

  @override
  String get common_search_noPatientResults =>
      'Aucun patient ne correspond à votre recherche.';

  @override
  String get common_drug_noFilterResults =>
      'Aucun médicament ne correspond à ce filtre.';

  @override
  String get common_unknownName => 'Inconnu';

  @override
  String get rfidStatus_read => 'Lu';

  @override
  String get rfidStatus_waiting => 'En attente';

  @override
  String get rfidStatus_inCabin => 'Dans la cabine';

  @override
  String get rfidStatus_notInCabin => 'Pas dans la cabine';

  @override
  String get rfidStatus_taken => 'Pris';

  @override
  String get rfidStatus_missing => 'Manquant';

  @override
  String get drawerStatus_full => 'Plein';

  @override
  String get drawerStatus_low => 'Faible';

  @override
  String get drawerStatus_critical => 'Critique';

  @override
  String get drawerStatus_empty => 'Vide';

  @override
  String cabin_cellCount(Object count) {
    return '$count cases';
  }

  @override
  String cabin_drawerStats(Object columns, Object rowCount, Object totalCells) {
    return '$rowCount rangées · $totalCells cases · $columns colonnes';
  }

  @override
  String hospitalization_admissionDate(Object date) {
    return 'Date d\'admission | $date';
  }

  @override
  String get movement_dateLabel => 'Date';

  @override
  String get movement_quantityLabel => 'Quantité';

  @override
  String get movement_showAll => 'Afficher tous les mouvements';

  @override
  String cabin_masterDrawerStats(Object groupCount, Object mult, Object steps) {
    return '$groupCount groupes · $steps étapes × $mult';
  }

  @override
  String get dashboard_cabinConnectionStatus_connected => 'Connecté';

  @override
  String get dashboard_cabinConnectionStatus_connecting => 'Connexion…';

  @override
  String get dashboard_cabinConnectionStatus_error => 'Aucune connexion';

  @override
  String get dashboard_cabinConnectionStatus_disconnected => 'Déconnecté';

  @override
  String get dashboard_cabinConnection_reconnectButton => 'Reconnecter';

  @override
  String get prescription_noPatients_title => 'Aucun patient attribué';

  @override
  String get prescription_noPatients_message =>
      'Aucun patient n\'a encore été attribué à cette cabine. Les patients doivent être attribués avant que les ordonnances puissent être examinées.';

  @override
  String get myPatients_empty_title =>
      'Aucun patient sélectionné pour l\'instant';

  @override
  String get myPatients_empty_description =>
      'Sélectionnez des patients dans la liste de gauche pour les ajouter à votre liste de patients. Les patients sélectionnés apparaîtront ici.';

  @override
  String get cabinStock_emptyTitle => 'Aucun stock pour ce patient';

  @override
  String get cabinStock_emptyDescription =>
      'Ce patient n\'a encore aucun médicament stocké dans cette cabine.';

  @override
  String get prescription_unadministeredEmptyTitle =>
      'Aucune ordonnance en attente';

  @override
  String get prescription_unadministeredEmptyDescription =>
      'Il n\'y a aucune ordonnance en attente d\'administration pour ce patient.';

  @override
  String get emptyState_noPatientSelectedTitle => 'Sélectionnez un patient';

  @override
  String get emptyState_noPatientSelectedDescription =>
      'Choisissez un patient dans la liste pour voir ses détails.';

  @override
  String get dateFilter_todayPreset => 'Aujourd\'hui';

  @override
  String get dateFilter_tomorrowPreset => 'Demain';

  @override
  String get dateFilter_last3DaysPreset => '3 derniers jours';

  @override
  String get dateFilter_last7DaysPreset => '7 derniers jours';

  @override
  String get dateFilter_allPreset => 'Tout';

  @override
  String get filter_all => 'Tous';

  @override
  String get census_action_reportExtraStock => 'Signaler un surplus de stock';

  @override
  String get census_extraStockDialogTitle => 'Signaler un surplus de stock';

  @override
  String get census_extraStockQuantityLabel => 'Quantité';

  @override
  String get common_action_add => 'Ajouter';

  @override
  String get census_extraStockSummaryTitle => 'Surplus de stock signalés';

  @override
  String get core_serialPortDisconnectedLabel => 'Non connecté';

  @override
  String core_serialConnectingStatus(String portName) {
    return 'Connexion au port : $portName...';
  }

  @override
  String core_serialConnectSuccessStatus(String portName) {
    return 'Connexion réussie : $portName';
  }

  @override
  String core_serialPortFailedScanningOthersStatus(String portName) {
    return 'Échec de $portName. Analyse des autres ports...';
  }

  @override
  String core_serialNoOtherPortsError(String portName) {
    return 'Le port par défaut ($portName) a échoué et aucun autre port n\'a été trouvé.';
  }

  @override
  String core_serialTryingPortStatus(String portName) {
    return 'Tentative : $portName...';
  }

  @override
  String core_serialConnectionEstablishedStatus(String portName) {
    return 'Connexion établie : $portName';
  }

  @override
  String get core_serialNoPortConnectedError =>
      'Impossible de se connecter à un port. Vérifiez les câbles.';

  @override
  String core_serialPortOpenFailedError(String portName) {
    return 'Le port n\'a pas pu être ouvert ($portName).';
  }

  @override
  String get core_serialNoConnectionError => 'Aucune connexion.';

  @override
  String get core_serialPortBusyTimeoutError => 'Délai d\'expiration du port.';

  @override
  String get core_serialWriteFailedError => 'Échec de l\'écriture.';

  @override
  String get common_defaultSuccessMessage => 'Opération réussie';

  @override
  String get common_operationSuccessMessage =>
      'Votre opération a été effectuée avec succès.';

  @override
  String get common_loadingEllipsis => 'Chargement...';

  @override
  String get common_searchHint => 'Rechercher...';

  @override
  String get common_searchTooltip => 'Rechercher';

  @override
  String get common_addTooltip => 'Ajouter';

  @override
  String get common_closeTooltip => 'Fermer';

  @override
  String get common_saveButton => 'Enregistrer';

  @override
  String get common_editTooltip => 'Modifier';

  @override
  String get common_deleteTooltip => 'Supprimer';

  @override
  String get common_statusLabel => 'Statut';

  @override
  String get common_emptyListMessage => 'La liste est actuellement vide';

  @override
  String get common_nameLabel => 'Nom';

  @override
  String get common_requiredFieldsError =>
      'Veuillez remplir les champs obligatoires.';

  @override
  String get common_descriptionLabel => 'Description';

  @override
  String get common_deselectAllButton => 'Tout désélectionner';

  @override
  String get common_selectAllButton => 'Tout sélectionner';

  @override
  String get common_defaultUnitFallback => 'Pièce';

  @override
  String get common_flagFirstDoseEmergency => 'Première dose urgente';

  @override
  String get common_flagAskDoctor => 'Demander au médecin';

  @override
  String get common_flagInCaseOfNecessity => 'Si nécessaire';

  @override
  String common_addItemHint(String item) {
    return 'Appuyez sur le bouton « + » pour ajouter un(e) nouveau/nouvelle $item';
  }

  @override
  String get common_genericErrorMessage => 'Une erreur s\'est produite.';

  @override
  String get hospitalizationCard_noDoctorFallback => 'Aucun médecin spécifié';

  @override
  String get hospitalizationCard_nationalIdLabel => 'N° d\'identité nationale';

  @override
  String get hospitalizationCard_admissionDateLabel => 'Date d\'admission';

  @override
  String get menuBrowser_categoriesHeader => 'CATÉGORIES';

  @override
  String get menuBrowser_searchHint => 'Rechercher une catégorie...';

  @override
  String menuBrowser_selectionCountBadge(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get menuBrowser_emptyCategoryMessage =>
      'Aucun menu trouvé dans cette catégorie';

  @override
  String rxGroup_headerTitle(Object id) {
    return 'Ordonnance n° $id';
  }

  @override
  String rxGroup_headerSubtitle(String doctorName, String date) {
    return '$doctorName · $date';
  }

  @override
  String rxGroup_itemCountBadge(int count) {
    return '$count articles';
  }

  @override
  String rxGroup_selectableCountLabel(int count) {
    return '$count articles pouvant faire l\'objet d\'une action';
  }

  @override
  String get rxGroup_unknownDoctorFallback => 'Inconnu';

  @override
  String get rxGroup_rfidTagLabel => 'ÉTIQUETTE RFID';

  @override
  String get rxGroup_rfidTagLoadingLabel => 'En attente de l\'étiquette...';

  @override
  String get rxGroup_rfidTagUnassignedLabel =>
      'Aucune étiquette assignée pour le moment';

  @override
  String get rxGroup_rfidChangeButton => 'Modifier';

  @override
  String get rxGroup_rfidAssignButton => 'Assigner une étiquette';

  @override
  String rxGroup_selectedCountBar(int count) {
    return '$count articles sélectionnés';
  }

  @override
  String get rxGroup_approveAction => 'Approuver';

  @override
  String get rxGroup_rejectAction => 'Rejeter';

  @override
  String get changePassword_dialogTitle => 'Changer le mot de passe';

  @override
  String get changePassword_currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get changePassword_newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get changePassword_confirmPasswordLabel =>
      'Confirmer le nouveau mot de passe';

  @override
  String get changePassword_submitButton => 'Changer le mot de passe';

  @override
  String get home_appBarBadgeLabel => 'PANNEAU DE GESTION';

  @override
  String get home_devSettingsTooltip => 'Paramètres développeur';

  @override
  String get home_noAuthorizedMenuTitle => 'Aucun menu autorisé trouvé';

  @override
  String get home_noAuthorizedMenuDescription =>
      'Aucune autorisation d\'accès n\'est définie pour votre compte.\nVeuillez contacter votre administrateur système pour obtenir un accès.';

  @override
  String get branch_listDialogTitle => 'Définition de la spécialité';

  @override
  String get branch_addTitle => 'Ajouter une spécialité';

  @override
  String get branch_editTitle => 'Modifier la spécialité';

  @override
  String get branch_nameLabel => 'Nom de la spécialité';

  @override
  String get firm_createSuccessMessage => 'Entreprise créée avec succès';

  @override
  String get firm_updateSuccessMessage => 'Entreprise mise à jour avec succès';

  @override
  String get firm_createPanelTitle => 'Nouvelle entreprise';

  @override
  String get firm_editPanelTitle => 'Modifier l\'entreprise';

  @override
  String get firm_createPanelSubtitle =>
      'Renseignez les informations de l\'entreprise';

  @override
  String get firm_editPanelSubtitle =>
      'Mettez à jour les informations de l\'entreprise';

  @override
  String get firm_nameLabel => 'Nom de l\'entreprise';

  @override
  String get firm_taxNoLabel => 'N° fiscal';

  @override
  String get firm_taxOfficeLabel => 'Centre des impôts';

  @override
  String get firm_typeLabel => 'Type d\'entreprise';

  @override
  String get firm_screenDefaultTitle => 'Définition de l\'entreprise';

  @override
  String get dosageForm_deleteSuccessMessage =>
      'La forme posologique a été supprimée avec succès.';

  @override
  String get dosageForm_saveSuccessMessage =>
      'La forme posologique a été enregistrée avec succès.';

  @override
  String get dosageForm_createTitle => 'Créer une forme posologique';

  @override
  String get dosageForm_editTitle => 'Modifier la forme posologique';

  @override
  String get dosageForm_listDialogTitle => 'Forme posologique';

  @override
  String get dosageForm_emptyTitle => 'Aucune forme posologique pour le moment';

  @override
  String get dosageForm_emptyDescription =>
      'Appuyez sur le bouton « + » pour créer une forme posologique';

  @override
  String get authorization_userTabTitle => 'Autorisation utilisateur';

  @override
  String get authorization_roleTabTitle => 'Autorisation de rôle';

  @override
  String get authorization_screenTitleFallback =>
      'Autorisation utilisateur/rôle';

  @override
  String authorization_rolePanelTitle(String roleName) {
    return 'Autorisation de rôle - $roleName';
  }

  @override
  String get authorization_tabMenuLabel => 'Menu';

  @override
  String get authorization_tabDrugLabel => 'Médicament';

  @override
  String get authorization_tabConsumableLabel => 'Consommable médical';

  @override
  String get authorization_drugTable_pullColumn => 'Prélever le médicament';

  @override
  String get authorization_drugTable_fillColumn => 'Remplissage';

  @override
  String get authorization_drugTable_returnColumn => 'Retour';

  @override
  String get authorization_drugTable_disposeColumn => 'Élimination';

  @override
  String get authorization_drugTable_allDrugsRow => 'Tous les médicaments';

  @override
  String get authorization_drugTable_unknownDrugFallback =>
      'Médicament inconnu';

  @override
  String get settings_updateSuccessMessage =>
      'Paramètres mis à jour avec succès.';

  @override
  String get settingsCabin_drawerOpenWaitLabel =>
      'Délai d\'attente tiroir ouvert (secondes)';

  @override
  String get settingsCabin_drawerOpenWaitDescription =>
      'Indique quand le système enverra une commande de fermeture au tiroir s\'il reste ouvert.';

  @override
  String get settingsDeveloper_adminDashboardActiveLabel =>
      'Tableau de bord admin actif';

  @override
  String get settingsDeveloper_appModeLabel => 'Mode de l\'application';

  @override
  String get settingsDeveloper_clientModeButton => 'Mode client';

  @override
  String get settingsDeveloper_managerModeButton => 'Mode gestionnaire';

  @override
  String get settingsGeneral_autoStandbyDurationLabel =>
      'Durée avant mise en veille automatique (secondes)';

  @override
  String get settingsGeneral_expiryWarningLabel => 'Alerte d\'expiration';

  @override
  String get settingsGeneral_hbysStockControlLabel => 'Contrôle de stock SIH';

  @override
  String get settingsGeneral_fingerprintOnlyLabel =>
      'N\'autoriser que le lecteur d\'empreintes digitales sur les cabines.';

  @override
  String get settingsGeneral_allowOutOfWindowOrdersLabel =>
      'Les commandes hors délai peuvent être acceptées.';

  @override
  String get settingsGeneral_perCellExpiryDateLabel =>
      'Autoriser la saisie d\'une date d\'expiration distincte pour chaque compartiment des tiroirs à dose unitaire lors du remplissage.';

  @override
  String get settingsGeneral_collectOrderTimeLabel =>
      'Plage horaire de consultation des détails de commande (heures)';

  @override
  String get settingsGeneral_wasteDestructionTimeLabel =>
      'Délai de péremption/destruction (heures)';

  @override
  String get settingsGeneral_wasteOrderReactivateLabel =>
      'Réactiver la commande après péremption/destruction';

  @override
  String get settingsGeneral_badgeCardPasswordLabel =>
      'Exiger un mot de passe lors de la connexion par badge';

  @override
  String get settingsPrescription_accessDurationLabel =>
      'Durée d\'accès à l\'ordonnance (minutes)';

  @override
  String get settingsPrescription_accessDurationDescription =>
      'Indique la durée pendant laquelle les ordonnances restent accessibles avant et après les heures de retrait des produits.';

  @override
  String get settingsView_cabinTabTitle =>
      'Paramètres de communication de la cabine';

  @override
  String get settingsView_prescriptionTabTitle => 'Paramètres de l\'ordonnance';

  @override
  String get settingsView_generalTabTitle => 'Paramètres généraux';

  @override
  String get settingsView_developerTabTitle => 'Paramètres développeur';

  @override
  String get settingsView_refreshPermissionsButton =>
      'Actualiser les autorisations';

  @override
  String stationSetup_defaultRoomName(int index) {
    return 'Chambre $index';
  }

  @override
  String get stationSetup_service_createdSuccessMessage =>
      'Service créé avec succès';

  @override
  String get stationSetup_service_updatedSuccessMessage =>
      'Service mis à jour avec succès';

  @override
  String get stationSetup_roomsSectionTitle => 'Chambres et lits';

  @override
  String stationSetup_roomsBedsSummary(int roomCount, int bedCount) {
    return '$roomCount chambres · $bedCount lits';
  }

  @override
  String get stationSetup_addRoomButton => 'Ajouter une chambre';

  @override
  String stationSetup_bedCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lits',
      one: '$count lit',
    );
    return '$_temp0';
  }

  @override
  String get stationSetup_noBedsAddedYetMessage =>
      'Aucun lit ajouté pour le moment';

  @override
  String get stationSetup_addBedButton => 'Ajouter un lit';

  @override
  String get stationSetup_service_formTitleNew => 'Nouveau service';

  @override
  String get stationSetup_service_formTitleEdit => 'Modifier le service';

  @override
  String get stationSetup_service_formSubtitleNew =>
      'Renseignez les informations du service';

  @override
  String get stationSetup_service_formSubtitleEdit =>
      'Mettez à jour les informations du service';

  @override
  String get stationSetup_service_nameLabel => 'Nom du service';

  @override
  String get stationSetup_service_branchLabel => 'Spécialité';

  @override
  String get stationSetup_service_branchSelectTitle =>
      'Sélectionner une spécialité';

  @override
  String get stationSetup_service_userLabel => 'Utilisateur';

  @override
  String get stationSetup_common_statusLabel => 'Statut';

  @override
  String get stationSetup_station_createdSuccessMessage =>
      'Station créée avec succès';

  @override
  String get stationSetup_station_updatedSuccessMessage =>
      'Station mise à jour avec succès';

  @override
  String get stationSetup_station_formTitleNew => 'Nouvelle station';

  @override
  String get stationSetup_station_formTitleEdit => 'Modifier la station';

  @override
  String get stationSetup_station_formSubtitleNew =>
      'Renseignez les informations de la station';

  @override
  String get stationSetup_station_formSubtitleEdit =>
      'Mettez à jour les informations de la station';

  @override
  String get stationSetup_station_nameLabel => 'Nom de la station';

  @override
  String get stationSetup_station_drugWarehouseLabel =>
      'Entrepôt de médicaments';

  @override
  String get stationSetup_station_drugWarehouseSelectTitle =>
      'Sélectionner un entrepôt de médicaments';

  @override
  String get stationSetup_station_drugStatusLabel => 'Statut du médicament';

  @override
  String get stationSetup_station_consumableWarehouseLabel =>
      'Entrepôt de consommables médicaux';

  @override
  String get stationSetup_station_consumableWarehouseSelectTitle =>
      'Sélectionner un entrepôt de consommables médicaux';

  @override
  String get stationSetup_station_consumableStatusLabel =>
      'Statut du consommable médical';

  @override
  String get stationSetup_station_serviceLabel => 'Service';

  @override
  String get stationSetup_station_serviceSelectTitle =>
      'Sélectionner un service';

  @override
  String get stationSetup_station_providedServicesLabel => 'Services desservis';

  @override
  String get stationSetup_station_typeLabel => 'Type de station';

  @override
  String get stationSetup_station_typePatientBasedLabel =>
      'Basé sur le patient';

  @override
  String get stationSetup_station_typeMedicineBasedLabel =>
      'Basé sur le médicament';

  @override
  String get stationSetup_warehouse_createdSuccessMessage =>
      'Entrepôt créé avec succès';

  @override
  String get stationSetup_warehouse_updatedSuccessMessage =>
      'Entrepôt mis à jour avec succès';

  @override
  String get stationSetup_warehouse_formTitleNew => 'Nouvel entrepôt';

  @override
  String get stationSetup_warehouse_formTitleEdit => 'Modifier l\'entrepôt';

  @override
  String get stationSetup_warehouse_formSubtitleNew =>
      'Renseignez les informations de l\'entrepôt';

  @override
  String get stationSetup_warehouse_formSubtitleEdit =>
      'Mettez à jour les informations de l\'entrepôt';

  @override
  String get stationSetup_warehouse_codeLabel => 'Code de l\'entrepôt';

  @override
  String get stationSetup_warehouse_nameLabel => 'Nom de l\'entrepôt';

  @override
  String get stationSetup_warehouse_typeLabel => 'Type d\'entrepôt';

  @override
  String get stationSetup_warehouse_managerLabel =>
      'Responsable de l\'entrepôt';

  @override
  String get stationSetup_warehouse_managerSelectTitle =>
      'Sélectionner un responsable d\'entrepôt';

  @override
  String get stationSetup_screen_stationTabTitle => 'Définition de la station';

  @override
  String get stationSetup_screen_serviceTabTitle => 'Définition du service';

  @override
  String get stationSetup_screen_warehouseTabTitle =>
      'Définition de l\'entrepôt';

  @override
  String get stationSetup_screen_setupWizardButton =>
      'Assistant de configuration';

  @override
  String get stationSetup_wizard_title =>
      'Assistant de configuration de la station';

  @override
  String get stationSetup_wizard_completeSetupButton =>
      'Terminer la configuration';

  @override
  String get stationSetup_wizard_continueButton => 'Continuer';

  @override
  String get stationSetup_wizard_backButton => 'Retour';

  @override
  String get unappliedPrescription_detailDialogTitle => 'Liste des matériaux';

  @override
  String get unappliedPrescription_screenTitleFallback =>
      'Ordonnances non appliquées';

  @override
  String get unappliedPrescription_viewDetailsTooltip => 'Voir les détails';

  @override
  String get dashboard_cabinsLoadErrorFallback =>
      'Les cabines n\'ont pas pu être chargées';

  @override
  String get dashboard_cabinListStaleLabel =>
      'La liste des cabines n\'est pas à jour';

  @override
  String get dashboardDrugActivityPanelTitle => 'MOUVEMENTS DE MÉDICAMENTS';

  @override
  String get dashboardDrugActivityEmptyTitle => 'Aucun mouvement';

  @override
  String get dashboard_drugActivityDateTimeLabel => 'DATE / HEURE';

  @override
  String get dashboard_missingStockPanelTitle =>
      'SIGNALEMENTS DE STOCK MANQUANT';

  @override
  String get dashboard_missingStockEmptyTitle =>
      'Aucun signalement de stock manquant';

  @override
  String get dashboard_missingStockTimeLabel => 'HEURE';

  @override
  String get dashboard_missingStockApproveButton => 'Approuver';

  @override
  String get dashboard_missingStockRejectButton => 'Rejeter';

  @override
  String get dashboard_otherCabinPlaceholderText =>
      'Matériaux périmés et stocks critiques (prochainement)';

  @override
  String get dashboard_unappliedPrescriptionsPanelTitle =>
      'ORDONNANCES NON APPLIQUÉES';

  @override
  String get dashboard_unappliedPrescriptionsEmptyTitle =>
      'Aucune ordonnance non appliquée';

  @override
  String get dashboard_doctorLabel => 'MÉDECIN';

  @override
  String get dashboard_roomBedLabel => 'CHAMBRE / LIT';

  @override
  String get dashboardUpcomingTreatmentsPanelTitle => 'TRAITEMENTS À VENIR';

  @override
  String get dashboardUpcomingTreatmentsEmptyTitle =>
      'Aucun traitement à venir';

  @override
  String get dashboard_listPanelLoadErrorFallback => 'Le chargement a échoué';

  @override
  String get prescription_actionCompletedSuccess =>
      'L\'opération a été effectuée avec succès.';

  @override
  String get prescription_approvedSuccess =>
      'L\'ordonnance a été approuvée avec succès.';

  @override
  String get prescription_detailPanelPatientFallback => 'Patient';

  @override
  String get prescription_detailPanelSubtitle => 'Historique des ordonnances';

  @override
  String get prescription_detailStartDateLabel => 'Date de début';

  @override
  String get prescription_detailEndDateLabel => 'Date de fin';

  @override
  String get prescription_detailStatusLabel => 'Statut';

  @override
  String get prescription_checkWarningDialogTitle =>
      'Avertissement de contrôle';

  @override
  String get prescription_saveWithTemplateSuccess =>
      'L\'ordonnance et le modèle ont été enregistrés avec succès.';

  @override
  String get prescription_savedTemplateFailedMessage =>
      'L\'ordonnance a été enregistrée, mais le modèle n\'a pas pu être enregistré.';

  @override
  String get prescription_savedSuccess =>
      'L\'ordonnance a été enregistrée avec succès.';

  @override
  String get prescription_creatingLoadingMessage =>
      'Création de l\'ordonnance en cours. Veuillez patienter.';

  @override
  String get prescription_templateSavingLoadingMessage =>
      'Enregistrement du modèle en cours.';

  @override
  String get prescription_newTitle => 'Nouvelle ordonnance';

  @override
  String get prescription_newDialogSubtitle =>
      'Créer une ordonnance ou en importer une depuis l\'historique';

  @override
  String get prescription_tabHistory => 'Historique';

  @override
  String get prescription_tabTemplates => 'Modèles';

  @override
  String get prescription_contentEmptyTitle =>
      'Vous n\'avez pas encore ajouté de médicament à l\'ordonnance.';

  @override
  String get prescription_contentEmptyDescription =>
      'Les médicaments que vous ajoutez s\'afficheront ici.';

  @override
  String get prescription_itemNoTimesLabel => 'Aucun horaire ajouté';

  @override
  String get prescription_itemNoMedicineSelected =>
      'Aucun médicament sélectionné pour le moment';

  @override
  String get prescription_patientFieldLabel => 'Patient';

  @override
  String get prescription_doctorFieldLabel => 'Médecin';

  @override
  String get prescription_saveButton => 'Enregistrer l\'ordonnance';

  @override
  String get prescription_saveAsTemplateCheckboxLabel =>
      'Enregistrer également comme modèle';

  @override
  String get prescription_templateNameHint => 'Nom du modèle';

  @override
  String get prescription_medicineFieldLabel => 'Médicament / Matériel';

  @override
  String get prescription_descriptionFieldLabel => 'Description';

  @override
  String get prescription_tomorrowLabel => 'Demain';

  @override
  String get prescription_timesLabel => 'Horaires';

  @override
  String get prescription_addTimeButton => 'Ajouter un horaire';

  @override
  String get prescription_historySelectPatientTitle =>
      'Sélectionner un patient';

  @override
  String get prescription_historySelectPatientDescription =>
      'Sélectionnez d\'abord un patient pour consulter son historique d\'ordonnances';

  @override
  String get prescription_historyEmptyDescription =>
      'Ce patient n\'a aucun historique d\'ordonnances';

  @override
  String prescription_addToRxButton(int count) {
    return 'Ajouter à l\'ordonnance ($count)';
  }

  @override
  String get prescription_templateEmptyTitle => 'Aucun modèle trouvé';

  @override
  String get prescription_templateEmptyDescription =>
      'Aucun modèle d\'ordonnance enregistré';

  @override
  String get prescription_templateNoItemsMessage =>
      'Ce modèle ne contient aucun article';

  @override
  String get prescription_screenTitleFallback => 'Opérations d\'ordonnance';

  @override
  String get prescription_contentTooltip => 'Contenu de l\'ordonnance';

  @override
  String get prescription_showActiveButton => 'Afficher les admissions actives';

  @override
  String get prescription_showDischargedButton =>
      'Afficher les patients sortis';

  @override
  String get cabinTemperature_screenTitle =>
      'Contrôle de température de la cabine';

  @override
  String get cabinTemperature_formDialogTitle => 'Modifier la cabine';

  @override
  String get cabinTemperature_insideBottomLabel =>
      'Température intérieure basse';

  @override
  String get cabinTemperature_insideTopLabel => 'Température intérieure haute';

  @override
  String get cabinTemperature_outsideBottomLabel =>
      'Température extérieure basse';

  @override
  String get cabinTemperature_outsideTopLabel => 'Température extérieure haute';

  @override
  String get cabinTemperature_humidityBottomLabel =>
      'Limite inférieure d\'humidité';

  @override
  String get cabinTemperature_humidityTopLabel =>
      'Limite supérieure d\'humidité';

  @override
  String cabinTemperature_genericErrorMessage(String error) {
    return 'Une erreur s\'est produite : $error';
  }

  @override
  String get cabinTemperature_stationNotSelectedError =>
      'Aucune station sélectionnée';

  @override
  String get cabinTemperature_createSuccess =>
      'Le paramètre de température de la cabine a été créé avec succès.';

  @override
  String get cabinTemperature_updateRecordNotFoundError =>
      'Aucun enregistrement trouvé à mettre à jour';

  @override
  String get cabinTemperature_updateSuccess =>
      'Le paramètre de température de la cabine a été mis à jour avec succès.';

  @override
  String get cabinTemperature_unnamedStationFallback => 'Station sans nom';

  @override
  String get cabinTemperature_stationsLoadingMessage =>
      'Chargement des stations...';

  @override
  String get cabinTemperature_detailsLoadingMessage =>
      'Chargement des détails de température...';

  @override
  String get cabinTemperature_columnCabin => 'Cabine';

  @override
  String get directedOrders_screenTitle => 'Liste des commandes dirigées';

  @override
  String get directedOrders_columnProtocolNo => 'N° de protocole';

  @override
  String get directedOrders_columnBed => 'Lit';

  @override
  String get directedOrders_columnRoom => 'Chambre';

  @override
  String get directedOrders_medicinesTooltip => 'Médicaments';

  @override
  String get directedOrders_patientsLoadingMessage =>
      'Chargement des patients...';

  @override
  String get directedOrders_columnBarcode => 'Code-barres';

  @override
  String get medicine_successCreated => 'Médicament créé';

  @override
  String get medicine_successUpdated => 'Médicament mis à jour';

  @override
  String get medicalConsumable_successCreated => 'Consommable médical créé';

  @override
  String get medicalConsumable_successUpdated =>
      'Consommable médical mis à jour';

  @override
  String get medicine_formTitleNew => 'Nouveau médicament';

  @override
  String get medicine_formTitleEdit => 'Modifier le médicament';

  @override
  String get medicine_formSubtitleNew =>
      'Renseignez les informations du médicament';

  @override
  String get medicine_formSubtitleEdit =>
      'Mettez à jour les informations du médicament';

  @override
  String get medicine_fieldDefinitionName => 'Nom de la définition';

  @override
  String get medicine_fieldBarcode => 'Code-barres';

  @override
  String get medicine_fieldName => 'Nom du médicament';

  @override
  String get medicine_fieldCode => 'Code du médicament';

  @override
  String get medicine_fieldPrescriptionType => 'Type d\'ordonnance';

  @override
  String get medicine_fieldDose => 'Dose';

  @override
  String get medicine_fieldManufacturer => 'Fabricant';

  @override
  String get medicine_fieldDailyMaxUsage =>
      'Quantité d\'utilisation maximale quotidienne';

  @override
  String get medicine_fieldDrugType => 'Type de médicament';

  @override
  String get medicine_fieldReturnType => 'Mode de retour';

  @override
  String get medicine_checkboxSerumMaxValue =>
      'Vérifier la valeur maximale dans l\'armoire à sérum';

  @override
  String get medicine_checkboxCubicMaxValue =>
      'Vérifier la valeur maximale dans le tiroir cubique';

  @override
  String get medicine_checkboxQrCode => 'Avec code QR';

  @override
  String get medicine_fieldPieceCountLabel => 'Nombre de pièces';

  @override
  String get medicine_fieldDrugClass => 'Classe de médicament';

  @override
  String get medicine_fieldPurchaseType => 'Mode d\'achat';

  @override
  String get medicine_checkboxUseMeasurementUnit =>
      'Utiliser une unité de mesure';

  @override
  String get medicine_fieldVolume => 'Volume';

  @override
  String get medicine_fieldDosageForm => 'Forme posologique';

  @override
  String get medicine_fieldStatus => 'Statut';

  @override
  String get medicine_fieldCountType => 'Type de comptage';

  @override
  String get medicine_fieldAtcCode => 'Code ATC';

  @override
  String get medicine_fieldEquivalentCode => 'Code équivalent';

  @override
  String get medicine_checkboxWitnessedPurchase => 'Achat avec témoin';

  @override
  String get medicine_checkboxWastageWitnessed =>
      'Perte/élimination avec témoin';

  @override
  String get medicine_checkboxDestroyable => 'Peut être éliminé';

  @override
  String get medicine_fieldActiveIngredient => 'Principe actif';

  @override
  String get medicine_fieldCollectNote => 'Note d\'achat';

  @override
  String get medicine_fieldReturnNote => 'Note de retour';

  @override
  String get medicine_fieldDestructionNote => 'Note d\'élimination';

  @override
  String get medicalConsumable_dialogTitle =>
      'Ajouter/Modifier un consommable médical';

  @override
  String get medicalConsumable_fieldName => 'Nom du matériel';

  @override
  String get medicalConsumable_fieldInstitutionCode =>
      'Code de l\'établissement';

  @override
  String get medicalConsumable_fieldSutCode => 'Code/Annexe SUT';

  @override
  String get medicalConsumable_fieldUbbCode => 'Code UBB';

  @override
  String get medicalConsumable_fieldMaterialType => 'Type de matériel';

  @override
  String get medicalConsumable_fieldStatus => 'Statut';

  @override
  String get medicine_screenTitleFallback =>
      'Définition médicament/consommable médical';

  @override
  String get medicine_newButtonLabel => 'Nouveau médicament';

  @override
  String get medicine_defineMedicalConsumableButton =>
      'Définir un consommable médical';

  @override
  String get medicine_defineActiveIngredientButton =>
      'Définir un principe actif';

  @override
  String get medicine_defineDrugClassButton =>
      'Définir une classe de médicament';

  @override
  String get medicine_defineDrugTypeButton => 'Définir un type de médicament';

  @override
  String get medicine_createKitButton => 'Créer un kit de médicaments';

  @override
  String get medicine_defineMaterialTypeButton => 'Définir un type de matériel';

  @override
  String get medicine_checkboxLowerDose =>
      'Une dose inférieure à celle spécifiée peut être prise';

  @override
  String get medicine_checkboxRfid => 'RFID disponible';

  @override
  String get medicine_checkboxMultiPatientAccess => 'Accès multi-patients';

  @override
  String get medicine_checkboxSingleUse => 'Usage unique';

  @override
  String get medicine_checkboxCameraRecording => 'Enregistrement caméra';

  @override
  String get medicine_checkboxIndependentMaterial => 'Médicament libre';

  @override
  String get medicine_checkboxWastagePharmacyApproval =>
      'Exiger l\'approbation de la pharmacie pour la perte/élimination ?';

  @override
  String get medicine_checkboxWastageOrderRenewed =>
      'Renouveler la commande de perte ?';

  @override
  String get medicine_fieldPersonnel => 'Personnel';

  @override
  String get medicine_fieldStation => 'Station';

  @override
  String get medicine_fieldUnit => 'Unité';

  @override
  String get refillList_dialogTitle => 'Liste de remplissage de médicaments';

  @override
  String refillList_recordNoLabel(Object id) {
    return 'N° d\'enregistrement de remplissage : $id';
  }

  @override
  String refillList_createdDateLabel(String date) {
    return 'Date de création : $date';
  }

  @override
  String refillList_assignedUserNameLabel(String name) {
    return 'Assigné à : $name';
  }

  @override
  String get refillList_formTitleCreate => 'Créer une liste de remplissage';

  @override
  String get refillList_formTitleUpdate =>
      'Mettre à jour la liste de remplissage';

  @override
  String get refillList_fieldAssignedUser =>
      'Utilisateur assigné au remplissage';

  @override
  String get refillList_screenTitleFallback => 'Liste de remplissage';

  @override
  String get refillList_newButtonLabel => 'Nouvelle liste de remplissage';

  @override
  String get report_stationsCategoryTitle => 'Stations';

  @override
  String get refillList_cellValueYes => 'Oui';

  @override
  String get refillList_cellValueNo => 'Non';

  @override
  String get refillList_updateStatusTooltip => 'Mettre à jour le statut';

  @override
  String get refillList_defaultUnitFallback => 'Pièce';

  @override
  String get report_expiredItemsTitleFallback => 'Matériaux périmés';

  @override
  String get report_stationStockTitle => 'Stock de la cabine de station';

  @override
  String get report_stationTransactionTitleFallback =>
      'Mouvements de la station';

  @override
  String get report_hospitalStocksTitleFallback =>
      'Liste du Matériel Hospitalier';

  @override
  String get inconsistency_screenTitleFallback => 'Mouvements d\'incohérence';

  @override
  String get inconsistency_viewTooltip => 'Afficher';

  @override
  String get inconsistency_photoTooltip => 'Photo';

  @override
  String get hospitalization_formTitleNew => 'Saisir une nouvelle admission';

  @override
  String get hospitalization_formTitleEdit => 'Modifier l\'admission';

  @override
  String get hospitalization_fieldPatient => 'Patient';

  @override
  String get hospitalization_fieldCode => 'Code d\'admission';

  @override
  String get hospitalization_fieldDoctor => 'Médecin';

  @override
  String get hospitalization_fieldPhysicalService => 'Service physique';

  @override
  String get hospitalization_fieldInpatientService =>
      'Service d\'hospitalisation';

  @override
  String get hospitalization_fieldRoom => 'Chambre';

  @override
  String get hospitalization_roomDialogTitle => 'Sélectionner une chambre';

  @override
  String get hospitalization_fieldBed => 'Lit';

  @override
  String get hospitalization_bedDialogTitle => 'Sélectionner un lit';

  @override
  String get hospitalization_fieldAdmissionDate => 'Date d\'admission';

  @override
  String get hospitalization_fieldExitDate => 'Date de sortie';

  @override
  String get hospitalization_checkboxBaby => 'Nourrisson';

  @override
  String get hospitalization_screenTitleFallback => 'Opérations patient';

  @override
  String get hospitalization_editPatientTooltip =>
      'Modifier les informations du patient';

  @override
  String get hospitalization_showActiveTooltip =>
      'Afficher les admissions actives';

  @override
  String get hospitalization_showDischargedTooltip =>
      'Afficher les patients sortis';

  @override
  String get hospitalization_createButton => 'Créer une nouvelle admission';

  @override
  String get patient_formTitleNew => 'Créer un nouveau patient';

  @override
  String get patient_formTitleEdit => 'Modifier le patient';

  @override
  String get patient_fieldIdentity => 'N° d\'identité nationale';

  @override
  String get patient_fieldName => 'Prénom';

  @override
  String get patient_fieldSurname => 'Nom de famille';

  @override
  String get patient_fieldBirthDate => 'Date de naissance';

  @override
  String get patient_fieldGender => 'Sexe';

  @override
  String get patient_fieldWeight => 'Poids';

  @override
  String get patient_fieldMotherName => 'Nom de la mère';

  @override
  String get patient_fieldFatherName => 'Nom du père';

  @override
  String get patient_fieldPhone => 'Téléphone';

  @override
  String get patient_fieldAddress => 'Adresse';

  @override
  String get patient_fieldProtocolNo => 'N° de protocole';

  @override
  String get activeIngredient_dialogSelectTitle =>
      'Sélectionner un principe actif';

  @override
  String get activeIngredient_dialogTitle => 'Définition du principe actif';

  @override
  String get activeIngredient_formAddTitle => 'Ajouter un principe actif';

  @override
  String get activeIngredient_formEditTitle => 'Modifier le principe actif';

  @override
  String get activeIngredient_listEmptyTitle =>
      'Aucun principe actif pour le moment';

  @override
  String get activeIngredient_itemNameLabel => 'principe actif';

  @override
  String get assignment_screenTitle => 'Attribution de matériel de station';

  @override
  String get assignment_stationSelectPlaceholder => 'Sélectionnez une station';

  @override
  String get drugClass_dialogSelectTitle =>
      'Sélectionner une classe de médicament';

  @override
  String get drugClass_dialogTitle => 'Définition de la classe de médicament';

  @override
  String get drugClass_formAddTitle => 'Ajouter une classe de médicament';

  @override
  String get drugClass_formEditTitle => 'Modifier la classe de médicament';

  @override
  String get drugClass_formNameLabel => 'Nom de la classe de médicament';

  @override
  String get drugClass_listEmptyTitle =>
      'Aucune classe de médicament pour le moment';

  @override
  String get drugClass_itemNameLabel => 'classe de médicament';

  @override
  String get drugType_dialogSelectTitle => 'Sélectionner un type de médicament';

  @override
  String get drugType_dialogTitle => 'Définition du type de médicament';

  @override
  String get drugType_formAddTitle => 'Ajouter un type de médicament';

  @override
  String get drugType_formEditTitle => 'Modifier le type de médicament';

  @override
  String get drugType_formNameLabel => 'Nom du type de médicament';

  @override
  String get drugType_listEmptyTitle =>
      'Aucun type de médicament pour le moment';

  @override
  String get drugType_itemNameLabel => 'type de médicament';

  @override
  String get kit_formAddTitle => 'Nouveau kit';

  @override
  String get kit_formEditTitle => 'Modifier le kit';

  @override
  String get kit_formNameLabel => 'Nom du kit';

  @override
  String get kit_dialogSelectTitle => 'Sélectionner un kit';

  @override
  String get kit_dialogTitle => 'Définition du kit';

  @override
  String get kit_listEmptyTitle => 'Aucun kit pour le moment';

  @override
  String get kit_listManageContentTooltip => 'Gérer le contenu du kit';

  @override
  String get kit_itemNameLabel => 'kit';

  @override
  String get kitContent_formAddTitle => 'Ajouter le contenu du kit';

  @override
  String get kitContent_formEditTitle => 'Modifier le contenu du kit';

  @override
  String get kitContent_formMaterialLabel => 'Matériel';

  @override
  String get kitContent_formPieceLabel => 'Nombre de pièces';

  @override
  String get kitContent_dialogTitle => 'Définition du contenu du kit';

  @override
  String get kitContent_listEmptyTitle => 'Aucun contenu de kit pour le moment';

  @override
  String get kitContent_itemNameLabel => 'contenu';

  @override
  String get materialType_formAddTitle => 'Nouveau type de matériel';

  @override
  String get materialType_formEditTitle => 'Modifier le type de matériel';

  @override
  String get materialType_formNameLabel => 'Nom du type de matériel';

  @override
  String get materialType_dialogSelectTitle =>
      'Sélectionner un type de matériel';

  @override
  String get materialType_dialogTitle => 'Définition du type de matériel';

  @override
  String get materialType_listEmptyTitle =>
      'Aucun type de matériel pour le moment';

  @override
  String get materialType_itemNameLabel => 'type de matériel';

  @override
  String get role_formEditTitle => 'Modifier le rôle';

  @override
  String get role_formAddTitle => 'Ajouter un rôle';

  @override
  String get role_formNameLabel => 'Nom du rôle';

  @override
  String get role_screenTitle => 'Définition du rôle';

  @override
  String get role_screenAddButton => 'Nouveau rôle';

  @override
  String get role_deleteSuccessMessage => 'Rôle supprimé avec succès';

  @override
  String get unit_formAddTitle => 'Créer une nouvelle unité';

  @override
  String get unit_formEditTitle => 'Modifier l\'unité';

  @override
  String get unit_dialogTitle => 'Unité';

  @override
  String get unit_itemNameLabel => 'unité';

  @override
  String get unit_listEmptyTitle => 'Aucune unité pour le moment';

  @override
  String get user_categoryNormalLabel => 'Normal';

  @override
  String get user_categoryTimeBasedLabel => 'Limité dans le temps';

  @override
  String get user_categoryTemporaryLabel => 'Temporaire';

  @override
  String get user_deleteSuccessMessage => 'Utilisateur supprimé avec succès';

  @override
  String get user_validDateUpdateSuccessMessage =>
      'Date d\'expiration mise à jour';

  @override
  String get user_formEditTitle => 'Modifier l\'utilisateur';

  @override
  String get user_formCreateTitle => 'Créer un utilisateur';

  @override
  String get user_registrationNumberLabel =>
      'N° de registre de l\'établissement';

  @override
  String get user_nameLabel => 'Prénom';

  @override
  String get user_surnameLabel => 'Nom de famille';

  @override
  String get user_roleTypeLabel => 'Type de profession';

  @override
  String get user_usageTypeLabel => 'Type d\'utilisation';

  @override
  String get user_validUntilLabel => 'Date d\'expiration';

  @override
  String get user_emailLabel => 'E-mail';

  @override
  String get user_orderPermissionLabel => 'Achat sans commande';

  @override
  String get user_witnessedStationEntryLabel => 'Entrée de station avec témoin';

  @override
  String get user_kitPurchaseLabel => 'Achat de kit';

  @override
  String get user_badgeCardLabel => 'Badge';

  @override
  String get user_badgeCardHint => 'Scannez la carte';

  @override
  String get user_authorizedStationsLabel => 'Stations autorisées';

  @override
  String get user_usernameLabel => 'Nom d\'utilisateur';

  @override
  String get user_screenTitle => 'Liste des utilisateurs';

  @override
  String get user_screenAddButton => 'Nouvel utilisateur';

  @override
  String get user_bulkUpdateValidDateButton =>
      'Mettre à jour la date d\'expiration';

  @override
  String get user_validDateDialogTitle => 'Mettre à jour la date';

  @override
  String get user_validDateDialogSaveButton => 'Mettre à jour';

  @override
  String get user_newValidUntilLabel => 'Nouvelle date d\'expiration';

  @override
  String get user_nationalIdColumnHeader => 'N° d\'identité nationale';

  @override
  String get warning_formAddTitle => 'Nouvel avertissement';

  @override
  String get warning_formEditTitle => 'Modifier l\'avertissement';

  @override
  String get warning_formAddSubtitle =>
      'Renseignez les informations de l\'avertissement';

  @override
  String get warning_formEditSubtitle =>
      'Mettez à jour les informations de l\'avertissement';

  @override
  String get warning_formSubjectLabel => 'Objet de l\'avertissement';

  @override
  String get warning_formTextLabel => 'Texte de l\'avertissement';

  @override
  String get warning_screenTitle => 'Définition de l\'avertissement';

  @override
  String get dashboard_allSectionsLoadError =>
      'Les données n\'ont pas pu être chargées. Veuillez réessayer.';

  @override
  String get dashboard_sktCriticalRingLabel => 'Critique\n(<7 jours)';

  @override
  String get dashboard_sktWarningRingLabel => 'Avertissement\n(7-30 jours)';

  @override
  String get dashboard_sktExpiredRingLabel => 'Périmés';

  @override
  String get dashboard_sktStatusHeader => 'STATUT D\'EXPIRATION';

  @override
  String dashboard_sktItemCountBadge(int count) {
    return '$count articles';
  }

  @override
  String get dashboard_sktExpiredTag => 'EXPIRÉ';

  @override
  String get dashboard_sktDestroyHint => 'détruire';

  @override
  String dashboard_sktDaysRemainingLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'jours restants',
      one: 'jour restant',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsHeader => 'TRAITEMENTS À VENIR';

  @override
  String dashboard_pendingTreatmentsBadge(int count) {
    return '$count en attente';
  }

  @override
  String get dashboard_pendingFilterLabel => 'En attente';

  @override
  String get dashboard_urgentFilterLabel => 'Urgent';

  @override
  String get dashboard_treatmentSearchHint =>
      'Rechercher un patient ou un médicament...';

  @override
  String get dashboard_newAssignButton => 'Nouvelle attribution';

  @override
  String get dashboard_noTreatmentsAllFilter =>
      'Aucun enregistrement de traitement trouvé';

  @override
  String get dashboard_noTreatmentsPendingFilter =>
      'Aucun traitement en attente';

  @override
  String get dashboard_noTreatmentsUrgentFilter => 'Aucun traitement urgent';

  @override
  String get dashboard_priorityUrgentLabel => 'Urgent';

  @override
  String get dashboard_priorityNormalLabel => 'Normal';

  @override
  String get dashboard_priorityRoutineLabel => 'Routine';

  @override
  String get dashboard_statusPendingLabel => 'En attente';

  @override
  String get dashboard_statusDoneLabel => 'Distribué';

  @override
  String get dashboard_statusReturnedLabel => 'Retourné';

  @override
  String settings_sectionComingSoon(String label) {
    return 'Paramètres $label bientôt disponibles';
  }

  @override
  String get refund_masterScreenNotReady =>
      'L\'écran de retour de la cabine maître n\'est pas encore prêt.';

  @override
  String get core_cabinConn_managerNotFoundError =>
      'Carte de gestion introuvable.';

  @override
  String get core_cabinConn_disconnectedError => 'Connexion perdue';

  @override
  String get common_action_pullDrawerTitle => 'Ouvrez le tiroir';

  @override
  String get common_action_pullDrawerSubtitle =>
      'Le verrou est ouvert, veuillez tirer.';

  @override
  String get masterDrawer_openingLidTitle => 'Ouverture des couvercles';

  @override
  String get masterDrawer_openingLidSubtitle =>
      'Préparation des couvercles du tiroir cubique.';

  @override
  String get masterDrawer_readySubtitle =>
      'Terminez l\'opération et confirmez.';

  @override
  String get common_action_closeDrawerTitle => 'Fermez le tiroir';

  @override
  String get common_action_closeDrawerSubtitle =>
      'L\'opération est confirmée, veuillez fermer.';

  @override
  String get common_action_drawerClosed => 'Tiroir fermé';

  @override
  String get common_action_operationCompletedSubtitle =>
      'L\'opération est terminée.';

  @override
  String get common_action_drawerError => 'Erreur de tiroir';

  @override
  String common_error_unexpectedWithDetail(Object error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String masterDrawer_lidOpenFailedError(Object error) {
    return 'Le couvercle n\'a pas pu être ouvert : $error';
  }

  @override
  String get common_action_devicePreparing => 'Préparation de l\'appareil...';

  @override
  String common_error_connectionErrorWithDetail(Object error) {
    return 'Erreur de connexion : $error';
  }

  @override
  String get common_action_lockOpening => 'Ouverture du verrou...';

  @override
  String common_error_lockOpenFailedWithDetail(Object error) {
    return 'Le verrou n\'a pas pu être ouvert : $error';
  }

  @override
  String mobileDrawer_portSubtitle(int port) {
    return 'Tiroir $port';
  }

  @override
  String get mobileDrawer_openedSubtitle =>
      'Fermez le tiroir pour terminer l\'opération.';

  @override
  String get mobileDrawer_closedSubtitle => 'En attente de votre confirmation';

  @override
  String common_error_managerConnectFailedWithDetail(Object error) {
    return 'Impossible de se connecter à la carte de gestion : $error';
  }

  @override
  String mobileDrawer_openCommandFailedError(Object error) {
    return 'Impossible d\'envoyer la commande d\'ouverture du tiroir : $error';
  }

  @override
  String get mobileDrawer_statusTimeoutError =>
      'Délai d\'expiration lors de la lecture de l\'état du tiroir.';

  @override
  String get mobileDrawer_openNotConfirmedError =>
      'Impossible de confirmer que le tiroir s\'est ouvert.';

  @override
  String mobileDrawer_statusReadError(Object error) {
    return 'Une erreur s\'est produite lors de la lecture de l\'état du tiroir : $error';
  }

  @override
  String get patientPicker_searchHint => 'Rechercher un patient';

  @override
  String get patientPicker_orderlessToggleLabel => 'Sans commande';

  @override
  String get patientPicker_orderedToggleLabel => 'Avec commande';

  @override
  String get patientPicker_myPatientsToggleLabel => 'Mes patients';

  @override
  String get patientPicker_urgentPatientHint =>
      'Créez un dossier pour un patient urgent qui ne figure pas dans la liste.';

  @override
  String get patientPicker_createUrgentPatientButton =>
      'Créer un patient urgent';

  @override
  String get patientPicker_urgentPatientCreatedMessage =>
      'Patient urgent créé.';

  @override
  String get patientPicker_urgentPatientCardDescription =>
      'Un patient urgent a été créé. Pour revenir au flux normal, vous devez supprimer le patient urgent.';

  @override
  String get hw_cabinOps_serumSlaveModeError =>
      'La carte sérum n\'a pas pu être mise en mode esclave...';

  @override
  String hw_cabinOps_solenoidMissingError(Object port) {
    return 'Le port $port n\'a pas de solénoïde (.no).';
  }

  @override
  String hw_cabinOps_portOpenFailedError(Object port, Object response) {
    return 'Le port $port n\'a pas pu être ouvert. Réponse : $response';
  }

  @override
  String hw_cabinOps_masterDrawerOpenFailedError(
    Object row,
    Object port,
    Object drawer,
    Object response,
  ) {
    return 'Le tiroir maître n\'a pas pu être ouvert (ligne=$row, port=$port, tiroir=$drawer). Réponse : $response';
  }

  @override
  String hw_cabinOps_masterSerumOpenFailedError(Object row, Object response) {
    return 'Le tiroir sérum maître n\'a pas pu être ouvert (ligne=$row). Réponse : $response';
  }

  @override
  String get hw_cabinOps_sensorLostDuringCloseDetail =>
      'La communication avec le matériel a été perdue (le capteur ne répond pas pendant la surveillance de la fermeture).';

  @override
  String get hw_cabinOps_sensorLostDuringOpenDetail =>
      'La communication avec le matériel a été perdue (le capteur ne répond pas).';

  @override
  String hw_cabinOps_fullyOpenTimeoutDetail(Object timeout) {
    return 'Le tiroir n\'a pas atteint l\'état complètement ouvert dans le délai de $timeout.';
  }

  @override
  String hw_serial_connectFailedDetailedError(String portName) {
    return 'Impossible de se connecter au port $portName. Assurez-vous que l\'appareil est connecté et sous tension, et que le port n\'est pas utilisé par une autre application.';
  }

  @override
  String hw_serial_portConfigFailedError(String portName, Object error) {
    return 'Échec de la configuration du port ($portName) : $error';
  }

  @override
  String hw_serial_systemErrorSuffix(Object error) {
    return 'Erreur système : $error';
  }

  @override
  String get hw_serial_portInUseSuffix =>
      'Le port est peut-être utilisé par une autre application.';

  @override
  String hw_serial_readErrorWithDetail(Object error) {
    return 'Erreur de lecture du port : $error';
  }

  @override
  String get hw_serial_reconnectingStatus => 'Redémarrage de la connexion.';

  @override
  String hw_rfid_connectFailedError(Object error) {
    return 'Impossible de se connecter au lecteur RFID : $error';
  }

  @override
  String get hw_rfid_invalidResponseError =>
      'Une réponse invalide a été reçue.';

  @override
  String hw_rfid_unreachableError(Object error) {
    return 'Le lecteur RFID n\'a pas pu être joint : $error';
  }

  @override
  String get hw_rfid_testTimeoutError => 'Le test de connexion RFID a expiré.';

  @override
  String get hw_rfid_powerChangeBlockedError =>
      'Le réglage de puissance ne peut pas être modifié pendant que l\'inventaire est actif. Appelez d\'abord stopInventory().';

  @override
  String hw_rfid_setModeRejectedError(Object status) {
    return 'SetWorkingMode a été rejeté (statut=0x$status)';
  }

  @override
  String hw_rfid_setAntennaRejectedError(Object status) {
    return 'SetWorkingAntenna a été rejeté (statut=0x$status)';
  }

  @override
  String get hw_rfid_antennaConnFailedHint =>
      ' (erreur de connexion d\'antenne — l\'un des ports activés est vide)';

  @override
  String get hw_rfid_noAntennaConnectedError =>
      'Impossible de se connecter à une antenne (tous les ports sont vides).';

  @override
  String get hw_rfid_notConnectedError =>
      'Le service RFID n\'est pas connecté.';

  @override
  String get hw_rfid_commandPendingError =>
      'La commande précédente est toujours en attente d\'une réponse.';

  @override
  String hw_rfid_commandTimeoutError(Object cmd) {
    return 'La réponse à la commande a expiré (cmd=0x$cmd).';
  }

  @override
  String hw_rfid_commandErrorWithDetail(Object error) {
    return 'Erreur de commande : $error';
  }

  @override
  String get hw_rfid_mockNotConnectedError =>
      'Le service RFID simulé n\'est pas connecté.';

  @override
  String get operationStatus_fatalErrorLabel => 'Erreur critique';

  @override
  String get operationStatus_errorLabel => 'Erreur';

  @override
  String get operationStatus_rollingBackLabel =>
      'Annulation de l\'opération en cours';

  @override
  String get operationStatus_finalizingLabel =>
      'Finalisation de l\'opération en cours';

  @override
  String get operationStatus_drugsStillInCabinetLabel =>
      'Les médicaments sont toujours dans la cabine';

  @override
  String get operationStatus_incompleteLabel => 'Incomplet / Incohérent';

  @override
  String get operationStatus_scanningLabel => 'Analyse en cours';

  @override
  String get operationStatus_reportedMissingLabel => 'Signalé manquant';

  @override
  String get operationBanner_unplannedMovementTitle =>
      'Mouvement imprévu détecté';

  @override
  String operationBanner_unplannedMovementMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$countString étiquettes ont été retirées de la cabine de manière imprévue.',
      one:
          '$countString étiquette a été retirée de la cabine de manière imprévue.',
    );
    return '$_temp0 Un signalement sera envoyé à la pharmacie.';
  }

  @override
  String get operationBanner_unexpectedTagBlockingTitle =>
      'Étiquette(s) n\'appartenant pas à cette cabine détectée(s)';

  @override
  String get operationBanner_unexpectedTagWarningTitle =>
      'Médicament inattendu';

  @override
  String operationBanner_unexpectedTagBlockingMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'les $countString étiquettes suivantes',
      one: 'la $countString étiquette suivante',
    );
    return 'Retirez $_temp0 du tiroir pour continuer.';
  }

  @override
  String operationBanner_unexpectedTagWarningMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString étiquettes n\'appartenant pas',
      one: '$countString étiquette n\'appartenant pas',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ont été lues',
      one: 'a été lue',
    );
    return '$_temp0 à cette cabine $_temp1. Veuillez la/les retirer.';
  }

  @override
  String get operationBanner_missingStockTitle => 'Stock manquant';

  @override
  String operationBanner_missingStockMessage(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString médicaments n\'ont pas été trouvés',
      one: '$countString médicament n\'a pas été trouvé',
    );
    return '$_temp0 dans la cabine. Cela sera signalé comme stock manquant une fois terminé.';
  }

  @override
  String get common_okButton => 'OK';

  @override
  String get cabinPatientPicker_searchHint =>
      'Rechercher un patient, une chambre, un lit ou un service...';

  @override
  String get common_unknownPatientFallback => 'Patient inconnu';

  @override
  String get patientListPanel_searchHint => 'Rechercher un patient...';

  @override
  String rxItemCard_maxQuantitySuffix(String max, String unit) {
    return '/ max. $max $unit';
  }

  @override
  String get census_extraStockSummaryMessage =>
      'Le stock excédentaire sera signalé à la fin de l\'opération.';

  @override
  String get cabinOperation_hint_scanning =>
      'Analyse de la cabine en cours, veuillez patienter';

  @override
  String get census_hint_waitingClose =>
      'Enregistré — fermez le tiroir pour terminer le comptage';

  @override
  String get census_hint_closedEarly =>
      'Le tiroir s\'est fermé prématurément — vous pouvez réessayer ou annuler';

  @override
  String get cabinOperation_hint_error =>
      'Une erreur s\'est produite — vous pouvez réessayer';

  @override
  String get census_hint_unexpectedTag =>
      'Une étiquette n\'appartenant pas à cette cabine est présente — retirez-la pour continuer';

  @override
  String get census_hint_readyToComplete =>
      'Appuyez sur le bouton pour terminer le comptage';

  @override
  String get cabinOperation_action_closeDrawer => 'Fermez le tiroir';

  @override
  String get census_label_counted => 'Compté';

  @override
  String get census_label_excess => 'Excédent';

  @override
  String get cabinOperation_label_unexpectedTag => 'Étranger';

  @override
  String get intake_error_witnessRequired =>
      'Une connexion de témoin est requise.';

  @override
  String get intake_error_noValidTargets =>
      'L\'entrée n\'a pas pu être effectuée pour les médicaments sélectionnés.';

  @override
  String get intake_error_noDrawerFound =>
      'Aucun tiroir trouvé pour le prélèvement.';

  @override
  String get intake_hint_noStock => 'Il n\'y a pas de stock dans la cabine';

  @override
  String intake_label_witnessName(String name) {
    return 'Témoin : $name';
  }

  @override
  String get intake_hint_witnessRequired => 'Connexion de témoin requise';

  @override
  String get intake_status_checking => 'Vérification en cours...';

  @override
  String get intake_status_readyToTake => 'Prêt pour le prélèvement';

  @override
  String get intake_status_checkFailed => 'Échec de la vérification';

  @override
  String get intake_emptyState_selectMedicine =>
      'Sélectionnez un médicament pour commencer l\'entrée.';

  @override
  String intake_label_multiMedicine(int count) {
    return '$count médicaments différents';
  }

  @override
  String intake_label_takenAmount(String amount, String unit) {
    return 'Prélevé : $amount $unit';
  }

  @override
  String intake_label_countFieldLabel(String unit) {
    return 'Comptage ($unit)';
  }

  @override
  String get intake_hint_nextCellOpens =>
      'La case suivante s\'ouvrira une fois que vous aurez confirmé.';

  @override
  String get intake_hint_confirmCloses =>
      'Le tiroir se fermera une fois que vous aurez confirmé.';

  @override
  String get intake_hint_searchMedicine =>
      'Rechercher un médicament (nom / code-barres)';

  @override
  String get intake_hint_selectionLocked =>
      'Entrée en cours — la sélection est verrouillée.';

  @override
  String get intake_hint_autoQueueOrder =>
      'Les tiroirs s\'ouvriront dans l\'ordre du chemin le plus court.';

  @override
  String intake_info_witnessAutoAssigned(String name) {
    return '$name a également été désigné comme témoin pour ce médicament.';
  }

  @override
  String get intake_error_queueTitle => 'L\'entrée n\'a pas pu être terminée';

  @override
  String get intake_error_queueMessage =>
      'Remettez les médicaments à l\'endroit où vous les avez pris.';

  @override
  String get intake_error_selfWitness =>
      'L\'utilisateur effectuant l\'opération ne peut pas également en être témoin.';

  @override
  String intake_success_witnessConfirmed(String name) {
    return '$name a été confirmé comme témoin.';
  }

  @override
  String get intake_witnessDialog_title => 'Vérification du témoin';

  @override
  String get intake_witnessDialog_usernameLabel =>
      'Nom d\'utilisateur du témoin';

  @override
  String get intake_witnessDialog_usernameRequired =>
      'Saisissez un nom d\'utilisateur';

  @override
  String get intake_witnessDialog_passwordLabel => 'Mot de passe du témoin';

  @override
  String get intake_witnessDialog_passwordRequired =>
      'Saisissez un mot de passe';

  @override
  String get intake_witnessDialog_confirmButton => 'Confirmer le témoin';

  @override
  String get intake_witnessDialog_anyoneInfo =>
      'Tout membre du personnel peut être témoin de cette opération.';

  @override
  String intake_witnessDialog_authorizedWitnesses(int count) {
    return 'Témoins autorisés ($count)';
  }

  @override
  String cabinOperation_hint_fatalError(String message) {
    return 'Une erreur critique s\'est produite : $message';
  }

  @override
  String get cabinOperation_hint_completed => 'Opération terminée';

  @override
  String get cabinOperation_hint_waitingCloseGeneric =>
      'Enregistré. Fermez le tiroir pour terminer l\'opération';

  @override
  String get cabinOperation_hint_closedEarlyGeneric =>
      'Le tiroir a été fermé. Vous pouvez annuler ou continuer là où vous vous êtes arrêté';

  @override
  String get cabinOperation_hint_ready =>
      'Prêt — vous pouvez terminer l\'opération';

  @override
  String get intake_hint_extraPlacement =>
      'Un médicament qui ne devrait pas se trouver dans la cabine a été chargé, veuillez le retirer.';

  @override
  String get intake_hint_takeItems =>
      'Prenez les médicaments, puis terminez l\'opération';

  @override
  String get cabinOperation_action_completeGeneric => 'Terminer l\'opération';

  @override
  String get rfidStatus_notFound => 'Introuvable';

  @override
  String get rfidStatus_scanning => 'Analyse en cours';

  @override
  String get intake_label_noRfid => 'Pas de RFID';

  @override
  String get cabinOperation_label_selected => 'Sélectionné';

  @override
  String get intake_label_readInCabin => 'Lu dans la cabine';

  @override
  String intake_label_tagCount(int count) {
    return '$count étiquettes';
  }

  @override
  String get intake_label_takenCount => 'Prélevé';

  @override
  String get intake_label_unauthorizedTake => 'Prélèvement non autorisé';

  @override
  String get intake_error_retryOrFinish =>
      'Vous pouvez réessayer, ou terminer l\'opération en reprenant les médicaments que vous avez placés.';

  @override
  String get refill_label_placed => 'Placé';

  @override
  String get refill_label_placedCount => 'Placé';

  @override
  String refill_label_placedProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String get cabinOperation_label_unplanned => 'Imprévu';

  @override
  String get refill_label_extraTag => 'Étiquette en trop';

  @override
  String get refill_error_retry => 'Vous pouvez réessayer.';

  @override
  String get unload_hint_waitingClose =>
      'Enregistré — fermez le tiroir pour terminer le déchargement';

  @override
  String get unload_hint_closedEarly =>
      'Le tiroir s\'est fermé prématurément — vous pouvez réessayer ou annuler';

  @override
  String get unload_hint_readyToComplete =>
      'Appuyez sur le bouton pour terminer le déchargement';

  @override
  String get unload_label_unloaded => 'Déchargé';

  @override
  String unload_label_unloadProgress(Object done, Object total) {
    return '$done / $total';
  }

  @override
  String wizard_stepBadge(int step, int total) {
    return 'Étape $step / $total';
  }

  @override
  String get wizard_step4Header => 'Configuration du tiroir';

  @override
  String get wizard_step4SubtitleMobile =>
      'Définissez le nombre de tiroirs, les sections internes et les connexions de port de la cabine mobile.';

  @override
  String get wizard_step4SubtitleMaster =>
      'La structure interne de la cabine sera lue automatiquement depuis l\'appareil.';

  @override
  String get wizard_backButton => 'Retour';

  @override
  String get wizard_testCabinConnectionButton =>
      'Tester la connexion de la cabine';

  @override
  String get wizard_testingInProgress => 'Test en cours…';

  @override
  String get wizard_connectionSuccessLabel => 'Connexion réussie';

  @override
  String get wizard_retestLink => 'Tester à nouveau';

  @override
  String get wizard_cabinConnectionErrorFallback =>
      'Impossible d\'établir une connexion. Vérifiez les paramètres du port.';

  @override
  String get wizard_testRfidConnectionButton =>
      'Tester la connexion de l\'antenne';

  @override
  String wizard_rfidFirmwareInfo(String firmwareVersion, Object power) {
    return '· FW $firmwareVersion  $power dBm';
  }

  @override
  String get wizard_rfidConnectionErrorFallback =>
      'Impossible d\'établir une connexion. Vérifiez les paramètres IP et de port.';

  @override
  String get wizard_portLabel => 'Port';

  @override
  String get wizard_rfidReaderToggleLabel => 'Possède un lecteur RFID';

  @override
  String get wizard_rfidIpAddressLabel => 'Adresse IP RFID';

  @override
  String get wizard_rfidPortFieldLabel => 'Port RFID';

  @override
  String get wizard_drawerCountRangeHint => '1 à 8 tiroirs';

  @override
  String get wizard_sameConfigToggleLabel =>
      'Tous les tiroirs ont la même structure';

  @override
  String get wizard_sameConfigToggleOnDesc =>
      'Tous les tiroirs utilisent la même configuration de lignes/colonnes';

  @override
  String get wizard_sameConfigToggleOffDesc =>
      'Si désactivé, les lignes/colonnes peuvent être définies séparément pour chaque tiroir';

  @override
  String wizard_drawerRowCellSummary(int rowCount, int totalCells) {
    return '$rowCount lignes · $totalCells cellules';
  }

  @override
  String wizard_drawerPortLabel(Object portNumber) {
    return 'Port $portNumber';
  }

  @override
  String wizard_rowLabel(int rowIndex) {
    return 'LIGNE $rowIndex';
  }

  @override
  String get wizard_serviceDetailsLoadError =>
      'Impossible de charger les détails du service.';

  @override
  String get wizard_stationDetailsLoadError =>
      'Impossible de charger les détails de la station.';

  @override
  String get wizard_stationsLoadErrorFallback =>
      'Impossible de charger les stations.';

  @override
  String get wizard_noStationsFoundMessage =>
      'Aucune station enregistrée n\'a été trouvée.';

  @override
  String get wizard_noRoomsDefinedMessage =>
      'Aucune chambre n\'est définie pour cette station.';

  @override
  String wizard_selectedRoomCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chambres',
      one: '$count chambre',
    );
    return '$_temp0';
  }

  @override
  String wizard_roomSelectionFraction(int selected, int total) {
    return '$selected/$total';
  }

  @override
  String get refill_hint_extraPlacement =>
      'Une étiquette autre que les médicaments sélectionnés a été placée, veuillez la retirer';

  @override
  String get refill_hint_placeItems =>
      'Placez les médicaments, puis terminez l\'opération';

  @override
  String get appException_networkUnavailable =>
      'Impossible de se connecter au serveur. Vérifiez votre connexion réseau.';

  @override
  String get appException_timeout =>
      'Le serveur n\'a pas répondu. Veuillez réessayer.';

  @override
  String appException_serviceError5xx(Object statusCode) {
    return 'Erreur du serveur ($statusCode). Veuillez réessayer.';
  }

  @override
  String appException_serviceErrorOther(Object statusCode) {
    return 'L\'opération n\'a pas pu être terminée ($statusCode).';
  }

  @override
  String get appException_malformedData =>
      'Des données inattendues ont été reçues du serveur.';

  @override
  String get appException_emptyResponse =>
      'Le serveur a renvoyé une réponse vide.';

  @override
  String appException_validationField(String field) {
    return 'Le champ $field est invalide.';
  }

  @override
  String get appException_validationGeneric =>
      'Les informations saisies sont invalides.';

  @override
  String get appException_mapping =>
      'Une erreur s\'est produite lors du traitement des données.';

  @override
  String get appException_cache => 'Impossible de lire les données locales.';

  @override
  String get appException_staleCache =>
      'Impossible d\'accéder aux données à jour. Veuillez vérifier la connexion.';

  @override
  String appException_notFoundWithType(String resourceType) {
    return '$resourceType introuvable.';
  }

  @override
  String get appException_notFoundGeneric => 'Enregistrement introuvable.';

  @override
  String get appException_unexpected =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get appException_serialPort =>
      'Impossible de se connecter au port série. Veuillez contacter le service technique.';

  @override
  String get appException_custom =>
      'Une erreur inconnue s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get dataError_emptyResponse => 'Le serveur a renvoyé une réponse vide';

  @override
  String get dataError_malformedResponse =>
      'La réponse n\'a pas pu être traitée';

  @override
  String get dataError_requestTimeout => 'La requête a expiré';

  @override
  String get dataError_networkUnavailable =>
      'Impossible de se connecter au réseau';

  @override
  String get dataError_genericApiError =>
      'Nous avons rencontré une erreur. Veuillez réessayer plus tard.';

  @override
  String get dataError_requestCancelled => 'La requête a été annulée';

  @override
  String get dataError_envelopeErrorFallback => 'Erreur';

  @override
  String get authError_invalidTokenResponse =>
      'Une réponse de jeton invalide a été reçue du serveur';

  @override
  String get authError_userInfoFetchFailed =>
      'Impossible de récupérer les informations utilisateur';

  @override
  String get authError_userInfoEmpty =>
      'Les informations utilisateur renvoyées étaient vides';

  @override
  String get authError_genericLoginError => 'Une erreur s\'est produite';

  @override
  String get authError_invalidCredentialsMock =>
      'Nom d\'utilisateur ou mot de passe incorrect.';

  @override
  String get dataGuard_deleteActiveIngredientIdEmpty =>
      'L\'ID du principe actif à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteBranchIdEmpty =>
      'L\'ID de la spécialité à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteCabinIdEmpty =>
      'L\'ID de la cabine à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDosageFormIdEmpty =>
      'L\'ID de la forme posologique à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDrugClassIdEmpty =>
      'L\'ID de la classe de médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteFirmIdEmpty =>
      'L\'ID de l\'entreprise à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteDrugTypeIdEmpty =>
      'L\'ID du type de médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteHospitalizationIdEmpty =>
      'L\'ID de l\'admission à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteKitIdEmpty =>
      'L\'ID du kit à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteKitContentIdEmpty =>
      'L\'ID du contenu du kit à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteMaterialTypeIdEmpty =>
      'L\'ID du type de matériel à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteMedicineIdEmpty =>
      'L\'ID du médicament à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deletePatientIdEmpty =>
      'L\'ID du patient à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteRoleIdEmpty =>
      'L\'ID du rôle à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteServiceIdEmpty =>
      'L\'ID du service à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteStationIdEmpty =>
      'L\'ID de la station à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteUnitIdEmpty =>
      'L\'ID de l\'unité à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteWarehouseIdEmpty =>
      'L\'ID de l\'entrepôt à supprimer ne peut pas être vide';

  @override
  String get dataGuard_deleteWarningIdEmpty =>
      'L\'ID de l\'avertissement à supprimer ne peut pas être vide';

  @override
  String get dataGuard_updatePatientIdEmpty =>
      'L\'ID du patient à mettre à jour ne peut pas être vide';

  @override
  String get dataGuard_updateHospitalizationIdEmpty =>
      'L\'ID de l\'admission à mettre à jour ne peut pas être vide';

  @override
  String get dataGuard_dosageFormNameRequired =>
      'Le nom de la forme galénique est requis';

  @override
  String get dataGuard_roleNameRequired => 'Le nom du rôle est requis';

  @override
  String get dataGuard_branchNameRequired => 'Le nom de la branche est requis';

  @override
  String get dataGuard_warehouseNameRequired =>
      'Le nom de l\'entrepôt est requis';

  @override
  String get dataGuard_warningTextRequired =>
      'Le texte de l\'avertissement est requis';

  @override
  String get dataGuard_activeIngredientNameRequired =>
      'Le champ nom est requis';

  @override
  String get core_genericErrorRetryMessage =>
      'Une erreur s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get core_genericErrorShortMessage => 'Une erreur s\'est produite.';

  @override
  String get common_defaultReportTitle => 'Rapport';

  @override
  String fileExport_savedMessage(String path) {
    return 'Fichier enregistré : $path';
  }

  @override
  String fileExport_pdfSaveErrorMessage(Object error) {
    return 'Erreur d\'enregistrement du PDF : $error';
  }

  @override
  String fileExport_printErrorMessage(Object error) {
    return 'Erreur d\'impression : $error';
  }

  @override
  String get fileExport_saveDialogTitle => 'Enregistrer le fichier';

  @override
  String fileExport_saveErrorMessage(Object error) {
    return 'Erreur d\'enregistrement du fichier : $error';
  }

  @override
  String fileExport_saveToDesktopErrorMessage(Object error) {
    return 'Erreur lors de l\'enregistrement sur le bureau : $error';
  }

  @override
  String fileExport_savedSuccessMessage(String path) {
    return 'Fichier enregistré avec succès : $path';
  }

  @override
  String get fileExport_saveCancelledMessage =>
      'L\'enregistrement du fichier a été annulé';

  @override
  String get fileExport_excelCreateFailedMessage =>
      'Impossible de créer le fichier Excel';

  @override
  String fileExport_excelExportFailedMessage(Object error) {
    return 'L\'export Excel a échoué : $error';
  }

  @override
  String fileExport_tableExportFailedMessage(Object error) {
    return 'L\'export du tableau a échoué : $error';
  }

  @override
  String get cabinCore_createError =>
      'Une erreur s\'est produite lors de la création de la cabine. Veuillez réessayer plus tard.';

  @override
  String get cabinCore_activeCabinNotFound => 'Aucune cabine active trouvée';

  @override
  String get cabinCore_mobileCabinDesignNotFound =>
      'Conception de cabine mobile introuvable';

  @override
  String get cabinCore_cabinDesignNotFound =>
      'Conception de cabine introuvable';

  @override
  String get cabinCore_createdButIdMissing =>
      'La cabine a été créée mais son ID n\'a pas pu être récupéré.';

  @override
  String get cabinCore_definitionsNotFound =>
      'Les définitions n\'ont pas pu être récupérées.';

  @override
  String get cabinCore_noCardsFound => 'Aucune carte n\'a été trouvée.';

  @override
  String get cabinCore_noMatchingDrawerFound =>
      'Aucun tiroir correspondant n\'a été trouvé.';

  @override
  String get cabinCore_designDataNotFound =>
      'Aucune donnée trouvée à enregistrer.';

  @override
  String get cabinCore_targetDrawerNotFound => 'Tiroir/case cible introuvable';

  @override
  String get cabinCore_unknownMedicineFallback => 'Médicament inconnu';

  @override
  String get cabinAssignmentList_selectColumn => 'Sélectionner';

  @override
  String get cabinAssignmentList_medicineColumn => 'Médicament';

  @override
  String get cabinAssignmentList_locationColumn => 'Emplacement';

  @override
  String get cabinAssignmentList_stockColumn => 'Stock';

  @override
  String get cabinAssignmentList_fillLevelColumn => 'Niveau de remplissage';

  @override
  String cabinAssignmentList_cubicLocationLabel(
    Object drawer,
    Object column,
    Object row,
  ) {
    return 'Tiroir $drawer - Colonne $column - Ligne $row';
  }

  @override
  String cabinAssignmentList_unitLocationLabel(Object drawer, Object cell) {
    return 'Tiroir $drawer - Case $cell';
  }

  @override
  String get cabinOverview_panelTitle => 'APERÇU DE LA CABINE';

  @override
  String get cabinOverview_cubicDrawerSubtitle => 'Tiroir cubique';

  @override
  String get cabinOverview_unitDoseDrawerSubtitle => 'Tiroir dose unitaire';

  @override
  String get cabinOverview_cubicTypeLabel => 'CUBIQUE';

  @override
  String get cabinOverview_unitDoseTypeLabel => 'DOSE UNITAIRE';

  @override
  String get cabinOverview_returnMergedCellLabel => 'RETOUR';

  @override
  String get cabinOverview_legendFillingLabel => 'En cours de remplissage';

  @override
  String get cabinOverview_legendCompletedLabel => 'Terminé';

  @override
  String get cabinOverview_legendQueuedLabel => 'En attente';

  @override
  String get cabinOverview_locationGuideLabel => 'GUIDE D\'EMPLACEMENT';

  @override
  String get prescriptionCore_createError =>
      'Une erreur s\'est produite lors de la création de l\'ordonnance. Veuillez réessayer plus tard.';

  @override
  String get prescriptionCore_rfidTagNotFoundInReader =>
      'Aucune étiquette RFID trouvée dans la zone du lecteur.';

  @override
  String prescriptionCore_rfidReadErrorWithDetail(Object error) {
    return 'Une erreur s\'est produite lors de la lecture de l\'étiquette RFID : $error';
  }

  @override
  String get prescriptionCore_actionApproveTitle =>
      'Approuver les demandes sélectionnées';

  @override
  String get prescriptionCore_actionCancelTitle =>
      'Annuler les demandes sélectionnées';

  @override
  String get prescriptionCore_actionRejectTitle =>
      'Rejeter les demandes sélectionnées';

  @override
  String get prescriptionCore_actionRejectAfterApproveTitle =>
      'Rejeter les demandes sélectionnées';

  @override
  String get tableCore_roleNameColumn => 'Nom du rôle';

  @override
  String get tableCore_warningSubjectColumn => 'Objet de l\'avertissement';

  @override
  String get tableCore_warningTextColumn => 'Texte de l\'avertissement';

  @override
  String get tableCore_warehouseCodeColumn => 'Code de l\'entrepôt';

  @override
  String get tableCore_warehouseNameColumn => 'Nom de l\'entrepôt';

  @override
  String get tableCore_warehouseManagerColumn => 'Responsable de l\'entrepôt';

  @override
  String get tableCore_dosageFormBranchColumn => 'Nom de la spécialité';

  @override
  String get tableCore_firmIdColumn => 'ID';

  @override
  String get tableCore_firmNameColumn => 'Nom';

  @override
  String get tableCore_firmTypeColumn => 'Type d\'entreprise';

  @override
  String get tableCore_firmTaxOfficeColumn => 'Centre des impôts';

  @override
  String get tableCore_firmTaxNoColumn => 'N° fiscal';

  @override
  String get tableCore_kitNameColumn => 'Nom du kit';

  @override
  String get tableCore_kitContentMaterialNameColumn => 'Nom du matériel';

  @override
  String get tableCore_kitContentPieceColumn => 'Nombre de pièces';

  @override
  String get tableCore_drugTypeColumn => 'Type de médicament';

  @override
  String get tableCore_drugClassColumn => 'Classe de médicament';

  @override
  String get tableCore_materialTypeColumn => 'Type de matériel';

  @override
  String get tableCore_stationCodeColumn => 'Code de la station';

  @override
  String get tableCore_stationNameColumn => 'Nom de la station';

  @override
  String get tableCore_stationDrugWarehouseColumn => 'Entrepôt de médicaments';

  @override
  String get tableCore_stationDrugColumn => 'Médicament';

  @override
  String get tableCore_stationConsumableWarehouseColumn =>
      'Entrepôt de consommables médicaux';

  @override
  String get tableCore_stationConsumableColumn => 'Consommable médical';

  @override
  String get tableCore_stationWorkingTypeColumn => 'Type de fonctionnement';

  @override
  String get tableCore_hospitalizationProtocolNoColumn => 'N° de protocole';

  @override
  String get tableCore_hospitalizationNationalIdColumn =>
      'N° d\'identité nationale';

  @override
  String get tableCore_hospitalizationPatientColumn => 'Patient';

  @override
  String get tableCore_patientRowNationalIdColumn =>
      'Identité nationale du patient';

  @override
  String get tableCore_patientRowFullNameColumn => 'Nom complet';

  @override
  String get tableCore_inconsistencyCabinColumn => 'Cabine';

  @override
  String get tableCore_inconsistencyRowNoColumn => 'N° de ligne';

  @override
  String get tableCore_inconsistencyCellColumn => 'Case';

  @override
  String get tableCore_inconsistencyExpectedColumn => 'Attendu';

  @override
  String get tableCore_inconsistencyCountedColumn => 'Quantité comptée';

  @override
  String get tableCore_stockTransactionDateColumn => 'Date';

  @override
  String get tableCore_stockTransactionBarcodeColumn => 'Code-barres';

  @override
  String get tableCore_stockTransactionTypeColumn => 'Type de transaction';

  @override
  String get tableCore_stockTransactionQuantityColumn => 'Quantité';

  @override
  String get tableCore_stockTransactionPreviousQuantityColumn =>
      'Quantité avant mouvement';

  @override
  String get tableCore_stockTransactionActorColumn => 'Effectué par';

  @override
  String get tableCore_serviceColumn => 'Service';

  @override
  String get tableCore_admissionDateColumn => 'Date d\'admission';

  @override
  String get tableCore_dischargeDateColumn => 'Date de sortie';

  @override
  String get tableCore_materialColumn => 'Matériel';

  @override
  String get tableCore_prescriptionMedicineColumn => 'Médicament';

  @override
  String get tableCore_prescriptionDoseColumn => 'Dose';

  @override
  String get tableCore_prescriptionApplicationUserColumn => 'Appliqué par';

  @override
  String get tableCore_prescriptionAppliedQuantityColumn =>
      'Quantité appliquée';

  @override
  String get tableCore_prescriptionApplicationDateColumn =>
      'Date d\'application';

  @override
  String get tableCore_prescriptionReturnUserColumn => 'Retourné par';

  @override
  String get tableCore_prescriptionReturnQuantityColumn => 'Quantité retournée';

  @override
  String get tableCore_prescriptionReturnDateColumn => 'Date de retour';

  @override
  String get tableCore_prescriptionWastageUserColumn => 'Gaspillé par';

  @override
  String get tableCore_prescriptionWastageDateColumn => 'Date de gaspillage';

  @override
  String get tableCore_prescriptionDestructionUserColumn => 'Détruit par';

  @override
  String get tableCore_prescriptionDestructionDateColumn =>
      'Date de destruction';

  @override
  String get tableCore_prescriptionStatusColumn => 'Statut';

  @override
  String get enumCore_statusActive => 'Actif';

  @override
  String get enumCore_statusPassive => 'Inactif';

  @override
  String get enumCore_warehouseTypeMain => 'Entrepôt principal';

  @override
  String get enumCore_firmTypeSupplier => 'Fournisseur';

  @override
  String get enumCore_firmTypeCustomer => 'Client';

  @override
  String get enumCore_firmTypeManufacturer => 'Fabricant';

  @override
  String get enumCore_warningSubjectUntimelyPurchase => 'Achat intempestif';

  @override
  String get enumCore_warningSubjectWaste => 'Perte';

  @override
  String get enumCore_warningSubjectInconsistencyResolution =>
      'Résolution d\'incohérence';

  @override
  String get enumCore_warningSubjectDisposal => 'Élimination';

  @override
  String get enumCore_stockTxKindRefill => 'Remplissage de Matériel';

  @override
  String get enumCore_stockTxKindStockOut => 'Sortie de Stock';

  @override
  String get enumCore_stockTxKindConsistent => 'Comptage Conforme';

  @override
  String get enumCore_stockTxKindReturnInward => 'Réception de Retour';

  @override
  String get enumCore_stockTxKindWastage => 'Gaspillage';

  @override
  String get enumCore_stockTxTypeIn => 'Entrée de stock';

  @override
  String get enumCore_stockTxTypeOut => 'Sortie de stock';

  @override
  String get enumCore_stockTxKindReturn => 'Retour de Matériel';

  @override
  String get enumCore_stockTxKindExcess => 'Excédent de Comptage';

  @override
  String get enumCore_stockTxKindShortage => 'Manque de Comptage';

  @override
  String get enumCore_stockTxKindPurchase => 'Réception de Matériel';

  @override
  String get enumCore_stockTxKindUnload => 'Déchargement de Matériel';

  @override
  String get enumCore_countTypeNone => 'Aucun comptage';

  @override
  String get enumCore_countTypeNormal => 'Comptage normal';

  @override
  String get enumCore_countTypeBlind => 'Comptage à l\'aveugle';

  @override
  String get enumCore_returnTypeToOrigin => 'Retour à l\'origine';

  @override
  String get enumCore_returnTypeToDrawer => 'Retour au tiroir';

  @override
  String get enumCore_returnTypeToReturnBox => 'Retour à la boîte de retour';

  @override
  String get enumCore_returnTypeToPharmacy => 'Retour à la pharmacie';

  @override
  String get enumCore_requestTypeNormal => 'Demande normale';

  @override
  String get enumCore_requestTypeUrgent => 'Demande urgente';

  @override
  String get enumCore_purchaseTypeBoth => 'Les deux';

  @override
  String get enumCore_prescriptionTypeWhite => 'Ordonnance blanche';

  @override
  String get enumCore_prescriptionTypeSerumWhite =>
      'Sérum (ordonnance blanche)';

  @override
  String get enumCore_prescriptionTypeRed => 'Ordonnance rouge';

  @override
  String get enumCore_prescriptionTypeGreen => 'Ordonnance verte';

  @override
  String get enumCore_prescriptionTypeOrange => 'Ordonnance orange';

  @override
  String get enumCore_prescriptionTypePurple => 'Ordonnance violette';

  @override
  String get enumCore_refillListStatusToCollect => 'À rassembler';

  @override
  String get enumCore_refillListStatusCollected => 'Rassemblé';

  @override
  String get enumCore_refillListStatusSent => 'Envoyé';

  @override
  String get enumCore_fillingTypeMinimum => 'Minimum';

  @override
  String get enumCore_fillingTypeCritical => 'Critique';

  @override
  String get enumCore_fillingTypeMaximum => 'Maximum';

  @override
  String get enumCore_patientFilterOrderTimeReached =>
      'Heure de commande atteinte';

  @override
  String get enumCore_patientFilterAll => 'Tous les patients';

  @override
  String get enumCore_patientFilterTimeNotReached => 'Heure non atteinte';

  @override
  String get enumCore_patientFilterTimePassed => 'Heure dépassée';

  @override
  String get enumCore_patientFilterReturnable => 'Retour possible';

  @override
  String get enumCore_patientFilterWasteDisposable =>
      'Perte/élimination possible';

  @override
  String get enumCore_cabinTypeStandard => 'Armoire Maître';

  @override
  String get enumCore_cabinTypeCloset => 'Armoire';

  @override
  String get enumCore_cabinTypeFridge => 'Réfrigérateur';

  @override
  String get enumCore_cabinTypeOpenCloset => 'Armoire ouverte';

  @override
  String get enumCore_cabinTypeMobile => 'Cabine mobile';

  @override
  String get enumCore_cabinTypeExternalReturn => 'Cabine de retour externe';

  @override
  String get enumCore_cabinTypeOpen => 'Cabine ouverte';

  @override
  String get enumCore_cabinTypeSerum => 'Cabine à sérum';

  @override
  String get enumCore_cabinOpModeAssignDrug => 'Attribution de médicament';

  @override
  String get enumCore_cabinOpModeRefill => 'Remplissage de médicament';

  @override
  String get enumCore_cabinOpModeCensus => 'Comptage de médicament';

  @override
  String get enumCore_cabinOpModeIntake => 'Entrée de médicament';

  @override
  String get enumCore_cabinOpModeFault => 'Panne de tiroir';

  @override
  String get enumCore_cabinOpModeUnload => 'Déchargement de médicament';

  @override
  String get enumCore_cabinInventoryTypeRefillOperationLabel => 'Remplissage';

  @override
  String get enumCore_cabinInventoryTypeIntakeOperationLabel => 'Prise';

  @override
  String get enumCore_cabinInventoryTypeUnloadOperationLabel => 'Déchargement';

  @override
  String get enumCore_cabinInventoryTypeCensusOperationLabel => 'Comptage';

  @override
  String get enumCore_cabinInventoryTypeDisposalOperationLabel => 'Élimination';

  @override
  String get enumCore_cabinInventoryTypeRefillListOperationLabel =>
      'Remplissage';

  @override
  String get enumCore_cabinInventoryTypeRefillTitle =>
      'Remplissage de médicament';

  @override
  String get enumCore_cabinInventoryTypeRefillListTitle =>
      'Liste de remplissage de médicament';

  @override
  String get enumCore_cabinInventoryTypeCensusTitle => 'Comptage de médicament';

  @override
  String get enumCore_cabinInventoryTypeDisposalTitle =>
      'Élimination de médicament';

  @override
  String get enumCore_cabinInventoryTypeUnloadTitle =>
      'Déchargement de médicament';

  @override
  String get enumCore_cabinInventoryTypeIntakeTitle => 'Prise de médicament';

  @override
  String get enumCore_cabinInventoryTypeRefillButtonText => 'Remplir';

  @override
  String get enumCore_cabinInventoryTypeRefillListButtonText => 'Remplir';

  @override
  String get enumCore_cabinInventoryTypeCensusButtonText =>
      'Effectuer le comptage';

  @override
  String get enumCore_cabinInventoryTypeDisposalButtonText => 'Éliminer';

  @override
  String get enumCore_cabinInventoryTypeUnloadButtonText =>
      'Décharger le médicament';

  @override
  String get enumCore_cabinInventoryTypeIntakeButtonText =>
      'Prendre le médicament';

  @override
  String get enumCore_cabinInventoryTypeRefillFieldText =>
      'Quantité de remplissage';

  @override
  String get enumCore_cabinInventoryTypeRefillListFieldText =>
      'Quantité de remplissage';

  @override
  String get enumCore_cabinInventoryTypeCensusFieldText =>
      'Quantité de comptage';

  @override
  String get enumCore_cabinInventoryTypeDisposalFieldText =>
      'Quantité d\'élimination';

  @override
  String get enumCore_cabinInventoryTypeUnloadFieldText =>
      'Quantité de déchargement';

  @override
  String get enumCore_cabinInventoryTypeIntakeFieldText => 'Quantité de prise';

  @override
  String get enumCore_cabinInventoryTypeRefillSequentialText =>
      'Démarrer le remplissage automatique';

  @override
  String get enumCore_cabinInventoryTypeRefillListSequentialText =>
      'Démarrer le remplissage automatique';

  @override
  String get enumCore_cabinInventoryTypeCensusSequentialText =>
      'Démarrer le comptage automatique';

  @override
  String get enumCore_cabinInventoryTypeDisposalSequentialText =>
      'Démarrer l\'élimination automatique';

  @override
  String get enumCore_cabinInventoryTypeUnloadSequentialText =>
      'Démarrer le déchargement automatique';

  @override
  String get enumCore_cabinInventoryTypeIntakeSequentialText =>
      'Démarrer la prise automatique';

  @override
  String get enumCore_permissionCan => 'Peut';

  @override
  String get enumCore_permissionCannot => 'Ne peut pas';

  @override
  String get enumCore_genderFemale => 'Femme';

  @override
  String get enumCore_genderMale => 'Homme';

  @override
  String get enumCore_genderUnknown => 'Inconnu';

  @override
  String get enumCore_userTypeUnlimited => 'Illimité';

  @override
  String get enumCore_appModeAdmin => 'Admin';

  @override
  String get enumCore_appModeManager => 'Gestion';

  @override
  String get enumCore_appModeStation => 'Station';

  @override
  String get enumCore_userRoleManager => 'Gestionnaire';

  @override
  String get enumCore_userRoleStationOperator => 'Opérateur de station';

  @override
  String get enumCore_parityBitNone => 'Aucun';

  @override
  String get enumCore_parityBitEven => 'Pair';

  @override
  String get enumCore_parityBitOdd => 'Impair';

  @override
  String get enumCore_cabinColorBlue => 'Bleu';

  @override
  String get enumCore_cabinColorTurquoise => 'Turquoise';

  @override
  String get enumCore_cabinColorGreen => 'Vert';

  @override
  String get enumCore_cabinColorRed => 'Rouge';

  @override
  String get enumCore_cabinColorOrange => 'Orange';

  @override
  String get enumCore_cabinColorPurple => 'Violet';

  @override
  String get enumCore_cabinColorGray => 'Gris';

  @override
  String get enumCore_cabinColorBlack => 'Noir';

  @override
  String get enumCore_cabinColorWhite => 'Blanc';

  @override
  String get common_confirmButton => 'Confirmer';

  @override
  String get common_viewInPreparationMessage =>
      'Cette vue est en cours de préparation...';

  @override
  String get common_warningTitle => 'Avertissement !';

  @override
  String get dialog_deleteTitle => 'Suppression';

  @override
  String get dialog_deleteDefaultMessage =>
      'Êtes-vous sûr de vouloir supprimer cet élément ?';

  @override
  String dialog_deleteItemMessage(String itemName) {
    return 'Êtes-vous sûr de vouloir supprimer « $itemName » ?\nCette action est irréversible.';
  }

  @override
  String get dialog_exitConfirmButtonText => 'Quitter';

  @override
  String get dialog_exitConfirmMessage =>
      'Vous avez des modifications non enregistrées. Si vous quittez, ces modifications seront perdues.';

  @override
  String get dialog_exitConfirmMessageNoChanges =>
      'Êtes-vous sûr de vouloir quitter cette page ?';

  @override
  String get dialog_confirmDiscardButton => 'Oui, annuler';

  @override
  String get dialog_logoutTitle => 'Se déconnecter';

  @override
  String get dialog_logoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String get dialog_exitTitle => 'Quitter';

  @override
  String get dialog_exitMessage =>
      'Les modifications non enregistrées peuvent être perdues.';

  @override
  String get dialog_saveTitle => 'Enregistrer';

  @override
  String get dialog_saveMessage =>
      'Voulez-vous enregistrer les modifications ?';

  @override
  String get dialog_discardTitle => 'Annuler';

  @override
  String get dialog_discardMessage =>
      'Les modifications apportées seront annulées.';

  @override
  String get dialog_customConfirmTitle => 'Confirmation';

  @override
  String get dialog_customConfirmMessage => 'Confirmez-vous cette action ?';

  @override
  String get table_noDataTitle => 'Aucune donnée trouvée';

  @override
  String get table_defaultPdfReportTitle => 'Rapport de tableau';

  @override
  String get table_actionsColumnHeader => 'Actions';

  @override
  String get table_activeFiltersLabel => 'Filtres :';

  @override
  String get common_clearButton => 'Effacer';

  @override
  String table_selectedCountLabel(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String table_columnSelectedCountLabel(String column, int count) {
    return '$column : $count sélectionné(s)';
  }

  @override
  String get table_columnFallbackLabel => 'Colonne';

  @override
  String table_selectAllCountLabel(int count) {
    return 'Tout sélectionner ($count)';
  }

  @override
  String get table_noResultsShort => 'Aucun résultat';

  @override
  String table_applyCountLabel(int count) {
    return 'Appliquer ($count)';
  }

  @override
  String get table_applyButton => 'Appliquer';

  @override
  String table_recordCountFiltered(int filtered, int total) {
    return '$filtered / $total enregistrements';
  }

  @override
  String table_recordCount(int total) {
    return '$total enregistrements';
  }

  @override
  String table_totalRecordCount(int total) {
    return 'Total : $total enregistrements';
  }

  @override
  String get table_prevPageTooltip => 'Page précédente';

  @override
  String get table_nextPageTooltip => 'Page suivante';

  @override
  String get table_exportSelectedTooltip => 'Exporter la sélection';

  @override
  String get table_categoriesDefaultTitle => 'Catégories';

  @override
  String table_columnFallback(int index) {
    return 'Colonne $index';
  }

  @override
  String get dateFilter_yesterday => 'Hier';

  @override
  String get dateFilter_lastWeek => 'La semaine dernière';

  @override
  String get dateFilter_thisMonth => 'Ce mois-ci';

  @override
  String get dateFilter_last30Days => 'Les 30 derniers jours';

  @override
  String get dateFilter_customRange => 'Définir une plage personnalisée...';

  @override
  String get dateFilter_clearFilter => 'Effacer le filtre';

  @override
  String get dateFilter_noFilter => 'Aucun filtre';

  @override
  String get dateFilter_selectedRange => 'Plage sélectionnée';

  @override
  String get dateFilter_selectRangeTitle => 'Sélectionner la plage de dates';

  @override
  String get dateFilter_startDate => 'Début';

  @override
  String get dateFilter_endDate => 'Fin';

  @override
  String get common_selectPlaceholder => 'Veuillez sélectionner';

  @override
  String selectionDialog_selectedCount(int count) {
    return '$count éléments sélectionnés';
  }

  @override
  String get selectionDialog_noSelection => 'Aucune sélection effectuée';

  @override
  String get selectionDialog_confirmButton => 'Sélectionner';

  @override
  String get dateField_placeholder => 'Sélectionner une date';

  @override
  String timeField_helpTextWithDay(String day) {
    return 'Sélectionnez une heure pour $day';
  }

  @override
  String get timeField_helpText => 'Sélectionner une heure';

  @override
  String get timeField_placeholder => 'Sélectionner l\'heure';

  @override
  String doseStepper_manualEntryTitle(String unit) {
    return 'Entrez la quantité en $unit';
  }

  @override
  String get numpad_defaultTitle => 'Entrez la quantité';

  @override
  String get keyboard_closeButton => 'Fermer';

  @override
  String get keyboard_enterLabel => '↵ OK';

  @override
  String get keyboard_dashKeyLabel => '— Tiret';

  @override
  String get keyboard_periodKeyLabel => '. Point';

  @override
  String get keyboard_shiftLabel => '⇧ Majuscule';

  @override
  String get keyboard_spaceLabel => 'ESPACE';

  @override
  String get staleBanner_justNow => 'à l\'instant';

  @override
  String staleBanner_minutesAgo(int minutes) {
    return 'il y a $minutes min';
  }

  @override
  String staleBanner_hoursAgo(int hours) {
    return 'il y a $hours h';
  }

  @override
  String get staleBanner_dataStaleMessage => 'Les données ne sont pas à jour. ';

  @override
  String get staleBanner_dataUnavailableMessage =>
      'Les données à jour sont indisponibles. L\'opération ne peut pas continuer. ';

  @override
  String staleBanner_lastUpdatedLabel(String time) {
    return 'Dernière mise à jour : $time';
  }

  @override
  String get staleBanner_blockedBadge => 'Bloqué';

  @override
  String timeChip_today(String time) {
    return 'Aujourd\'hui $time';
  }

  @override
  String timeChip_tomorrow(String time) {
    return 'Demain $time';
  }

  @override
  String get cabin_lockButton => 'Verrouiller';

  @override
  String get cabin_criticalStockLabel => 'Stock critique';

  @override
  String get cabin_criticalStockSubLabel => 'réapprovisionnement nécessaire';

  @override
  String get cabin_legendFillNormal => 'Stock normal';

  @override
  String get cabin_legendFillNeeded => 'Remplissage nécessaire';

  @override
  String get cabin_legendFillUrgent => 'Remplissage urgent';

  @override
  String get cabin_serumTypeLabel => 'Serum';

  @override
  String get cabin_unitDoseTypeLabel => 'Dose Unitaire';

  @override
  String get refund_showCompletedTooltip => 'Afficher les Terminés';

  @override
  String get refund_showIncompleteTooltip => 'Afficher les Non Terminés';

  @override
  String get refund_takeTooltip => 'Prendre le retour';

  @override
  String get refund_deleteDialog_title => 'Description';

  @override
  String get refund_deleteDialog_saveButton => 'Supprimer';

  @override
  String get refund_deleteDialog_reasonLabel =>
      'Veuillez expliquer la raison de la suppression';

  @override
  String get refund_pdf_title => 'Rapport de retour pharmacie';

  @override
  String refund_pdf_station(String station) {
    return 'Station : $station';
  }

  @override
  String refund_pdf_dateRange(String startDate, String endDate) {
    return 'Date : $startDate - $endDate';
  }

  @override
  String get dashboard_sensor_title => 'Capteurs';

  @override
  String get dashboard_sensor_temperature => 'Température';

  @override
  String get dashboard_sensor_humidity => 'Humidité';

  @override
  String get dashboard_sensor_battery => 'Batterie';

  @override
  String get dashboard_climate_title => 'Conditions ambiantes';

  @override
  String get dashboard_sensor_outOfRange => 'Hors plage';

  @override
  String get dashboard_sensor_paused => 'En pause';

  @override
  String get dashboard_upcomingTreatmentsPanelTitle => 'Traitements à Venir';

  @override
  String dashboard_upcomingTreatmentsCountBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planifiés',
      one: '$count planifié',
    );
    return '$_temp0';
  }

  @override
  String get dashboard_upcomingTreatmentsEmptyTitle =>
      'Aucun traitement planifié';

  @override
  String get dashboard_upcomingTreatmentsOverdueStatus => 'en retard';

  @override
  String get dashboard_drugActivityPanelTitle => 'Activité des Médicaments';

  @override
  String get dashboard_drugActivityEmptyTitle =>
      'Aucune activité pour le moment';

  @override
  String get dashboard_activitiesLoadError =>
      'Impossible de charger l\'activité des médicaments';

  @override
  String get dashboard_telemetryPanelTitle => 'Environnement de l\'Armoire';

  @override
  String get dashboard_telemetryPausedStatus => 'En pause';

  @override
  String get dashboard_kpiActivePatientsLabel => 'Patients Actifs';

  @override
  String get dashboard_kpiCompletedOperationsLabel => 'Opérations Terminées';

  @override
  String get dashboard_kpiPendingPrescriptionsLabel =>
      'Prescriptions en Attente';

  @override
  String get dashboard_kpiCriticalAlertsLabel => 'Alertes Critiques';

  @override
  String get common_seeAllButton => 'Tout Voir';

  @override
  String get common_unknownFallback => 'Inconnu';

  @override
  String get common_justNowStatus => 'à l\'instant';

  @override
  String common_minutesAgoStatus(int count) {
    return 'il y a $count min';
  }

  @override
  String common_hoursAgoStatus(int count) {
    return 'il y a $count h';
  }

  @override
  String common_daysAgoStatus(int count) {
    return 'il y a $count j';
  }

  @override
  String common_minutesRemainingStatus(int count) {
    return 'dans $count min';
  }

  @override
  String common_hoursRemainingStatus(int count) {
    return 'dans $count h';
  }

  @override
  String common_daysRemainingStatus(int count) {
    return 'dans $count j';
  }

  @override
  String get refill_hint_selectSlots =>
      'Sélectionnez les cellules à remplir. Les cellules à faible stock sont signalées.';

  @override
  String get refill_title_fillCells => 'Remplir les cellules';

  @override
  String get refill_hint_miadRequired => 'Date de péremption requise';

  @override
  String get refill_status_openingTitle => 'Ouverture du tiroir…';

  @override
  String get refill_status_openingBody =>
      'Veuillez patienter, le tiroir physique s\'ouvre.';

  @override
  String get refill_status_waitingPullTitle => 'Tirez le tiroir';

  @override
  String get refill_status_waitingPullBody =>
      'Le verrou est libéré. Tirez le tiroir pour continuer.';

  @override
  String get refill_status_openingLidTitle => 'Ouverture de la cellule…';

  @override
  String get refill_status_openingLidBody =>
      'Veuillez patienter, le couvercle de la cellule s\'ouvre.';

  @override
  String get refill_status_stockOk => 'En stock';

  @override
  String get refill_status_stockLow => 'Faible';

  @override
  String get refill_status_stockCritical => 'Critique';

  @override
  String get refill_stop_confirmTitle => 'Arrêter le remplissage ?';

  @override
  String get refill_stop_confirmMessage =>
      'Si vous arrêtez, le tiroir ouvert sera verrouillé et ce remplissage sera marqué comme partiellement terminé. Les quantités saisies sont conservées, mais vous ne pourrez pas reprendre — vous devrez démarrer un nouveau remplissage.';

  @override
  String get refill_stop_confirmYes => 'Oui, arrêter';

  @override
  String get enumCore_prescriptionMovementPendingApprovalLabel =>
      'En attente d\'approbation';

  @override
  String get enumCore_prescriptionMovementPurchasePendingLabel =>
      'En attente d\'achat';

  @override
  String get enumCore_prescriptionMovementAppliedLabel => 'Appliqué';

  @override
  String get enumCore_prescriptionMovementReturnedLabel => 'Retourné';

  @override
  String get enumCore_prescriptionMovementWastagedLabel => 'Gaspillé';

  @override
  String get enumCore_prescriptionMovementDestructedLabel => 'Détruit';

  @override
  String get enumCore_prescriptionMovementCancelledLabel => 'Annulé';

  @override
  String get enumCore_prescriptionMovementRejectedLabel => 'Rejeté';

  @override
  String get enumCore_prescriptionMovementFilledWaitingLabel =>
      'En attente de remplissage';

  @override
  String get enumCore_prescriptionMovementReturnPendingLabel =>
      'Retour en attente';

  @override
  String get enumCore_prescriptionMovementUnloadedLabel => 'Déchargé';

  @override
  String get enumCore_prescriptionMovementShortageReportedLabel =>
      'Pénurie signalée';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingLabel =>
      'Réapprovisionnement en attente';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActorLabel =>
      'Créé par';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActorLabel =>
      'Rempli par';

  @override
  String get enumCore_prescriptionMovementAppliedActorLabel => 'Appliqué par';

  @override
  String get enumCore_prescriptionMovementReturnedActorLabel => 'Retourné par';

  @override
  String get enumCore_prescriptionMovementWastagedActorLabel => 'Gaspillé par';

  @override
  String get enumCore_prescriptionMovementDestructedActorLabel => 'Détruit par';

  @override
  String get enumCore_prescriptionMovementCancelledActorLabel => 'Annulé par';

  @override
  String get enumCore_prescriptionMovementRejectedActorLabel => 'Rejeté par';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActorLabel =>
      'Approuvé par';

  @override
  String get enumCore_prescriptionMovementReturnPendingActorLabel =>
      'Retour demandé par';

  @override
  String get enumCore_prescriptionMovementUnloadedActorLabel => 'Déchargé par';

  @override
  String get enumCore_prescriptionMovementShortageReportedActorLabel =>
      'Pénurie signalée par';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActorLabel =>
      'Réapprovisionnement approuvé par';

  @override
  String get enumCore_prescriptionMovementRedirectedLabel => 'Redirigé';

  @override
  String get enumCore_prescriptionMovementRedirectedActorLabel =>
      'Redirigé par';

  @override
  String get enumCore_prescriptionMovementRedirectedActionLabel => 'A redirigé';

  @override
  String get enumCore_prescriptionMovementPendingApprovalActionLabel => 'Créé';

  @override
  String get enumCore_prescriptionMovementPurchasePendingActionLabel =>
      'Rempli';

  @override
  String get enumCore_prescriptionMovementAppliedActionLabel => 'Appliqué';

  @override
  String get enumCore_prescriptionMovementReturnedActionLabel => 'Retourné';

  @override
  String get enumCore_prescriptionMovementWastagedActionLabel => 'Gaspillé';

  @override
  String get enumCore_prescriptionMovementDestructedActionLabel => 'Détruit';

  @override
  String get enumCore_prescriptionMovementCancelledActionLabel => 'Annulé';

  @override
  String get enumCore_prescriptionMovementRejectedActionLabel => 'Rejeté';

  @override
  String get enumCore_prescriptionMovementFilledWaitingActionLabel =>
      'Approuvé';

  @override
  String get enumCore_prescriptionMovementReturnPendingActionLabel =>
      'Retour demandé';

  @override
  String get enumCore_prescriptionMovementUnloadedActionLabel => 'Déchargé';

  @override
  String get enumCore_prescriptionMovementShortageReportedActionLabel =>
      'Pénurie signalée';

  @override
  String get enumCore_prescriptionMovementReplenishmentPendingActionLabel =>
      'Réapprovisionnement approuvé';

  @override
  String get userAuth_table_firstNameColumn => 'Prénom';

  @override
  String get userAuth_table_lastNameColumn => 'Nom';

  @override
  String get userAuth_table_occupationTypeColumn => 'Type de profession';

  @override
  String get userAuth_table_expiryDateColumn => 'Date d\'expiration';

  @override
  String get userAuth_table_remainingDaysColumn => 'Jours restants';

  @override
  String get userAuth_table_statusColumn => 'Statut';

  @override
  String get medicine_table_barcodeColumn => 'Code-barres';

  @override
  String get medicine_table_atcCodeColumn => 'Code ATC';

  @override
  String get medicine_table_nameColumn => 'Nom';

  @override
  String get medicine_table_materialTypeColumn => 'Type de matériel';

  @override
  String get medicine_table_prescriptionTypeColumn => 'Type d\'ordonnance';

  @override
  String get medicine_table_countTypeColumn => 'Type de comptage';

  @override
  String get medicine_table_purchaseTypeColumn => 'Mode d\'acquisition';

  @override
  String get medicine_table_returnTypeColumn => 'Mode de retour';

  @override
  String get medicine_table_statusColumn => 'Actif';

  @override
  String get enumCore_medicineTypeDrug => 'Médicament';

  @override
  String get enumCore_medicineTypeConsumable => 'Consommable médical';

  @override
  String get refund_table_patientCodeColumn => 'Code patient';

  @override
  String get refund_table_patientColumn => 'Patient';

  @override
  String get refund_table_userColumn => 'Utilisateur';

  @override
  String get refund_table_medicineColumn => 'Médicament';

  @override
  String get refund_table_quantityColumn => 'Quantité';

  @override
  String get refund_table_dateColumn => 'Date';

  @override
  String get refund_table_approvedUserColumn => 'Retour accepté par';

  @override
  String get refund_table_approvedDateColumn => 'Date d\'acceptation';

  @override
  String get refund_table_descriptionColumn => 'Description';

  @override
  String get authorization_table_userColumn => 'Utilisateur';

  @override
  String get authorization_table_roleColumn => 'Rôle';

  @override
  String get authorization_table_encryptedLoginColumn => 'Connexion chiffrée';

  @override
  String get authorization_table_isDeletedColumn => 'Supprimé';

  @override
  String get authorization_table_extraAuthCountColumn =>
      'Autorisation supplémentaire';

  @override
  String get authorization_summary_viewDetailsTooltip => 'Voir les détails';

  @override
  String get authorization_summary_dialogTitle =>
      'Résumé des autorisations utilisateur';

  @override
  String get authorization_summary_roleMenusTitle => 'Menus autorisés par rôle';

  @override
  String get authorization_summary_roleMenusEmptyLabel =>
      'Aucune autorisation par rôle';

  @override
  String get authorization_summary_extraMenusTitle =>
      'Menus supplémentaires autorisés';

  @override
  String get authorization_summary_extraMenusEmptyLabel =>
      'Aucune autorisation supplémentaire';

  @override
  String get cabinTemperature_table_dateColumn => 'Date';

  @override
  String get cabinTemperature_table_cabinColumn => 'Armoire';

  @override
  String get cabinTemperature_table_insideTempColumn =>
      'Température intérieure';

  @override
  String get cabinTemperature_table_outsideTempColumn =>
      'Température extérieure';

  @override
  String get cabinTemperature_table_humidityColumn => 'Humidité';

  @override
  String get cabinTemperature_action_showOutOfRange => 'Afficher hors limites';

  @override
  String get cabinTemperature_action_showAll => 'Tout afficher';

  @override
  String get cabinTemperature_currentStationNotFoundError =>
      'Aucune station active n\'a pu être trouvée';

  @override
  String get expiredItems_table_barcodeColumn => 'Code-barres';

  @override
  String get expiredItems_table_medicineColumn => 'Médicament';

  @override
  String get expiredItems_table_cabinColumn => 'Armoire';

  @override
  String get expiredItems_table_locationColumn => 'Emplacement';

  @override
  String get expiredItems_table_minQuantityColumn => 'Minimum';

  @override
  String get expiredItems_table_maxQuantityColumn => 'Maximum';

  @override
  String get expiredItems_table_criticalQuantityColumn => 'Critique';

  @override
  String get expiredItems_table_quantityColumn => 'Quantité';

  @override
  String get expiredItems_table_expiryDateColumn => 'Date d\'exp.';

  @override
  String get expiredItems_table_remainingDaysColumn => 'Jours restants';

  @override
  String get hospitalStock_table_serviceColumn => 'Service';

  @override
  String get hospitalStock_table_codeColumn => 'Code';

  @override
  String get hospitalStock_table_medicineColumn => 'Médicament';

  @override
  String get hospitalStock_table_quantityColumn => 'Quantité';

  @override
  String get patientInventory_table_doctorColumn => 'Médecin';

  @override
  String get patientInventory_table_departmentColumn => 'Département';

  @override
  String get patientInventory_table_barcodeColumn => 'Code-barres';

  @override
  String get patientInventory_table_medicineColumn => 'Médicament';

  @override
  String get patientInventory_table_requestedQuantityColumn => 'Qté demandée';

  @override
  String get patientInventory_table_processedQuantityColumn => 'Qté traitée';

  @override
  String get patientInventory_table_requestDateColumn => 'Date de demande';

  @override
  String get patientInventory_table_processDateColumn => 'Date de traitement';

  @override
  String get patientInventory_table_movementColumn => 'Mouvement';

  @override
  String patientInventory_pdf_title(String patientName) {
    return 'Liste d\'inventaire du patient $patientName';
  }

  @override
  String patientInventory_pdf_patientCode(Object code) {
    return 'Code patient : $code';
  }

  @override
  String patientInventory_pdf_service(String name) {
    return 'Service : $name';
  }

  @override
  String patientInventory_pdf_bed(String name) {
    return 'Lit : $name';
  }

  @override
  String patientInventory_pdf_reportDate(String date) {
    return 'Date du rapport : $date';
  }

  @override
  String get service_table_nameColumn => 'Nom du service';

  @override
  String get service_table_branchColumn => 'Branche';

  @override
  String get service_table_managerColumn => 'Responsable du service';

  @override
  String get service_table_statusColumn => 'Statut';

  @override
  String get unappliedPrescription_table_serviceColumn => 'Service';

  @override
  String get unappliedPrescription_table_roomColumn => 'Chambre';

  @override
  String get unappliedPrescription_table_bedColumn => 'Lit';

  @override
  String get unappliedPrescription_table_patientCodeColumn => 'Code patient';

  @override
  String get unappliedPrescription_table_patientColumn => 'Patient';

  @override
  String get unappliedPrescription_table_hospitalizationCodeColumn =>
      'Code d\'admission';

  @override
  String get unappliedPrescription_table_admissionDateColumn =>
      'Date d\'admission';

  @override
  String get unappliedPrescription_table_pendingCountColumn => 'En attente';

  @override
  String get drugActivity_table_dateColumn => 'Date';

  @override
  String get drugActivity_table_timeColumn => 'Heure';

  @override
  String get drugActivity_table_patientColumn => 'Patient';

  @override
  String get drugActivity_table_userColumn => 'Utilisateur';

  @override
  String get drugActivity_table_medicineColumn => 'Médicament';

  @override
  String get drugActivity_table_quantityColumn => 'Quantité';

  @override
  String get drugActivity_table_movementColumn => 'Mouvement';

  @override
  String get rfid_notConnectedError => 'Le lecteur RFID n\'est pas connecté';

  @override
  String rfid_inventoryStartFailedError(String detail) {
    return 'Échec du démarrage de l\'inventaire RFID : $detail';
  }

  @override
  String rfid_inventoryStreamError(String detail) {
    return 'Erreur du flux d\'inventaire RFID : $detail';
  }

  @override
  String get mobileDrawer_cabinConnectionErrorMessage =>
      'Impossible de communiquer avec l\'armoire. Veuillez réessayer ou contacter le personnel autorisé.';

  @override
  String get settingsView_title => 'Paramètres';

  @override
  String get settingsView_subtitle => 'CONFIGURATION SYSTÈME';

  @override
  String get settingsView_generalNav => 'Général';

  @override
  String get settingsView_appearanceNav => 'Apparence';

  @override
  String get settingsView_cabinNav => 'Paramètres de l\'armoire';

  @override
  String get settingsView_prescriptionNav => 'Paramètres de prescription';

  @override
  String get settingsView_developerNav => 'Développeur';

  @override
  String get settingsView_debugNav => 'Débogage';

  @override
  String get settingsView_sectionComingSoon =>
      'Le contenu de cette section sera bientôt disponible.';

  @override
  String get census_mode_allCabin => 'Toute la cabine';

  @override
  String get census_mode_byDrawer => 'Par tiroir';

  @override
  String get census_mode_byMedicine => 'Par médicament';

  @override
  String get census_hint_noMedicines => 'Aucun médicament à compter';

  @override
  String census_label_queueProgress(Object current, Object total) {
    return '$current / $total tiroirs';
  }

  @override
  String get census_action_stop => 'Arrêter';

  @override
  String get census_stop_confirmTitle =>
      'Voulez-vous vraiment arrêter l\'inventaire ?';

  @override
  String get census_stop_confirmMessage =>
      'Le processus d\'inventaire sera arrêté ; les comptages déjà effectués resteront enregistrés.';

  @override
  String get census_stop_confirmYes => 'Oui, arrêter';

  @override
  String get census_status_waitingPullTitle => 'En attente du tiroir';

  @override
  String get census_status_waitingPullBody => 'Veuillez tirer le tiroir';

  @override
  String get census_status_openingLidTitle => 'Ouverture de la case';

  @override
  String get census_status_openingLidBody =>
      'Veuillez patienter, la case s\'ouvre';

  @override
  String get census_status_openingTitle => 'Ouverture du tiroir';

  @override
  String get census_status_openingBody =>
      'Veuillez patienter, le tiroir s\'ouvre';

  @override
  String get census_action_nextCell => 'Case suivante';

  @override
  String get census_action_completeCensus => 'Terminer l\'inventaire';

  @override
  String get census_error_queueTitle =>
      'Une erreur s\'est produite pendant l\'inventaire';

  @override
  String get census_error_queueMessage =>
      'Vous pouvez retirer les médicaments du tiroir et continuer, ou terminer le processus ici.';

  @override
  String get census_error_continueNext => 'Continuer';

  @override
  String get census_error_endProcess => 'Terminer';

  @override
  String get census_label_countQty => 'Comptage';

  @override
  String get intake_screenTitle => 'Prise de Médicament';

  @override
  String get intake_phase_patientLabel => 'Sélection du Patient';

  @override
  String get intake_phase_medicineLabel => 'Sélection des Médicaments';

  @override
  String get intake_phase_executingLabel => 'Processus de Prise';

  @override
  String patientPicker_roomLabel(String room) {
    return 'Chambre $room';
  }

  @override
  String patientPicker_bedLabel(String bed) {
    return 'Lit $bed';
  }

  @override
  String intake_label_countFieldLabelIndexed(String unit, int index) {
    return 'Comptage $index ($unit)';
  }

  @override
  String get patientListPanel_filter_patientStatusLabel => 'Statut du Patient';

  @override
  String get patientListPanel_filter_orderStatusLabel => 'Statut de Commande';

  @override
  String get patientListPanel_filter_dialogTitle => 'Filtres';

  @override
  String get masterDrawer_status_devicePreparingTitle => 'Préparation';

  @override
  String get masterDrawer_status_devicePreparingSubtitle =>
      'Le système se prépare. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_lockOpeningTitle => 'Déverrouillage';

  @override
  String get masterDrawer_status_lockOpeningSubtitle =>
      'Le verrou du tiroir s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_waitingPullTitle => 'Veuillez Tirer le Tiroir';

  @override
  String get masterDrawer_status_waitingPullSubtitle =>
      'Le verrou a été libéré. Tirez le tiroir pour l\'ouvrir et continuer.';

  @override
  String get masterDrawer_status_openingLidTitle => 'Ouverture du Compartiment';

  @override
  String get masterDrawer_status_openingLidSubtitle =>
      'Le couvercle du compartiment s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_status_waitingCloseTitle =>
      'Veuillez Fermer le Tiroir';

  @override
  String get masterDrawer_status_waitingCloseSubtitle =>
      'Fermez le tiroir pour passer à l\'étape suivante.';

  @override
  String get masterDrawer_status_failedTitle => 'Un Problème est Survenu';

  @override
  String get masterDrawer_status_failedSubtitle =>
      'Veuillez patienter, l\'état du tiroir est en cours de vérification.';

  @override
  String get masterDrawer_status_openingTitle => 'Ouverture du Tiroir';

  @override
  String get masterDrawer_status_openingSubtitle =>
      'Le tiroir s\'ouvre. Veuillez patienter un instant.';

  @override
  String get masterDrawer_stop_waitingCloseTitle =>
      'Veuillez Fermer le Tiroir Ouvert';

  @override
  String get masterDrawer_stop_waitingCloseSubtitle =>
      'Veuillez fermer le tiroir ouvert. Le processus s\'arrêtera une fois celui-ci fermé.';

  @override
  String intake_label_queueProgress(int done, int total) {
    return 'Tiroir $done/$total';
  }

  @override
  String get intake_action_stop => 'Arrêter';

  @override
  String get intake_stop_confirmTitle => 'Arrêter la Prise ?';

  @override
  String get intake_stop_confirmMessage =>
      'Le processus de prise en cours sera arrêté. Les tiroirs terminés seront conservés.';

  @override
  String get intake_stop_confirmYes => 'Oui, Arrêter';

  @override
  String intake_hint_mergedFromMultiplePrescriptions(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Combiné à partir de $countString prescriptions',
      one: 'Combiné à partir de $countString prescription',
    );
    return '$_temp0';
  }

  @override
  String get refund_hint_searchMedicine => 'Rechercher un médicament';

  @override
  String get refund_hint_selectPatientFirst =>
      'Sélectionnez d\'abord un patient';

  @override
  String get refund_hint_noMedicineFound =>
      'Aucun médicament remboursable trouvé';

  @override
  String get refund_action_start => 'Démarrer le retour';

  @override
  String get refund_action_nextCell => 'Cellule suivante';

  @override
  String get refund_action_completeRefund => 'Terminer le retour';

  @override
  String get refund_action_stop => 'Arrêter';

  @override
  String get refund_action_stopConfirmTitle => 'Arrêter le retour ?';

  @override
  String get refund_action_stopConfirmMessage =>
      'Les retours terminés seront conservés, les tiroirs restants ne seront pas traités.';

  @override
  String get refund_action_stopConfirmYes => 'Oui, arrêter';

  @override
  String get refund_field_maxAmount => 'Max. remboursable';

  @override
  String get refund_field_returnNote => 'Note de retour';

  @override
  String get refund_status_checking => 'Vérification en cours...';

  @override
  String get refund_status_ready => 'Prêt';

  @override
  String get refund_status_checkFailed => 'Échec de la vérification';

  @override
  String get refund_error_queueTitle => 'Erreur de retour';

  @override
  String get refund_error_continueNext => 'Continuer avec le suivant';

  @override
  String get refund_error_endProcess => 'Terminer le processus';

  @override
  String get refund_error_amountZero =>
      'La quantité à retourner ne peut pas être 0';

  @override
  String get refund_error_amountExceedsMax =>
      'Le montant du retour ne peut pas dépasser la quantité reçue';

  @override
  String refund_label_progress(int done, int total) {
    return '$done / $total tiroirs';
  }

  @override
  String get waste_hint_searchMedicine => 'Rechercher un médicament';

  @override
  String get waste_hint_selectPatientFirst =>
      'Sélectionnez un patient pour continuer';

  @override
  String get waste_hint_noMedicineFound =>
      'Aucun médicament à jeter/détruire trouvé';

  @override
  String waste_label_availableAmount(String amount) {
    return 'Quantité disponible : $amount';
  }

  @override
  String get waste_error_amountZero => 'La quantité ne peut pas être 0.';

  @override
  String get waste_error_wastageAmountExceeded =>
      'La quantité à gaspiller ne peut pas dépasser la quantité reçue.';

  @override
  String get waste_error_destructionAmountExceeded =>
      'La quantité à détruire ne peut pas dépasser la quantité reçue.';

  @override
  String get waste_success_operationCompleted =>
      'Opération de gaspillage/destruction réussie.';

  @override
  String get witnessDialog_title => 'Vérification du témoin';

  @override
  String get witnessDialog_usernameLabel => 'Nom d\'utilisateur';

  @override
  String get witnessDialog_usernameRequired =>
      'Le nom d\'utilisateur est requis';

  @override
  String get witnessDialog_passwordLabel => 'Mot de passe';

  @override
  String get witnessDialog_passwordRequired => 'Le mot de passe est requis';

  @override
  String get witnessDialog_confirmButton => 'Confirmer';

  @override
  String get witnessDialog_anyoneInfo =>
      'N\'importe quel utilisateur peut témoigner pour cet élément.';

  @override
  String witnessDialog_authorizedWitnesses(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString témoins autorisés',
      one: '$countString témoin autorisé',
    );
    return '$_temp0';
  }

  @override
  String get witnessDialog_error_selfWitness =>
      'Vous ne pouvez pas témoigner de votre propre opération.';

  @override
  String witnessDialog_success_confirmed(String witnessName) {
    return '$witnessName confirmé comme témoin.';
  }

  @override
  String witnessDialog_assignedLabel(String witnessName) {
    return 'Témoin : $witnessName';
  }

  @override
  String get witnessDialog_requiredHint => 'Confirmation du témoin requise';

  @override
  String witnessDialog_autoAssigned(String witnessName) {
    return '$witnessName a été automatiquement assigné comme témoin pour cet élément.';
  }

  @override
  String get unload_hint_searchMedicine =>
      'Rechercher un médicament ou un code-barres';

  @override
  String get unload_hint_noMedicineFound => 'Aucun médicament trouvé';

  @override
  String get unload_action_stop => 'Arrêter';

  @override
  String get unload_action_nextCell => 'Cellule suivante';

  @override
  String get unload_action_completeUnloading => 'Terminer le déchargement';

  @override
  String get unload_stop_confirmTitle => 'Arrêter le déchargement ?';

  @override
  String get unload_stop_confirmMessage =>
      'Les tiroirs restants dans la file d\'attente ne seront pas déchargés. Voulez-vous vraiment arrêter ?';

  @override
  String get unload_stop_confirmYes => 'Oui, arrêter';

  @override
  String get unload_error_queueTitle => 'Erreur de Vidage';

  @override
  String get unload_error_continueNext => 'Continuer au tiroir suivant';

  @override
  String get unload_error_endProcess => 'Terminer le processus';

  @override
  String unload_label_queueProgress(int done, int total) {
    return 'Tiroir $done sur $total';
  }

  @override
  String get unload_label_countQty => 'Comptage';

  @override
  String get unload_label_unloadQty => 'Qté à retirer';

  @override
  String get refund_label_quantity => 'Quantité';

  @override
  String destruction_label_queueProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String get destruction_action_stop => 'Arrêter';

  @override
  String get destruction_stop_confirmTitle => 'Arrêter la destruction ?';

  @override
  String get destruction_stop_confirmMessage =>
      'Le processus de destruction sera arrêté. Les éléments déjà traités seront conservés.';

  @override
  String get destruction_stop_confirmYes => 'Oui, arrêter';

  @override
  String get destruction_label_quantity => 'Qté à détruire';

  @override
  String get destruction_action_nextCell => 'Cellule suivante';

  @override
  String get destruction_action_completeDestruction =>
      'Terminer la destruction';

  @override
  String get waste_hint_notAuthorized =>
      'Vous n\'êtes pas autorisé à détruire ce médicament';

  @override
  String get intake_action_checkEquivalent => 'Vérifier l\'équivalent';

  @override
  String get intake_hint_noEquivalentFound =>
      'Aucun médicament équivalent trouvé';

  @override
  String get intake_label_equivalentOptions => 'Équivalents disponibles';

  @override
  String get intake_hint_searchingOtherStations =>
      'Recherche dans d\'autres armoires...';

  @override
  String get intake_hint_noStockAnywhere =>
      'Ce médicament est introuvable dans toutes les armoires';

  @override
  String get intake_label_otherStationOptions =>
      'Disponible dans d\'autres armoires';

  @override
  String get intake_action_redirect => 'Rediriger';

  @override
  String intake_hint_redirectedTo(String stationName) {
    return 'Redirigé vers l\'armoire $stationName';
  }

  @override
  String get intake_status_redirected => 'Redirigé';

  @override
  String get intake_tab_prescriptions => 'Prescriptions';

  @override
  String get intake_tab_redirectedOrders => 'Commandes redirigées';

  @override
  String get intake_hint_noRedirectedOrders => 'Aucune commande redirigée';

  @override
  String intake_status_redirectedFrom(String stationName) {
    return 'Redirigé depuis $stationName';
  }

  @override
  String intake_label_redirectedBy(String userName) {
    return 'Redirigé par $userName';
  }

  @override
  String get refund_action_completeDirect => 'Retourner';

  @override
  String get refund_success_dialogTitle => 'Retour terminé';

  @override
  String get refund_success_toPharmacyMessage =>
      'Le retour a été effectué. Veuillez remettre le médicament au pharmacien.';

  @override
  String get refund_success_toReturnBoxMessage =>
      'Le retour a été effectué. Veuillez placer le médicament dans la boîte de retour.';

  @override
  String get refund_error_amountExceeded =>
      'La quantité à retourner ne peut pas dépasser la quantité reçue';

  @override
  String get refund_error_genericCheckFailed =>
      'Une erreur s\'est produite. Veuillez réessayer plus tard.';

  @override
  String get refund_error_returnDrawerNotDefined =>
      'Le tiroir de retour n\'est pas défini. Veuillez le définir dans l\'écran de conception de la cabine.';

  @override
  String get refund_error_completeFailed =>
      'Une erreur s\'est produite lors du retour.';

  @override
  String get cabin_returnDrawerName => 'Tiroir de retour';

  @override
  String get cabin_returnDrawerView => 'Boîte de retour';

  @override
  String get cabin_returnDrawerViewTitle =>
      'Ce tiroir est désigné comme boîte de retour';

  @override
  String get cabin_returnDrawerViewSubtitle =>
      'L\'attribution/le remplissage de médicaments n\'est pas disponible pour ce tiroir';

  @override
  String get cabinDesign_dialogTitle => 'Conception de l\'armoire';

  @override
  String get cabinDesign_syncBadge => 'SYNCHRONISÉ';

  @override
  String get cabinDesign_basicSettings_sectionTitle => 'Paramètres de base';

  @override
  String get cabinDesign_basicSettings_nameLabel => 'Nom de l\'armoire';

  @override
  String get cabinDesign_basicSettings_stationLabel => 'Station';

  @override
  String get cabinDesign_basicSettings_comPortLabel => 'Port COM';

  @override
  String get cabinDesign_basicSettings_dvrIpLabel => 'IP DVR';

  @override
  String get cabinDesign_detail_sectionTitle => 'Détail du tiroir';

  @override
  String get cabinDesign_detail_typeLabel => 'Type';

  @override
  String cabinDesign_detail_typeKubik(int rows, int cols) {
    return 'Cubique $rows×$cols';
  }

  @override
  String get cabinDesign_detail_cellCountLabel => 'Nombre de cases';

  @override
  String get cabinDesign_detail_addressLabel => 'Adresse';

  @override
  String get cabinDesign_detail_configLabel => 'Configuration';

  @override
  String get cabinDesign_returnDrawer_toggleLabel => 'Tiroir de retour';

  @override
  String get cabinDesign_returnDrawer_toggleHint =>
      'Ce tiroir sera réservé aux opérations de retour';

  @override
  String cabinDesign_returnDrawer_currentInfo(String address) {
    return 'Un seul tiroir de retour peut être désigné par armoire. Actuellement : $address';
  }

  @override
  String get cabinDesign_returnDrawer_noneInfo =>
      'Un seul tiroir de retour peut être désigné par armoire. Aucun désigné pour le moment.';

  @override
  String get cabinDesign_serum_sectionTitle => 'Disposition interne';

  @override
  String get cabinDesign_serum_manualBadge => 'CONFIGURATION MANUELLE';

  @override
  String get cabinDesign_serum_infoBanner =>
      'La disposition interne d\'une armoire à sérum n\'est pas lue depuis la carte ; définissez ici ses tiroirs et la disposition du matériel.';

  @override
  String get cabinDesign_serum_equipmentLayoutTitle =>
      'Disposition du matériel';

  @override
  String cabinDesign_serum_drawerBadge(int index) {
    return 'S-0$index';
  }

  @override
  String get cabinDesign_serum_topViewLabel => 'Vue de dessus';

  @override
  String cabinDesign_serum_shelfCardTitle(int index) {
    return 'Étagère $index';
  }

  @override
  String cabinDesign_serum_shelfCardSummary(int used, int total, int count) {
    return '$used/$total emplacements • $count plateaux';
  }

  @override
  String get cabinDesign_serum_lockToggleLabel => 'Verrou électromagnétique';

  @override
  String get cabinDesign_serum_addSmallButton => 'Petit';

  @override
  String get cabinDesign_serum_addMediumButton => 'Moyen';

  @override
  String get cabinDesign_serum_addLargeButton => 'Grand';

  @override
  String get cabinDesign_serum_traySizeSmallLabel => 'Petit';

  @override
  String get cabinDesign_serum_traySizeMediumLabel => 'Moyen';

  @override
  String get cabinDesign_serum_traySizeLargeLabel => 'Grand';

  @override
  String cabinDesign_serum_trayListItemLabel(int index, String sizeLabel) {
    return '$index. Plateau • $sizeLabel';
  }

  @override
  String cabinDesign_serum_areaUsedLabel(int used, int total) {
    return '$used/$total emplacements utilisés';
  }

  @override
  String get cabinDesign_serum_capacityFullWarning =>
      'Étagère pleine, impossible d\'ajouter un plateau';

  @override
  String get cabinDesign_serum_leftLabel => 'Gauche';

  @override
  String get cabinDesign_serum_rightLabel => 'Droite';

  @override
  String get cabinDesign_noSelectionHint =>
      'Sélectionnez un tiroir pour voir ses détails.';

  @override
  String get cabinDesign_scanButton => 'Scanner l\'appareil';

  @override
  String get cabinDesign_saveButton => 'Enregistrer la conception';

  @override
  String get cabinDesign_returnBadge => 'RETOUR';

  @override
  String get cabin_returnBoxLabel => 'BOÎTE DE RETOUR';

  @override
  String get unload_segment_returnDrawer => 'Tiroir de Retour';

  @override
  String get unload_segment_returnBox => 'Boîte de Retour';

  @override
  String get unload_hint_noDrawerMedicineFound =>
      'Aucun médicament trouvé dans le tiroir de retour';

  @override
  String get unload_hint_noBoxMedicineFound =>
      'Aucun médicament trouvé dans la boîte de retour';

  @override
  String get unload_fieldReturnedBy => 'Retourné Par';

  @override
  String get unload_action_startDrawerUnload => 'Démarrer le Vidage du Tiroir';

  @override
  String get unload_action_completeBoxUnload =>
      'Terminer le Vidage de la Boîte';

  @override
  String get unload_label_drawerInProgress =>
      'Vidage du Tiroir de Retour en Cours';

  @override
  String get unload_action_stopConfirmTitle => 'Arrêter le Vidage du Tiroir ?';

  @override
  String get unload_action_stopConfirmMessage =>
      'Le tiroir se fermera et le vidage ne sera pas terminé. Voulez-vous continuer ?';

  @override
  String get unload_action_stopConfirmYes => 'Oui, Arrêter';

  @override
  String get unload_action_completeDrawerUnload =>
      'Terminer le Vidage du Tiroir';

  @override
  String get masterDrawer_error_managerNotFound =>
      'Carte de gestion introuvable. Vérifiez la connexion de l\'armoire.';

  @override
  String get masterDrawer_error_managerConnectFailed =>
      'Impossible de se connecter à l\'armoire. Vérifiez la connexion et réessayez.';

  @override
  String get masterDrawer_error_lockOpenFailed =>
      'Le verrou du tiroir n\'a pas pu être ouvert. Vérifiez le matériel.';

  @override
  String get masterDrawer_error_lidOpenFailed =>
      'Le couvercle n\'a pas pu être ouvert. Assurez-vous que le tiroir est complètement ouvert.';

  @override
  String get masterDrawer_error_lockOpenTimeout =>
      'Le tiroir ne s\'est pas complètement ouvert à temps. Veuillez tirer le tiroir jusqu\'au bout.';

  @override
  String get masterDrawer_error_sensorCommunicationLost =>
      'La communication avec le matériel a été perdue. Vérifiez la connexion et réessayez.';

  @override
  String get masterDrawer_error_unexpectedlyClosed =>
      'Le tiroir a été fermé de manière inattendue pendant son utilisation. Veuillez le rouvrir et réessayer.';

  @override
  String get masterDrawer_status_completingTitle =>
      'Finalisation de votre opération';

  @override
  String get masterDrawer_status_completingSubtitle => 'Veuillez patienter';

  @override
  String get cabinDesign_cabinList_sectionTitle => 'Armoires Définies';

  @override
  String cabinDesign_cabinList_countBadge(int count) {
    return '$count Armoires';
  }

  @override
  String get cabinDesign_cabinList_addCabinButton =>
      'Définir une Nouvelle Armoire';

  @override
  String get cabinDesign_cabinList_noPortLabel => 'Aucun Port';

  @override
  String get cabinDesign_cabinList_passiveBadge => 'Inactif';

  @override
  String get cabinDesign_newCabin_typeLabel => 'Type d\'Armoire';

  @override
  String get cabinDesign_newCabin_addressLabel => 'Adresse';

  @override
  String get cabinDesign_newCabin_noAddressAvailableWarning =>
      'Aucune adresse disponible dans cette station (les 15 adresses B-P sont déjà utilisées).';

  @override
  String get cabinDesign_newCabin_saveAndScanButton => 'Enregistrer et Scanner';

  @override
  String get cabinDesign_newCabin_invalidAddressError =>
      'L\'adresse sélectionnée n\'est pas valide.';

  @override
  String get cabinDesign_basicSettings_rescanButton => 'Rescanner';

  @override
  String get cabinDesign_basicSettings_deactivateButton => 'Désactiver';

  @override
  String get cabinDesign_basicSettings_activateButton => 'Activer';

  @override
  String get cabinSelection_screenTitle => 'Sélectionner une Armoire';

  @override
  String get cabinSelection_continueButton => 'Continuer';

  @override
  String get cabinSelection_dataUnavailableLabel => 'Aucune Donnée';

  @override
  String get cabinOperation_changeCabinButton => 'Sélectionner une Armoire';

  @override
  String get assignment_idle_kicker => 'CONFIGURATION DE L\'ARMOIRE';

  @override
  String get assignment_idle_title => 'Attribution de Médicaments';

  @override
  String get assignment_idle_description =>
      'Touchez une case de l\'armoire à gauche ; choisissez un médicament dans la liste pour cette case et saisissez les quantités minimale, critique et maximale. Touchez une case remplie pour modifier son attribution existante.';

  @override
  String get assignment_idle_tableTitle => 'Attributions Actuelles';

  @override
  String get assignment_idle_columnLocation => 'Emplacement';

  @override
  String get assignment_idle_columnDrug => 'Médicament';

  @override
  String get assignment_idle_columnMin => 'Min';

  @override
  String get assignment_idle_columnCritical => 'Critique';

  @override
  String get assignment_idle_columnMax => 'Max';

  @override
  String get assignment_idle_editLink => 'Modifier';

  @override
  String assignment_idle_locationLabel(String drawer, int cell) {
    return 'Tiroir $drawer — Case $cell';
  }

  @override
  String get assignment_edit_title => 'Modifier l\'Attribution';

  @override
  String get assignment_edit_cancelButton => 'Annuler';

  @override
  String get assignment_edit_selectDrugStep => '1 — Sélectionner un Médicament';

  @override
  String get assignment_edit_quantityStep => '2 — Saisir les Quantités';

  @override
  String get assignment_edit_searchHint => 'Rechercher un médicament...';

  @override
  String get assignment_edit_inCabinBadge => 'Dans l\'Armoire';

  @override
  String get assignment_edit_minQuantityLabel => 'Quantité Minimale';

  @override
  String get assignment_edit_minQuantityHint =>
      'Une commande est suggérée en dessous de ce niveau';

  @override
  String get assignment_edit_criticalQuantityLabel => 'Quantité Critique';

  @override
  String get assignment_edit_criticalQuantityHint =>
      'Une alerte critique est déclenchée à ce niveau';

  @override
  String get assignment_edit_maxQuantityLabel => 'Quantité Maximale';

  @override
  String get assignment_edit_maxQuantityHint => 'Capacité maximale de la case';

  @override
  String get assignment_edit_removeLink => 'Supprimer l\'Attribution';

  @override
  String get assignment_edit_saveButton => 'Enregistrer les Modifications';

  @override
  String get assignment_edit_previousPage => 'Précédent';

  @override
  String get assignment_edit_nextPage => 'Suivant';

  @override
  String assignment_edit_pageIndicator(int current, int total) {
    return 'Page $current / $total';
  }

  @override
  String get unscannedBarcode_scan_actionLabel => 'Scanner le code-barres';

  @override
  String dashboard_delayMinutesLabel(int minutes) {
    return '$minutes min';
  }

  @override
  String dashboard_delayHoursMinutesLabel(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get dashboard_upcomingTreatmentsDelayedTitle => 'En Retard';

  @override
  String get dashboard_upcomingTreatmentsDueSoonTitle => 'Dans les 20 Minutes';

  @override
  String get dashboard_upcomingTreatmentsUpcomingTitle => '20-60 Min';

  @override
  String dashboard_upcomingTreatmentsDueInMinutesLabel(int minutes) {
    return 'DANS $minutes MIN';
  }
}
