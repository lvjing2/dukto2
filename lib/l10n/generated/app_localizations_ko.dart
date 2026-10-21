// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String todayTime(String arg0) {
    return '오늘 $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return '어제 $arg0';
  }

  @override
  String get lessThanSecond => '1초 미만';

  @override
  String secondsDuration(String arg0) {
    return '$arg0초';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0분 $arg1초';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0시간 $arg1분 $arg2초';
  }

  @override
  String get phone => '휴대폰';

  @override
  String get tablet => '태블릿';

  @override
  String get computer => '컴퓨터';

  @override
  String get device => '기기';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0에서 $arg1 전송 요청';
  }

  @override
  String get batchConsent => '한 번 승인하면 모두 수신합니다';

  @override
  String get textConsent => '이 텍스트를 수신할까요?';

  @override
  String get fileConsent => '이 파일을 수신할까요?';

  @override
  String approvalWarning(String arg0) {
    return '발신자 이름은 확인되지 않았습니다. 아는 내용만 수락하세요. $arg0분 후 만료됩니다.';
  }

  @override
  String receiveAt(String arg0) {
    return '저장 위치: $arg0';
  }

  @override
  String get decline => '거절';

  @override
  String get receiveAll => '모두 수신';

  @override
  String get receiveText => '텍스트 수신';

  @override
  String get receiveFile => '파일 수신';

  @override
  String verifyPeer(String arg0) {
    return '$arg0 확인';
  }

  @override
  String get verificationInstructions => '상대 기기의 내 기기 정보를 열어 아래 코드와 비교하세요.';

  @override
  String get verificationWarning =>
      '기기 이름만으로 신원을 확인할 수 없습니다. 상대 화면을 확인한 뒤 승인하세요.';

  @override
  String get cancel => '취소';

  @override
  String get confirmConnection => '일치함, 연결';

  @override
  String get localInfo => '내 기기 정보';

  @override
  String get showLocalCode => '수동 연결 시 이 코드를 확인하세요. 스캔 연결은 기기 신원을 자동으로 확인합니다.';

  @override
  String get generating => '생성 중…';

  @override
  String get deviceName => '기기 이름';

  @override
  String get preparing => '준비 중…';

  @override
  String get connectionAddress => '연결 주소';

  @override
  String get addressWhenConnected => '네트워크에 연결하면 주소가 표시됩니다';

  @override
  String get done => '완료';

  @override
  String get manualConnection => '수동 연결';

  @override
  String get findPeerAddress => '상대 기기의 내 기기 정보에서 주소를 확인하세요.';

  @override
  String get deviceAddress => '기기 주소';

  @override
  String get addressSeparator => '주소와 포트는 콜론 :으로 구분하세요';

  @override
  String get next => '다음';

  @override
  String get connecting => '연결 중…';

  @override
  String get connectionFailed => '연결할 수 없습니다. 주소와 네트워크를 확인하세요.';

  @override
  String sendToPeer(String arg0) {
    return '$arg0(으)로 전송';
  }

  @override
  String get hideKeyboard => '키보드 숨기기';

  @override
  String get settings => '설정';

  @override
  String get thisDevice => '이 기기';

  @override
  String get discoverable => '주변 기기에 표시됨';

  @override
  String get starting => '시작 중…';

  @override
  String nearbyDevices(String arg0) {
    return '주변 기기: $arg0';
  }

  @override
  String get refreshDevices => '기기 새로고침';

  @override
  String get searchingDevices => '검색 중…';

  @override
  String get findingDevices => '주변 기기 검색 중…';

  @override
  String get noDevices => '기기를 찾지 못했습니다';

  @override
  String get verifiedSelected => '확인됨 · 선택됨';

  @override
  String get verifiedOffline => '확인됨 · 오프라인';

  @override
  String get unverified => '미확인';

  @override
  String get receivingContent => '수신 중';

  @override
  String get sendingContent => '콘텐츠 전송';

  @override
  String get directTransfer => '파일과 텍스트는 기기 간에 직접 전송됩니다.';

  @override
  String sendTo(String arg0) {
    return '전송 대상$arg0';
  }

  @override
  String get codeVerified => '기기 신원 확인됨';

  @override
  String get viewVerification => '기기 코드 보기';

  @override
  String get file => '파일';

  @override
  String get text => '텍스트';

  @override
  String get betweenDevices => '콘텐츠는 이 두 기기 사이에서만 전송됩니다.';

  @override
  String get encryptedLan => 'LAN 직접 전송 · 암호화';

  @override
  String get statusPrefix => '완료';

  @override
  String get preparingIdentity => '기기 ID 준비 중…';

  @override
  String get noNearbyDevices => '주변 기기가 없습니다';

  @override
  String get selectDevice => '기기를 선택해 시작하세요';

  @override
  String get sameWifiHint => '두 기기를 같은 네트워크에 연결하고\n상대 기기에서 Dukto2를 여세요.';

  @override
  String get selectVerifyHint => '기기를 선택하고 확인 코드를 비교하세요.';

  @override
  String get enterAddress => '수동 연결';

  @override
  String get textCopied => '텍스트 복사됨';

  @override
  String get copyFailed => '복사할 수 없습니다. 다시 시도하세요.';

  @override
  String get textContent => '텍스트 내용';

  @override
  String filePreviewHint(String arg0) {
    return '미리보기입니다. 전체 크기: $arg0. 전문은 파일에서 확인하세요.';
  }

  @override
  String get textPreviewHint => '미리보기입니다. 텍스트 복사는 전체 내용을 복사합니다.';

  @override
  String get close => '닫기';

  @override
  String get openFullText => '전체 텍스트 열기';

  @override
  String get copyPreview => '미리보기 복사';

  @override
  String get copyText => '텍스트 복사';

  @override
  String get emptyClipboard => '클립보드에 텍스트가 없습니다';

  @override
  String get editorLimit =>
      '편집기는 1 MiB까지 지원합니다. 더 큰 텍스트는 파일에서 불러오세요(최대 16 MiB).';

  @override
  String get clipboardFailed => '클립보드를 읽을 수 없습니다. 다시 시도하세요.';

  @override
  String get textPlaceholder => '텍스트 입력 또는 링크 붙여넣기';

  @override
  String get textFileLoaded => 'UTF-8 텍스트를 불러왔습니다. 전체 파일을 전송합니다.';

  @override
  String get textLimit => '최대 16 MiB · 수신 승인 필요';

  @override
  String get textUnsupported => '상대 기기가 텍스트를 지원하지 않습니다. 앱을 업데이트하세요.';

  @override
  String get waitingText => '수신 대기 중…';

  @override
  String get sendingText => '텍스트 전송 및 검증 중…';

  @override
  String get textSent => '텍스트 전송 및 검증 완료';

  @override
  String get textCancelled => '전송이 취소되었습니다. 텍스트는 유지됩니다.';

  @override
  String get pasteText => '텍스트 붙여넣기';

  @override
  String get moreTextActions => '기타 텍스트 작업';

  @override
  String get loadTextFile => '텍스트 파일 불러오기';

  @override
  String get clearText => '내용 지우기';

  @override
  String get cancelTransfer => '전송 취소';

  @override
  String get sendText => '텍스트 전송';

  @override
  String get send => '전송';

  @override
  String get chooseFileHint => '전송할 파일을 선택하세요';

  @override
  String get approvalBeforeTransfer => '수신자가 승인하면 전송이 시작됩니다';

  @override
  String get picking => '선택 중…';

  @override
  String get chooseFiles => '파일 선택';

  @override
  String get multiSelectHint => '다중 선택 · 순서대로 전송';

  @override
  String get waitingBatch => '일괄 업로드 대기 중…';

  @override
  String get waitingUpload => '발신자 대기 중…';

  @override
  String get verifyingFile => '파일 검증 중…';

  @override
  String get receiving => '수신 중';

  @override
  String get ready => '준비됨';

  @override
  String get waitingReceiver => '승인 대기 중';

  @override
  String get sending => '전송 중';

  @override
  String get waitingVerification => '검증 대기 중…';

  @override
  String get sentVerified => '전송 및 검증 완료';

  @override
  String get sendCancelled => '전송 취소됨';

  @override
  String get sendFailedRetry => '전송하지 못했습니다. 다시 시도하세요.';

  @override
  String get batchSent => '모든 파일 전송 및 검증 완료';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1개 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1개 전송됨 · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '파일 $arg0개',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => '선택한 파일 제거';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return '$arg0 제거';
  }

  @override
  String get receiveProgress => '수신 진행률';

  @override
  String get sendProgress => '전송 진행률';

  @override
  String get sendOtherFiles => '다른 파일 전송';

  @override
  String get chooseAgain => '다시 선택';

  @override
  String get continueSending => '계속';

  @override
  String get resend => '재전송';

  @override
  String get sendFiles => '파일 전송';

  @override
  String get recentTransfers => '최근 전송';

  @override
  String get allDevices => '모든 기기';

  @override
  String get otherDevice => '다른 기기';

  @override
  String get emptyHistory => '완료된 파일과 텍스트가 여기에 표시됩니다.';

  @override
  String get textMessage => '텍스트 메시지';

  @override
  String get received => '수신됨';

  @override
  String get sent => '전송됨';

  @override
  String durationLabel(String arg0) {
    return '소요 시간: $arg0';
  }

  @override
  String get viewText => '텍스트 보기';

  @override
  String get openFolderHint => '로컬 파일 폴더 열기';

  @override
  String get noLocalFile => '로컬 파일 위치가 없습니다';

  @override
  String get openFolder => '폴더 열기';

  @override
  String get about => 'Dukto2 정보';

  @override
  String get aboutTribute =>
      'Dukto와 제작자 Emanuele Colombo에게 경의를 표하며, 지속적으로 유지 관리하는 xuzhen과 커뮤니티에 감사드립니다.';

  @override
  String get aboutAi => '코드, UI, 테스트, 문서는 사람의 지도 아래 OpenAI Codex로 제작되었습니다.';

  @override
  String get aboutProject => 'Dukto의 단순하고 직접적인 경험을 이어가는 독립적인 재구현 프로젝트입니다.';

  @override
  String get licenses => '타사 라이선스';

  @override
  String get notificationsAllowed => '시스템 알림 허용됨';

  @override
  String get notificationsDenied => '시스템 알림 꺼짐';

  @override
  String get notificationsUndetermined => '아직 허용되지 않음';

  @override
  String get notificationsManaged => '시스템에서 알림 관리';

  @override
  String get notificationsUnavailable => '알림 상태 확인 불가';

  @override
  String get notificationsChecking => '알림 확인 중…';

  @override
  String get folderBusy => '전송 중에는 수신 폴더를 변경할 수 없습니다.';

  @override
  String get receiveLocation => '수신 위치';

  @override
  String get changeFolder => '폴더 변경';

  @override
  String get restoreDefault => '기본값 복원';

  @override
  String get readingDeviceName => '기기 이름 읽는 중…';

  @override
  String get notifications => '알림';

  @override
  String get completionNotifications => '전송 완료 알림';

  @override
  String get allowNotifications => '알림 허용';

  @override
  String get systemNotificationSettings => '시스템 알림 설정';

  @override
  String get ongoingNotificationHint => '진행 중인 전송 알림은 유지됩니다.';

  @override
  String get appearance => '화면 모드';

  @override
  String get followSystem => '시스템 설정 따르기';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get chooseFolder => '수신 폴더 선택';

  @override
  String get appStorage => '앱 저장소';

  @override
  String get backgroundIos => '앱을 전면에 유지하세요. 앱 전환이나 화면 잠금으로 전송이 중단될 수 있습니다.';

  @override
  String get backgroundAndroid => '승인된 전송은 백그라운드에서 계속됩니다. 앱을 강제 종료하지 마세요.';

  @override
  String get backgroundDesktop => '전송 중에는 앱을 실행하고 절전 모드를 피하세요.';

  @override
  String get backgroundStopped => '백그라운드 전송 중지됨';

  @override
  String get downloadsUnavailable => '시스템 다운로드 폴더 사용 불가';

  @override
  String get discoveryUnavailable => '자동 검색을 사용할 수 없습니다. 수동 연결을 시도하세요.';

  @override
  String get readyLan => '준비됨 · 같은 네트워크에서 전송';

  @override
  String get startupFailed => '시작할 수 없습니다. 네트워크 권한을 확인하세요.';

  @override
  String get checkNetworkPermissions => '네트워크 권한을 확인한 뒤 앱을 다시 여세요';

  @override
  String get networkRecoveryFailed => '네트워크를 복구할 수 없습니다. 다시 새로고침하세요.';

  @override
  String get settingsSaveFailed => '설정을 저장할 수 없습니다. 다시 시도하세요.';

  @override
  String get notificationRequestFailed => '권한을 요청할 수 없습니다. 시스템 설정을 확인하세요.';

  @override
  String get notificationSettingsFailed =>
      '설정을 열 수 없습니다. Dukto2 알림 권한을 직접 확인하세요.';

  @override
  String get receiveComplete => '수신 완료';

  @override
  String get sendComplete => '전송 완료';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 수신 및 검증 완료';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 전송 및 검증 완료';
  }

  @override
  String get folderUnavailable => '수신 폴더를 사용할 수 없습니다. 다시 선택하세요.';

  @override
  String get authorizedFolder => '허용된 폴더';

  @override
  String get folderUpdated => '수신 위치 변경됨';

  @override
  String get folderChangeFailed => '수신 위치를 변경할 수 없습니다';

  @override
  String get folderReset => '기본 수신 위치 복원됨';

  @override
  String get folderResetFailed => '수신 위치를 복원할 수 없습니다';

  @override
  String receivingName(String arg0) {
    return '$arg0 수신 중';
  }

  @override
  String get textReceived => '텍스트 수신 및 검증 완료';

  @override
  String receivedName(String arg0) {
    return '$arg0 수신 및 검증 완료';
  }

  @override
  String receiveFailed(String arg0) {
    return '수신 실패: $arg0';
  }

  @override
  String get receiveCancelled => '수신 취소됨';

  @override
  String get waitingFiles => '파일 대기 중';

  @override
  String get newRequest => '새 수신 요청';

  @override
  String get receiveDeclined => '수신 거절됨';

  @override
  String receivingBatchName(String arg0) {
    return '일괄 파일 수신 중: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return '$arg0 선택됨';
  }

  @override
  String get receivingFiles => '파일 수신 중';

  @override
  String get sendingFiles => '파일 전송 중';

  @override
  String sendingName(String arg0) {
    return '$arg0 전송 중';
  }

  @override
  String get fileSizeUnavailable => '파일 크기를 읽을 수 없습니다. 먼저 기기에 다운로드하세요.';

  @override
  String preparingFiles(String arg0) {
    return '$arg0 준비 중';
  }

  @override
  String get filePickerFailed => '파일을 선택할 수 없습니다';

  @override
  String get textFileLimit => '최대 16 MiB의 UTF-8 텍스트 파일 선택';

  @override
  String get textLoadFailed => '텍스트를 불러올 수 없습니다. 파일과 UTF-8 인코딩을 확인하세요.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return '$arg0의 $arg1 수락 대기 중…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return '일괄 파일 전송 중 $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return '$arg0의 수락 대기 중…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 전송 및 검증 완료';
  }

  @override
  String sendFailed(String arg0) {
    return '전송 실패: $arg0';
  }

  @override
  String get canResend => '다시 전송할 수 있습니다';

  @override
  String get fileMissing => '파일이 이동되거나 삭제됨';

  @override
  String get folderOpenUnavailable => '파일 폴더를 열 수 없습니다';

  @override
  String get folderOpenFailed => '폴더를 열 수 없습니다';

  @override
  String savedCopy(String arg0) {
    return '$arg0 사본 저장됨';
  }

  @override
  String get finderFailed => 'Finder에서 파일을 표시할 수 없습니다';

  @override
  String get exportFailed => '파일을 내보낼 수 없습니다';

  @override
  String get failurePlatform => '전송을 시작할 수 없습니다. 앱 권한을 확인하세요.';

  @override
  String get failureCancelled => '전송 취소됨';

  @override
  String get failureDeclined => '상대가 거절했거나 승인 시간이 초과되었습니다';

  @override
  String get failureBusy => '상대 기기가 사용 중입니다. 나중에 시도하세요.';

  @override
  String get failureExpired => '전송이 만료되었습니다. 다시 보내세요.';

  @override
  String get failureTimeout => '연결 또는 전송 시간이 초과되었습니다. 네트워크를 확인하세요.';

  @override
  String get failureNetwork => '연결이 중단되었습니다. 두 기기를 확인하세요.';

  @override
  String get failureCertificate => '기기 확인에 실패했습니다. 코드를 다시 비교하세요.';

  @override
  String get failureData => '잘못된 데이터 또는 호환되지 않는 앱 버전';

  @override
  String get failureIntegrity => '파일 크기 또는 체크섬 불일치';

  @override
  String get failureStorage => '읽거나 쓸 수 없습니다. 폴더 권한과 여유 공간을 확인하세요.';

  @override
  String get failureUnexpected => '전송이 완료되지 않았습니다. 다시 시도하세요.';

  @override
  String get addressRequired => 'IPv4 주소와 포트를 입력하세요';

  @override
  String get addressInvalid => '올바른 IPv4 주소와 1~65535 포트를 입력하세요';

  @override
  String get language => '언어';

  @override
  String get languageChoice => '언어';

  @override
  String get downloadsLocation => '다운로드 / Dukto2';

  @override
  String get iosLocation => '파일 / Dukto2 / 받은 파일';

  @override
  String get transferChannel => '파일 전송';

  @override
  String get transferNotification => 'Dukto2 전송';

  @override
  String get preparingTransfer => '전송 준비 중…';

  @override
  String get backgroundExpired => '백그라운드 시간이 만료되었습니다. 앱으로 돌아와 다시 보내세요.';

  @override
  String get notificationCancelled => '알림에서 취소됨';

  @override
  String get networkPermission =>
      'Dukto2는 로컬 네트워크의 기기를 찾고 연결하여 사용자가 선택한 파일과 텍스트를 전송합니다.';

  @override
  String get qrSelf => '현재 기기의 QR 코드입니다. 다른 기기를 스캔하세요.';

  @override
  String get qrConnecting => 'QR 코드의 기기 주소 시도 중…';

  @override
  String get qrConnectionFailed =>
      '연결할 수 없습니다. 상대 앱 실행 여부, 기기 간 통신, QR 코드 유효성을 확인하세요.';

  @override
  String get showQr => 'QR 코드 표시';

  @override
  String get scanQr => '스캔하여 연결';

  @override
  String get qrInstructions => '다른 기기에서 Dukto2를 여세요.';

  @override
  String get connectionQr => '연결 QR 코드';

  @override
  String get qrAfterWifi => '네트워크에 연결하면 QR 코드가 표시됩니다';

  @override
  String get qrSemantic => 'Dukto2 기기 연결 QR 코드';

  @override
  String get qrVerify =>
      '같은 네트워크에서 기기끼리 직접 통신할 수 있다면 서브넷이 달라도 ‘스캔하여 연결’을 누르고 이 QR 코드를 스캔해 연결할 수 있습니다.';

  @override
  String get cameraUnavailable => '카메라를 사용할 수 없습니다. 시스템 설정에서 카메라를 허용하고 다시 여세요.';

  @override
  String get backToConnection => '연결 화면으로 돌아가기';

  @override
  String get qrAim => '상대 기기의 ‘이 기기’에 있는 연결 QR 코드를 비추세요.';

  @override
  String get subnetHint => '기기 간 직접 통신이 가능하면 같은 네트워크의 다른 서브넷에서도 QR 연결이 됩니다.';

  @override
  String get qrExpected => 'Dukto2 연결 QR 코드를 스캔하세요';

  @override
  String get qrInvalid => '잘못된 QR 코드입니다. 상대 기기 정보를 다시 여세요.';

  @override
  String get qrUnreachable => '연결하거나 확인할 수 없습니다. Dukto2와 네트워크를 확인한 뒤 다시 스캔하세요.';

  @override
  String get qrNoCamera => '카메라를 찾을 수 없습니다. QR 이미지를 선택할 수 있습니다.';

  @override
  String get qrCamera => '카메라';

  @override
  String get qrChooseImage => 'QR 이미지 선택';

  @override
  String get qrOpenCamera => '카메라 열기';

  @override
  String get qrImageNotFound => 'QR 코드를 찾지 못했습니다. 더 선명한 이미지를 선택하세요.';

  @override
  String get qrImageTooLarge => '이미지가 너무 큽니다. 20 MiB 및 1,600만 화소 이하로 선택하세요.';

  @override
  String get qrImageUnreadable => '이미지를 읽을 수 없습니다. PNG, JPEG 또는 BMP를 선택하세요.';

  @override
  String get deviceOffline => '오프라인';

  @override
  String get deviceChecking => '연결 확인 중…';

  @override
  String get deviceIdentityChanged => '기기 식별 정보가 변경됨';

  @override
  String get deviceOnline => '온라인 · 식별 정보 확인됨';

  @override
  String get aboutAuthor => '제작자: lvjing2';

  @override
  String get peerCancelledTransfer => '상대 기기에서 전송을 취소했습니다';
}
