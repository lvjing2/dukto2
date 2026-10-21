// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String todayTime(String arg0) {
    return '今日 $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return '昨日 $arg0';
  }

  @override
  String get lessThanSecond => '1 秒未満';

  @override
  String secondsDuration(String arg0) {
    return '$arg0 秒';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0 分 $arg1 秒';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0 時間 $arg1 分 $arg2 秒';
  }

  @override
  String get phone => 'スマートフォン';

  @override
  String get tablet => 'タブレット';

  @override
  String get computer => 'パソコン';

  @override
  String get device => 'デバイス';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 から $arg1 の送信リクエスト';
  }

  @override
  String get batchConsent => '一度の承認でまとめて受信します';

  @override
  String get textConsent => 'このテキストを受信しますか？';

  @override
  String get fileConsent => 'このファイルを受信しますか？';

  @override
  String approvalWarning(String arg0) {
    return '送信者名は未確認です。心当たりのある内容のみ承認してください。$arg0 分で期限が切れます。';
  }

  @override
  String receiveAt(String arg0) {
    return '保存先: $arg0';
  }

  @override
  String get decline => '拒否';

  @override
  String get receiveAll => 'すべて受信';

  @override
  String get receiveText => 'テキストを受信';

  @override
  String get receiveFile => 'ファイルを受信';

  @override
  String verifyPeer(String arg0) {
    return '$arg0 を確認';
  }

  @override
  String get verificationInstructions => '相手の「本機情報」を開き、下のコードと照合してください。';

  @override
  String get verificationWarning => '名前だけでは本人確認できません。相手の画面を確認してから承認してください。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirmConnection => '一致したので接続';

  @override
  String get localInfo => '本機情報';

  @override
  String get showLocalCode => '手動接続時にこのコードを照合してください。スキャン接続では端末の識別情報を自動確認します。';

  @override
  String get generating => '生成中…';

  @override
  String get deviceName => 'デバイス名';

  @override
  String get preparing => '準備中…';

  @override
  String get connectionAddress => '接続アドレス';

  @override
  String get addressWhenConnected => 'ネットワーク に接続するとアドレスが表示されます';

  @override
  String get done => '完了';

  @override
  String get manualConnection => '手動接続';

  @override
  String get findPeerAddress => '相手の「本機情報」でアドレスを確認してください。';

  @override
  String get deviceAddress => 'デバイスのアドレス';

  @override
  String get addressSeparator => 'アドレスとポートは半角コロン : で区切ります';

  @override
  String get next => '次へ';

  @override
  String get connecting => '接続中…';

  @override
  String get connectionFailed => '接続できません。アドレスとネットワークを確認してください。';

  @override
  String sendToPeer(String arg0) {
    return '$arg0 に送信';
  }

  @override
  String get hideKeyboard => 'キーボードを閉じる';

  @override
  String get settings => '設定';

  @override
  String get thisDevice => 'このデバイス';

  @override
  String get discoverable => '近くのデバイスに表示中';

  @override
  String get starting => '起動中…';

  @override
  String nearbyDevices(String arg0) {
    return '近くのデバイス: $arg0';
  }

  @override
  String get refreshDevices => 'デバイスを更新';

  @override
  String get searchingDevices => '検索中…';

  @override
  String get findingDevices => '近くのデバイスを検索中…';

  @override
  String get noDevices => 'デバイスが見つかりません';

  @override
  String get verifiedSelected => '確認済み · 選択中';

  @override
  String get verifiedOffline => '確認済み · オフライン';

  @override
  String get unverified => '未確認';

  @override
  String get receivingContent => '受信中';

  @override
  String get sendingContent => 'コンテンツを送信';

  @override
  String get directTransfer => 'ファイルとテキストをデバイス間で直接転送します。';

  @override
  String sendTo(String arg0) {
    return '送信先$arg0';
  }

  @override
  String get codeVerified => '端末の識別情報を確認済み';

  @override
  String get viewVerification => 'デバイスのコードを表示';

  @override
  String get file => 'ファイル';

  @override
  String get text => 'テキスト';

  @override
  String get betweenDevices => 'この 2 台の間でのみ転送されます。';

  @override
  String get encryptedLan => 'LAN 直接転送 · 暗号化';

  @override
  String get statusPrefix => '完了';

  @override
  String get preparingIdentity => 'デバイス ID を準備中…';

  @override
  String get noNearbyDevices => '近くのデバイスが見つかりません';

  @override
  String get selectDevice => 'デバイスを選択して開始';

  @override
  String get sameWifiHint => '両方を同じ ネットワーク に接続し、\n相手のデバイスで Dukto2 を開いてください。';

  @override
  String get selectVerifyHint => 'デバイスを選び、確認コードを照合してください。';

  @override
  String get enterAddress => '手動接続';

  @override
  String get textCopied => 'コピーしました';

  @override
  String get copyFailed => 'コピーできません。再試行してください。';

  @override
  String get textContent => 'テキスト内容';

  @override
  String filePreviewHint(String arg0) {
    return 'プレビューのみ。合計 $arg0。全文はファイルを開いてください。';
  }

  @override
  String get textPreviewHint => 'プレビューのみ。「テキストをコピー」で全文をコピーできます。';

  @override
  String get close => '閉じる';

  @override
  String get openFullText => '全文を開く';

  @override
  String get copyPreview => 'プレビューをコピー';

  @override
  String get copyText => 'テキストをコピー';

  @override
  String get emptyClipboard => 'クリップボードにテキストがありません';

  @override
  String get editorLimit => '入力欄は 1 MiB まで。大きなテキストはファイルから読み込んでください（最大 16 MiB）。';

  @override
  String get clipboardFailed => 'クリップボードを読み取れません。再試行してください。';

  @override
  String get textPlaceholder => 'テキストを入力、またはリンクを貼り付け';

  @override
  String get textFileLoaded => 'UTF-8 テキストを読み込みました。ファイル全体を送信します。';

  @override
  String get textLimit => '最大 16 MiB · 受信者の承認が必要';

  @override
  String get textUnsupported => '相手はテキストに未対応です。相手のアプリを更新してください。';

  @override
  String get waitingText => '受信者を待っています…';

  @override
  String get sendingText => 'テキストを送信・検証中…';

  @override
  String get textSent => 'テキストの送信・検証が完了';

  @override
  String get textCancelled => '送信をキャンセルしました。入力内容は保持されます。';

  @override
  String get pasteText => 'テキストを貼り付け';

  @override
  String get moreTextActions => 'その他のテキスト操作';

  @override
  String get loadTextFile => 'テキストファイルを読み込む';

  @override
  String get clearText => '内容を消去';

  @override
  String get cancelTransfer => '転送をキャンセル';

  @override
  String get sendText => 'テキストを送信';

  @override
  String get send => '送信';

  @override
  String get chooseFileHint => '送信するファイルを選択';

  @override
  String get approvalBeforeTransfer => '受信者の承認後に転送を開始します';

  @override
  String get picking => '選択中…';

  @override
  String get chooseFiles => 'ファイルを選択';

  @override
  String get multiSelectHint => '複数選択 · 順番に送信';

  @override
  String get waitingBatch => '一括アップロードを待っています…';

  @override
  String get waitingUpload => '送信者を待っています…';

  @override
  String get verifyingFile => 'ファイルを検証中…';

  @override
  String get receiving => '受信中';

  @override
  String get ready => '準備完了';

  @override
  String get waitingReceiver => '承認待ち';

  @override
  String get sending => '送信中';

  @override
  String get waitingVerification => '検証待ち…';

  @override
  String get sentVerified => '送信・検証済み';

  @override
  String get sendCancelled => '送信をキャンセルしました';

  @override
  String get sendFailedRetry => '送信できませんでした。再試行してください。';

  @override
  String get batchSent => 'すべて送信・検証済み';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 件 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 件送信済み · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 個のファイル',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => '選択したファイルを解除';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return '$arg0 を解除';
  }

  @override
  String get receiveProgress => '受信の進捗';

  @override
  String get sendProgress => '送信の進捗';

  @override
  String get sendOtherFiles => '別のファイルを送信';

  @override
  String get chooseAgain => '選び直す';

  @override
  String get continueSending => '続ける';

  @override
  String get resend => '再送信';

  @override
  String get sendFiles => 'ファイルを送信';

  @override
  String get recentTransfers => '最近の転送';

  @override
  String get allDevices => 'すべてのデバイス';

  @override
  String get otherDevice => '別のデバイス';

  @override
  String get emptyHistory => '転送したファイルやテキストがここに表示されます。';

  @override
  String get textMessage => 'テキストメッセージ';

  @override
  String get received => '受信済み';

  @override
  String get sent => '送信済み';

  @override
  String durationLabel(String arg0) {
    return '所要時間: $arg0';
  }

  @override
  String get viewText => 'テキストを見る';

  @override
  String get openFolderHint => 'ローカルファイルのフォルダを開く';

  @override
  String get noLocalFile => 'ローカルの保存先がありません';

  @override
  String get openFolder => 'フォルダを開く';

  @override
  String get about => 'Dukto2 について';

  @override
  String get aboutTribute =>
      'Dukto と作者 Emanuele Colombo 氏に敬意を表します。保守を続ける xuzhen 氏とコミュニティに感謝します。';

  @override
  String get aboutAi => 'コード、UI、テスト、文書は、人の指示のもと OpenAI Codex で作成されています。';

  @override
  String get aboutProject => 'Dukto のシンプルで直接的な体験を受け継ぐ、独立した再実装です。';

  @override
  String get licenses => 'サードパーティのライセンス';

  @override
  String get notificationsAllowed => '通知は許可されています';

  @override
  String get notificationsDenied => '通知は無効です';

  @override
  String get notificationsUndetermined => '未許可';

  @override
  String get notificationsManaged => '通知はシステムで管理されます';

  @override
  String get notificationsUnavailable => '通知状態を取得できません';

  @override
  String get notificationsChecking => '通知を確認中…';

  @override
  String get folderBusy => '転送中は受信フォルダを変更できません。';

  @override
  String get receiveLocation => '受信先';

  @override
  String get changeFolder => 'フォルダを変更';

  @override
  String get restoreDefault => '既定に戻す';

  @override
  String get readingDeviceName => 'デバイス名を取得中…';

  @override
  String get notifications => '通知';

  @override
  String get completionNotifications => '転送完了の通知';

  @override
  String get allowNotifications => '通知を許可';

  @override
  String get systemNotificationSettings => 'システムの通知設定';

  @override
  String get ongoingNotificationHint => '転送中の通知は引き続き表示されます。';

  @override
  String get appearance => '外観';

  @override
  String get followSystem => 'システムに従う';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get chooseFolder => '受信フォルダを選択';

  @override
  String get appStorage => 'アプリ内';

  @override
  String get backgroundIos => '転送中はアプリを前面に保ってください。アプリの切り替えや画面ロックで中断する場合があります。';

  @override
  String get backgroundAndroid => '承認後はバックグラウンドで転送を続けられます。強制終了しないでください。';

  @override
  String get backgroundDesktop => '転送中はアプリを終了せず、デバイスをスリープさせないでください。';

  @override
  String get backgroundStopped => 'バックグラウンド転送が停止しました';

  @override
  String get downloadsUnavailable => 'ダウンロードフォルダを取得できません';

  @override
  String get discoveryUnavailable => '自動検出を利用できません。手動接続をお試しください。';

  @override
  String get readyLan => '準備完了 · 同じ ネットワーク で転送可能';

  @override
  String get startupFailed => '起動できません。ネットワーク権限を確認してください。';

  @override
  String get checkNetworkPermissions => 'ネットワーク権限を確認して再起動してください';

  @override
  String get networkRecoveryFailed => 'ネットワークを復旧できません。再度更新してください。';

  @override
  String get settingsSaveFailed => '設定を保存できません。再試行してください。';

  @override
  String get notificationRequestFailed => '権限を要求できません。システム設定を確認してください。';

  @override
  String get notificationSettingsFailed => '設定を開けません。Dukto2 の通知権限を手動で確認してください。';

  @override
  String get receiveComplete => '受信完了';

  @override
  String get sendComplete => '送信完了';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 を受信・検証しました';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 を送信・検証しました';
  }

  @override
  String get folderUnavailable => '受信フォルダを利用できません。選択し直してください。';

  @override
  String get authorizedFolder => '許可済みフォルダ';

  @override
  String get folderUpdated => '受信先を更新しました';

  @override
  String get folderChangeFailed => '受信先を変更できません';

  @override
  String get folderReset => '既定の受信先に戻しました';

  @override
  String get folderResetFailed => '受信先を復元できません';

  @override
  String receivingName(String arg0) {
    return '$arg0 を受信中';
  }

  @override
  String get textReceived => 'テキストの受信・検証が完了';

  @override
  String receivedName(String arg0) {
    return '$arg0 を受信・検証しました';
  }

  @override
  String receiveFailed(String arg0) {
    return '受信失敗: $arg0';
  }

  @override
  String get receiveCancelled => '受信をキャンセルしました';

  @override
  String get waitingFiles => 'ファイル待ち';

  @override
  String get newRequest => '新しい受信リクエスト';

  @override
  String get receiveDeclined => '受信を拒否しました';

  @override
  String receivingBatchName(String arg0) {
    return '一括ファイル受信中: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return '$arg0 を選択しました';
  }

  @override
  String get receivingFiles => 'ファイル受信中';

  @override
  String get sendingFiles => 'ファイル送信中';

  @override
  String sendingName(String arg0) {
    return '$arg0 を送信中';
  }

  @override
  String get fileSizeUnavailable => 'サイズを取得できません。先にファイルをこのデバイスに保存してください。';

  @override
  String preparingFiles(String arg0) {
    return '$arg0を準備中';
  }

  @override
  String get filePickerFailed => 'ファイルを選択できません';

  @override
  String get textFileLimit => '最大 16 MiB の UTF-8 テキストファイルを選択';

  @override
  String get textLoadFailed => '読み込めません。ファイルと UTF-8 エンコードを確認してください。';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return '$arg0 による $arg1 の承認待ち…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return '一括送信中 $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return '$arg0 の承認待ち…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 を送信・検証しました';
  }

  @override
  String sendFailed(String arg0) {
    return '送信失敗: $arg0';
  }

  @override
  String get canResend => '再送信できます';

  @override
  String get fileMissing => 'ファイルは移動または削除されました';

  @override
  String get folderOpenUnavailable => 'ファイルのフォルダを開けません';

  @override
  String get folderOpenFailed => 'フォルダを開けません';

  @override
  String savedCopy(String arg0) {
    return '$arg0 のコピーを保存しました';
  }

  @override
  String get finderFailed => 'Finder でファイルを表示できません';

  @override
  String get exportFailed => 'ファイルを書き出せません';

  @override
  String get failurePlatform => '転送を開始できません。アプリの権限を確認してください。';

  @override
  String get failureCancelled => '転送をキャンセルしました';

  @override
  String get failureDeclined => '受信が拒否されたか、承認がタイムアウトしました';

  @override
  String get failureBusy => '相手は別の転送中です。後でお試しください。';

  @override
  String get failureExpired => '転送の期限が切れました。再送信してください。';

  @override
  String get failureTimeout => '接続または転送がタイムアウトしました。ネットワークを確認してください。';

  @override
  String get failureNetwork => '接続が中断されました。両方のデバイスを確認してください。';

  @override
  String get failureCertificate => 'デバイスの確認に失敗しました。コードを照合し直してください。';

  @override
  String get failureData => 'データが無効か、バージョンが非対応です';

  @override
  String get failureIntegrity => 'ファイルサイズまたはチェックサムが一致しません';

  @override
  String get failureStorage => '読み書きできません。フォルダ権限と空き容量を確認してください。';

  @override
  String get failureUnexpected => '転送が完了しませんでした。再試行してください。';

  @override
  String get addressRequired => 'IPv4 アドレスとポートを入力';

  @override
  String get addressInvalid => '有効な IPv4 アドレスと 1～65535 のポートを入力';

  @override
  String get language => '言語';

  @override
  String get languageChoice => '言語';

  @override
  String get downloadsLocation => 'ダウンロード / Dukto2';

  @override
  String get iosLocation => 'ファイル / Dukto2 / 受信ファイル';

  @override
  String get transferChannel => 'ファイル転送';

  @override
  String get transferNotification => 'Dukto2 転送中';

  @override
  String get preparingTransfer => '転送を準備中…';

  @override
  String get backgroundExpired => 'バックグラウンド実行時間が終了しました。アプリに戻って再送信してください。';

  @override
  String get notificationCancelled => '通知からキャンセルしました';

  @override
  String get networkPermission =>
      'Dukto2 はローカルネットワーク上のデバイスを検出・接続し、承認したファイルやテキストを転送します。';

  @override
  String get qrSelf => 'このデバイス自身の QR コードです。別のデバイスをスキャンしてください。';

  @override
  String get qrConnecting => 'QR コードのアドレスに接続中…';

  @override
  String get qrConnectionFailed => '接続できません。相手のアプリ、通信経路、QR コードの有効性を確認してください。';

  @override
  String get showQr => 'QR コードを表示';

  @override
  String get scanQr => 'スキャンして接続';

  @override
  String get qrInstructions => '相手の端末で Dukto2 を開いてください。';

  @override
  String get connectionQr => '接続用 QR コード';

  @override
  String get qrAfterWifi => 'ネットワーク に接続すると QR コードを表示します';

  @override
  String get qrSemantic => 'Dukto2 デバイス接続用 QR コード';

  @override
  String get qrVerify =>
      '同じネットワークで端末同士が直接通信できれば、サブネットが異なっていても「スキャンして接続」をタップしてこのQRコードをスキャンすると接続できます。';

  @override
  String get cameraUnavailable => 'カメラを利用できません。システム設定でカメラを許可してスキャナーを開き直してください。';

  @override
  String get backToConnection => '接続画面に戻る';

  @override
  String get qrAim => '相手の「このデバイス」にある接続 QR コードに向けてください。';

  @override
  String get subnetHint => '同じ ネットワーク で直接通信できれば、別のサブネット間でも QR 接続できます。';

  @override
  String get qrExpected => 'Dukto2 の接続 QR コードをスキャン';

  @override
  String get qrInvalid => '無効な QR コードです。相手の本機情報を開き直してください。';

  @override
  String get qrUnreachable => '接続または確認できません。相手の Dukto2 と通信環境を確認して再スキャンしてください。';

  @override
  String get qrNoCamera => 'カメラが見つかりません。QR画像を選択できます。';

  @override
  String get qrCamera => 'カメラ';

  @override
  String get qrChooseImage => 'QR画像を選択';

  @override
  String get qrOpenCamera => 'カメラを開く';

  @override
  String get qrImageNotFound => 'QRコードが見つかりません。より鮮明な画像を選んでください。';

  @override
  String get qrImageTooLarge => '画像が大きすぎます。20 MiB、1600万画素以下にしてください。';

  @override
  String get qrImageUnreadable => '画像を読み込めません。PNG、JPEG、BMPを選んでください。';

  @override
  String get deviceOffline => 'オフライン';

  @override
  String get deviceChecking => '接続を確認中…';

  @override
  String get deviceIdentityChanged => 'デバイスの識別情報が変更されました';

  @override
  String get deviceOnline => 'オンライン · 識別情報確認済み';

  @override
  String get aboutAuthor => '作者：lvjing2';

  @override
  String get peerCancelledTransfer => '相手のデバイスが転送をキャンセルしました';
}
