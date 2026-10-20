import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  /// Dukto2 todayTime. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Today {arg0}'**
  String todayTime(String arg0);

  /// Dukto2 yesterdayTime. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Yesterday {arg0}'**
  String yesterdayTime(String arg0);

  /// Dukto2 lessThanSecond. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 second'**
  String get lessThanSecond;

  /// Dukto2 secondsDuration. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} s'**
  String secondsDuration(String arg0);

  /// Dukto2 minutesDuration. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} min {arg1} s'**
  String minutesDuration(String arg0, String arg1);

  /// Dukto2 hoursDuration. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} h {arg1} min {arg2} s'**
  String hoursDuration(String arg0, String arg1, String arg2);

  /// Dukto2 phone. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Dukto2 tablet. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// Dukto2 computer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// Dukto2 device. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// Dukto2 incomingOffer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} wants to send {arg1}'**
  String incomingOffer(String arg0, String arg1);

  /// Dukto2 batchConsent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Approve once to receive this batch'**
  String get batchConsent;

  /// Dukto2 textConsent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receive this text?'**
  String get textConsent;

  /// Dukto2 fileConsent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receive this file?'**
  String get fileConsent;

  /// Dukto2 approvalWarning. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The sender name is unverified. Only accept content you recognize. This request expires in {arg0} minutes.'**
  String approvalWarning(String arg0);

  /// Dukto2 receiveAt. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Save to: {arg0}'**
  String receiveAt(String arg0);

  /// Dukto2 decline. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Dukto2 receiveAll. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receive all'**
  String get receiveAll;

  /// Dukto2 receiveText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receive text'**
  String get receiveText;

  /// Dukto2 receiveFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receive file'**
  String get receiveFile;

  /// Dukto2 verifyPeer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Verify {arg0}'**
  String verifyPeer(String arg0);

  /// Dukto2 verificationInstructions. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Open Local information on the other device and compare its code with the one below.'**
  String get verificationInstructions;

  /// Dukto2 verificationWarning. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'A device name does not prove identity. Check the other screen before confirming.'**
  String get verificationWarning;

  /// Dukto2 cancel. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Dukto2 confirmConnection. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Codes match, connect'**
  String get confirmConnection;

  /// Dukto2 localInfo. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Local information'**
  String get localInfo;

  /// Dukto2 showLocalCode. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Compare this code for manual connections. Scanning verifies the device identity automatically.'**
  String get showLocalCode;

  /// Dukto2 generating. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get generating;

  /// Dukto2 deviceName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Device name'**
  String get deviceName;

  /// Dukto2 preparing. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparing;

  /// Dukto2 connectionAddress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connection address'**
  String get connectionAddress;

  /// Dukto2 addressWhenConnected. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connect to a network to see addresses'**
  String get addressWhenConnected;

  /// Dukto2 done. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Dukto2 manualConnection. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Manual connection'**
  String get manualConnection;

  /// Dukto2 findPeerAddress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Find the address in the other device\'s Local information.'**
  String get findPeerAddress;

  /// Dukto2 deviceAddress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Device address'**
  String get deviceAddress;

  /// Dukto2 addressSeparator. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Separate address and port with a colon :'**
  String get addressSeparator;

  /// Dukto2 next. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Dukto2 connecting. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// Dukto2 connectionFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check the address and network.'**
  String get connectionFailed;

  /// Dukto2 sendToPeer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send to {arg0}'**
  String sendToPeer(String arg0);

  /// Dukto2 hideKeyboard. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Hide keyboard'**
  String get hideKeyboard;

  /// Dukto2 settings. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Dukto2 thisDevice. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDevice;

  /// Dukto2 discoverable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Visible to nearby devices'**
  String get discoverable;

  /// Dukto2 starting. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Starting…'**
  String get starting;

  /// Dukto2 nearbyDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Nearby devices: {arg0}'**
  String nearbyDevices(String arg0);

  /// Dukto2 refreshDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Refresh devices'**
  String get refreshDevices;

  /// Dukto2 findingDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Looking for nearby devices…'**
  String get findingDevices;

  /// Dukto2 noDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevices;

  /// Dukto2 verifiedSelected. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Verified · Selected'**
  String get verifiedSelected;

  /// Dukto2 verifiedOffline. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Verified · Offline'**
  String get verifiedOffline;

  /// Dukto2 unverified. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// Dukto2 receivingContent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get receivingContent;

  /// Dukto2 sendingContent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send content'**
  String get sendingContent;

  /// Dukto2 directTransfer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Files and text transfer directly between devices.'**
  String get directTransfer;

  /// Dukto2 sendTo. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send to{arg0}'**
  String sendTo(String arg0);

  /// Dukto2 codeVerified. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Device identity verified'**
  String get codeVerified;

  /// Dukto2 viewVerification. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'View device code'**
  String get viewVerification;

  /// Dukto2 file. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// Dukto2 text. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// Dukto2 betweenDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Content transfers only between these two devices.'**
  String get betweenDevices;

  /// Dukto2 encryptedLan. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Direct LAN · Encrypted'**
  String get encryptedLan;

  /// Dukto2 statusPrefix. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusPrefix;

  /// Dukto2 preparingIdentity. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preparing device identity…'**
  String get preparingIdentity;

  /// Dukto2 noNearbyDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'No nearby devices found'**
  String get noNearbyDevices;

  /// Dukto2 selectDevice. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Select a device to start'**
  String get selectDevice;

  /// Dukto2 sameWifiHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connect both devices to the same network,\nand open Dukto2 on the other device.'**
  String get sameWifiHint;

  /// Dukto2 selectVerifyHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Select a device and compare its verification code.'**
  String get selectVerifyHint;

  /// Dukto2 enterAddress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Manual connection'**
  String get enterAddress;

  /// Dukto2 textCopied. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text copied'**
  String get textCopied;

  /// Dukto2 copyFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not copy. Try again.'**
  String get copyFailed;

  /// Dukto2 textContent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text content'**
  String get textContent;

  /// Dukto2 filePreviewHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preview only. Total size: {arg0}. Open the file to view the full text.'**
  String filePreviewHint(String arg0);

  /// Dukto2 textPreviewHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preview only. Copy text to copy the full content.'**
  String get textPreviewHint;

  /// Dukto2 close. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Dukto2 openFullText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Open full text'**
  String get openFullText;

  /// Dukto2 copyPreview. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Copy preview'**
  String get copyPreview;

  /// Dukto2 copyText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get copyText;

  /// Dukto2 emptyClipboard. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'No text in the clipboard'**
  String get emptyClipboard;

  /// Dukto2 editorLimit. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The editor supports 1 MiB. Load larger text from a file (up to 16 MiB).'**
  String get editorLimit;

  /// Dukto2 clipboardFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not read the clipboard. Try again.'**
  String get clipboardFailed;

  /// Dukto2 textPlaceholder. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enter text or paste a link'**
  String get textPlaceholder;

  /// Dukto2 textFileLoaded. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'UTF-8 text loaded. The full file will be streamed.'**
  String get textFileLoaded;

  /// Dukto2 textLimit. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Up to 16 MiB · Receiver approval required'**
  String get textLimit;

  /// Dukto2 textUnsupported. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'This device does not support text. Update its app first.'**
  String get textUnsupported;

  /// Dukto2 waitingText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the receiver…'**
  String get waitingText;

  /// Dukto2 sendingText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending and verifying text…'**
  String get sendingText;

  /// Dukto2 textSent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text sent and verified'**
  String get textSent;

  /// Dukto2 textCancelled. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending cancelled. Text kept.'**
  String get textCancelled;

  /// Dukto2 pasteText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get pasteText;

  /// Dukto2 moreTextActions. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'More text actions'**
  String get moreTextActions;

  /// Dukto2 loadTextFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Load text file'**
  String get loadTextFile;

  /// Dukto2 clearText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Clear content'**
  String get clearText;

  /// Dukto2 cancelTransfer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Cancel transfer'**
  String get cancelTransfer;

  /// Dukto2 sendText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send text'**
  String get sendText;

  /// Dukto2 send. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Dukto2 chooseFileHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose files to send'**
  String get chooseFileHint;

  /// Dukto2 approvalBeforeTransfer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Transfer starts after the receiver approves'**
  String get approvalBeforeTransfer;

  /// Dukto2 picking. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choosing…'**
  String get picking;

  /// Dukto2 chooseFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose files'**
  String get chooseFiles;

  /// Dukto2 multiSelectHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Select multiple · Send in order'**
  String get multiSelectHint;

  /// Dukto2 waitingBatch. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for batch upload…'**
  String get waitingBatch;

  /// Dukto2 waitingUpload. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the sender…'**
  String get waitingUpload;

  /// Dukto2 verifyingFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Verifying file…'**
  String get verifyingFile;

  /// Dukto2 receiving. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get receiving;

  /// Dukto2 ready. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Dukto2 waitingReceiver. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get waitingReceiver;

  /// Dukto2 sending. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get sending;

  /// Dukto2 waitingVerification. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification…'**
  String get waitingVerification;

  /// Dukto2 sentVerified. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sent and verified'**
  String get sentVerified;

  /// Dukto2 sendCancelled. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending cancelled'**
  String get sendCancelled;

  /// Dukto2 sendFailedRetry. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending failed. Try again.'**
  String get sendFailedRetry;

  /// Dukto2 batchSent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'All files sent and verified'**
  String get batchSent;

  /// Dukto2 batchCurrent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Item {arg0} / {arg1} · {arg2}'**
  String batchCurrent(String arg0, String arg1, String arg2);

  /// Dukto2 batchCompleted. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} / {arg1} sent · {arg2}'**
  String batchCompleted(String arg0, String arg1, String arg2);

  /// Dukto2 fileCount. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0, plural, one{{arg0} file} other{{arg0} files}}'**
  String fileCount(int arg0);

  /// Dukto2 removeFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Remove selected files'**
  String get removeFiles;

  /// Dukto2 fileSummary. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} · {arg1}{arg2}'**
  String fileSummary(String arg0, String arg1, String arg2);

  /// Dukto2 removeFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Remove {arg0}'**
  String removeFile(String arg0);

  /// Dukto2 receiveProgress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving progress'**
  String get receiveProgress;

  /// Dukto2 sendProgress. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending progress'**
  String get sendProgress;

  /// Dukto2 sendOtherFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send other files'**
  String get sendOtherFiles;

  /// Dukto2 chooseAgain. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose again'**
  String get chooseAgain;

  /// Dukto2 continueSending. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueSending;

  /// Dukto2 resend. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// Dukto2 sendFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Send files'**
  String get sendFiles;

  /// Dukto2 recentTransfers. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Recent transfers'**
  String get recentTransfers;

  /// Dukto2 allDevices. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'All devices'**
  String get allDevices;

  /// Dukto2 otherDevice. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Another device'**
  String get otherDevice;

  /// Dukto2 emptyHistory. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Completed files and text will appear here.'**
  String get emptyHistory;

  /// Dukto2 textMessage. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text message'**
  String get textMessage;

  /// Dukto2 received. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// Dukto2 sent. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// Dukto2 durationLabel. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Duration: {arg0}'**
  String durationLabel(String arg0);

  /// Dukto2 viewText. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'View text'**
  String get viewText;

  /// Dukto2 openFolderHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Open the local file\'s folder'**
  String get openFolderHint;

  /// Dukto2 noLocalFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'No local file location is available'**
  String get noLocalFile;

  /// Dukto2 openFolder. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// Dukto2 about. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'About Dukto2'**
  String get about;

  /// Dukto2 aboutTribute. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'A tribute to Dukto and its creator Emanuele Colombo. Thanks to xuzhen and the community for their continued maintenance.'**
  String get aboutTribute;

  /// Dukto2 aboutAi. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Code, UI, tests and documentation created with OpenAI Codex under human direction.'**
  String get aboutAi;

  /// Dukto2 aboutProject. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'An independent rewrite carrying forward Dukto\'s simple, direct experience.'**
  String get aboutProject;

  /// Dukto2 licenses. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Third-party licenses'**
  String get licenses;

  /// Dukto2 notificationsAllowed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'System notifications allowed'**
  String get notificationsAllowed;

  /// Dukto2 notificationsDenied. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'System notifications disabled'**
  String get notificationsDenied;

  /// Dukto2 notificationsUndetermined. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Not authorized yet'**
  String get notificationsUndetermined;

  /// Dukto2 notificationsManaged. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Notifications managed by the system'**
  String get notificationsManaged;

  /// Dukto2 notificationsUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Notification status unavailable'**
  String get notificationsUnavailable;

  /// Dukto2 notificationsChecking. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Checking notifications…'**
  String get notificationsChecking;

  /// Dukto2 folderBusy. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The receiving folder cannot change during a transfer.'**
  String get folderBusy;

  /// Dukto2 receiveLocation. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving location'**
  String get receiveLocation;

  /// Dukto2 changeFolder. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Change folder'**
  String get changeFolder;

  /// Dukto2 restoreDefault. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Restore default'**
  String get restoreDefault;

  /// Dukto2 readingDeviceName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Reading device name…'**
  String get readingDeviceName;

  /// Dukto2 notifications. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Dukto2 completionNotifications. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Transfer completion notifications'**
  String get completionNotifications;

  /// Dukto2 allowNotifications. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// Dukto2 systemNotificationSettings. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'System notification settings'**
  String get systemNotificationSettings;

  /// Dukto2 ongoingNotificationHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The ongoing transfer notification stays enabled.'**
  String get ongoingNotificationHint;

  /// Dukto2 appearance. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dukto2 followSystem. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// Dukto2 light. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dukto2 dark. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Dukto2 chooseFolder. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose receiving folder'**
  String get chooseFolder;

  /// Dukto2 appStorage. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'App storage'**
  String get appStorage;

  /// Dukto2 backgroundIos. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Keep the app in the foreground. Switching apps or locking the screen may interrupt a transfer.'**
  String get backgroundIos;

  /// Dukto2 backgroundAndroid. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Approved transfers can continue in the background. Do not force-stop the app.'**
  String get backgroundAndroid;

  /// Dukto2 backgroundDesktop. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Keep the app running and avoid sleep during transfers.'**
  String get backgroundDesktop;

  /// Dukto2 backgroundStopped. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Background transfer stopped'**
  String get backgroundStopped;

  /// Dukto2 downloadsUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'System Downloads folder unavailable'**
  String get downloadsUnavailable;

  /// Dukto2 discoveryUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Discovery unavailable. Try a manual connection.'**
  String get discoveryUnavailable;

  /// Dukto2 readyLan. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Ready · Transfer on the same network'**
  String get readyLan;

  /// Dukto2 startupFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not start. Check network permissions.'**
  String get startupFailed;

  /// Dukto2 checkNetworkPermissions. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Check network permissions and reopen the app'**
  String get checkNetworkPermissions;

  /// Dukto2 networkRecoveryFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not restore networking. Refresh again.'**
  String get networkRecoveryFailed;

  /// Dukto2 settingsSaveFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings. Try again.'**
  String get settingsSaveFailed;

  /// Dukto2 notificationRequestFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not request permission. Check system settings.'**
  String get notificationRequestFailed;

  /// Dukto2 notificationSettingsFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Check Dukto2 notification permissions manually.'**
  String get notificationSettingsFailed;

  /// Dukto2 receiveComplete. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving complete'**
  String get receiveComplete;

  /// Dukto2 sendComplete. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending complete'**
  String get sendComplete;

  /// Dukto2 receivedVerified. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} received and verified'**
  String receivedVerified(String arg0);

  /// Dukto2 sentContentVerified. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'{arg0} sent and verified'**
  String sentContentVerified(String arg0);

  /// Dukto2 folderUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving folder unavailable. Select it again.'**
  String get folderUnavailable;

  /// Dukto2 authorizedFolder. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Authorized folder'**
  String get authorizedFolder;

  /// Dukto2 folderUpdated. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving location updated'**
  String get folderUpdated;

  /// Dukto2 folderChangeFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not change the receiving location'**
  String get folderChangeFailed;

  /// Dukto2 folderReset. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Default receiving location restored'**
  String get folderReset;

  /// Dukto2 folderResetFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not restore the receiving location'**
  String get folderResetFailed;

  /// Dukto2 receivingName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving {arg0}'**
  String receivingName(String arg0);

  /// Dukto2 textReceived. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Text received and verified'**
  String get textReceived;

  /// Dukto2 receivedName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Received {arg0} and verified'**
  String receivedName(String arg0);

  /// Dukto2 receiveFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving failed: {arg0}'**
  String receiveFailed(String arg0);

  /// Dukto2 receiveCancelled. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving cancelled'**
  String get receiveCancelled;

  /// Dukto2 waitingFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for files'**
  String get waitingFiles;

  /// Dukto2 newRequest. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'New receiving request'**
  String get newRequest;

  /// Dukto2 receiveDeclined. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving declined'**
  String get receiveDeclined;

  /// Dukto2 receivingBatchName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving batch file: {arg0}'**
  String receivingBatchName(String arg0);

  /// Dukto2 selectedPeer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Selected {arg0}'**
  String selectedPeer(String arg0);

  /// Dukto2 receivingFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Receiving files'**
  String get receivingFiles;

  /// Dukto2 sendingFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending files'**
  String get sendingFiles;

  /// Dukto2 sendingName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending {arg0}'**
  String sendingName(String arg0);

  /// Dukto2 fileSizeUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not read file size. Download the file to this device first.'**
  String get fileSizeUnavailable;

  /// Dukto2 preparingFiles. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preparing {arg0}'**
  String preparingFiles(String arg0);

  /// Dukto2 filePickerFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not choose files'**
  String get filePickerFailed;

  /// Dukto2 textFileLimit. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Choose a UTF-8 text file up to 16 MiB'**
  String get textFileLimit;

  /// Dukto2 textLoadFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not load text. Check the file and UTF-8 encoding.'**
  String get textLoadFailed;

  /// Dukto2 waitingPeerFile. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {arg0} to accept {arg1}…'**
  String waitingPeerFile(String arg0, String arg1);

  /// Dukto2 sendingBatchIndex. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending batch file {arg0} / {arg1}'**
  String sendingBatchIndex(String arg0, String arg1);

  /// Dukto2 waitingPeer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Waiting for {arg0} to accept…'**
  String waitingPeer(String arg0);

  /// Dukto2 sentName. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sent {arg0} and verified'**
  String sentName(String arg0);

  /// Dukto2 sendFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Sending failed: {arg0}'**
  String sendFailed(String arg0);

  /// Dukto2 canResend. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'You can send again'**
  String get canResend;

  /// Dukto2 fileMissing. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'File moved or deleted'**
  String get fileMissing;

  /// Dukto2 folderOpenUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file\'s folder'**
  String get folderOpenUnavailable;

  /// Dukto2 folderOpenFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not open the folder'**
  String get folderOpenFailed;

  /// Dukto2 savedCopy. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Saved a copy of {arg0}'**
  String savedCopy(String arg0);

  /// Dukto2 finderFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not reveal the file in Finder'**
  String get finderFailed;

  /// Dukto2 exportFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not export the file'**
  String get exportFailed;

  /// Dukto2 failurePlatform. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not start the transfer. Check app permissions.'**
  String get failurePlatform;

  /// Dukto2 failureCancelled. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Transfer cancelled'**
  String get failureCancelled;

  /// Dukto2 failureDeclined. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The receiver declined or approval timed out'**
  String get failureDeclined;

  /// Dukto2 failureBusy. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'The receiver is busy. Try again later.'**
  String get failureBusy;

  /// Dukto2 failureExpired. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Transfer expired. Send again.'**
  String get failureExpired;

  /// Dukto2 failureTimeout. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connection or transfer timed out. Check the network.'**
  String get failureTimeout;

  /// Dukto2 failureNetwork. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connection interrupted. Check both devices.'**
  String get failureNetwork;

  /// Dukto2 failureCertificate. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Device verification failed. Compare codes again.'**
  String get failureCertificate;

  /// Dukto2 failureData. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Invalid data or incompatible app version'**
  String get failureData;

  /// Dukto2 failureIntegrity. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'File size or checksum mismatch'**
  String get failureIntegrity;

  /// Dukto2 failureStorage. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Could not read or write. Check folder access and free space.'**
  String get failureStorage;

  /// Dukto2 failureUnexpected. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Transfer incomplete. Try again.'**
  String get failureUnexpected;

  /// Dukto2 addressRequired. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enter an IPv4 address and port'**
  String get addressRequired;

  /// Dukto2 addressInvalid. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IPv4 address and port from 1 to 65535'**
  String get addressInvalid;

  /// Dukto2 language. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Dukto2 languageChoice. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageChoice;

  /// Dukto2 downloadsLocation. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Downloads / Dukto2'**
  String get downloadsLocation;

  /// Dukto2 iosLocation. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Files / Dukto2 / Received files'**
  String get iosLocation;

  /// Dukto2 transferChannel. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'File transfers'**
  String get transferChannel;

  /// Dukto2 transferNotification. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Dukto2 transfer'**
  String get transferNotification;

  /// Dukto2 preparingTransfer. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Preparing transfer…'**
  String get preparingTransfer;

  /// Dukto2 backgroundExpired. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Background time expired. Return to the app and send again.'**
  String get backgroundExpired;

  /// Dukto2 notificationCancelled. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Cancelled from notification'**
  String get notificationCancelled;

  /// Dukto2 networkPermission. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Dukto2 discovers and connects to devices on your local network to transfer files and text you choose to send or receive.'**
  String get networkPermission;

  /// Dukto2 qrSelf. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'This is this device’s QR code. Scan another device instead.'**
  String get qrSelf;

  /// Dukto2 qrConnecting. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Trying the device addresses in the QR code…'**
  String get qrConnecting;

  /// Dukto2 qrConnectionFailed. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Check that the other app is open, the devices can communicate, and the QR code is still valid.'**
  String get qrConnectionFailed;

  /// Dukto2 showQr. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Show QR code'**
  String get showQr;

  /// Dukto2 scanQr. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Scan to connect'**
  String get scanQr;

  /// Dukto2 qrInstructions. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Open Dukto2 on the other device.\nIf you share network but use different subnets, try scanning its QR code.'**
  String get qrInstructions;

  /// Dukto2 connectionQr. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connection QR code'**
  String get connectionQr;

  /// Dukto2 qrAfterWifi. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Connect to a network to show the QR code'**
  String get qrAfterWifi;

  /// Dukto2 qrSemantic. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Dukto2 device connection QR code'**
  String get qrSemantic;

  /// Dukto2 qrVerify. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'On the same network, even across different subnets, if the devices can communicate directly, tap “Scan to connect” and scan this QR code to connect.'**
  String get qrVerify;

  /// Dukto2 cameraUnavailable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable. Allow camera access for Dukto2 in system settings, then open the scanner again.'**
  String get cameraUnavailable;

  /// Dukto2 backToConnection. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Back to connection'**
  String get backToConnection;

  /// Dukto2 qrAim. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the connection QR code in the other device’s “This device” panel.'**
  String get qrAim;

  /// Dukto2 subnetHint. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'QR connection also works across subnets on the same network, provided the devices can communicate directly.'**
  String get subnetHint;

  /// Dukto2 qrExpected. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Scan a Dukto2 connection QR code'**
  String get qrExpected;

  /// Dukto2 qrInvalid. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code. Open “This device” again on the other device.'**
  String get qrInvalid;

  /// Dukto2 qrUnreachable. Keep names, paths and codes unchanged.
  ///
  /// In en, this message translates to:
  /// **'Unable to reach or verify this device. Check that Dukto2 is open and the network allows device communication, then scan again.'**
  String get qrUnreachable;

  /// Windows QR scanner: qrNoCamera
  ///
  /// In en, this message translates to:
  /// **'No camera found. You can choose a QR image.'**
  String get qrNoCamera;

  /// Windows QR scanner: qrCamera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get qrCamera;

  /// Windows QR scanner: qrChooseImage
  ///
  /// In en, this message translates to:
  /// **'Choose QR image'**
  String get qrChooseImage;

  /// Windows QR scanner: qrOpenCamera
  ///
  /// In en, this message translates to:
  /// **'Open camera'**
  String get qrOpenCamera;

  /// Windows QR scanner: qrImageNotFound
  ///
  /// In en, this message translates to:
  /// **'No QR code found. Choose a clearer image.'**
  String get qrImageNotFound;

  /// Windows QR scanner: qrImageTooLarge
  ///
  /// In en, this message translates to:
  /// **'Image too large. Use an image under 20 MiB and 16 megapixels.'**
  String get qrImageTooLarge;

  /// Windows QR scanner: qrImageUnreadable
  ///
  /// In en, this message translates to:
  /// **'Cannot read this image. Choose a PNG, JPEG or BMP image.'**
  String get qrImageUnreadable;

  /// Selected device connection status; separate from discovery.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get deviceOffline;

  /// Selected device connection status; separate from discovery.
  ///
  /// In en, this message translates to:
  /// **'Checking connection…'**
  String get deviceChecking;

  /// Selected device connection status; separate from discovery.
  ///
  /// In en, this message translates to:
  /// **'Device identity changed'**
  String get deviceIdentityChanged;

  /// Selected device is reachable and its full identity matches.
  ///
  /// In en, this message translates to:
  /// **'Online · Identity verified'**
  String get deviceOnline;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
