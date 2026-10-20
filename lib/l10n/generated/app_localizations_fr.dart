// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Aujourd’hui $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Hier $arg0';
  }

  @override
  String get lessThanSecond => 'Moins d’une seconde';

  @override
  String secondsDuration(String arg0) {
    return '$arg0 s';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0 min $arg1 s';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0 h $arg1 min $arg2 s';
  }

  @override
  String get phone => 'Téléphone';

  @override
  String get tablet => 'Tablette';

  @override
  String get computer => 'Ordinateur';

  @override
  String get device => 'Appareil';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 souhaite envoyer $arg1';
  }

  @override
  String get batchConsent => 'Une confirmation pour recevoir ce lot';

  @override
  String get textConsent => 'Recevoir ce texte ?';

  @override
  String get fileConsent => 'Recevoir ce fichier ?';

  @override
  String approvalWarning(String arg0) {
    return 'Le nom de l’expéditeur n’est pas vérifié. N’acceptez que du contenu connu. Expiration dans $arg0 minutes.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Enregistrer dans : $arg0';
  }

  @override
  String get decline => 'Refuser';

  @override
  String get receiveAll => 'Tout recevoir';

  @override
  String get receiveText => 'Recevoir le texte';

  @override
  String get receiveFile => 'Recevoir le fichier';

  @override
  String verifyPeer(String arg0) {
    return 'Vérifier $arg0';
  }

  @override
  String get verificationInstructions =>
      'Ouvrez les informations locales sur l’autre appareil et comparez les codes.';

  @override
  String get verificationWarning =>
      'Le nom ne prouve pas l’identité. Vérifiez l’autre écran avant de confirmer.';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirmConnection => 'Codes identiques, connecter';

  @override
  String get localInfo => 'Informations locales';

  @override
  String get showLocalCode =>
      'Comparez ce code pour une connexion manuelle. Le scan vérifie automatiquement l’identité.';

  @override
  String get generating => 'Génération…';

  @override
  String get deviceName => 'Nom de l’appareil';

  @override
  String get preparing => 'Préparation…';

  @override
  String get connectionAddress => 'Adresse de connexion';

  @override
  String get addressWhenConnected =>
      'Connectez-vous au réseau pour voir les adresses';

  @override
  String get done => 'Terminé';

  @override
  String get manualConnection => 'Connexion manuelle';

  @override
  String get findPeerAddress =>
      'Trouvez l’adresse dans les informations locales de l’autre appareil.';

  @override
  String get deviceAddress => 'Adresse de l’appareil';

  @override
  String get addressSeparator =>
      'Séparez l’adresse et le port par deux-points :';

  @override
  String get next => 'Suivant';

  @override
  String get connecting => 'Connexion…';

  @override
  String get connectionFailed =>
      'Connexion impossible. Vérifiez l’adresse et le réseau.';

  @override
  String sendToPeer(String arg0) {
    return 'Envoyer à $arg0';
  }

  @override
  String get hideKeyboard => 'Masquer le clavier';

  @override
  String get settings => 'Paramètres';

  @override
  String get thisDevice => 'Cet appareil';

  @override
  String get discoverable => 'Visible pour les appareils à proximité';

  @override
  String get starting => 'Démarrage…';

  @override
  String nearbyDevices(String arg0) {
    return 'Appareils à proximité : $arg0';
  }

  @override
  String get refreshDevices => 'Actualiser les appareils';

  @override
  String get findingDevices => 'Recherche d’appareils…';

  @override
  String get noDevices => 'Aucun appareil trouvé';

  @override
  String get verifiedSelected => 'Vérifié · Sélectionné';

  @override
  String get verifiedOffline => 'Vérifié · Hors ligne';

  @override
  String get unverified => 'Non vérifié';

  @override
  String get receivingContent => 'Réception';

  @override
  String get sendingContent => 'Envoyer du contenu';

  @override
  String get directTransfer =>
      'Fichiers et textes sont transférés directement entre les appareils.';

  @override
  String sendTo(String arg0) {
    return 'Envoyer à$arg0';
  }

  @override
  String get codeVerified => 'Identité de l’appareil vérifiée';

  @override
  String get viewVerification => 'Voir le code de l’appareil';

  @override
  String get file => 'Fichier';

  @override
  String get text => 'Texte';

  @override
  String get betweenDevices =>
      'Le contenu ne transite qu’entre ces deux appareils.';

  @override
  String get encryptedLan => 'LAN direct · Chiffré';

  @override
  String get statusPrefix => 'Terminé';

  @override
  String get preparingIdentity => 'Préparation de l’identité…';

  @override
  String get noNearbyDevices => 'Aucun appareil à proximité';

  @override
  String get selectDevice => 'Choisissez un appareil pour commencer';

  @override
  String get sameWifiHint =>
      'Connectez les appareils au même réseau\net ouvrez Dukto2 sur l’autre appareil.';

  @override
  String get selectVerifyHint => 'Choisissez un appareil et comparez son code.';

  @override
  String get enterAddress => 'Connexion manuelle';

  @override
  String get textCopied => 'Texte copié';

  @override
  String get copyFailed => 'Copie impossible. Réessayez.';

  @override
  String get textContent => 'Contenu du texte';

  @override
  String filePreviewHint(String arg0) {
    return 'Aperçu uniquement. Taille : $arg0. Ouvrez le fichier pour tout lire.';
  }

  @override
  String get textPreviewHint =>
      'Aperçu uniquement. « Copier le texte » copie tout le contenu.';

  @override
  String get close => 'Fermer';

  @override
  String get openFullText => 'Ouvrir le texte complet';

  @override
  String get copyPreview => 'Copier l’aperçu';

  @override
  String get copyText => 'Copier le texte';

  @override
  String get emptyClipboard => 'Le presse-papiers ne contient pas de texte';

  @override
  String get editorLimit =>
      'L’éditeur accepte 1 Mio. Chargez les textes plus longs depuis un fichier (16 Mio maximum).';

  @override
  String get clipboardFailed =>
      'Lecture du presse-papiers impossible. Réessayez.';

  @override
  String get textPlaceholder => 'Saisissez du texte ou collez un lien';

  @override
  String get textFileLoaded =>
      'Texte UTF-8 chargé. Le fichier complet sera transmis.';

  @override
  String get textLimit => '16 Mio maximum · Accord requis';

  @override
  String get textUnsupported =>
      'Cet appareil ne prend pas en charge le texte. Mettez son application à jour.';

  @override
  String get waitingText => 'En attente du destinataire…';

  @override
  String get sendingText => 'Envoi et vérification du texte…';

  @override
  String get textSent => 'Texte envoyé et vérifié';

  @override
  String get textCancelled => 'Envoi annulé. Texte conservé.';

  @override
  String get pasteText => 'Coller du texte';

  @override
  String get moreTextActions => 'Autres actions de texte';

  @override
  String get loadTextFile => 'Charger un fichier texte';

  @override
  String get clearText => 'Effacer le contenu';

  @override
  String get cancelTransfer => 'Annuler le transfert';

  @override
  String get sendText => 'Envoyer le texte';

  @override
  String get send => 'Envoyer';

  @override
  String get chooseFileHint => 'Choisissez les fichiers à envoyer';

  @override
  String get approvalBeforeTransfer =>
      'Le transfert commence après accord du destinataire';

  @override
  String get picking => 'Sélection…';

  @override
  String get chooseFiles => 'Choisir les fichiers';

  @override
  String get multiSelectHint => 'Sélection multiple · Envoi dans l’ordre';

  @override
  String get waitingBatch => 'En attente de l’envoi du lot…';

  @override
  String get waitingUpload => 'En attente de l’expéditeur…';

  @override
  String get verifyingFile => 'Vérification du fichier…';

  @override
  String get receiving => 'Réception';

  @override
  String get ready => 'Prêt';

  @override
  String get waitingReceiver => 'En attente d’accord';

  @override
  String get sending => 'Envoi';

  @override
  String get waitingVerification => 'En attente de vérification…';

  @override
  String get sentVerified => 'Envoyé et vérifié';

  @override
  String get sendCancelled => 'Envoi annulé';

  @override
  String get sendFailedRetry => 'Échec de l’envoi. Réessayez.';

  @override
  String get batchSent => 'Tous les fichiers envoyés et vérifiés';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Fichier $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 envoyés · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 fichiers',
      one: '$arg0 fichier',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Retirer les fichiers sélectionnés';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Retirer $arg0';
  }

  @override
  String get receiveProgress => 'Progression de réception';

  @override
  String get sendProgress => 'Progression d’envoi';

  @override
  String get sendOtherFiles => 'Envoyer d’autres fichiers';

  @override
  String get chooseAgain => 'Choisir à nouveau';

  @override
  String get continueSending => 'Continuer';

  @override
  String get resend => 'Renvoyer';

  @override
  String get sendFiles => 'Envoyer les fichiers';

  @override
  String get recentTransfers => 'Transferts récents';

  @override
  String get allDevices => 'Tous les appareils';

  @override
  String get otherDevice => 'Autre appareil';

  @override
  String get emptyHistory =>
      'Les fichiers et textes transférés apparaîtront ici.';

  @override
  String get textMessage => 'Message texte';

  @override
  String get received => 'Reçu';

  @override
  String get sent => 'Envoyé';

  @override
  String durationLabel(String arg0) {
    return 'Durée : $arg0';
  }

  @override
  String get viewText => 'Voir le texte';

  @override
  String get openFolderHint => 'Ouvrir le dossier du fichier local';

  @override
  String get noLocalFile => 'Aucun emplacement local disponible';

  @override
  String get openFolder => 'Ouvrir le dossier';

  @override
  String get about => 'À propos de Dukto2';

  @override
  String get aboutTribute =>
      'Un hommage à Dukto et à son créateur Emanuele Colombo. Merci à xuzhen et à la communauté pour leur maintenance continue.';

  @override
  String get aboutAi =>
      'Code, interface, tests et documentation créés avec OpenAI Codex sous direction humaine.';

  @override
  String get aboutProject =>
      'Une réécriture indépendante qui perpétue la simplicité de Dukto.';

  @override
  String get licenses => 'Licences tierces';

  @override
  String get notificationsAllowed => 'Notifications autorisées';

  @override
  String get notificationsDenied => 'Notifications désactivées';

  @override
  String get notificationsUndetermined => 'Pas encore autorisé';

  @override
  String get notificationsManaged => 'Notifications gérées par le système';

  @override
  String get notificationsUnavailable => 'État des notifications indisponible';

  @override
  String get notificationsChecking => 'Vérification des notifications…';

  @override
  String get folderBusy =>
      'Le dossier ne peut pas changer pendant un transfert.';

  @override
  String get receiveLocation => 'Emplacement de réception';

  @override
  String get changeFolder => 'Changer de dossier';

  @override
  String get restoreDefault => 'Par défaut';

  @override
  String get readingDeviceName => 'Lecture du nom de l’appareil…';

  @override
  String get notifications => 'Notifications';

  @override
  String get completionNotifications => 'Notifications de fin de transfert';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get systemNotificationSettings => 'Réglages système des notifications';

  @override
  String get ongoingNotificationHint =>
      'La notification du transfert en cours reste active.';

  @override
  String get appearance => 'Apparence';

  @override
  String get followSystem => 'Suivre le système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get chooseFolder => 'Choisir le dossier de réception';

  @override
  String get appStorage => 'Stockage de l’application';

  @override
  String get backgroundIos =>
      'Gardez l’application au premier plan. Changer d’app ou verrouiller l’écran peut interrompre le transfert.';

  @override
  String get backgroundAndroid =>
      'Les transferts approuvés continuent en arrière-plan. Ne forcez pas l’arrêt de l’application.';

  @override
  String get backgroundDesktop =>
      'Gardez l’application ouverte et évitez la mise en veille pendant les transferts.';

  @override
  String get backgroundStopped => 'Transfert en arrière-plan arrêté';

  @override
  String get downloadsUnavailable => 'Dossier Téléchargements indisponible';

  @override
  String get discoveryUnavailable =>
      'Détection indisponible. Essayez une connexion manuelle.';

  @override
  String get readyLan => 'Prêt · Même réseau';

  @override
  String get startupFailed =>
      'Démarrage impossible. Vérifiez les autorisations réseau.';

  @override
  String get checkNetworkPermissions =>
      'Vérifiez les autorisations réseau et rouvrez l’app';

  @override
  String get networkRecoveryFailed =>
      'Réseau non rétabli. Actualisez à nouveau.';

  @override
  String get settingsSaveFailed =>
      'Enregistrement des paramètres impossible. Réessayez.';

  @override
  String get notificationRequestFailed =>
      'Demande d’autorisation impossible. Vérifiez les réglages système.';

  @override
  String get notificationSettingsFailed =>
      'Ouverture des réglages impossible. Vérifiez les autorisations de notification de Dukto2.';

  @override
  String get receiveComplete => 'Réception terminée';

  @override
  String get sendComplete => 'Envoi terminé';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 reçu et vérifié';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 envoyé et vérifié';
  }

  @override
  String get folderUnavailable =>
      'Dossier de réception indisponible. Sélectionnez-le à nouveau.';

  @override
  String get authorizedFolder => 'Dossier autorisé';

  @override
  String get folderUpdated => 'Emplacement de réception mis à jour';

  @override
  String get folderChangeFailed =>
      'Impossible de changer l’emplacement de réception';

  @override
  String get folderReset => 'Emplacement par défaut rétabli';

  @override
  String get folderResetFailed => 'Impossible de rétablir l’emplacement';

  @override
  String receivingName(String arg0) {
    return 'Réception de $arg0';
  }

  @override
  String get textReceived => 'Texte reçu et vérifié';

  @override
  String receivedName(String arg0) {
    return '$arg0 reçu et vérifié';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Échec de réception : $arg0';
  }

  @override
  String get receiveCancelled => 'Réception annulée';

  @override
  String get waitingFiles => 'En attente de fichiers';

  @override
  String get newRequest => 'Nouvelle demande de réception';

  @override
  String get receiveDeclined => 'Réception refusée';

  @override
  String receivingBatchName(String arg0) {
    return 'Réception du lot : $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Sélection : $arg0';
  }

  @override
  String get receivingFiles => 'Réception de fichiers';

  @override
  String get sendingFiles => 'Envoi de fichiers';

  @override
  String sendingName(String arg0) {
    return 'Envoi de $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Taille illisible. Téléchargez d’abord le fichier sur cet appareil.';

  @override
  String preparingFiles(String arg0) {
    return 'Préparation : $arg0';
  }

  @override
  String get filePickerFailed => 'Sélection de fichiers impossible';

  @override
  String get textFileLimit => 'Choisissez un texte UTF-8 de 16 Mio maximum';

  @override
  String get textLoadFailed =>
      'Chargement impossible. Vérifiez le fichier et l’encodage UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'En attente de l’accord de $arg0 pour $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Envoi du fichier $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'En attente de l’accord de $arg0…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 envoyé et vérifié';
  }

  @override
  String sendFailed(String arg0) {
    return 'Échec d’envoi : $arg0';
  }

  @override
  String get canResend => 'Vous pouvez renvoyer';

  @override
  String get fileMissing => 'Fichier déplacé ou supprimé';

  @override
  String get folderOpenUnavailable =>
      'Impossible d’ouvrir le dossier du fichier';

  @override
  String get folderOpenFailed => 'Impossible d’ouvrir le dossier';

  @override
  String savedCopy(String arg0) {
    return 'Copie de $arg0 enregistrée';
  }

  @override
  String get finderFailed => 'Impossible d’afficher le fichier dans le Finder';

  @override
  String get exportFailed => 'Impossible d’exporter le fichier';

  @override
  String get failurePlatform =>
      'Transfert impossible. Vérifiez les autorisations de l’app.';

  @override
  String get failureCancelled => 'Transfert annulé';

  @override
  String get failureDeclined =>
      'Refus du destinataire ou délai d’accord expiré';

  @override
  String get failureBusy => 'Destinataire occupé. Réessayez plus tard.';

  @override
  String get failureExpired => 'Transfert expiré. Renvoyez.';

  @override
  String get failureTimeout =>
      'Délai de connexion ou de transfert dépassé. Vérifiez le réseau.';

  @override
  String get failureNetwork =>
      'Connexion interrompue. Vérifiez les deux appareils.';

  @override
  String get failureCertificate =>
      'Vérification échouée. Comparez à nouveau les codes.';

  @override
  String get failureData => 'Données invalides ou version incompatible';

  @override
  String get failureIntegrity => 'Taille ou empreinte du fichier incorrecte';

  @override
  String get failureStorage =>
      'Lecture ou écriture impossible. Vérifiez les accès et l’espace libre.';

  @override
  String get failureUnexpected => 'Transfert incomplet. Réessayez.';

  @override
  String get addressRequired => 'Saisissez une adresse IPv4 et un port';

  @override
  String get addressInvalid =>
      'Saisissez une IPv4 valide et un port de 1 à 65535';

  @override
  String get language => 'Langue';

  @override
  String get languageChoice => 'Langue';

  @override
  String get downloadsLocation => 'Téléchargements / Dukto2';

  @override
  String get iosLocation => 'Fichiers / Dukto2 / Réceptions';

  @override
  String get transferChannel => 'Transferts de fichiers';

  @override
  String get transferNotification => 'Transfert Dukto2';

  @override
  String get preparingTransfer => 'Préparation du transfert…';

  @override
  String get backgroundExpired =>
      'Temps d’arrière-plan écoulé. Revenez dans l’app et renvoyez.';

  @override
  String get notificationCancelled => 'Annulé depuis la notification';

  @override
  String get networkPermission =>
      'Dukto2 détecte et connecte les appareils du réseau local pour transférer les fichiers et textes que vous acceptez d’envoyer ou recevoir.';

  @override
  String get qrSelf =>
      'C’est le code de cet appareil. Scannez celui d’un autre.';

  @override
  String get qrConnecting => 'Essai des adresses du code QR…';

  @override
  String get qrConnectionFailed =>
      'Connexion impossible. Vérifiez que l’app est ouverte, que les appareils communiquent et que le QR est valide.';

  @override
  String get showQr => 'Afficher le code QR';

  @override
  String get scanQr => 'Scanner pour connecter';

  @override
  String get qrInstructions =>
      'Ouvrez Dukto2 sur l’autre appareil.\nSur le même réseau avec des sous-réseaux différents, essayez son QR.';

  @override
  String get connectionQr => 'Code QR de connexion';

  @override
  String get qrAfterWifi => 'Connectez-vous au réseau pour afficher le QR';

  @override
  String get qrSemantic => 'Code QR de connexion Dukto2';

  @override
  String get qrVerify =>
      'Sur le même réseau, même sur des sous-réseaux différents, si les appareils peuvent communiquer directement, touchez « Scanner pour se connecter » et scannez ce code QR.';

  @override
  String get cameraUnavailable =>
      'Caméra indisponible. Autorisez-la dans les réglages système puis rouvrez le scanner.';

  @override
  String get backToConnection => 'Retour à la connexion';

  @override
  String get qrAim =>
      'Visez le QR de connexion dans « Cet appareil » sur l’autre appareil.';

  @override
  String get subnetHint =>
      'Le QR fonctionne entre sous-réseaux du même réseau si les appareils peuvent communiquer directement.';

  @override
  String get qrExpected => 'Scannez un code QR Dukto2';

  @override
  String get qrInvalid =>
      'QR invalide. Rouvrez les informations locales sur l’autre appareil.';

  @override
  String get qrUnreachable =>
      'Connexion ou vérification impossible. Vérifiez Dukto2 et le réseau, puis scannez à nouveau.';

  @override
  String get qrNoCamera =>
      'Aucune caméra détectée. Vous pouvez choisir une image QR.';

  @override
  String get qrCamera => 'Caméra';

  @override
  String get qrChooseImage => 'Choisir une image QR';

  @override
  String get qrOpenCamera => 'Ouvrir la caméra';

  @override
  String get qrImageNotFound =>
      'Aucun code QR détecté. Choisissez une image plus nette.';

  @override
  String get qrImageTooLarge =>
      'Image trop grande. Utilisez moins de 20 Mio et 16 mégapixels.';

  @override
  String get qrImageUnreadable =>
      'Image illisible. Choisissez un fichier PNG, JPEG ou BMP.';
}
