// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'اليوم $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'أمس $arg0';
  }

  @override
  String get lessThanSecond => 'أقل من ثانية';

  @override
  String secondsDuration(String arg0) {
    return '$arg0 ث';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0 د $arg1 ث';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0 س $arg1 د $arg2 ث';
  }

  @override
  String get phone => 'هاتف';

  @override
  String get tablet => 'جهاز لوحي';

  @override
  String get computer => 'حاسوب';

  @override
  String get device => 'جهاز';

  @override
  String incomingOffer(String arg0, String arg1) {
    return 'يريد $arg0 إرسال $arg1';
  }

  @override
  String get batchConsent => 'وافق مرة واحدة لاستلام هذه الدفعة';

  @override
  String get textConsent => 'هل تريد استلام هذا النص؟';

  @override
  String get fileConsent => 'هل تريد استلام هذا الملف؟';

  @override
  String approvalWarning(String arg0) {
    return 'اسم المرسل غير موثّق. اقبل المحتوى الذي تعرفه فقط. ينتهي الطلب خلال $arg0 دقائق.';
  }

  @override
  String receiveAt(String arg0) {
    return 'حفظ في: $arg0';
  }

  @override
  String get decline => 'رفض';

  @override
  String get receiveAll => 'استلام الكل';

  @override
  String get receiveText => 'استلام النص';

  @override
  String get receiveFile => 'استلام الملف';

  @override
  String verifyPeer(String arg0) {
    return 'التحقق من $arg0';
  }

  @override
  String get verificationInstructions =>
      'افتح معلومات الجهاز الآخر وقارن رمزه بالرمز أدناه.';

  @override
  String get verificationWarning =>
      'اسم الجهاز لا يثبت هويته. تحقق من الشاشة الأخرى قبل التأكيد.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirmConnection => 'الرمزان متطابقان، اتصال';

  @override
  String get localInfo => 'معلومات الجهاز';

  @override
  String get showLocalCode =>
      'قارن هذا الرمز عند الاتصال يدويًا. يتحقق المسح من هوية الجهاز تلقائيًا.';

  @override
  String get generating => 'جارٍ الإنشاء…';

  @override
  String get deviceName => 'اسم الجهاز';

  @override
  String get preparing => 'جارٍ التحضير…';

  @override
  String get connectionAddress => 'عنوان الاتصال';

  @override
  String get addressWhenConnected => 'اتصل بشبكة لعرض العناوين';

  @override
  String get done => 'تم';

  @override
  String get manualConnection => 'اتصال يدوي';

  @override
  String get findPeerAddress => 'ابحث عن العنوان في معلومات الجهاز الآخر.';

  @override
  String get deviceAddress => 'عنوان الجهاز';

  @override
  String get addressSeparator => 'افصل العنوان والمنفذ بنقطتين :';

  @override
  String get next => 'التالي';

  @override
  String get connecting => 'جارٍ الاتصال…';

  @override
  String get connectionFailed => 'تعذر الاتصال. تحقق من العنوان والشبكة.';

  @override
  String sendToPeer(String arg0) {
    return 'إرسال إلى $arg0';
  }

  @override
  String get hideKeyboard => 'إخفاء لوحة المفاتيح';

  @override
  String get settings => 'الإعدادات';

  @override
  String get thisDevice => 'هذا الجهاز';

  @override
  String get discoverable => 'مرئي للأجهزة القريبة';

  @override
  String get starting => 'جارٍ البدء…';

  @override
  String nearbyDevices(String arg0) {
    return 'الأجهزة القريبة: $arg0';
  }

  @override
  String get refreshDevices => 'تحديث الأجهزة';

  @override
  String get searchingDevices => 'جارٍ البحث…';

  @override
  String get findingDevices => 'جارٍ البحث عن الأجهزة القريبة…';

  @override
  String get noDevices => 'لم يُعثر على أجهزة';

  @override
  String get verifiedSelected => 'موثّق · محدد';

  @override
  String get verifiedOffline => 'موثّق · غير متصل';

  @override
  String get unverified => 'غير موثّق';

  @override
  String get receivingContent => 'جارٍ الاستلام';

  @override
  String get sendingContent => 'إرسال محتوى';

  @override
  String get directTransfer => 'تُنقل الملفات والنصوص مباشرة بين الأجهزة.';

  @override
  String sendTo(String arg0) {
    return 'إرسال إلى$arg0';
  }

  @override
  String get codeVerified => 'تم التحقق من هوية الجهاز';

  @override
  String get viewVerification => 'عرض رمز الجهاز';

  @override
  String get file => 'ملف';

  @override
  String get text => 'نص';

  @override
  String get betweenDevices => 'يُنقل المحتوى بين هذين الجهازين فقط.';

  @override
  String get encryptedLan => 'شبكة محلية مباشرة · مشفّر';

  @override
  String get statusPrefix => 'مكتمل';

  @override
  String get preparingIdentity => 'جارٍ تحضير هوية الجهاز…';

  @override
  String get noNearbyDevices => 'لا توجد أجهزة قريبة';

  @override
  String get selectDevice => 'اختر جهازًا للبدء';

  @override
  String get sameWifiHint =>
      'صل الجهازين بنفس شبكة\nوافتح Dukto2 على الجهاز الآخر.';

  @override
  String get selectVerifyHint => 'اختر جهازًا وقارن رمز التحقق الخاص به.';

  @override
  String get enterAddress => 'اتصال يدوي';

  @override
  String get textCopied => 'تم نسخ النص';

  @override
  String get copyFailed => 'تعذر النسخ. أعد المحاولة.';

  @override
  String get textContent => 'محتوى النص';

  @override
  String filePreviewHint(String arg0) {
    return 'معاينة فقط. الحجم الكلي: $arg0. افتح الملف لعرض النص كاملًا.';
  }

  @override
  String get textPreviewHint => 'معاينة فقط. نسخ النص ينسخ المحتوى كاملًا.';

  @override
  String get close => 'إغلاق';

  @override
  String get openFullText => 'فتح النص الكامل';

  @override
  String get copyPreview => 'نسخ المعاينة';

  @override
  String get copyText => 'نسخ النص';

  @override
  String get emptyClipboard => 'لا يوجد نص في الحافظة';

  @override
  String get editorLimit =>
      'يدعم المحرر 1 MiB. حمّل النصوص الأكبر من ملف (حتى 16 MiB).';

  @override
  String get clipboardFailed => 'تعذرت قراءة الحافظة. أعد المحاولة.';

  @override
  String get textPlaceholder => 'أدخل نصًا أو الصق رابطًا';

  @override
  String get textFileLoaded => 'تم تحميل نص UTF-8. سيُنقل الملف كاملًا.';

  @override
  String get textLimit => 'حتى 16 MiB · تتطلب موافقة المستلم';

  @override
  String get textUnsupported => 'هذا الجهاز لا يدعم النصوص. حدّث تطبيقه أولًا.';

  @override
  String get waitingText => 'بانتظار المستلم…';

  @override
  String get sendingText => 'جارٍ إرسال النص والتحقق منه…';

  @override
  String get textSent => 'تم إرسال النص والتحقق منه';

  @override
  String get textCancelled => 'أُلغي الإرسال. تم الاحتفاظ بالنص.';

  @override
  String get pasteText => 'لصق النص';

  @override
  String get moreTextActions => 'المزيد من إجراءات النص';

  @override
  String get loadTextFile => 'تحميل ملف نصي';

  @override
  String get clearText => 'مسح المحتوى';

  @override
  String get cancelTransfer => 'إلغاء النقل';

  @override
  String get sendText => 'إرسال النص';

  @override
  String get send => 'إرسال';

  @override
  String get chooseFileHint => 'اختر ملفات لإرسالها';

  @override
  String get approvalBeforeTransfer => 'يبدأ النقل بعد موافقة المستلم';

  @override
  String get picking => 'جارٍ الاختيار…';

  @override
  String get chooseFiles => 'اختيار الملفات';

  @override
  String get multiSelectHint => 'اختيار متعدد · إرسال بالترتيب';

  @override
  String get waitingBatch => 'بانتظار رفع الدفعة…';

  @override
  String get waitingUpload => 'بانتظار المرسل…';

  @override
  String get verifyingFile => 'جارٍ التحقق من الملف…';

  @override
  String get receiving => 'جارٍ الاستلام';

  @override
  String get ready => 'جاهز';

  @override
  String get waitingReceiver => 'بانتظار الموافقة';

  @override
  String get sending => 'جارٍ الإرسال';

  @override
  String get waitingVerification => 'بانتظار التحقق…';

  @override
  String get sentVerified => 'أُرسل وتم التحقق';

  @override
  String get sendCancelled => 'أُلغي الإرسال';

  @override
  String get sendFailedRetry => 'فشل الإرسال. أعد المحاولة.';

  @override
  String get batchSent => 'تم إرسال جميع الملفات والتحقق منها';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'ملف $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return 'أُرسل $arg0 / $arg1 · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 ملف',
      many: '$arg0 ملفًا',
      few: '$arg0 ملفات',
      two: 'ملفان',
      one: 'ملف واحد',
      zero: 'لا ملفات',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'إزالة الملفات المحددة';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'إزالة $arg0';
  }

  @override
  String get receiveProgress => 'تقدم الاستلام';

  @override
  String get sendProgress => 'تقدم الإرسال';

  @override
  String get sendOtherFiles => 'إرسال ملفات أخرى';

  @override
  String get chooseAgain => 'اختيار مجددًا';

  @override
  String get continueSending => 'متابعة';

  @override
  String get resend => 'إعادة الإرسال';

  @override
  String get sendFiles => 'إرسال الملفات';

  @override
  String get recentTransfers => 'عمليات النقل الأخيرة';

  @override
  String get allDevices => 'جميع الأجهزة';

  @override
  String get otherDevice => 'جهاز آخر';

  @override
  String get emptyHistory => 'ستظهر الملفات والنصوص المكتملة هنا.';

  @override
  String get textMessage => 'رسالة نصية';

  @override
  String get received => 'مُستلم';

  @override
  String get sent => 'مُرسل';

  @override
  String durationLabel(String arg0) {
    return 'المدة: $arg0';
  }

  @override
  String get viewText => 'عرض النص';

  @override
  String get openFolderHint => 'فتح مجلد الملف المحلي';

  @override
  String get noLocalFile => 'موقع الملف المحلي غير متاح';

  @override
  String get openFolder => 'فتح المجلد';

  @override
  String get about => 'حول Dukto2';

  @override
  String get aboutTribute =>
      'تقديرًا لـ Dukto ومبدعه Emanuele Colombo. شكرًا لـ xuzhen والمجتمع على الصيانة المستمرة.';

  @override
  String get aboutAi =>
      'أُنشئت الشفرة والواجهة والاختبارات والتوثيق باستخدام OpenAI Codex بتوجيه بشري.';

  @override
  String get aboutProject =>
      'إعادة كتابة مستقلة تواصل تجربة Dukto البسيطة والمباشرة.';

  @override
  String get licenses => 'تراخيص الجهات الخارجية';

  @override
  String get notificationsAllowed => 'إشعارات النظام مسموحة';

  @override
  String get notificationsDenied => 'إشعارات النظام معطلة';

  @override
  String get notificationsUndetermined => 'لم يُمنح الإذن بعد';

  @override
  String get notificationsManaged => 'النظام يدير الإشعارات';

  @override
  String get notificationsUnavailable => 'حالة الإشعارات غير متاحة';

  @override
  String get notificationsChecking => 'جارٍ فحص الإشعارات…';

  @override
  String get folderBusy => 'لا يمكن تغيير مجلد الاستلام أثناء النقل.';

  @override
  String get receiveLocation => 'موقع الاستلام';

  @override
  String get changeFolder => 'تغيير المجلد';

  @override
  String get restoreDefault => 'استعادة الافتراضي';

  @override
  String get readingDeviceName => 'جارٍ قراءة اسم الجهاز…';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get completionNotifications => 'إشعارات اكتمال النقل';

  @override
  String get allowNotifications => 'السماح بالإشعارات';

  @override
  String get systemNotificationSettings => 'إعدادات إشعارات النظام';

  @override
  String get ongoingNotificationHint => 'يبقى إشعار النقل الجاري مفعّلًا.';

  @override
  String get appearance => 'المظهر';

  @override
  String get followSystem => 'اتباع النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get chooseFolder => 'اختيار مجلد الاستلام';

  @override
  String get appStorage => 'تخزين التطبيق';

  @override
  String get backgroundIos =>
      'أبقِ التطبيق في المقدمة. قد يؤدي تبديل التطبيق أو قفل الشاشة إلى قطع النقل.';

  @override
  String get backgroundAndroid =>
      'يمكن أن تستمر عمليات النقل الموافق عليها في الخلفية. لا توقف التطبيق قسرًا.';

  @override
  String get backgroundDesktop =>
      'أبقِ التطبيق قيد التشغيل وتجنب السكون أثناء النقل.';

  @override
  String get backgroundStopped => 'توقف النقل في الخلفية';

  @override
  String get downloadsUnavailable => 'مجلد التنزيلات غير متاح';

  @override
  String get discoveryUnavailable => 'الاكتشاف غير متاح. جرّب الاتصال اليدوي.';

  @override
  String get readyLan => 'جاهز · النقل على نفس الشبكة';

  @override
  String get startupFailed => 'تعذر البدء. تحقق من أذونات الشبكة.';

  @override
  String get checkNetworkPermissions =>
      'تحقق من أذونات الشبكة وأعد فتح التطبيق';

  @override
  String get networkRecoveryFailed => 'تعذرت استعادة الشبكة. حدّث مجددًا.';

  @override
  String get settingsSaveFailed => 'تعذر حفظ الإعدادات. أعد المحاولة.';

  @override
  String get notificationRequestFailed =>
      'تعذر طلب الإذن. تحقق من إعدادات النظام.';

  @override
  String get notificationSettingsFailed =>
      'تعذر فتح الإعدادات. تحقق يدويًا من أذونات إشعارات Dukto2.';

  @override
  String get receiveComplete => 'اكتمل الاستلام';

  @override
  String get sendComplete => 'اكتمل الإرسال';

  @override
  String receivedVerified(String arg0) {
    return 'تم استلام $arg0 والتحقق منه';
  }

  @override
  String sentContentVerified(String arg0) {
    return 'تم إرسال $arg0 والتحقق منه';
  }

  @override
  String get folderUnavailable => 'مجلد الاستلام غير متاح. اختره مجددًا.';

  @override
  String get authorizedFolder => 'مجلد مصرح به';

  @override
  String get folderUpdated => 'تم تحديث موقع الاستلام';

  @override
  String get folderChangeFailed => 'تعذر تغيير موقع الاستلام';

  @override
  String get folderReset => 'تمت استعادة موقع الاستلام الافتراضي';

  @override
  String get folderResetFailed => 'تعذرت استعادة موقع الاستلام';

  @override
  String receivingName(String arg0) {
    return 'جارٍ استلام $arg0';
  }

  @override
  String get textReceived => 'تم استلام النص والتحقق منه';

  @override
  String receivedName(String arg0) {
    return 'تم استلام $arg0 والتحقق منه';
  }

  @override
  String receiveFailed(String arg0) {
    return 'فشل الاستلام: $arg0';
  }

  @override
  String get receiveCancelled => 'أُلغي الاستلام';

  @override
  String get waitingFiles => 'بانتظار الملفات';

  @override
  String get newRequest => 'طلب استلام جديد';

  @override
  String get receiveDeclined => 'رُفض الاستلام';

  @override
  String receivingBatchName(String arg0) {
    return 'جارٍ استلام ملف الدفعة: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'تم تحديد $arg0';
  }

  @override
  String get receivingFiles => 'جارٍ استلام الملفات';

  @override
  String get sendingFiles => 'جارٍ إرسال الملفات';

  @override
  String sendingName(String arg0) {
    return 'جارٍ إرسال $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'تعذرت قراءة حجم الملف. نزّله على هذا الجهاز أولًا.';

  @override
  String preparingFiles(String arg0) {
    return 'جارٍ تحضير $arg0';
  }

  @override
  String get filePickerFailed => 'تعذر اختيار الملفات';

  @override
  String get textFileLimit => 'اختر ملف UTF-8 نصيًا حتى 16 MiB';

  @override
  String get textLoadFailed => 'تعذر تحميل النص. تحقق من الملف وترميز UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'بانتظار موافقة $arg0 على $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'جارٍ إرسال ملف الدفعة $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'بانتظار موافقة $arg0…';
  }

  @override
  String sentName(String arg0) {
    return 'تم إرسال $arg0 والتحقق منه';
  }

  @override
  String sendFailed(String arg0) {
    return 'فشل الإرسال: $arg0';
  }

  @override
  String get canResend => 'يمكنك الإرسال مجددًا';

  @override
  String get fileMissing => 'نُقل الملف أو حُذف';

  @override
  String get folderOpenUnavailable => 'تعذر فتح مجلد الملف';

  @override
  String get folderOpenFailed => 'تعذر فتح المجلد';

  @override
  String savedCopy(String arg0) {
    return 'تم حفظ نسخة من $arg0';
  }

  @override
  String get finderFailed => 'تعذر إظهار الملف في Finder';

  @override
  String get exportFailed => 'تعذر تصدير الملف';

  @override
  String get failurePlatform => 'تعذر بدء النقل. تحقق من أذونات التطبيق.';

  @override
  String get failureCancelled => 'أُلغي النقل';

  @override
  String get failureDeclined => 'رفض المستلم أو انتهت مهلة الموافقة';

  @override
  String get failureBusy => 'المستلم مشغول. أعد المحاولة لاحقًا.';

  @override
  String get failureExpired => 'انتهت صلاحية النقل. أرسل مجددًا.';

  @override
  String get failureTimeout => 'انتهت مهلة الاتصال أو النقل. تحقق من الشبكة.';

  @override
  String get failureNetwork => 'انقطع الاتصال. تحقق من الجهازين.';

  @override
  String get failureCertificate => 'فشل التحقق من الجهاز. قارن الرموز مجددًا.';

  @override
  String get failureData => 'بيانات غير صالحة أو إصدار غير متوافق';

  @override
  String get failureIntegrity => 'حجم الملف أو بصمته غير متطابقين';

  @override
  String get failureStorage =>
      'تعذرت القراءة أو الكتابة. تحقق من صلاحيات المجلد والمساحة الحرة.';

  @override
  String get failureUnexpected => 'النقل غير مكتمل. أعد المحاولة.';

  @override
  String get addressRequired => 'أدخل عنوان IPv4 والمنفذ';

  @override
  String get addressInvalid => 'أدخل عنوان IPv4 صالحًا ومنفذًا من 1 إلى 65535';

  @override
  String get language => 'اللغة';

  @override
  String get languageChoice => 'اللغة';

  @override
  String get downloadsLocation => 'التنزيلات / Dukto2';

  @override
  String get iosLocation => 'الملفات / Dukto2 / الملفات المستلمة';

  @override
  String get transferChannel => 'نقل الملفات';

  @override
  String get transferNotification => 'نقل Dukto2';

  @override
  String get preparingTransfer => 'جارٍ تحضير النقل…';

  @override
  String get backgroundExpired =>
      'انتهى وقت الخلفية. عد إلى التطبيق وأرسل مجددًا.';

  @override
  String get notificationCancelled => 'أُلغي من الإشعار';

  @override
  String get networkPermission =>
      'يكتشف Dukto2 الأجهزة على شبكتك المحلية ويتصل بها لنقل الملفات والنصوص التي تختار إرسالها أو استلامها.';

  @override
  String get qrSelf => 'هذا رمز هذا الجهاز. امسح رمز جهاز آخر.';

  @override
  String get qrConnecting => 'جارٍ تجربة عناوين الجهاز في رمز QR…';

  @override
  String get qrConnectionFailed =>
      'تعذر الاتصال. تحقق من فتح التطبيق وإمكانية التواصل بين الجهازين وصلاحية الرمز.';

  @override
  String get showQr => 'عرض رمز QR';

  @override
  String get scanQr => 'مسح للاتصال';

  @override
  String get qrInstructions => 'افتح Dukto2 على الجهاز الآخر.';

  @override
  String get connectionQr => 'رمز QR للاتصال';

  @override
  String get qrAfterWifi => 'اتصل بشبكة لعرض رمز QR';

  @override
  String get qrSemantic => 'رمز QR لاتصال جهاز Dukto2';

  @override
  String get qrVerify =>
      'على الشبكة نفسها، حتى عبر شبكات فرعية مختلفة، إذا كان الجهازان يستطيعان الاتصال مباشرة، فاضغط على «المسح للاتصال» وامسح رمز QR هذا.';

  @override
  String get cameraUnavailable =>
      'الكاميرا غير متاحة. اسمح لـ Dukto2 باستخدامها في إعدادات النظام ثم افتح الماسح مجددًا.';

  @override
  String get backToConnection => 'العودة إلى الاتصال';

  @override
  String get qrAim =>
      'وجّه الكاميرا نحو رمز QR في لوحة «هذا الجهاز» على الجهاز الآخر.';

  @override
  String get subnetHint =>
      'يعمل اتصال QR عبر الشبكات الفرعية لنفس الشبكة إذا أمكن للجهازين التواصل مباشرة.';

  @override
  String get qrExpected => 'امسح رمز اتصال Dukto2';

  @override
  String get qrInvalid => 'رمز غير صالح. أعد فتح معلومات الجهاز الآخر.';

  @override
  String get qrUnreachable =>
      'تعذر الوصول إلى الجهاز أو التحقق منه. تحقق من Dukto2 واتصال الشبكة ثم امسح مجددًا.';

  @override
  String get qrNoCamera => 'لم يتم العثور على كاميرا. يمكنك اختيار صورة QR.';

  @override
  String get qrCamera => 'الكاميرا';

  @override
  String get qrChooseImage => 'اختيار صورة QR';

  @override
  String get qrOpenCamera => 'فتح الكاميرا';

  @override
  String get qrImageNotFound => 'لم يتم العثور على رمز QR. اختر صورة أوضح.';

  @override
  String get qrImageTooLarge =>
      'الصورة كبيرة جدًا. استخدم أقل من 20 MiB و16 ميغابكسل.';

  @override
  String get qrImageUnreadable => 'تعذر قراءة الصورة. اختر PNG أو JPEG أو BMP.';

  @override
  String get deviceOffline => 'غير متصل';

  @override
  String get deviceChecking => 'جارٍ التحقق من الاتصال…';

  @override
  String get deviceIdentityChanged => 'تغيّرت هوية الجهاز';

  @override
  String get deviceOnline => 'متصل · تم التحقق من الهوية';

  @override
  String get aboutAuthor => 'المؤلف: lvjing2';
}
