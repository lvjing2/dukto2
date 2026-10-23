// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Сегодня $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Вчера $arg0';
  }

  @override
  String get lessThanSecond => 'Менее 1 секунды';

  @override
  String secondsDuration(String arg0) {
    return '$arg0 с';
  }

  @override
  String minutesDuration(String arg0, String arg1) {
    return '$arg0 мин $arg1 с';
  }

  @override
  String hoursDuration(String arg0, String arg1, String arg2) {
    return '$arg0 ч $arg1 мин $arg2 с';
  }

  @override
  String get phone => 'Телефон';

  @override
  String get tablet => 'Планшет';

  @override
  String get computer => 'Компьютер';

  @override
  String get device => 'Устройство';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 хочет отправить: $arg1';
  }

  @override
  String get batchConsent => 'Подтвердите один раз для всего пакета';

  @override
  String get textConsent => 'Принять этот текст?';

  @override
  String get fileConsent => 'Принять этот файл?';

  @override
  String approvalWarning(String arg0) {
    return 'Имя отправителя не проверено. Принимайте только знакомые данные. Запрос истечёт через $arg0 мин.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Сохранить в: $arg0';
  }

  @override
  String get decline => 'Отклонить';

  @override
  String get receiveAll => 'Принять всё';

  @override
  String get receiveText => 'Принять текст';

  @override
  String get receiveFile => 'Принять файл';

  @override
  String verifyPeer(String arg0) {
    return 'Проверить $arg0';
  }

  @override
  String get verificationInstructions =>
      'Откройте сведения на другом устройстве и сравните код с указанным ниже.';

  @override
  String get verificationWarning =>
      'Имя не подтверждает подлинность. Проверьте код на другом экране.';

  @override
  String get cancel => 'Отмена';

  @override
  String get confirmConnection => 'Коды совпадают, подключить';

  @override
  String get localInfo => 'Сведения об устройстве';

  @override
  String get showLocalCode =>
      'Сравните этот код при ручном подключении. При сканировании устройство проверяется автоматически.';

  @override
  String get generating => 'Создание…';

  @override
  String get deviceName => 'Имя устройства';

  @override
  String get preparing => 'Подготовка…';

  @override
  String get connectionAddress => 'Адрес подключения';

  @override
  String get addressWhenConnected =>
      'Подключитесь к сети, чтобы увидеть адреса';

  @override
  String get done => 'Готово';

  @override
  String get manualConnection => 'Ручное подключение';

  @override
  String get findPeerAddress => 'Адрес указан в сведениях другого устройства.';

  @override
  String get deviceAddress => 'Адрес устройства';

  @override
  String get addressSeparator => 'Разделите адрес и порт двоеточием :';

  @override
  String get next => 'Далее';

  @override
  String get connecting => 'Подключение…';

  @override
  String get connectionFailed =>
      'Не удалось подключиться. Проверьте адрес и сеть.';

  @override
  String sendToPeer(String arg0) {
    return 'Отправить на $arg0';
  }

  @override
  String get hideKeyboard => 'Скрыть клавиатуру';

  @override
  String get settings => 'Настройки';

  @override
  String get thisDevice => 'Это устройство';

  @override
  String get discoverable => 'Видно устройствам поблизости';

  @override
  String get starting => 'Запуск…';

  @override
  String nearbyDevices(String arg0) {
    return 'Устройства поблизости: $arg0';
  }

  @override
  String get refreshDevices => 'Обновить устройства';

  @override
  String get searchingDevices => 'Поиск…';

  @override
  String get findingDevices => 'Поиск устройств поблизости…';

  @override
  String get noDevices => 'Устройства не найдены';

  @override
  String get verifiedSelected => 'Проверено · Выбрано';

  @override
  String get verifiedOffline => 'Проверено · Не в сети';

  @override
  String get unverified => 'Не проверено';

  @override
  String get receivingContent => 'Приём';

  @override
  String get sendingContent => 'Отправить данные';

  @override
  String get directTransfer =>
      'Файлы и текст передаются в зашифрованном виде напрямую только между двумя устройствами по локальной сети.';

  @override
  String sendTo(String arg0) {
    return 'Отправить на$arg0';
  }

  @override
  String get codeVerified => 'Устройство проверено';

  @override
  String get viewVerification => 'Показать код устройства';

  @override
  String get file => 'Файл';

  @override
  String get text => 'Текст';

  @override
  String get statusPrefix => 'Завершено';

  @override
  String get preparingIdentity => 'Подготовка идентификатора…';

  @override
  String get noNearbyDevices => 'Нет устройств поблизости';

  @override
  String get selectDevice => 'Выберите устройство для начала';

  @override
  String get sameWifiHint =>
      'Подключите устройства к одной сети\nи откройте Dukto2 на другом устройстве.';

  @override
  String get selectVerifyHint => 'Выберите устройство и сравните код.';

  @override
  String get enterAddress => 'Ручное подключение';

  @override
  String get textCopied => 'Текст скопирован';

  @override
  String get copyFailed => 'Не удалось скопировать. Повторите.';

  @override
  String get textContent => 'Текстовое содержимое';

  @override
  String filePreviewHint(String arg0) {
    return 'Только предпросмотр. Всего: $arg0. Полный текст доступен в файле.';
  }

  @override
  String get textPreviewHint =>
      'Только предпросмотр. Кнопка копирования копирует весь текст.';

  @override
  String get close => 'Закрыть';

  @override
  String get openFullText => 'Открыть полный текст';

  @override
  String get copyPreview => 'Копировать предпросмотр';

  @override
  String get copyText => 'Копировать текст';

  @override
  String get emptyClipboard => 'В буфере обмена нет текста';

  @override
  String get editorLimit =>
      'В редакторе доступен 1 МиБ. Больший текст загрузите из файла (до 16 МиБ).';

  @override
  String get clipboardFailed => 'Не удалось прочитать буфер обмена. Повторите.';

  @override
  String get textPlaceholder => 'Введите текст или вставьте ссылку';

  @override
  String get textFileLoaded => 'Текст UTF-8 загружен. Будет передан весь файл.';

  @override
  String get textLimit => 'До 16 МиБ · Нужно согласие получателя';

  @override
  String get textUnsupported =>
      'Устройство не поддерживает текст. Обновите приложение на нём.';

  @override
  String get waitingText => 'Ожидание получателя…';

  @override
  String get sendingText => 'Отправка и проверка текста…';

  @override
  String get textSent => 'Текст отправлен и проверен';

  @override
  String get textCancelled => 'Отправка отменена. Текст сохранён.';

  @override
  String get pasteText => 'Вставить текст';

  @override
  String get moreTextActions => 'Другие действия с текстом';

  @override
  String get loadTextFile => 'Загрузить текстовый файл';

  @override
  String get clearText => 'Очистить текст';

  @override
  String get cancelTransfer => 'Отменить передачу';

  @override
  String get sendText => 'Отправить текст';

  @override
  String get send => 'Отправить';

  @override
  String get chooseFileHint => 'Выберите файлы для отправки';

  @override
  String get approvalBeforeTransfer =>
      'Передача начнётся после согласия получателя';

  @override
  String get picking => 'Выбор…';

  @override
  String get chooseFiles => 'Выбрать файлы';

  @override
  String get multiSelectHint => 'Несколько файлов · По порядку';

  @override
  String get waitingBatch => 'Ожидание загрузки пакета…';

  @override
  String get waitingUpload => 'Ожидание отправителя…';

  @override
  String get verifyingFile => 'Проверка файла…';

  @override
  String get receiving => 'Приём';

  @override
  String get ready => 'Готово';

  @override
  String get waitingReceiver => 'Ожидание согласия';

  @override
  String get sending => 'Отправка';

  @override
  String get waitingVerification => 'Ожидание проверки…';

  @override
  String get sentVerified => 'Отправлено и проверено';

  @override
  String get sendCancelled => 'Отправка отменена';

  @override
  String get sendFailedRetry => 'Ошибка отправки. Повторите.';

  @override
  String get batchSent => 'Все файлы отправлены и проверены';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Файл $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return 'Отправлено $arg0 / $arg1 · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 файла',
      many: '$arg0 файлов',
      few: '$arg0 файла',
      one: '$arg0 файл',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Убрать выбранные файлы';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Убрать $arg0';
  }

  @override
  String get receiveProgress => 'Ход приёма';

  @override
  String get sendProgress => 'Ход отправки';

  @override
  String get sendOtherFiles => 'Отправить другие файлы';

  @override
  String get chooseAgain => 'Выбрать заново';

  @override
  String get continueSending => 'Продолжить';

  @override
  String get resend => 'Отправить снова';

  @override
  String get sendFiles => 'Отправить файлы';

  @override
  String get recentTransfers => 'Недавние передачи';

  @override
  String get allDevices => 'Все устройства';

  @override
  String get otherDevice => 'Другое устройство';

  @override
  String get emptyHistory => 'Здесь появятся переданные файлы и тексты.';

  @override
  String get textMessage => 'Текстовое сообщение';

  @override
  String get received => 'Получено';

  @override
  String get sent => 'Отправлено';

  @override
  String durationLabel(String arg0) {
    return 'Время: $arg0';
  }

  @override
  String get viewText => 'Просмотреть текст';

  @override
  String get openFolderHint => 'Открыть папку локального файла';

  @override
  String get noLocalFile => 'Расположение файла недоступно';

  @override
  String get openFolder => 'Открыть папку';

  @override
  String get about => 'О Dukto2';

  @override
  String get aboutTribute =>
      'Посвящается Dukto и его автору Emanuele Colombo. Спасибо xuzhen и сообществу за поддержку проекта.';

  @override
  String get aboutAi =>
      'Код, интерфейс, тесты и документация созданы с OpenAI Codex под руководством человека.';

  @override
  String get aboutProject =>
      'Независимая реализация, продолжающая простой и удобный подход Dukto.';

  @override
  String get licenses => 'Лицензии сторонних компонентов';

  @override
  String get notificationsAllowed => 'Уведомления разрешены';

  @override
  String get notificationsDenied => 'Уведомления отключены';

  @override
  String get notificationsUndetermined => 'Ещё не разрешено';

  @override
  String get notificationsManaged => 'Уведомления управляются системой';

  @override
  String get notificationsUnavailable => 'Статус уведомлений недоступен';

  @override
  String get notificationsChecking => 'Проверка уведомлений…';

  @override
  String get folderBusy => 'Нельзя менять папку во время передачи.';

  @override
  String get receiveLocation => 'Папка приёма';

  @override
  String get changeFolder => 'Изменить папку';

  @override
  String get restoreDefault => 'По умолчанию';

  @override
  String get readingDeviceName => 'Чтение имени устройства…';

  @override
  String get notifications => 'Уведомления';

  @override
  String get completionNotifications => 'Уведомления о завершении';

  @override
  String get allowNotifications => 'Разрешить уведомления';

  @override
  String get systemNotificationSettings => 'Системные настройки уведомлений';

  @override
  String get ongoingNotificationHint =>
      'Уведомление текущей передачи останется включённым.';

  @override
  String get appearance => 'Оформление';

  @override
  String get followSystem => 'Как в системе';

  @override
  String get light => 'Светлое';

  @override
  String get dark => 'Тёмное';

  @override
  String get chooseFolder => 'Выбрать папку приёма';

  @override
  String get appStorage => 'Хранилище приложения';

  @override
  String get backgroundIos =>
      'Оставьте приложение открытым. Переключение или блокировка экрана могут прервать передачу.';

  @override
  String get backgroundAndroid =>
      'Разрешённые передачи продолжаются в фоне. Не останавливайте приложение принудительно.';

  @override
  String get backgroundDesktop =>
      'Не закрывайте приложение и не допускайте спящего режима при передаче.';

  @override
  String get backgroundStopped => 'Фоновая передача остановлена';

  @override
  String get downloadsUnavailable => 'Папка загрузок недоступна';

  @override
  String get discoveryUnavailable => 'Поиск недоступен. Подключитесь вручную.';

  @override
  String get readyLan => 'Готово · Одна сеть';

  @override
  String get startupFailed =>
      'Не удалось запустить. Проверьте разрешения сети.';

  @override
  String get checkNetworkPermissions =>
      'Проверьте разрешения сети и откройте приложение заново';

  @override
  String get networkRecoveryFailed =>
      'Не удалось восстановить сеть. Обновите ещё раз.';

  @override
  String get settingsSaveFailed => 'Не удалось сохранить настройки. Повторите.';

  @override
  String get notificationRequestFailed =>
      'Не удалось запросить разрешение. Проверьте настройки системы.';

  @override
  String get notificationSettingsFailed =>
      'Не удалось открыть настройки. Проверьте разрешения уведомлений Dukto2 вручную.';

  @override
  String get receiveComplete => 'Приём завершён';

  @override
  String get sendComplete => 'Отправка завершена';

  @override
  String receivedVerified(String arg0) {
    return 'Получено и проверено: $arg0';
  }

  @override
  String sentContentVerified(String arg0) {
    return 'Отправлено и проверено: $arg0';
  }

  @override
  String get folderUnavailable =>
      'Папка приёма недоступна. Выберите её заново.';

  @override
  String get authorizedFolder => 'Разрешённая папка';

  @override
  String get folderUpdated => 'Папка приёма обновлена';

  @override
  String get folderChangeFailed => 'Не удалось изменить папку приёма';

  @override
  String get folderReset => 'Восстановлена папка приёма по умолчанию';

  @override
  String get folderResetFailed => 'Не удалось восстановить папку приёма';

  @override
  String receivingName(String arg0) {
    return 'Приём: $arg0';
  }

  @override
  String get textReceived => 'Текст получен и проверен';

  @override
  String receivedName(String arg0) {
    return 'Получено и проверено: $arg0';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Ошибка приёма: $arg0';
  }

  @override
  String get receiveCancelled => 'Приём отменён';

  @override
  String get waitingFiles => 'Ожидание файлов';

  @override
  String get newRequest => 'Новый запрос на приём';

  @override
  String get receiveDeclined => 'Приём отклонён';

  @override
  String receivingBatchName(String arg0) {
    return 'Приём файла пакета: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Выбрано: $arg0';
  }

  @override
  String get receivingFiles => 'Приём файлов';

  @override
  String get sendingFiles => 'Отправка файлов';

  @override
  String sendingName(String arg0) {
    return 'Отправка: $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Не удалось узнать размер. Сначала загрузите файл на устройство.';

  @override
  String preparingFiles(String arg0) {
    return 'Подготовка: $arg0';
  }

  @override
  String get filePickerFailed => 'Не удалось выбрать файлы';

  @override
  String get textFileLimit => 'Выберите файл UTF-8 до 16 МиБ';

  @override
  String get textLoadFailed =>
      'Не удалось загрузить текст. Проверьте файл и кодировку UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Ожидание согласия $arg0 на $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Отправка файла $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Ожидание согласия $arg0…';
  }

  @override
  String sentName(String arg0) {
    return 'Отправлено и проверено: $arg0';
  }

  @override
  String sendFailed(String arg0) {
    return 'Ошибка отправки: $arg0';
  }

  @override
  String get canResend => 'Можно отправить снова';

  @override
  String get fileMissing => 'Файл перемещён или удалён';

  @override
  String get folderOpenUnavailable => 'Не удалось открыть папку файла';

  @override
  String get folderOpenFailed => 'Не удалось открыть папку';

  @override
  String savedCopy(String arg0) {
    return 'Копия $arg0 сохранена';
  }

  @override
  String get finderFailed => 'Не удалось показать файл в Finder';

  @override
  String get exportFailed => 'Не удалось экспортировать файл';

  @override
  String get failurePlatform =>
      'Не удалось начать передачу. Проверьте разрешения.';

  @override
  String get failureCancelled => 'Передача отменена';

  @override
  String get failureDeclined =>
      'Получатель отказал или время подтверждения истекло';

  @override
  String get failureBusy => 'Получатель занят. Повторите позже.';

  @override
  String get failureExpired => 'Передача истекла. Отправьте снова.';

  @override
  String get failureTimeout =>
      'Время подключения или передачи истекло. Проверьте сеть.';

  @override
  String get failureNetwork => 'Соединение прервано. Проверьте оба устройства.';

  @override
  String get failureCertificate =>
      'Проверка устройства не пройдена. Сравните коды заново.';

  @override
  String get failureData => 'Неверные данные или несовместимая версия';

  @override
  String get failureIntegrity => 'Размер или контрольная сумма не совпадают';

  @override
  String get failureStorage =>
      'Ошибка чтения или записи. Проверьте права папки и свободное место.';

  @override
  String get failureUnexpected => 'Передача не завершена. Повторите.';

  @override
  String get addressRequired => 'Введите IPv4-адрес и порт';

  @override
  String get addressInvalid => 'Введите верный IPv4-адрес и порт от 1 до 65535';

  @override
  String get language => 'Язык';

  @override
  String get languageChoice => 'Язык';

  @override
  String get downloadsLocation => 'Загрузки / Dukto2';

  @override
  String get iosLocation => 'Файлы / Dukto2 / Полученные';

  @override
  String get transferChannel => 'Передача файлов';

  @override
  String get transferNotification => 'Передача Dukto2';

  @override
  String get preparingTransfer => 'Подготовка передачи…';

  @override
  String get backgroundExpired =>
      'Время работы в фоне истекло. Вернитесь в приложение и отправьте снова.';

  @override
  String get notificationCancelled => 'Отменено из уведомления';

  @override
  String get networkPermission =>
      'Dukto2 находит устройства в локальной сети и подключается к ним для передачи выбранных вами файлов и текстов.';

  @override
  String get qrSelf => 'Это код текущего устройства. Сканируйте другое.';

  @override
  String get qrConnecting => 'Проверка адресов из QR-кода…';

  @override
  String get qrConnectionFailed =>
      'Не удалось подключиться. Проверьте, что приложение открыто, устройства доступны и код действителен.';

  @override
  String get showQr => 'Показать QR-код';

  @override
  String get scanQr => 'Подключиться по QR';

  @override
  String get qrInstructions => 'Откройте Dukto2 на другом устройстве.';

  @override
  String get connectionQr => 'QR-код подключения';

  @override
  String get qrAfterWifi => 'Подключитесь к сети для показа QR-кода';

  @override
  String get qrSemantic => 'QR-код подключения Dukto2';

  @override
  String get qrVerify =>
      'В одной сети, даже в разных подсетях, если устройства могут обмениваться данными напрямую, нажмите «Подключиться по QR» и отсканируйте этот QR-код.';

  @override
  String get cameraUnavailable =>
      'Камера недоступна. Разрешите доступ в настройках системы и откройте сканер снова.';

  @override
  String get backToConnection => 'Назад к подключению';

  @override
  String get qrAim =>
      'Наведите на QR-код в разделе «Это устройство» на другом устройстве.';

  @override
  String get subnetHint =>
      'QR-подключение работает между подсетями одного сеть при прямой доступности устройств.';

  @override
  String get qrExpected => 'Сканируйте QR-код Dukto2';

  @override
  String get qrInvalid =>
      'Неверный QR-код. Откройте сведения на другом устройстве заново.';

  @override
  String get qrUnreachable =>
      'Устройство недоступно или не проверено. Проверьте Dukto2 и сеть и сканируйте снова.';

  @override
  String get qrNoCamera =>
      'Камера не найдена. Можно выбрать изображение QR-кода.';

  @override
  String get qrCamera => 'Камера';

  @override
  String get qrChooseImage => 'Выбрать QR-изображение';

  @override
  String get qrOpenCamera => 'Открыть камеру';

  @override
  String get qrImageNotFound =>
      'QR-код не найден. Выберите более чёткое изображение.';

  @override
  String get qrImageTooLarge =>
      'Изображение слишком большое. Максимум 20 МиБ и 16 мегапикселей.';

  @override
  String get qrImageUnreadable =>
      'Не удалось прочитать изображение. Выберите PNG, JPEG или BMP.';

  @override
  String get deviceOffline => 'Не в сети';

  @override
  String get deviceChecking => 'Проверка соединения…';

  @override
  String get deviceIdentityChanged => 'Идентификатор устройства изменился';

  @override
  String get deviceOnline => 'В сети · Личность подтверждена';

  @override
  String get aboutAuthor => 'Автор: lvjing2';

  @override
  String get peerCancelledTransfer => 'Другое устройство отменило передачу';

  @override
  String get backgroundReceive => 'Фоновый приём';

  @override
  String get backgroundReceiveHint =>
      'Ожидание запросов 30 минут после выхода. Ограничения энергосбережения системы сохраняются.';

  @override
  String get backgroundReceiveActive => 'Ожидание запросов · до 30 минут';

  @override
  String get stopBackgroundReceive => 'Завершить ожидание';

  @override
  String get receiveRequests => 'Запросы на приём';

  @override
  String get receiveRequestBody => 'Нажмите, проверьте список и подтвердите.';

  @override
  String get backgroundReceiveUnavailable =>
      'Разрешите уведомления и оба канала приёма в настройках системы.';
}
