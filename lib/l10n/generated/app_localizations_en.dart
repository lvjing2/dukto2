// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Today $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Yesterday $arg0';
  }

  @override
  String get lessThanSecond => 'Less than 1 second';

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
  String get phone => 'Phone';

  @override
  String get tablet => 'Tablet';

  @override
  String get computer => 'Computer';

  @override
  String get device => 'Device';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 wants to send $arg1';
  }

  @override
  String get batchConsent => 'Approve once to receive this batch';

  @override
  String get textConsent => 'Receive this text?';

  @override
  String get fileConsent => 'Receive this file?';

  @override
  String approvalWarning(String arg0) {
    return 'The sender name is unverified. Only accept content you recognize. This request expires in $arg0 minutes.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Save to: $arg0';
  }

  @override
  String get decline => 'Decline';

  @override
  String get receiveAll => 'Receive all';

  @override
  String get receiveText => 'Receive text';

  @override
  String get receiveFile => 'Receive file';

  @override
  String verifyPeer(String arg0) {
    return 'Verify $arg0';
  }

  @override
  String get verificationInstructions =>
      'Open Local information on the other device and compare its code with the one below.';

  @override
  String get verificationWarning =>
      'A device name does not prove identity. Check the other screen before confirming.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirmConnection => 'Codes match, connect';

  @override
  String get localInfo => 'Local information';

  @override
  String get showLocalCode =>
      'Compare this code for manual connections. Scanning verifies the device identity automatically.';

  @override
  String get generating => 'Generating…';

  @override
  String get deviceName => 'Device name';

  @override
  String get preparing => 'Preparing…';

  @override
  String get connectionAddress => 'Connection address';

  @override
  String get addressWhenConnected => 'Connect to a network to see addresses';

  @override
  String get done => 'Done';

  @override
  String get manualConnection => 'Manual connection';

  @override
  String get findPeerAddress =>
      'Find the address in the other device\'s Local information.';

  @override
  String get deviceAddress => 'Device address';

  @override
  String get addressSeparator => 'Separate address and port with a colon :';

  @override
  String get next => 'Next';

  @override
  String get connecting => 'Connecting…';

  @override
  String get connectionFailed =>
      'Could not connect. Check the address and network.';

  @override
  String sendToPeer(String arg0) {
    return 'Send to $arg0';
  }

  @override
  String get hideKeyboard => 'Hide keyboard';

  @override
  String get settings => 'Settings';

  @override
  String get thisDevice => 'This device';

  @override
  String get discoverable => 'Visible to nearby devices';

  @override
  String get starting => 'Starting…';

  @override
  String nearbyDevices(String arg0) {
    return 'Nearby devices: $arg0';
  }

  @override
  String get refreshDevices => 'Refresh devices';

  @override
  String get searchingDevices => 'Searching…';

  @override
  String get findingDevices => 'Looking for nearby devices…';

  @override
  String get noDevices => 'No devices found';

  @override
  String get verifiedSelected => 'Verified · Selected';

  @override
  String get verifiedOffline => 'Verified · Offline';

  @override
  String get unverified => 'Unverified';

  @override
  String get receivingContent => 'Receiving';

  @override
  String get sendingContent => 'Send content';

  @override
  String get directTransfer =>
      'Files and text are encrypted and transferred directly between the two devices over the local network.';

  @override
  String sendTo(String arg0) {
    return 'Send to$arg0';
  }

  @override
  String get codeVerified => 'Device identity verified';

  @override
  String get viewVerification => 'View device code';

  @override
  String get file => 'File';

  @override
  String get text => 'Text';

  @override
  String get statusPrefix => 'Completed';

  @override
  String get preparingIdentity => 'Preparing device identity…';

  @override
  String get noNearbyDevices => 'No nearby devices found';

  @override
  String get selectDevice => 'Select a device to start';

  @override
  String get sameWifiHint =>
      'Connect both devices to the same network,\nand open Dukto2 on the other device.';

  @override
  String get selectVerifyHint =>
      'Select a device and compare its verification code.';

  @override
  String get enterAddress => 'Manual connection';

  @override
  String get textCopied => 'Text copied';

  @override
  String get copyFailed => 'Could not copy. Try again.';

  @override
  String get textContent => 'Text content';

  @override
  String filePreviewHint(String arg0) {
    return 'Preview only. Total size: $arg0. Open the file to view the full text.';
  }

  @override
  String get textPreviewHint =>
      'Preview only. Copy text to copy the full content.';

  @override
  String get close => 'Close';

  @override
  String get openFullText => 'Open full text';

  @override
  String get copyPreview => 'Copy preview';

  @override
  String get copyText => 'Copy text';

  @override
  String get emptyClipboard => 'No text in the clipboard';

  @override
  String get editorLimit =>
      'The editor supports 1 MiB. Load larger text from a file (up to 16 MiB).';

  @override
  String get clipboardFailed => 'Could not read the clipboard. Try again.';

  @override
  String get textPlaceholder => 'Enter text or paste a link';

  @override
  String get textFileLoaded =>
      'UTF-8 text loaded. The full file will be streamed.';

  @override
  String get textLimit => 'Up to 16 MiB · Receiver approval required';

  @override
  String get textUnsupported =>
      'This device does not support text. Update its app first.';

  @override
  String get waitingText => 'Waiting for the receiver…';

  @override
  String get sendingText => 'Sending and verifying text…';

  @override
  String get textSent => 'Text sent and verified';

  @override
  String get textCancelled => 'Sending cancelled. Text kept.';

  @override
  String get pasteText => 'Paste text';

  @override
  String get moreTextActions => 'More text actions';

  @override
  String get loadTextFile => 'Load text file';

  @override
  String get clearText => 'Clear content';

  @override
  String get cancelTransfer => 'Cancel transfer';

  @override
  String get sendText => 'Send text';

  @override
  String get send => 'Send';

  @override
  String get chooseFileHint => 'Choose files to send';

  @override
  String get approvalBeforeTransfer =>
      'Transfer starts after the receiver approves';

  @override
  String get picking => 'Choosing…';

  @override
  String get chooseFiles => 'Choose files';

  @override
  String get multiSelectHint => 'Select multiple · Send in order';

  @override
  String get waitingBatch => 'Waiting for batch upload…';

  @override
  String get waitingUpload => 'Waiting for the sender…';

  @override
  String get verifyingFile => 'Verifying file…';

  @override
  String get receiving => 'Receiving';

  @override
  String get ready => 'Ready';

  @override
  String get waitingReceiver => 'Waiting for approval';

  @override
  String get sending => 'Sending';

  @override
  String get waitingVerification => 'Waiting for verification…';

  @override
  String get sentVerified => 'Sent and verified';

  @override
  String get sendCancelled => 'Sending cancelled';

  @override
  String get sendFailedRetry => 'Sending failed. Try again.';

  @override
  String get batchSent => 'All files sent and verified';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Item $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 sent · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 files',
      one: '$arg0 file',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Remove selected files';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Remove $arg0';
  }

  @override
  String get receiveProgress => 'Receiving progress';

  @override
  String get sendProgress => 'Sending progress';

  @override
  String get sendOtherFiles => 'Send other files';

  @override
  String get chooseAgain => 'Choose again';

  @override
  String get continueSending => 'Continue';

  @override
  String get resend => 'Resend';

  @override
  String get sendFiles => 'Send files';

  @override
  String get recentTransfers => 'Recent transfers';

  @override
  String get allDevices => 'All devices';

  @override
  String get otherDevice => 'Another device';

  @override
  String get emptyHistory => 'Completed files and text will appear here.';

  @override
  String get textMessage => 'Text message';

  @override
  String get received => 'Received';

  @override
  String get sent => 'Sent';

  @override
  String durationLabel(String arg0) {
    return 'Duration: $arg0';
  }

  @override
  String get viewText => 'View text';

  @override
  String get openFolderHint => 'Open the local file\'s folder';

  @override
  String get noLocalFile => 'No local file location is available';

  @override
  String get openFolder => 'Open folder';

  @override
  String get about => 'About Dukto2';

  @override
  String get aboutTribute =>
      'A tribute to Dukto and its creator Emanuele Colombo. Thanks to xuzhen and the community for their continued maintenance.';

  @override
  String get aboutAi =>
      'Code, UI, tests and documentation created with OpenAI Codex under human direction.';

  @override
  String get aboutProject =>
      'An independent rewrite carrying forward Dukto\'s simple, direct experience.';

  @override
  String get licenses => 'Third-party licenses';

  @override
  String get notificationsAllowed => 'System notifications allowed';

  @override
  String get notificationsDenied => 'System notifications disabled';

  @override
  String get notificationsUndetermined => 'Not authorized yet';

  @override
  String get notificationsManaged => 'Notifications managed by the system';

  @override
  String get notificationsUnavailable => 'Notification status unavailable';

  @override
  String get notificationsChecking => 'Checking notifications…';

  @override
  String get folderBusy =>
      'The receiving folder cannot change during a transfer.';

  @override
  String get receiveLocation => 'Receiving location';

  @override
  String get changeFolder => 'Change folder';

  @override
  String get restoreDefault => 'Restore default';

  @override
  String get readingDeviceName => 'Reading device name…';

  @override
  String get notifications => 'Notifications';

  @override
  String get completionNotifications => 'Transfer completion notifications';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get systemNotificationSettings => 'System notification settings';

  @override
  String get ongoingNotificationHint =>
      'The ongoing transfer notification stays enabled.';

  @override
  String get appearance => 'Appearance';

  @override
  String get followSystem => 'Follow system';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get chooseFolder => 'Choose receiving folder';

  @override
  String get appStorage => 'App storage';

  @override
  String get backgroundIos =>
      'Keep the app in the foreground. Switching apps or locking the screen may interrupt a transfer.';

  @override
  String get backgroundAndroid =>
      'Approved transfers can continue in the background. Do not force-stop the app.';

  @override
  String get backgroundDesktop =>
      'Keep the app running and avoid sleep during transfers.';

  @override
  String get backgroundStopped => 'Background transfer stopped';

  @override
  String get downloadsUnavailable => 'System Downloads folder unavailable';

  @override
  String get discoveryUnavailable =>
      'Discovery unavailable. Try a manual connection.';

  @override
  String get readyLan => 'Ready · Transfer on the same network';

  @override
  String get startupFailed => 'Could not start. Check network permissions.';

  @override
  String get checkNetworkPermissions =>
      'Check network permissions and reopen the app';

  @override
  String get networkRecoveryFailed =>
      'Could not restore networking. Refresh again.';

  @override
  String get settingsSaveFailed => 'Could not save settings. Try again.';

  @override
  String get notificationRequestFailed =>
      'Could not request permission. Check system settings.';

  @override
  String get notificationSettingsFailed =>
      'Could not open settings. Check Dukto2 notification permissions manually.';

  @override
  String get receiveComplete => 'Receiving complete';

  @override
  String get sendComplete => 'Sending complete';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 received and verified';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 sent and verified';
  }

  @override
  String get folderUnavailable =>
      'Receiving folder unavailable. Select it again.';

  @override
  String get authorizedFolder => 'Authorized folder';

  @override
  String get folderUpdated => 'Receiving location updated';

  @override
  String get folderChangeFailed => 'Could not change the receiving location';

  @override
  String get folderReset => 'Default receiving location restored';

  @override
  String get folderResetFailed => 'Could not restore the receiving location';

  @override
  String receivingName(String arg0) {
    return 'Receiving $arg0';
  }

  @override
  String get textReceived => 'Text received and verified';

  @override
  String receivedName(String arg0) {
    return 'Received $arg0 and verified';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Receiving failed: $arg0';
  }

  @override
  String get receiveCancelled => 'Receiving cancelled';

  @override
  String get waitingFiles => 'Waiting for files';

  @override
  String get newRequest => 'New receiving request';

  @override
  String get receiveDeclined => 'Receiving declined';

  @override
  String receivingBatchName(String arg0) {
    return 'Receiving batch file: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Selected $arg0';
  }

  @override
  String get receivingFiles => 'Receiving files';

  @override
  String get sendingFiles => 'Sending files';

  @override
  String sendingName(String arg0) {
    return 'Sending $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Could not read file size. Download the file to this device first.';

  @override
  String preparingFiles(String arg0) {
    return 'Preparing $arg0';
  }

  @override
  String get filePickerFailed => 'Could not choose files';

  @override
  String get textFileLimit => 'Choose a UTF-8 text file up to 16 MiB';

  @override
  String get textLoadFailed =>
      'Could not load text. Check the file and UTF-8 encoding.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Waiting for $arg0 to accept $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Sending batch file $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Waiting for $arg0 to accept…';
  }

  @override
  String sentName(String arg0) {
    return 'Sent $arg0 and verified';
  }

  @override
  String sendFailed(String arg0) {
    return 'Sending failed: $arg0';
  }

  @override
  String get canResend => 'You can send again';

  @override
  String get fileMissing => 'File moved or deleted';

  @override
  String get folderOpenUnavailable => 'Could not open the file\'s folder';

  @override
  String get folderOpenFailed => 'Could not open the folder';

  @override
  String savedCopy(String arg0) {
    return 'Saved a copy of $arg0';
  }

  @override
  String get finderFailed => 'Could not reveal the file in Finder';

  @override
  String get exportFailed => 'Could not export the file';

  @override
  String get failurePlatform =>
      'Could not start the transfer. Check app permissions.';

  @override
  String get failureCancelled => 'Transfer cancelled';

  @override
  String get failureDeclined => 'The receiver declined or approval timed out';

  @override
  String get failureBusy => 'The receiver is busy. Try again later.';

  @override
  String get failureExpired => 'Transfer expired. Send again.';

  @override
  String get failureTimeout =>
      'Connection or transfer timed out. Check the network.';

  @override
  String get failureNetwork => 'Connection interrupted. Check both devices.';

  @override
  String get failureCertificate =>
      'Device verification failed. Compare codes again.';

  @override
  String get failureData => 'Invalid data or incompatible app version';

  @override
  String get failureIntegrity => 'File size or checksum mismatch';

  @override
  String get failureStorage =>
      'Could not read or write. Check folder access and free space.';

  @override
  String get failureUnexpected => 'Transfer incomplete. Try again.';

  @override
  String get addressRequired => 'Enter an IPv4 address and port';

  @override
  String get addressInvalid =>
      'Enter a valid IPv4 address and port from 1 to 65535';

  @override
  String get language => 'Language';

  @override
  String get languageChoice => 'Language';

  @override
  String get downloadsLocation => 'Downloads / Dukto2';

  @override
  String get iosLocation => 'Files / Dukto2 / Received files';

  @override
  String get transferChannel => 'File transfers';

  @override
  String get transferNotification => 'Dukto2 transfer';

  @override
  String get preparingTransfer => 'Preparing transfer…';

  @override
  String get backgroundExpired =>
      'Background time expired. Return to the app and send again.';

  @override
  String get notificationCancelled => 'Cancelled from notification';

  @override
  String get networkPermission =>
      'Dukto2 discovers and connects to devices on your local network to transfer files and text you choose to send or receive.';

  @override
  String get qrSelf =>
      'This is this device’s QR code. Scan another device instead.';

  @override
  String get qrConnecting => 'Trying the device addresses in the QR code…';

  @override
  String get qrConnectionFailed =>
      'Unable to connect. Check that the other app is open, the devices can communicate, and the QR code is still valid.';

  @override
  String get showQr => 'Show QR code';

  @override
  String get scanQr => 'Scan to connect';

  @override
  String get qrInstructions => 'Open Dukto2 on the other device.';

  @override
  String get connectionQr => 'Connection QR code';

  @override
  String get qrAfterWifi => 'Connect to a network to show the QR code';

  @override
  String get qrSemantic => 'Dukto2 device connection QR code';

  @override
  String get qrVerify =>
      'On the same network, even across different subnets, if the devices can communicate directly, tap “Scan to connect” and scan this QR code to connect.';

  @override
  String get cameraUnavailable =>
      'Camera unavailable. Allow camera access for Dukto2 in system settings, then open the scanner again.';

  @override
  String get backToConnection => 'Back to connection';

  @override
  String get qrAim =>
      'Point the camera at the connection QR code in the other device’s “This device” panel.';

  @override
  String get subnetHint =>
      'QR connection also works across subnets on the same network, provided the devices can communicate directly.';

  @override
  String get qrExpected => 'Scan a Dukto2 connection QR code';

  @override
  String get qrInvalid =>
      'Invalid QR code. Open “This device” again on the other device.';

  @override
  String get qrUnreachable =>
      'Unable to reach or verify this device. Check that Dukto2 is open and the network allows device communication, then scan again.';

  @override
  String get qrNoCamera => 'No camera found. You can choose a QR image.';

  @override
  String get qrCamera => 'Camera';

  @override
  String get qrChooseImage => 'Choose QR image';

  @override
  String get qrOpenCamera => 'Open camera';

  @override
  String get qrImageNotFound => 'No QR code found. Choose a clearer image.';

  @override
  String get qrImageTooLarge =>
      'Image too large. Use an image under 20 MiB and 16 megapixels.';

  @override
  String get qrImageUnreadable =>
      'Cannot read this image. Choose a PNG, JPEG or BMP image.';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get deviceChecking => 'Checking connection…';

  @override
  String get deviceIdentityChanged => 'Device identity changed';

  @override
  String get deviceOnline => 'Online · Identity verified';

  @override
  String get aboutAuthor => 'Author: lvjing2';

  @override
  String get peerCancelledTransfer => 'The other device cancelled the transfer';
}
