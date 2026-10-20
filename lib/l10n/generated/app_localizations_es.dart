// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Hoy $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Ayer $arg0';
  }

  @override
  String get lessThanSecond => 'Menos de 1 segundo';

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
  String get phone => 'Teléfono';

  @override
  String get tablet => 'Tableta';

  @override
  String get computer => 'Ordenador';

  @override
  String get device => 'Dispositivo';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 quiere enviar $arg1';
  }

  @override
  String get batchConsent => 'Confirma una vez para recibir este lote';

  @override
  String get textConsent => '¿Recibir este texto?';

  @override
  String get fileConsent => '¿Recibir este archivo?';

  @override
  String approvalWarning(String arg0) {
    return 'El nombre no está verificado. Acepta solo contenido reconocido. Caduca en $arg0 minutos.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Guardar en: $arg0';
  }

  @override
  String get decline => 'Rechazar';

  @override
  String get receiveAll => 'Recibir todo';

  @override
  String get receiveText => 'Recibir texto';

  @override
  String get receiveFile => 'Recibir archivo';

  @override
  String verifyPeer(String arg0) {
    return 'Verificar $arg0';
  }

  @override
  String get verificationInstructions =>
      'Abre la información local del otro dispositivo y compara su código.';

  @override
  String get verificationWarning =>
      'El nombre no demuestra la identidad. Comprueba la otra pantalla antes de confirmar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmConnection => 'Coinciden, conectar';

  @override
  String get localInfo => 'Información local';

  @override
  String get showLocalCode =>
      'Compara este código para conexiones manuales. El escaneo verifica la identidad automáticamente.';

  @override
  String get generating => 'Generando…';

  @override
  String get deviceName => 'Nombre del dispositivo';

  @override
  String get preparing => 'Preparando…';

  @override
  String get connectionAddress => 'Dirección de conexión';

  @override
  String get addressWhenConnected =>
      'Conéctate a una red para ver las direcciones';

  @override
  String get done => 'Listo';

  @override
  String get manualConnection => 'Conexión manual';

  @override
  String get findPeerAddress =>
      'Busca la dirección en la información local del otro dispositivo.';

  @override
  String get deviceAddress => 'Dirección del dispositivo';

  @override
  String get addressSeparator => 'Separa dirección y puerto con dos puntos :';

  @override
  String get next => 'Siguiente';

  @override
  String get connecting => 'Conectando…';

  @override
  String get connectionFailed =>
      'No se pudo conectar. Comprueba la dirección y la red.';

  @override
  String sendToPeer(String arg0) {
    return 'Enviar a $arg0';
  }

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get settings => 'Ajustes';

  @override
  String get thisDevice => 'Este dispositivo';

  @override
  String get discoverable => 'Visible para dispositivos cercanos';

  @override
  String get starting => 'Iniciando…';

  @override
  String nearbyDevices(String arg0) {
    return 'Dispositivos cercanos: $arg0';
  }

  @override
  String get refreshDevices => 'Actualizar dispositivos';

  @override
  String get findingDevices => 'Buscando dispositivos…';

  @override
  String get noDevices => 'No se encontraron dispositivos';

  @override
  String get verifiedSelected => 'Verificado · Seleccionado';

  @override
  String get verifiedOffline => 'Verificado · Sin conexión';

  @override
  String get unverified => 'Sin verificar';

  @override
  String get receivingContent => 'Recibiendo';

  @override
  String get sendingContent => 'Enviar contenido';

  @override
  String get directTransfer =>
      'Los archivos y textos se transfieren directamente entre dispositivos.';

  @override
  String sendTo(String arg0) {
    return 'Enviar a$arg0';
  }

  @override
  String get codeVerified => 'Identidad del dispositivo verificada';

  @override
  String get viewVerification => 'Ver código del dispositivo';

  @override
  String get file => 'Archivo';

  @override
  String get text => 'Texto';

  @override
  String get betweenDevices =>
      'El contenido solo se transfiere entre estos dos dispositivos.';

  @override
  String get encryptedLan => 'LAN directa · Cifrado';

  @override
  String get statusPrefix => 'Completado';

  @override
  String get preparingIdentity => 'Preparando identidad…';

  @override
  String get noNearbyDevices => 'No hay dispositivos cercanos';

  @override
  String get selectDevice => 'Selecciona un dispositivo para empezar';

  @override
  String get sameWifiHint =>
      'Conecta ambos dispositivos a la misma red\ny abre Dukto2 en el otro dispositivo.';

  @override
  String get selectVerifyHint =>
      'Selecciona un dispositivo y compara su código.';

  @override
  String get enterAddress => 'Conexión manual';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get copyFailed => 'No se pudo copiar. Inténtalo de nuevo.';

  @override
  String get textContent => 'Contenido del texto';

  @override
  String filePreviewHint(String arg0) {
    return 'Solo vista previa. Tamaño total: $arg0. Abre el archivo para ver todo.';
  }

  @override
  String get textPreviewHint =>
      'Solo vista previa. Copiar texto copia todo el contenido.';

  @override
  String get close => 'Cerrar';

  @override
  String get openFullText => 'Abrir texto completo';

  @override
  String get copyPreview => 'Copiar vista previa';

  @override
  String get copyText => 'Copiar texto';

  @override
  String get emptyClipboard => 'El portapapeles no contiene texto';

  @override
  String get editorLimit =>
      'El editor admite 1 MiB. Carga textos mayores desde un archivo (hasta 16 MiB).';

  @override
  String get clipboardFailed => 'No se pudo leer el portapapeles. Reinténtalo.';

  @override
  String get textPlaceholder => 'Escribe texto o pega un enlace';

  @override
  String get textFileLoaded =>
      'Texto UTF-8 cargado. Se enviará el archivo completo.';

  @override
  String get textLimit => 'Hasta 16 MiB · Requiere aprobación';

  @override
  String get textUnsupported =>
      'Este dispositivo no admite texto. Actualiza su aplicación.';

  @override
  String get waitingText => 'Esperando al receptor…';

  @override
  String get sendingText => 'Enviando y verificando texto…';

  @override
  String get textSent => 'Texto enviado y verificado';

  @override
  String get textCancelled => 'Envío cancelado. Texto conservado.';

  @override
  String get pasteText => 'Pegar texto';

  @override
  String get moreTextActions => 'Más acciones de texto';

  @override
  String get loadTextFile => 'Cargar archivo de texto';

  @override
  String get clearText => 'Borrar contenido';

  @override
  String get cancelTransfer => 'Cancelar transferencia';

  @override
  String get sendText => 'Enviar texto';

  @override
  String get send => 'Enviar';

  @override
  String get chooseFileHint => 'Elige archivos para enviar';

  @override
  String get approvalBeforeTransfer =>
      'La transferencia comienza al aprobar el receptor';

  @override
  String get picking => 'Seleccionando…';

  @override
  String get chooseFiles => 'Elegir archivos';

  @override
  String get multiSelectHint => 'Selección múltiple · Envío en orden';

  @override
  String get waitingBatch => 'Esperando carga del lote…';

  @override
  String get waitingUpload => 'Esperando al remitente…';

  @override
  String get verifyingFile => 'Verificando archivo…';

  @override
  String get receiving => 'Recibiendo';

  @override
  String get ready => 'Listo';

  @override
  String get waitingReceiver => 'Esperando aprobación';

  @override
  String get sending => 'Enviando';

  @override
  String get waitingVerification => 'Esperando verificación…';

  @override
  String get sentVerified => 'Enviado y verificado';

  @override
  String get sendCancelled => 'Envío cancelado';

  @override
  String get sendFailedRetry => 'Error al enviar. Reinténtalo.';

  @override
  String get batchSent => 'Todos los archivos enviados y verificados';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Archivo $arg0 / $arg1 · $arg2';
  }

  @override
  String batchCompleted(String arg0, String arg1, String arg2) {
    return '$arg0 / $arg1 enviados · $arg2';
  }

  @override
  String fileCount(int arg0) {
    String _temp0 = intl.Intl.pluralLogic(
      arg0,
      locale: localeName,
      other: '$arg0 archivos',
      one: '$arg0 archivo',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Quitar archivos seleccionados';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Quitar $arg0';
  }

  @override
  String get receiveProgress => 'Progreso de recepción';

  @override
  String get sendProgress => 'Progreso de envío';

  @override
  String get sendOtherFiles => 'Enviar otros archivos';

  @override
  String get chooseAgain => 'Elegir de nuevo';

  @override
  String get continueSending => 'Continuar';

  @override
  String get resend => 'Reenviar';

  @override
  String get sendFiles => 'Enviar archivos';

  @override
  String get recentTransfers => 'Transferencias recientes';

  @override
  String get allDevices => 'Todos los dispositivos';

  @override
  String get otherDevice => 'Otro dispositivo';

  @override
  String get emptyHistory =>
      'Los archivos y textos completados aparecerán aquí.';

  @override
  String get textMessage => 'Mensaje de texto';

  @override
  String get received => 'Recibido';

  @override
  String get sent => 'Enviado';

  @override
  String durationLabel(String arg0) {
    return 'Duración: $arg0';
  }

  @override
  String get viewText => 'Ver texto';

  @override
  String get openFolderHint => 'Abrir carpeta del archivo local';

  @override
  String get noLocalFile => 'No hay ubicación local disponible';

  @override
  String get openFolder => 'Abrir carpeta';

  @override
  String get about => 'Acerca de Dukto2';

  @override
  String get aboutTribute =>
      'Un homenaje a Dukto y su creador Emanuele Colombo. Gracias a xuzhen y a la comunidad por su mantenimiento continuo.';

  @override
  String get aboutAi =>
      'Código, interfaz, pruebas y documentación creados con OpenAI Codex bajo dirección humana.';

  @override
  String get aboutProject =>
      'Una reimplementación independiente que continúa la experiencia sencilla y directa de Dukto.';

  @override
  String get licenses => 'Licencias de terceros';

  @override
  String get notificationsAllowed => 'Notificaciones permitidas';

  @override
  String get notificationsDenied => 'Notificaciones desactivadas';

  @override
  String get notificationsUndetermined => 'Aún sin autorización';

  @override
  String get notificationsManaged =>
      'Notificaciones gestionadas por el sistema';

  @override
  String get notificationsUnavailable =>
      'Estado de notificaciones no disponible';

  @override
  String get notificationsChecking => 'Comprobando notificaciones…';

  @override
  String get folderBusy =>
      'No se puede cambiar la carpeta durante una transferencia.';

  @override
  String get receiveLocation => 'Ubicación de recepción';

  @override
  String get changeFolder => 'Cambiar carpeta';

  @override
  String get restoreDefault => 'Restablecer';

  @override
  String get readingDeviceName => 'Leyendo nombre del dispositivo…';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get completionNotifications => 'Notificar al completar';

  @override
  String get allowNotifications => 'Permitir notificaciones';

  @override
  String get systemNotificationSettings => 'Ajustes de notificaciones';

  @override
  String get ongoingNotificationHint =>
      'La notificación de transferencia en curso permanece activa.';

  @override
  String get appearance => 'Apariencia';

  @override
  String get followSystem => 'Seguir al sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get chooseFolder => 'Elegir carpeta de recepción';

  @override
  String get appStorage => 'Almacenamiento de la aplicación';

  @override
  String get backgroundIos =>
      'Mantén la aplicación en primer plano. Cambiar de aplicación o bloquear puede interrumpir la transferencia.';

  @override
  String get backgroundAndroid =>
      'Las transferencias aprobadas pueden continuar en segundo plano. No fuerces el cierre.';

  @override
  String get backgroundDesktop =>
      'Mantén la aplicación abierta y evita la suspensión durante la transferencia.';

  @override
  String get backgroundStopped => 'Transferencia en segundo plano detenida';

  @override
  String get downloadsUnavailable => 'La carpeta Descargas no está disponible';

  @override
  String get discoveryUnavailable =>
      'Descubrimiento no disponible. Prueba la conexión manual.';

  @override
  String get readyLan => 'Listo · Misma red';

  @override
  String get startupFailed =>
      'No se pudo iniciar. Comprueba los permisos de red.';

  @override
  String get checkNetworkPermissions =>
      'Comprueba permisos de red y vuelve a abrir la app';

  @override
  String get networkRecoveryFailed =>
      'No se pudo restaurar la red. Actualiza de nuevo.';

  @override
  String get settingsSaveFailed =>
      'No se pudieron guardar los ajustes. Reinténtalo.';

  @override
  String get notificationRequestFailed =>
      'No se pudo solicitar permiso. Revisa los ajustes del sistema.';

  @override
  String get notificationSettingsFailed =>
      'No se pudieron abrir los ajustes. Revisa los permisos de notificaciones de Dukto2.';

  @override
  String get receiveComplete => 'Recepción completada';

  @override
  String get sendComplete => 'Envío completado';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 recibido y verificado';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 enviado y verificado';
  }

  @override
  String get folderUnavailable =>
      'Carpeta de recepción no disponible. Elígela de nuevo.';

  @override
  String get authorizedFolder => 'Carpeta autorizada';

  @override
  String get folderUpdated => 'Ubicación de recepción actualizada';

  @override
  String get folderChangeFailed =>
      'No se pudo cambiar la ubicación de recepción';

  @override
  String get folderReset => 'Ubicación predeterminada restaurada';

  @override
  String get folderResetFailed => 'No se pudo restaurar la ubicación';

  @override
  String receivingName(String arg0) {
    return 'Recibiendo $arg0';
  }

  @override
  String get textReceived => 'Texto recibido y verificado';

  @override
  String receivedName(String arg0) {
    return '$arg0 recibido y verificado';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Error al recibir: $arg0';
  }

  @override
  String get receiveCancelled => 'Recepción cancelada';

  @override
  String get waitingFiles => 'Esperando archivos';

  @override
  String get newRequest => 'Nueva solicitud de recepción';

  @override
  String get receiveDeclined => 'Recepción rechazada';

  @override
  String receivingBatchName(String arg0) {
    return 'Recibiendo archivo del lote: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Seleccionado: $arg0';
  }

  @override
  String get receivingFiles => 'Recibiendo archivos';

  @override
  String get sendingFiles => 'Enviando archivos';

  @override
  String sendingName(String arg0) {
    return 'Enviando $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'No se pudo leer el tamaño. Descarga el archivo al dispositivo primero.';

  @override
  String preparingFiles(String arg0) {
    return 'Preparando $arg0';
  }

  @override
  String get filePickerFailed => 'No se pudieron elegir archivos';

  @override
  String get textFileLimit => 'Elige un archivo UTF-8 de hasta 16 MiB';

  @override
  String get textLoadFailed =>
      'No se pudo cargar el texto. Comprueba el archivo y la codificación UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Esperando que $arg0 acepte $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Enviando archivo $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Esperando que $arg0 acepte…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 enviado y verificado';
  }

  @override
  String sendFailed(String arg0) {
    return 'Error al enviar: $arg0';
  }

  @override
  String get canResend => 'Puedes volver a enviar';

  @override
  String get fileMissing => 'Archivo movido o eliminado';

  @override
  String get folderOpenUnavailable => 'No se pudo abrir la carpeta del archivo';

  @override
  String get folderOpenFailed => 'No se pudo abrir la carpeta';

  @override
  String savedCopy(String arg0) {
    return 'Copia de $arg0 guardada';
  }

  @override
  String get finderFailed => 'No se pudo mostrar el archivo en Finder';

  @override
  String get exportFailed => 'No se pudo exportar el archivo';

  @override
  String get failurePlatform =>
      'No se pudo iniciar la transferencia. Comprueba los permisos.';

  @override
  String get failureCancelled => 'Transferencia cancelada';

  @override
  String get failureDeclined => 'El receptor rechazó o caducó la aprobación';

  @override
  String get failureBusy => 'El receptor está ocupado. Inténtalo más tarde.';

  @override
  String get failureExpired => 'Transferencia caducada. Vuelve a enviar.';

  @override
  String get failureTimeout =>
      'Conexión o transferencia agotada. Comprueba la red.';

  @override
  String get failureNetwork =>
      'Conexión interrumpida. Comprueba ambos dispositivos.';

  @override
  String get failureCertificate =>
      'Error de verificación. Compara los códigos de nuevo.';

  @override
  String get failureData => 'Datos no válidos o versión incompatible';

  @override
  String get failureIntegrity =>
      'El tamaño o la suma de comprobación no coincide';

  @override
  String get failureStorage =>
      'Error de lectura o escritura. Comprueba permisos y espacio libre.';

  @override
  String get failureUnexpected =>
      'Transferencia incompleta. Inténtalo de nuevo.';

  @override
  String get addressRequired => 'Introduce dirección IPv4 y puerto';

  @override
  String get addressInvalid => 'Introduce IPv4 válido y puerto entre 1 y 65535';

  @override
  String get language => 'Idioma';

  @override
  String get languageChoice => 'Idioma';

  @override
  String get downloadsLocation => 'Descargas / Dukto2';

  @override
  String get iosLocation => 'Archivos / Dukto2 / Recibidos';

  @override
  String get transferChannel => 'Transferencias de archivos';

  @override
  String get transferNotification => 'Transferencia de Dukto2';

  @override
  String get preparingTransfer => 'Preparando transferencia…';

  @override
  String get backgroundExpired =>
      'Tiempo en segundo plano agotado. Vuelve a la aplicación y envía de nuevo.';

  @override
  String get notificationCancelled => 'Cancelado desde la notificación';

  @override
  String get networkPermission =>
      'Dukto2 descubre y conecta dispositivos en la red local para transferir los archivos y textos que decidas enviar o recibir.';

  @override
  String get qrSelf =>
      'Este es tu propio código. Escanea el de otro dispositivo.';

  @override
  String get qrConnecting => 'Probando direcciones del código QR…';

  @override
  String get qrConnectionFailed =>
      'No se pudo conectar. Comprueba que la app está abierta, la red permite comunicar y el QR es válido.';

  @override
  String get showQr => 'Mostrar código QR';

  @override
  String get scanQr => 'Escanear para conectar';

  @override
  String get qrInstructions =>
      'Abre Dukto2 en el otro dispositivo.\nSi comparten red en subredes distintas, prueba el código QR.';

  @override
  String get connectionQr => 'Código QR de conexión';

  @override
  String get qrAfterWifi => 'Conéctate a una red para mostrar el QR';

  @override
  String get qrSemantic => 'Código QR de conexión de Dukto2';

  @override
  String get qrVerify =>
      'En la misma red, incluso en subredes distintas, si los dispositivos pueden comunicarse directamente, pulsa «Escanear para conectar» y escanea este código QR.';

  @override
  String get cameraUnavailable =>
      'Cámara no disponible. Permite acceso en los ajustes del sistema y vuelve a escanear.';

  @override
  String get backToConnection => 'Volver a conexión';

  @override
  String get qrAim =>
      'Apunta al QR de conexión en «Este dispositivo» del otro equipo.';

  @override
  String get subnetHint =>
      'El QR funciona entre subredes de la misma red si los dispositivos pueden comunicarse directamente.';

  @override
  String get qrExpected => 'Escanea un código QR de Dukto2';

  @override
  String get qrInvalid =>
      'QR no válido. Reabre la información local en el otro dispositivo.';

  @override
  String get qrUnreachable =>
      'No se pudo conectar o verificar. Comprueba Dukto2 y la comunicación de red, y escanea de nuevo.';

  @override
  String get qrNoCamera =>
      'No se encontró ninguna cámara. Puedes elegir una imagen QR.';

  @override
  String get qrCamera => 'Cámara';

  @override
  String get qrChooseImage => 'Elegir imagen QR';

  @override
  String get qrOpenCamera => 'Abrir cámara';

  @override
  String get qrImageNotFound =>
      'No se encontró ningún código QR. Elige una imagen más clara.';

  @override
  String get qrImageTooLarge =>
      'Imagen demasiado grande. Usa menos de 20 MiB y 16 megapíxeles.';

  @override
  String get qrImageUnreadable =>
      'No se puede leer la imagen. Elige PNG, JPEG o BMP.';
}
