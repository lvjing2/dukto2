// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String todayTime(String arg0) {
    return '今天 $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return '昨天 $arg0';
  }

  @override
  String get lessThanSecond => '小于 1 秒';

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
    return '$arg0 小时 $arg1 分 $arg2 秒';
  }

  @override
  String get phone => '手机';

  @override
  String get tablet => '平板';

  @override
  String get computer => '电脑';

  @override
  String get device => '设备';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 想发送 $arg1';
  }

  @override
  String get batchConsent => '确认一次，接收这批文件';

  @override
  String get textConsent => '是否接收这段文本？';

  @override
  String get fileConsent => '是否接收这个文件？';

  @override
  String approvalWarning(String arg0) {
    return '来源名称未经验证，仅接收你认识的内容。请求将在 $arg0 分钟后过期。';
  }

  @override
  String receiveAt(String arg0) {
    return '接收位置：$arg0';
  }

  @override
  String get decline => '拒绝';

  @override
  String get receiveAll => '接收全部';

  @override
  String get receiveText => '接收文本';

  @override
  String get receiveFile => '接收文件';

  @override
  String verifyPeer(String arg0) {
    return '核对 $arg0';
  }

  @override
  String get verificationInstructions => '在对方设备打开「本机信息」，确认核对码与下方完全一致。';

  @override
  String get verificationWarning => '设备名称不能证明身份。请实际查看对方屏幕后再确认。';

  @override
  String get cancel => '取消';

  @override
  String get confirmConnection => '一致，连接';

  @override
  String get localInfo => '本机信息';

  @override
  String get showLocalCode => '手动连接时核对此处的设备码；扫码连接无需再次核对。';

  @override
  String get generating => '正在生成…';

  @override
  String get deviceName => '设备名称';

  @override
  String get preparing => '准备中…';

  @override
  String get connectionAddress => '手动连接地址';

  @override
  String get addressWhenConnected => '连接网络后显示地址';

  @override
  String get done => '完成';

  @override
  String get manualConnection => '手动连接';

  @override
  String get findPeerAddress => '在对方设备的「本机信息」中找到地址。';

  @override
  String get deviceAddress => '设备地址';

  @override
  String get addressSeparator => '地址与端口之间使用英文冒号 :';

  @override
  String get next => '下一步';

  @override
  String get connecting => '正在连接设备…';

  @override
  String get connectionFailed => '连接失败，请检查地址和网络';

  @override
  String sendToPeer(String arg0) {
    return '发送到 $arg0';
  }

  @override
  String get hideKeyboard => '收起键盘';

  @override
  String get settings => '设置';

  @override
  String get thisDevice => '本机';

  @override
  String get discoverable => '可被附近设备发现';

  @override
  String get starting => '正在启动…';

  @override
  String nearbyDevices(String arg0) {
    return '附近设备 $arg0';
  }

  @override
  String get refreshDevices => '刷新设备';

  @override
  String get searchingDevices => '正在搜索…';

  @override
  String get findingDevices => '正在查找附近设备…';

  @override
  String get noDevices => '还没有发现设备';

  @override
  String get verifiedSelected => '已核对 · 已选择';

  @override
  String get verifiedOffline => '已核对 · 未发现';

  @override
  String get unverified => '未核对';

  @override
  String get receivingContent => '接收内容';

  @override
  String get sendingContent => '发送内容';

  @override
  String get directTransfer => '文件与文本仅在两台设备之间通过局域网直接加密传输。';

  @override
  String sendTo(String arg0) {
    return '发送到$arg0';
  }

  @override
  String get codeVerified => '设备身份已验证';

  @override
  String get viewVerification => '查看设备核对码';

  @override
  String get file => '文件';

  @override
  String get text => '文本';

  @override
  String get statusPrefix => '已';

  @override
  String get preparingIdentity => '正在准备本机身份…';

  @override
  String get noNearbyDevices => '还没有发现附近设备';

  @override
  String get selectDevice => '选择一台设备开始';

  @override
  String get sameWifiHint => '让两台设备连接同一网络，\n并在对方设备打开 Dukto2。';

  @override
  String get selectVerifyHint => '点击设备，核对屏幕上的身份码。';

  @override
  String get enterAddress => '手动连接';

  @override
  String get textCopied => '已复制文本';

  @override
  String get copyFailed => '无法复制，请重试';

  @override
  String get textContent => '文本内容';

  @override
  String filePreviewHint(String arg0) {
    return '以下为预览。文本总大小 $arg0，完整内容请打开文件查看。';
  }

  @override
  String get textPreviewHint => '以下为预览，可使用「复制文本」复制完整内容。';

  @override
  String get close => '关闭';

  @override
  String get openFullText => '打开完整文本';

  @override
  String get copyPreview => '复制预览';

  @override
  String get copyText => '复制文本';

  @override
  String get emptyClipboard => '剪贴板中没有文本';

  @override
  String get editorLimit => '编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）';

  @override
  String get clipboardFailed => '无法读取剪贴板，请重试';

  @override
  String get textPlaceholder => '输入文字或粘贴链接';

  @override
  String get textFileLoaded => '已载入 UTF-8 文本文件，完整内容将流式传输。';

  @override
  String get textLimit => '文本上限 16 MiB · 对方确认后接收';

  @override
  String get textUnsupported => '对方版本暂不支持文本，请先更新对方应用。';

  @override
  String get waitingText => '等待对方接收文本…';

  @override
  String get sendingText => '正在发送并校验文本…';

  @override
  String get textSent => '文本已发送，对方校验通过';

  @override
  String get textCancelled => '已取消发送，文本已保留';

  @override
  String get pasteText => '粘贴文本';

  @override
  String get moreTextActions => '更多文本操作';

  @override
  String get loadTextFile => '载入文本文件';

  @override
  String get clearText => '清空内容';

  @override
  String get cancelTransfer => '取消传输';

  @override
  String get sendText => '发送文本';

  @override
  String get send => '发送';

  @override
  String get chooseFileHint => '选择文件，发送给对方';

  @override
  String get approvalBeforeTransfer => '对方确认接收后开始传输';

  @override
  String get picking => '正在选择…';

  @override
  String get chooseFiles => '选择文件';

  @override
  String get multiSelectHint => '支持多选 · 按顺序发送';

  @override
  String get waitingBatch => '等待本批文件上传…';

  @override
  String get waitingUpload => '等待发送方上传…';

  @override
  String get verifyingFile => '正在校验文件…';

  @override
  String get receiving => '正在接收';

  @override
  String get ready => '准备就绪';

  @override
  String get waitingReceiver => '等待对方接收';

  @override
  String get sending => '正在发送';

  @override
  String get waitingVerification => '等待对方校验…';

  @override
  String get sentVerified => '已发送，校验通过';

  @override
  String get sendCancelled => '已取消发送';

  @override
  String get sendFailedRetry => '发送失败，可重新发送';

  @override
  String get batchSent => '全部已发送，校验通过';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return '第 $arg0 / $arg1 项 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 项已发送 · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 个文件',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => '移除已选文件';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return '移除 $arg0';
  }

  @override
  String get receiveProgress => '接收进度';

  @override
  String get sendProgress => '发送进度';

  @override
  String get sendOtherFiles => '发送其他文件';

  @override
  String get chooseAgain => '重新选择';

  @override
  String get continueSending => '继续发送';

  @override
  String get resend => '重新发送';

  @override
  String get sendFiles => '发送文件';

  @override
  String get recentTransfers => '最近传输';

  @override
  String get allDevices => '全部设备';

  @override
  String get otherDevice => '另一台设备';

  @override
  String get emptyHistory => '完成的文件与文本会显示在这里。';

  @override
  String get textMessage => '文本消息';

  @override
  String get received => '已接收';

  @override
  String get sent => '已发送';

  @override
  String durationLabel(String arg0) {
    return '耗时 $arg0';
  }

  @override
  String get viewText => '查看文本';

  @override
  String get openFolderHint => '打开本机文件所在目录';

  @override
  String get noLocalFile => '此记录没有可用的本机文件位置';

  @override
  String get openFolder => '打开目录';

  @override
  String get about => '关于 Dukto2';

  @override
  String get aboutTribute =>
      '致敬 Dukto 与原作者 Emanuele Colombo，感谢 xuzhen 及社区贡献者的持续维护。';

  @override
  String get aboutAi => '由 OpenAI Codex 在人工指导下创作代码、UI、测试与文档。';

  @override
  String get aboutProject => '一个希望延续 Dukto 简单、直接体验的独立重写项目。';

  @override
  String get licenses => '第三方许可';

  @override
  String get notificationsAllowed => '系统通知已允许';

  @override
  String get notificationsDenied => '系统通知已关闭';

  @override
  String get notificationsUndetermined => '尚未授权';

  @override
  String get notificationsManaged => '通知由系统管理';

  @override
  String get notificationsUnavailable => '暂时无法读取系统通知状态';

  @override
  String get notificationsChecking => '正在检查系统通知…';

  @override
  String get folderBusy => '传输中，暂不可更改接收目录。';

  @override
  String get receiveLocation => '接收位置';

  @override
  String get changeFolder => '更改目录';

  @override
  String get restoreDefault => '恢复默认';

  @override
  String get readingDeviceName => '正在读取设备名称…';

  @override
  String get notifications => '通知';

  @override
  String get completionNotifications => '传输完成通知';

  @override
  String get allowNotifications => '允许通知';

  @override
  String get systemNotificationSettings => '系统通知设置';

  @override
  String get ongoingNotificationHint => '传输中的状态通知仍会保留。';

  @override
  String get appearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get chooseFolder => '选择接收文件夹';

  @override
  String get appStorage => '应用内';

  @override
  String get backgroundIos => '传输时请保持应用在前台，切换应用或锁屏可能中断。';

  @override
  String get backgroundAndroid => '确认收发后可在后台继续传输，请勿强行停止应用。';

  @override
  String get backgroundDesktop => '传输时请保持应用运行，避免设备休眠。';

  @override
  String get backgroundStopped => '后台传输已停止';

  @override
  String get downloadsUnavailable => '无法找到系统下载目录';

  @override
  String get discoveryUnavailable => '自动发现暂不可用，可使用手动连接';

  @override
  String get readyLan => '已就绪 · 同一网络下可互传';

  @override
  String get startupFailed => '启动失败，请检查网络权限';

  @override
  String get checkNetworkPermissions => '检查系统网络权限后重新打开应用';

  @override
  String get networkRecoveryFailed => '网络恢复失败，请再次刷新';

  @override
  String get settingsSaveFailed => '设置未能保存，请重试';

  @override
  String get notificationRequestFailed => '无法请求通知权限，请在系统设置中检查';

  @override
  String get notificationSettingsFailed => '无法打开系统设置，请手动检查 Dukto2 通知权限';

  @override
  String get receiveComplete => '接收完成';

  @override
  String get sendComplete => '发送完成';

  @override
  String receivedVerified(String arg0) {
    return '$arg0已接收并通过校验';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0已发送并通过校验';
  }

  @override
  String get folderUnavailable => '接收文件夹不可用，请重新选择';

  @override
  String get authorizedFolder => '已授权文件夹';

  @override
  String get folderUpdated => '接收位置已更新';

  @override
  String get folderChangeFailed => '无法设置接收位置';

  @override
  String get folderReset => '已恢复默认接收位置';

  @override
  String get folderResetFailed => '无法恢复接收位置';

  @override
  String receivingName(String arg0) {
    return '正在接收 $arg0';
  }

  @override
  String get textReceived => '已接收文本，校验通过';

  @override
  String receivedName(String arg0) {
    return '已接收 $arg0，校验通过';
  }

  @override
  String receiveFailed(String arg0) {
    return '接收失败：$arg0';
  }

  @override
  String get receiveCancelled => '已取消接收';

  @override
  String get waitingFiles => '等待文件';

  @override
  String get newRequest => '有新的接收请求';

  @override
  String get receiveDeclined => '已拒绝接收';

  @override
  String receivingBatchName(String arg0) {
    return '正在接收本批文件：$arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return '已选择 $arg0';
  }

  @override
  String get receivingFiles => '正在接收文件';

  @override
  String get sendingFiles => '正在发送文件';

  @override
  String sendingName(String arg0) {
    return '正在发送 $arg0';
  }

  @override
  String get fileSizeUnavailable => '无法读取文件大小，请先将文件下载到本机';

  @override
  String preparingFiles(String arg0) {
    return '准备发送 $arg0';
  }

  @override
  String get filePickerFailed => '选择文件失败';

  @override
  String get textFileLimit => '请选择 16 MiB 以内的 UTF-8 文本文件';

  @override
  String get textLoadFailed => '载入文本失败，请检查文件和 UTF-8 编码';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return '等待 $arg0 确认接收 $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return '正在发送本批文件 $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return '等待 $arg0 确认接收…';
  }

  @override
  String sentName(String arg0) {
    return '已发送 $arg0，对方校验通过';
  }

  @override
  String sendFailed(String arg0) {
    return '发送失败：$arg0';
  }

  @override
  String get canResend => '可重新发送';

  @override
  String get fileMissing => '文件已移动或删除';

  @override
  String get folderOpenUnavailable => '无法打开文件目录';

  @override
  String get folderOpenFailed => '打开目录失败';

  @override
  String savedCopy(String arg0) {
    return '已另存 $arg0';
  }

  @override
  String get finderFailed => '无法在 Finder 显示文件';

  @override
  String get exportFailed => '导出失败';

  @override
  String get failurePlatform => '系统未能启动传输，请检查应用权限后重试';

  @override
  String get failureCancelled => '传输已取消';

  @override
  String get failureDeclined => '对方未同意接收，或确认已超时';

  @override
  String get failureBusy => '对方正在处理其他传输，请稍后重试';

  @override
  String get failureExpired => '本次传输已过期，请重新发送';

  @override
  String get failureTimeout => '连接或传输超时，请检查网络后重试';

  @override
  String get failureNetwork => '网络连接中断，请检查设备连接';

  @override
  String get failureCertificate => '设备身份核验失败，请重新核对设备';

  @override
  String get failureData => '传输数据无效或版本不兼容';

  @override
  String get failureIntegrity => '文件大小或校验不一致，请重新发送';

  @override
  String get failureStorage => '无法读写文件，请检查目录权限和可用空间';

  @override
  String get failureUnexpected => '传输未完成，请稍后重试';

  @override
  String get addressRequired => '请输入 IPv4 地址和端口';

  @override
  String get addressInvalid => '请输入有效的 IPv4 地址和 1–65535 端口';

  @override
  String get language => '语言';

  @override
  String get languageChoice => '语言 / Language';

  @override
  String get downloadsLocation => '下载 / Dukto2';

  @override
  String get iosLocation => '文件 / Dukto2 / 接收文件';

  @override
  String get transferChannel => '文件传输';

  @override
  String get transferNotification => 'Dukto2 正在传输';

  @override
  String get preparingTransfer => '正在准备传输…';

  @override
  String get backgroundExpired => '后台运行时间已用尽，请返回应用重新发送';

  @override
  String get notificationCancelled => '已从通知取消传输';

  @override
  String get networkPermission => 'Dukto2 需要发现并连接同一局域网的设备，直接传输你确认发送或接收的文件与文本。';

  @override
  String get qrSelf => '这是本机的二维码，请扫描另一台设备。';

  @override
  String get qrConnecting => '正在尝试二维码中的设备地址…';

  @override
  String get qrConnectionFailed => '连接失败：请确认对方应用已打开、设备可以互通，且二维码仍有效。';

  @override
  String get showQr => '显示二维码';

  @override
  String get scanQr => '扫码连接';

  @override
  String get qrInstructions => '在对方设备打开 Dukto2。';

  @override
  String get connectionQr => '连接二维码';

  @override
  String get qrAfterWifi => '连接网络后显示二维码';

  @override
  String get qrSemantic => 'Dukto2 设备连接二维码';

  @override
  String get qrVerify => '同一网络下，即使处于不同子网，只要设备能够互通，点击「扫码连接」扫描此二维码即可连接。';

  @override
  String get cameraUnavailable => '无法使用相机。请在系统设置中允许 Dukto2 使用相机，然后重新进入扫码。';

  @override
  String get backToConnection => '返回连接页面';

  @override
  String get qrAim => '对准另一台设备「本机信息」中的连接二维码。';

  @override
  String get subnetHint => '同一网络下，即使处于不同子网，也可以扫码连接；设备之间需要能够直接通信。';

  @override
  String get qrExpected => '请扫描 Dukto2 的连接二维码';

  @override
  String get qrInvalid => '连接二维码无效，请在对方设备重新打开本机信息';

  @override
  String get qrUnreachable => '无法连接二维码中的设备，或设备身份不一致。请确认对方应用已打开、网络允许设备互通，再重新扫码。';

  @override
  String get qrNoCamera => '未找到摄像头，可从图片识别。';

  @override
  String get qrCamera => '摄像头';

  @override
  String get qrChooseImage => '从图片识别';

  @override
  String get qrOpenCamera => '打开摄像头';

  @override
  String get qrImageNotFound => '未识别到二维码，请选择更清晰的图片。';

  @override
  String get qrImageTooLarge => '图片过大，请选择小于 20 MiB、1600 万像素的图片。';

  @override
  String get qrImageUnreadable => '无法读取图片，请选择 PNG、JPEG 或 BMP 图片。';

  @override
  String get deviceOffline => '离线';

  @override
  String get deviceChecking => '正在检查连接…';

  @override
  String get deviceIdentityChanged => '设备身份已变化';

  @override
  String get deviceOnline => '在线 · 已核对';

  @override
  String get aboutAuthor => '作者：lvjing2';

  @override
  String get peerCancelledTransfer => '对方已取消传输';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String todayTime(String arg0) {
    return '今天 $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return '昨天 $arg0';
  }

  @override
  String get lessThanSecond => '小于 1 秒';

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
    return '$arg0 小时 $arg1 分 $arg2 秒';
  }

  @override
  String get phone => '手机';

  @override
  String get tablet => '平板';

  @override
  String get computer => '电脑';

  @override
  String get device => '设备';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 想发送 $arg1';
  }

  @override
  String get batchConsent => '确认一次，接收这批文件';

  @override
  String get textConsent => '是否接收这段文本？';

  @override
  String get fileConsent => '是否接收这个文件？';

  @override
  String approvalWarning(String arg0) {
    return '来源名称未经验证，仅接收你认识的内容。请求将在 $arg0 分钟后过期。';
  }

  @override
  String receiveAt(String arg0) {
    return '接收位置：$arg0';
  }

  @override
  String get decline => '拒绝';

  @override
  String get receiveAll => '接收全部';

  @override
  String get receiveText => '接收文本';

  @override
  String get receiveFile => '接收文件';

  @override
  String verifyPeer(String arg0) {
    return '核对 $arg0';
  }

  @override
  String get verificationInstructions => '在对方设备打开「本机信息」，确认核对码与下方完全一致。';

  @override
  String get verificationWarning => '设备名称不能证明身份。请实际查看对方屏幕后再确认。';

  @override
  String get cancel => '取消';

  @override
  String get confirmConnection => '一致，连接';

  @override
  String get localInfo => '本机信息';

  @override
  String get showLocalCode => '手动连接时核对此处的设备码；扫码连接无需再次核对。';

  @override
  String get generating => '正在生成…';

  @override
  String get deviceName => '设备名称';

  @override
  String get preparing => '准备中…';

  @override
  String get connectionAddress => '手动连接地址';

  @override
  String get addressWhenConnected => '连接网络后显示地址';

  @override
  String get done => '完成';

  @override
  String get manualConnection => '手动连接';

  @override
  String get findPeerAddress => '在对方设备的「本机信息」中找到地址。';

  @override
  String get deviceAddress => '设备地址';

  @override
  String get addressSeparator => '地址与端口之间使用英文冒号 :';

  @override
  String get next => '下一步';

  @override
  String get connecting => '正在连接设备…';

  @override
  String get connectionFailed => '连接失败，请检查地址和网络';

  @override
  String sendToPeer(String arg0) {
    return '发送到 $arg0';
  }

  @override
  String get hideKeyboard => '收起键盘';

  @override
  String get settings => '设置';

  @override
  String get thisDevice => '本机';

  @override
  String get discoverable => '可被附近设备发现';

  @override
  String get starting => '正在启动…';

  @override
  String nearbyDevices(String arg0) {
    return '附近设备 $arg0';
  }

  @override
  String get refreshDevices => '刷新设备';

  @override
  String get searchingDevices => '正在搜索…';

  @override
  String get findingDevices => '正在查找附近设备…';

  @override
  String get noDevices => '还没有发现设备';

  @override
  String get verifiedSelected => '已核对 · 已选择';

  @override
  String get verifiedOffline => '已核对 · 未发现';

  @override
  String get unverified => '未核对';

  @override
  String get receivingContent => '接收内容';

  @override
  String get sendingContent => '发送内容';

  @override
  String get directTransfer => '文件与文本仅在两台设备之间通过局域网直接加密传输。';

  @override
  String sendTo(String arg0) {
    return '发送到$arg0';
  }

  @override
  String get codeVerified => '设备身份已验证';

  @override
  String get viewVerification => '查看设备核对码';

  @override
  String get file => '文件';

  @override
  String get text => '文本';

  @override
  String get statusPrefix => '已';

  @override
  String get preparingIdentity => '正在准备本机身份…';

  @override
  String get noNearbyDevices => '还没有发现附近设备';

  @override
  String get selectDevice => '选择一台设备开始';

  @override
  String get sameWifiHint => '让两台设备连接同一网络，\n并在对方设备打开 Dukto2。';

  @override
  String get selectVerifyHint => '点击设备，核对屏幕上的身份码。';

  @override
  String get enterAddress => '手动连接';

  @override
  String get textCopied => '已复制文本';

  @override
  String get copyFailed => '无法复制，请重试';

  @override
  String get textContent => '文本内容';

  @override
  String filePreviewHint(String arg0) {
    return '以下为预览。文本总大小 $arg0，完整内容请打开文件查看。';
  }

  @override
  String get textPreviewHint => '以下为预览，可使用「复制文本」复制完整内容。';

  @override
  String get close => '关闭';

  @override
  String get openFullText => '打开完整文本';

  @override
  String get copyPreview => '复制预览';

  @override
  String get copyText => '复制文本';

  @override
  String get emptyClipboard => '剪贴板中没有文本';

  @override
  String get editorLimit => '编辑区最多 1 MiB，大文本请从文件载入（上限 16 MiB）';

  @override
  String get clipboardFailed => '无法读取剪贴板，请重试';

  @override
  String get textPlaceholder => '输入文字或粘贴链接';

  @override
  String get textFileLoaded => '已载入 UTF-8 文本文件，完整内容将流式传输。';

  @override
  String get textLimit => '文本上限 16 MiB · 对方确认后接收';

  @override
  String get textUnsupported => '对方版本暂不支持文本，请先更新对方应用。';

  @override
  String get waitingText => '等待对方接收文本…';

  @override
  String get sendingText => '正在发送并校验文本…';

  @override
  String get textSent => '文本已发送，对方校验通过';

  @override
  String get textCancelled => '已取消发送，文本已保留';

  @override
  String get pasteText => '粘贴文本';

  @override
  String get moreTextActions => '更多文本操作';

  @override
  String get loadTextFile => '载入文本文件';

  @override
  String get clearText => '清空内容';

  @override
  String get cancelTransfer => '取消传输';

  @override
  String get sendText => '发送文本';

  @override
  String get send => '发送';

  @override
  String get chooseFileHint => '选择文件，发送给对方';

  @override
  String get approvalBeforeTransfer => '对方确认接收后开始传输';

  @override
  String get picking => '正在选择…';

  @override
  String get chooseFiles => '选择文件';

  @override
  String get multiSelectHint => '支持多选 · 按顺序发送';

  @override
  String get waitingBatch => '等待本批文件上传…';

  @override
  String get waitingUpload => '等待发送方上传…';

  @override
  String get verifyingFile => '正在校验文件…';

  @override
  String get receiving => '正在接收';

  @override
  String get ready => '准备就绪';

  @override
  String get waitingReceiver => '等待对方接收';

  @override
  String get sending => '正在发送';

  @override
  String get waitingVerification => '等待对方校验…';

  @override
  String get sentVerified => '已发送，校验通过';

  @override
  String get sendCancelled => '已取消发送';

  @override
  String get sendFailedRetry => '发送失败，可重新发送';

  @override
  String get batchSent => '全部已发送，校验通过';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return '第 $arg0 / $arg1 项 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 项已发送 · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 个文件',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => '移除已选文件';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return '移除 $arg0';
  }

  @override
  String get receiveProgress => '接收进度';

  @override
  String get sendProgress => '发送进度';

  @override
  String get sendOtherFiles => '发送其他文件';

  @override
  String get chooseAgain => '重新选择';

  @override
  String get continueSending => '继续发送';

  @override
  String get resend => '重新发送';

  @override
  String get sendFiles => '发送文件';

  @override
  String get recentTransfers => '最近传输';

  @override
  String get allDevices => '全部设备';

  @override
  String get otherDevice => '另一台设备';

  @override
  String get emptyHistory => '完成的文件与文本会显示在这里。';

  @override
  String get textMessage => '文本消息';

  @override
  String get received => '已接收';

  @override
  String get sent => '已发送';

  @override
  String durationLabel(String arg0) {
    return '耗时 $arg0';
  }

  @override
  String get viewText => '查看文本';

  @override
  String get openFolderHint => '打开本机文件所在目录';

  @override
  String get noLocalFile => '此记录没有可用的本机文件位置';

  @override
  String get openFolder => '打开目录';

  @override
  String get about => '关于 Dukto2';

  @override
  String get aboutTribute =>
      '致敬 Dukto 与原作者 Emanuele Colombo，感谢 xuzhen 及社区贡献者的持续维护。';

  @override
  String get aboutAi => '由 OpenAI Codex 在人工指导下创作代码、UI、测试与文档。';

  @override
  String get aboutProject => '一个希望延续 Dukto 简单、直接体验的独立重写项目。';

  @override
  String get licenses => '第三方许可';

  @override
  String get notificationsAllowed => '系统通知已允许';

  @override
  String get notificationsDenied => '系统通知已关闭';

  @override
  String get notificationsUndetermined => '尚未授权';

  @override
  String get notificationsManaged => '通知由系统管理';

  @override
  String get notificationsUnavailable => '暂时无法读取系统通知状态';

  @override
  String get notificationsChecking => '正在检查系统通知…';

  @override
  String get folderBusy => '传输中，暂不可更改接收目录。';

  @override
  String get receiveLocation => '接收位置';

  @override
  String get changeFolder => '更改目录';

  @override
  String get restoreDefault => '恢复默认';

  @override
  String get readingDeviceName => '正在读取设备名称…';

  @override
  String get notifications => '通知';

  @override
  String get completionNotifications => '传输完成通知';

  @override
  String get allowNotifications => '允许通知';

  @override
  String get systemNotificationSettings => '系统通知设置';

  @override
  String get ongoingNotificationHint => '传输中的状态通知仍会保留。';

  @override
  String get appearance => '外观';

  @override
  String get followSystem => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get chooseFolder => '选择接收文件夹';

  @override
  String get appStorage => '应用内';

  @override
  String get backgroundIos => '传输时请保持应用在前台，切换应用或锁屏可能中断。';

  @override
  String get backgroundAndroid => '确认收发后可在后台继续传输，请勿强行停止应用。';

  @override
  String get backgroundDesktop => '传输时请保持应用运行，避免设备休眠。';

  @override
  String get backgroundStopped => '后台传输已停止';

  @override
  String get downloadsUnavailable => '无法找到系统下载目录';

  @override
  String get discoveryUnavailable => '自动发现暂不可用，可使用手动连接';

  @override
  String get readyLan => '已就绪 · 同一网络下可互传';

  @override
  String get startupFailed => '启动失败，请检查网络权限';

  @override
  String get checkNetworkPermissions => '检查系统网络权限后重新打开应用';

  @override
  String get networkRecoveryFailed => '网络恢复失败，请再次刷新';

  @override
  String get settingsSaveFailed => '设置未能保存，请重试';

  @override
  String get notificationRequestFailed => '无法请求通知权限，请在系统设置中检查';

  @override
  String get notificationSettingsFailed => '无法打开系统设置，请手动检查 Dukto2 通知权限';

  @override
  String get receiveComplete => '接收完成';

  @override
  String get sendComplete => '发送完成';

  @override
  String receivedVerified(String arg0) {
    return '$arg0已接收并通过校验';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0已发送并通过校验';
  }

  @override
  String get folderUnavailable => '接收文件夹不可用，请重新选择';

  @override
  String get authorizedFolder => '已授权文件夹';

  @override
  String get folderUpdated => '接收位置已更新';

  @override
  String get folderChangeFailed => '无法设置接收位置';

  @override
  String get folderReset => '已恢复默认接收位置';

  @override
  String get folderResetFailed => '无法恢复接收位置';

  @override
  String receivingName(String arg0) {
    return '正在接收 $arg0';
  }

  @override
  String get textReceived => '已接收文本，校验通过';

  @override
  String receivedName(String arg0) {
    return '已接收 $arg0，校验通过';
  }

  @override
  String receiveFailed(String arg0) {
    return '接收失败：$arg0';
  }

  @override
  String get receiveCancelled => '已取消接收';

  @override
  String get waitingFiles => '等待文件';

  @override
  String get newRequest => '有新的接收请求';

  @override
  String get receiveDeclined => '已拒绝接收';

  @override
  String receivingBatchName(String arg0) {
    return '正在接收本批文件：$arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return '已选择 $arg0';
  }

  @override
  String get receivingFiles => '正在接收文件';

  @override
  String get sendingFiles => '正在发送文件';

  @override
  String sendingName(String arg0) {
    return '正在发送 $arg0';
  }

  @override
  String get fileSizeUnavailable => '无法读取文件大小，请先将文件下载到本机';

  @override
  String preparingFiles(String arg0) {
    return '准备发送 $arg0';
  }

  @override
  String get filePickerFailed => '选择文件失败';

  @override
  String get textFileLimit => '请选择 16 MiB 以内的 UTF-8 文本文件';

  @override
  String get textLoadFailed => '载入文本失败，请检查文件和 UTF-8 编码';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return '等待 $arg0 确认接收 $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return '正在发送本批文件 $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return '等待 $arg0 确认接收…';
  }

  @override
  String sentName(String arg0) {
    return '已发送 $arg0，对方校验通过';
  }

  @override
  String sendFailed(String arg0) {
    return '发送失败：$arg0';
  }

  @override
  String get canResend => '可重新发送';

  @override
  String get fileMissing => '文件已移动或删除';

  @override
  String get folderOpenUnavailable => '无法打开文件目录';

  @override
  String get folderOpenFailed => '打开目录失败';

  @override
  String savedCopy(String arg0) {
    return '已另存 $arg0';
  }

  @override
  String get finderFailed => '无法在 Finder 显示文件';

  @override
  String get exportFailed => '导出失败';

  @override
  String get failurePlatform => '系统未能启动传输，请检查应用权限后重试';

  @override
  String get failureCancelled => '传输已取消';

  @override
  String get failureDeclined => '对方未同意接收，或确认已超时';

  @override
  String get failureBusy => '对方正在处理其他传输，请稍后重试';

  @override
  String get failureExpired => '本次传输已过期，请重新发送';

  @override
  String get failureTimeout => '连接或传输超时，请检查网络后重试';

  @override
  String get failureNetwork => '网络连接中断，请检查设备连接';

  @override
  String get failureCertificate => '设备身份核验失败，请重新核对设备';

  @override
  String get failureData => '传输数据无效或版本不兼容';

  @override
  String get failureIntegrity => '文件大小或校验不一致，请重新发送';

  @override
  String get failureStorage => '无法读写文件，请检查目录权限和可用空间';

  @override
  String get failureUnexpected => '传输未完成，请稍后重试';

  @override
  String get addressRequired => '请输入 IPv4 地址和端口';

  @override
  String get addressInvalid => '请输入有效的 IPv4 地址和 1–65535 端口';

  @override
  String get language => '语言';

  @override
  String get languageChoice => '语言 / Language';

  @override
  String get downloadsLocation => '下载 / Dukto2';

  @override
  String get iosLocation => '文件 / Dukto2 / 接收文件';

  @override
  String get transferChannel => '文件传输';

  @override
  String get transferNotification => 'Dukto2 正在传输';

  @override
  String get preparingTransfer => '正在准备传输…';

  @override
  String get backgroundExpired => '后台运行时间已用尽，请返回应用重新发送';

  @override
  String get notificationCancelled => '已从通知取消传输';

  @override
  String get networkPermission => 'Dukto2 需要发现并连接同一局域网的设备，直接传输你确认发送或接收的文件与文本。';

  @override
  String get qrSelf => '这是本机的二维码，请扫描另一台设备。';

  @override
  String get qrConnecting => '正在尝试二维码中的设备地址…';

  @override
  String get qrConnectionFailed => '连接失败：请确认对方应用已打开、设备可以互通，且二维码仍有效。';

  @override
  String get showQr => '显示二维码';

  @override
  String get scanQr => '扫码连接';

  @override
  String get qrInstructions => '在对方设备打开 Dukto2。';

  @override
  String get connectionQr => '连接二维码';

  @override
  String get qrAfterWifi => '连接网络后显示二维码';

  @override
  String get qrSemantic => 'Dukto2 设备连接二维码';

  @override
  String get qrVerify => '同一网络下，即使处于不同子网，只要设备能够互通，点击「扫码连接」扫描此二维码即可连接。';

  @override
  String get cameraUnavailable => '无法使用相机。请在系统设置中允许 Dukto2 使用相机，然后重新进入扫码。';

  @override
  String get backToConnection => '返回连接页面';

  @override
  String get qrAim => '对准另一台设备「本机信息」中的连接二维码。';

  @override
  String get subnetHint => '同一网络下，即使处于不同子网，也可以扫码连接；设备之间需要能够直接通信。';

  @override
  String get qrExpected => '请扫描 Dukto2 的连接二维码';

  @override
  String get qrInvalid => '连接二维码无效，请在对方设备重新打开本机信息';

  @override
  String get qrUnreachable => '无法连接二维码中的设备，或设备身份不一致。请确认对方应用已打开、网络允许设备互通，再重新扫码。';

  @override
  String get qrNoCamera => '未找到摄像头，可从图片识别。';

  @override
  String get qrCamera => '摄像头';

  @override
  String get qrChooseImage => '从图片识别';

  @override
  String get qrOpenCamera => '打开摄像头';

  @override
  String get qrImageNotFound => '未识别到二维码，请选择更清晰的图片。';

  @override
  String get qrImageTooLarge => '图片过大，请选择小于 20 MiB、1600 万像素的图片。';

  @override
  String get qrImageUnreadable => '无法读取图片，请选择 PNG、JPEG 或 BMP 图片。';

  @override
  String get deviceOffline => '离线';

  @override
  String get deviceChecking => '正在检查连接…';

  @override
  String get deviceIdentityChanged => '设备身份已变化';

  @override
  String get deviceOnline => '在线 · 已核对';

  @override
  String get aboutAuthor => '作者：lvjing2';

  @override
  String get peerCancelledTransfer => '对方已取消传输';
}
