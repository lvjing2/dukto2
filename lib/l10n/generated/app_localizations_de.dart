// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Heute $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Gestern $arg0';
  }

  @override
  String get lessThanSecond => 'Unter 1 Sekunde';

  @override
  String secondsDuration(String arg0) {
    return '$arg0 s';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0 Min. $arg1 Sek.';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0 Std. $arg1 Min. $arg2 Sek.';
  }

  @override
  String get phone => 'Smartphone';

  @override
  String get tablet => 'Tablet';

  @override
  String get computer => 'Computer';

  @override
  String get device => 'Gerät';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 möchte $arg1 senden';
  }

  @override
  String get batchConsent => 'Einmal bestätigen, um den Stapel zu empfangen';

  @override
  String get textConsent => 'Diesen Text empfangen?';

  @override
  String get fileConsent => 'Diese Datei empfangen?';

  @override
  String approvalWarning(String arg0) {
    return 'Der Absendername ist nicht verifiziert. Nur bekannte Inhalte annehmen. Die Anfrage läuft in $arg0 Minuten ab.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Speichern unter: $arg0';
  }

  @override
  String get decline => 'Ablehnen';

  @override
  String get receiveAll => 'Alle empfangen';

  @override
  String get receiveText => 'Text empfangen';

  @override
  String get receiveFile => 'Datei empfangen';

  @override
  String verifyPeer(String arg0) {
    return '$arg0 verifizieren';
  }

  @override
  String get verificationInstructions =>
      'Lokale Informationen auf dem anderen Gerät öffnen und den Code vergleichen.';

  @override
  String get verificationWarning =>
      'Der Gerätename beweist keine Identität. Vor dem Bestätigen den anderen Bildschirm prüfen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirmConnection => 'Codes stimmen überein';

  @override
  String get localInfo => 'Lokale Informationen';

  @override
  String get showLocalCode =>
      'Prüfen Sie diesen Code bei manuellen Verbindungen. Beim Scannen wird die Geräteidentität automatisch geprüft.';

  @override
  String get generating => 'Wird erstellt…';

  @override
  String get deviceName => 'Gerätename';

  @override
  String get preparing => 'Vorbereitung…';

  @override
  String get connectionAddress => 'Verbindungsadresse';

  @override
  String get addressWhenConnected =>
      'Für Adressen mit einem Netzwerk verbinden';

  @override
  String get done => 'Fertig';

  @override
  String get manualConnection => 'Manuell verbinden';

  @override
  String get findPeerAddress =>
      'Adresse unter „Lokale Informationen“ auf dem anderen Gerät ablesen.';

  @override
  String get deviceAddress => 'Geräteadresse';

  @override
  String get addressSeparator => 'Adresse und Port mit Doppelpunkt : trennen';

  @override
  String get next => 'Weiter';

  @override
  String get connecting => 'Verbindung wird hergestellt…';

  @override
  String get connectionFailed =>
      'Verbindung fehlgeschlagen. Adresse und Netzwerk prüfen.';

  @override
  String sendToPeer(String arg0) {
    return 'An $arg0 senden';
  }

  @override
  String get hideKeyboard => 'Tastatur ausblenden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get thisDevice => 'Dieses Gerät';

  @override
  String get discoverable => 'Für Geräte in der Nähe sichtbar';

  @override
  String get starting => 'Startet…';

  @override
  String nearbyDevices(String arg0) {
    return 'Geräte in der Nähe: $arg0';
  }

  @override
  String get refreshDevices => 'Geräte aktualisieren';

  @override
  String get findingDevices => 'Suche nach Geräten…';

  @override
  String get noDevices => 'Keine Geräte gefunden';

  @override
  String get verifiedSelected => 'Verifiziert · Ausgewählt';

  @override
  String get verifiedOffline => 'Verifiziert · Offline';

  @override
  String get unverified => 'Nicht verifiziert';

  @override
  String get receivingContent => 'Empfang';

  @override
  String get sendingContent => 'Inhalte senden';

  @override
  String get directTransfer =>
      'Dateien und Texte werden direkt zwischen Geräten übertragen.';

  @override
  String sendTo(String arg0) {
    return 'Senden an$arg0';
  }

  @override
  String get codeVerified => 'Geräteidentität bestätigt';

  @override
  String get viewVerification => 'Gerätecode anzeigen';

  @override
  String get file => 'Datei';

  @override
  String get text => 'Text';

  @override
  String get betweenDevices =>
      'Inhalte werden nur zwischen diesen beiden Geräten übertragen.';

  @override
  String get encryptedLan => 'Direktes LAN · Verschlüsselt';

  @override
  String get statusPrefix => 'Abgeschlossen';

  @override
  String get preparingIdentity => 'Geräteidentität wird vorbereitet…';

  @override
  String get noNearbyDevices => 'Keine Geräte in der Nähe';

  @override
  String get selectDevice => 'Zum Starten ein Gerät auswählen';

  @override
  String get sameWifiHint =>
      'Beide Geräte mit demselben Netzwerk verbinden\nund Dukto2 auf dem anderen Gerät öffnen.';

  @override
  String get selectVerifyHint => 'Gerät auswählen und Code vergleichen.';

  @override
  String get enterAddress => 'Manuell verbinden';

  @override
  String get textCopied => 'Text kopiert';

  @override
  String get copyFailed => 'Kopieren fehlgeschlagen. Erneut versuchen.';

  @override
  String get textContent => 'Textinhalt';

  @override
  String filePreviewHint(String arg0) {
    return 'Nur Vorschau. Gesamtgröße: $arg0. Für den vollständigen Text die Datei öffnen.';
  }

  @override
  String get textPreviewHint =>
      'Nur Vorschau. „Text kopieren“ kopiert den vollständigen Inhalt.';

  @override
  String get close => 'Schließen';

  @override
  String get openFullText => 'Vollständigen Text öffnen';

  @override
  String get copyPreview => 'Vorschau kopieren';

  @override
  String get copyText => 'Text kopieren';

  @override
  String get emptyClipboard => 'Kein Text in der Zwischenablage';

  @override
  String get editorLimit =>
      'Der Editor unterstützt 1 MiB. Größere Texte aus einer Datei laden (bis 16 MiB).';

  @override
  String get clipboardFailed =>
      'Zwischenablage konnte nicht gelesen werden. Erneut versuchen.';

  @override
  String get textPlaceholder => 'Text eingeben oder Link einfügen';

  @override
  String get textFileLoaded =>
      'UTF-8-Text geladen. Die vollständige Datei wird übertragen.';

  @override
  String get textLimit => 'Bis 16 MiB · Zustimmung erforderlich';

  @override
  String get textUnsupported =>
      'Dieses Gerät unterstützt keinen Text. Zuerst seine App aktualisieren.';

  @override
  String get waitingText => 'Warte auf Empfänger…';

  @override
  String get sendingText => 'Text wird gesendet und geprüft…';

  @override
  String get textSent => 'Text gesendet und geprüft';

  @override
  String get textCancelled => 'Senden abgebrochen. Text beibehalten.';

  @override
  String get pasteText => 'Text einfügen';

  @override
  String get moreTextActions => 'Weitere Textaktionen';

  @override
  String get loadTextFile => 'Textdatei laden';

  @override
  String get clearText => 'Inhalt löschen';

  @override
  String get cancelTransfer => 'Übertragung abbrechen';

  @override
  String get sendText => 'Text senden';

  @override
  String get send => 'Senden';

  @override
  String get chooseFileHint => 'Dateien zum Senden auswählen';

  @override
  String get approvalBeforeTransfer =>
      'Die Übertragung beginnt nach Zustimmung';

  @override
  String get picking => 'Auswahl…';

  @override
  String get chooseFiles => 'Dateien auswählen';

  @override
  String get multiSelectHint => 'Mehrfachauswahl · Der Reihe nach senden';

  @override
  String get waitingBatch => 'Warte auf Stapelübertragung…';

  @override
  String get waitingUpload => 'Warte auf Absender…';

  @override
  String get verifyingFile => 'Datei wird geprüft…';

  @override
  String get receiving => 'Wird empfangen';

  @override
  String get ready => 'Bereit';

  @override
  String get waitingReceiver => 'Warte auf Zustimmung';

  @override
  String get sending => 'Wird gesendet';

  @override
  String get waitingVerification => 'Warte auf Prüfung…';

  @override
  String get sentVerified => 'Gesendet und geprüft';

  @override
  String get sendCancelled => 'Senden abgebrochen';

  @override
  String get sendFailedRetry => 'Senden fehlgeschlagen. Erneut versuchen.';

  @override
  String get batchSent => 'Alle Dateien gesendet und geprüft';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Datei $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 gesendet · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 Dateien',
      one: '$arg0 Datei',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Ausgewählte Dateien entfernen';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return '$arg0 entfernen';
  }

  @override
  String get receiveProgress => 'Empfangsfortschritt';

  @override
  String get sendProgress => 'Sendefortschritt';

  @override
  String get sendOtherFiles => 'Andere Dateien senden';

  @override
  String get chooseAgain => 'Erneut auswählen';

  @override
  String get continueSending => 'Fortsetzen';

  @override
  String get resend => 'Erneut senden';

  @override
  String get sendFiles => 'Dateien senden';

  @override
  String get recentTransfers => 'Letzte Übertragungen';

  @override
  String get allDevices => 'Alle Geräte';

  @override
  String get otherDevice => 'Anderes Gerät';

  @override
  String get emptyHistory =>
      'Abgeschlossene Dateien und Texte erscheinen hier.';

  @override
  String get textMessage => 'Textnachricht';

  @override
  String get received => 'Empfangen';

  @override
  String get sent => 'Gesendet';

  @override
  String durationLabel(String arg0) {
    return 'Dauer: $arg0';
  }

  @override
  String get viewText => 'Text ansehen';

  @override
  String get openFolderHint => 'Ordner der lokalen Datei öffnen';

  @override
  String get noLocalFile => 'Kein lokaler Dateipfad verfügbar';

  @override
  String get openFolder => 'Ordner öffnen';

  @override
  String get about => 'Über Dukto2';

  @override
  String get aboutTribute =>
      'Eine Hommage an Dukto und seinen Entwickler Emanuele Colombo. Danke an xuzhen und die Community für die fortlaufende Pflege.';

  @override
  String get aboutAi =>
      'Code, Oberfläche, Tests und Dokumentation mit OpenAI Codex unter menschlicher Leitung erstellt.';

  @override
  String get aboutProject =>
      'Eine eigenständige Neuentwicklung, die Duktos einfaches, direktes Erlebnis fortführt.';

  @override
  String get licenses => 'Drittanbieterlizenzen';

  @override
  String get notificationsAllowed => 'Benachrichtigungen erlaubt';

  @override
  String get notificationsDenied => 'Benachrichtigungen deaktiviert';

  @override
  String get notificationsUndetermined => 'Noch nicht autorisiert';

  @override
  String get notificationsManaged => 'Vom System verwaltet';

  @override
  String get notificationsUnavailable =>
      'Benachrichtigungsstatus nicht verfügbar';

  @override
  String get notificationsChecking => 'Benachrichtigungen werden geprüft…';

  @override
  String get folderBusy =>
      'Empfangsordner während der Übertragung nicht änderbar.';

  @override
  String get receiveLocation => 'Empfangsordner';

  @override
  String get changeFolder => 'Ordner ändern';

  @override
  String get restoreDefault => 'Zurücksetzen';

  @override
  String get readingDeviceName => 'Gerätename wird gelesen…';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get completionNotifications => 'Benachrichtigung bei Abschluss';

  @override
  String get allowNotifications => 'Benachrichtigungen erlauben';

  @override
  String get systemNotificationSettings =>
      'Systemeinstellungen für Mitteilungen';

  @override
  String get ongoingNotificationHint =>
      'Die Benachrichtigung laufender Übertragungen bleibt aktiv.';

  @override
  String get appearance => 'Darstellung';

  @override
  String get followSystem => 'Systemeinstellung';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get chooseFolder => 'Empfangsordner auswählen';

  @override
  String get appStorage => 'App-Speicher';

  @override
  String get backgroundIos =>
      'App im Vordergrund lassen. App-Wechsel oder Sperren kann Übertragungen unterbrechen.';

  @override
  String get backgroundAndroid =>
      'Bestätigte Übertragungen laufen im Hintergrund weiter. App nicht zwangsweise beenden.';

  @override
  String get backgroundDesktop =>
      'App geöffnet lassen und Ruhezustand während der Übertragung vermeiden.';

  @override
  String get backgroundStopped => 'Hintergrundübertragung beendet';

  @override
  String get downloadsUnavailable => 'Downloadordner nicht verfügbar';

  @override
  String get discoveryUnavailable =>
      'Gerätesuche nicht verfügbar. Manuell verbinden.';

  @override
  String get readyLan => 'Bereit · Im selben Netzwerk';

  @override
  String get startupFailed =>
      'Start fehlgeschlagen. Netzwerkberechtigungen prüfen.';

  @override
  String get checkNetworkPermissions =>
      'Netzwerkberechtigungen prüfen und App neu öffnen';

  @override
  String get networkRecoveryFailed =>
      'Netzwerk nicht wiederhergestellt. Erneut aktualisieren.';

  @override
  String get settingsSaveFailed =>
      'Einstellungen nicht gespeichert. Erneut versuchen.';

  @override
  String get notificationRequestFailed =>
      'Berechtigung konnte nicht angefordert werden. Systemeinstellungen prüfen.';

  @override
  String get notificationSettingsFailed =>
      'Einstellungen konnten nicht geöffnet werden. Dukto2-Mitteilungsrechte manuell prüfen.';

  @override
  String get receiveComplete => 'Empfang abgeschlossen';

  @override
  String get sendComplete => 'Senden abgeschlossen';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 empfangen und geprüft';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 gesendet und geprüft';
  }

  @override
  String get folderUnavailable =>
      'Empfangsordner nicht verfügbar. Erneut auswählen.';

  @override
  String get authorizedFolder => 'Autorisierter Ordner';

  @override
  String get folderUpdated => 'Empfangsordner aktualisiert';

  @override
  String get folderChangeFailed =>
      'Empfangsordner konnte nicht geändert werden';

  @override
  String get folderReset => 'Standard-Empfangsordner wiederhergestellt';

  @override
  String get folderResetFailed => 'Empfangsordner nicht wiederhergestellt';

  @override
  String receivingName(String arg0) {
    return 'Empfange $arg0';
  }

  @override
  String get textReceived => 'Text empfangen und geprüft';

  @override
  String receivedName(String arg0) {
    return '$arg0 empfangen und geprüft';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Empfang fehlgeschlagen: $arg0';
  }

  @override
  String get receiveCancelled => 'Empfang abgebrochen';

  @override
  String get waitingFiles => 'Warte auf Dateien';

  @override
  String get newRequest => 'Neue Empfangsanfrage';

  @override
  String get receiveDeclined => 'Empfang abgelehnt';

  @override
  String receivingBatchName(String arg0) {
    return 'Empfange Stapeldatei: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Ausgewählt: $arg0';
  }

  @override
  String get receivingFiles => 'Dateien werden empfangen';

  @override
  String get sendingFiles => 'Dateien werden gesendet';

  @override
  String sendingName(String arg0) {
    return 'Sende $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Dateigröße nicht lesbar. Datei zuerst auf dieses Gerät herunterladen.';

  @override
  String preparingFiles(String arg0) {
    return 'Vorbereitung: $arg0';
  }

  @override
  String get filePickerFailed => 'Dateiauswahl fehlgeschlagen';

  @override
  String get textFileLimit => 'UTF-8-Textdatei bis 16 MiB auswählen';

  @override
  String get textLoadFailed =>
      'Text konnte nicht geladen werden. Datei und UTF-8-Kodierung prüfen.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Warte auf Zustimmung von $arg0 für $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Sende Stapeldatei $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Warte auf Zustimmung von $arg0…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 gesendet und geprüft';
  }

  @override
  String sendFailed(String arg0) {
    return 'Senden fehlgeschlagen: $arg0';
  }

  @override
  String get canResend => 'Erneutes Senden möglich';

  @override
  String get fileMissing => 'Datei verschoben oder gelöscht';

  @override
  String get folderOpenUnavailable =>
      'Dateiordner konnte nicht geöffnet werden';

  @override
  String get folderOpenFailed => 'Ordner konnte nicht geöffnet werden';

  @override
  String savedCopy(String arg0) {
    return 'Kopie von $arg0 gespeichert';
  }

  @override
  String get finderFailed => 'Datei konnte nicht im Finder angezeigt werden';

  @override
  String get exportFailed => 'Dateiexport fehlgeschlagen';

  @override
  String get failurePlatform =>
      'Übertragung nicht gestartet. App-Berechtigungen prüfen.';

  @override
  String get failureCancelled => 'Übertragung abgebrochen';

  @override
  String get failureDeclined =>
      'Empfänger hat abgelehnt oder Zustimmung ist abgelaufen';

  @override
  String get failureBusy => 'Empfänger beschäftigt. Später erneut versuchen.';

  @override
  String get failureExpired => 'Übertragung abgelaufen. Erneut senden.';

  @override
  String get failureTimeout => 'Zeitüberschreitung. Netzwerk prüfen.';

  @override
  String get failureNetwork => 'Verbindung unterbrochen. Beide Geräte prüfen.';

  @override
  String get failureCertificate =>
      'Geräteprüfung fehlgeschlagen. Codes erneut vergleichen.';

  @override
  String get failureData => 'Ungültige Daten oder inkompatible App-Version';

  @override
  String get failureIntegrity => 'Dateigröße oder Prüfsumme stimmt nicht';

  @override
  String get failureStorage =>
      'Lesen oder Schreiben fehlgeschlagen. Ordnerrechte und freien Speicher prüfen.';

  @override
  String get failureUnexpected =>
      'Übertragung unvollständig. Erneut versuchen.';

  @override
  String get addressRequired => 'IPv4-Adresse und Port eingeben';

  @override
  String get addressInvalid =>
      'Gültige IPv4-Adresse und Port von 1 bis 65535 eingeben';

  @override
  String get language => 'Sprache';

  @override
  String get languageChoice => 'Sprache';

  @override
  String get downloadsLocation => 'Downloads / Dukto2';

  @override
  String get iosLocation => 'Dateien / Dukto2 / Empfangene Dateien';

  @override
  String get transferChannel => 'Dateiübertragungen';

  @override
  String get transferNotification => 'Dukto2-Übertragung';

  @override
  String get preparingTransfer => 'Übertragung wird vorbereitet…';

  @override
  String get backgroundExpired =>
      'Hintergrundzeit abgelaufen. Zur App zurückkehren und erneut senden.';

  @override
  String get notificationCancelled => 'Über Benachrichtigung abgebrochen';

  @override
  String get networkPermission =>
      'Dukto2 findet und verbindet Geräte im lokalen Netzwerk, um die von Ihnen ausgewählten Dateien und Texte zu übertragen.';

  @override
  String get qrSelf =>
      'Dies ist der eigene QR-Code. Den eines anderen Geräts scannen.';

  @override
  String get qrConnecting => 'Adressen aus dem QR-Code werden geprüft…';

  @override
  String get qrConnectionFailed =>
      'Verbindung fehlgeschlagen. App, Netzwerkverbindung und Gültigkeit des QR-Codes prüfen.';

  @override
  String get showQr => 'QR-Code anzeigen';

  @override
  String get scanQr => 'Zum Verbinden scannen';

  @override
  String get qrInstructions =>
      'Dukto2 auf dem anderen Gerät öffnen.\nBei verschiedenen Subnetzen im selben Netzwerk den QR-Code versuchen.';

  @override
  String get connectionQr => 'Verbindungs-QR-Code';

  @override
  String get qrAfterWifi => 'Für den QR-Code mit einem Netzwerk verbinden';

  @override
  String get qrSemantic => 'Dukto2-Geräte-QR-Code';

  @override
  String get qrVerify =>
      'Wenn sich die Geräte im selben Netzwerk direkt erreichen können, tippen Sie auch über verschiedene Subnetze hinweg auf „Zum Verbinden scannen“ und scannen Sie diesen QR-Code.';

  @override
  String get cameraUnavailable =>
      'Kamera nicht verfügbar. Zugriff in den Systemeinstellungen erlauben und Scanner neu öffnen.';

  @override
  String get backToConnection => 'Zurück zur Verbindung';

  @override
  String get qrAim =>
      'Kamera auf den QR-Code unter „Dieses Gerät“ des anderen Geräts richten.';

  @override
  String get subnetHint =>
      'QR-Verbindungen funktionieren zwischen Subnetzen desselben Netzwerks, wenn die Geräte direkt kommunizieren können.';

  @override
  String get qrExpected => 'Einen Dukto2-QR-Code scannen';

  @override
  String get qrInvalid =>
      'Ungültiger QR-Code. Lokale Informationen auf dem anderen Gerät neu öffnen.';

  @override
  String get qrUnreachable =>
      'Gerät nicht erreichbar oder nicht verifiziert. Dukto2 und Netzwerk prüfen und erneut scannen.';

  @override
  String get qrNoCamera =>
      'Keine Kamera gefunden. Du kannst ein QR-Bild auswählen.';

  @override
  String get qrCamera => 'Kamera';

  @override
  String get qrChooseImage => 'QR-Bild auswählen';

  @override
  String get qrOpenCamera => 'Kamera öffnen';

  @override
  String get qrImageNotFound =>
      'Kein QR-Code gefunden. Wähle ein schärferes Bild.';

  @override
  String get qrImageTooLarge =>
      'Bild zu groß. Verwende weniger als 20 MiB und 16 Megapixel.';

  @override
  String get qrImageUnreadable =>
      'Bild nicht lesbar. Wähle PNG, JPEG oder BMP.';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get deviceChecking => 'Verbindung wird geprüft…';

  @override
  String get deviceIdentityChanged => 'Geräteidentität geändert';

  @override
  String get deviceOnline => 'Online · Identität geprüft';
}
