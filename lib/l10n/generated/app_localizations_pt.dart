// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String todayTime(String arg0) {
    return 'Hoje $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Ontem $arg0';
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
  String get phone => 'Celular';

  @override
  String get tablet => 'Tablet';

  @override
  String get computer => 'Computador';

  @override
  String get device => 'Dispositivo';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 quer enviar $arg1';
  }

  @override
  String get batchConsent => 'Confirme uma vez para receber este lote';

  @override
  String get textConsent => 'Receber este texto?';

  @override
  String get fileConsent => 'Receber este arquivo?';

  @override
  String approvalWarning(String arg0) {
    return 'O nome não foi verificado. Aceite apenas conteúdo conhecido. Expira em $arg0 minutos.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Salvar em: $arg0';
  }

  @override
  String get decline => 'Recusar';

  @override
  String get receiveAll => 'Receber tudo';

  @override
  String get receiveText => 'Receber texto';

  @override
  String get receiveFile => 'Receber arquivo';

  @override
  String verifyPeer(String arg0) {
    return 'Verificar $arg0';
  }

  @override
  String get verificationInstructions =>
      'Abra as informações locais no outro dispositivo e compare o código.';

  @override
  String get verificationWarning =>
      'O nome não comprova a identidade. Confira a outra tela antes de confirmar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmConnection => 'Códigos iguais, conectar';

  @override
  String get localInfo => 'Informações locais';

  @override
  String get showLocalCode =>
      'Compare este código nas conexões manuais. A leitura verifica a identidade automaticamente.';

  @override
  String get generating => 'Gerando…';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get preparing => 'Preparando…';

  @override
  String get connectionAddress => 'Endereço de conexão';

  @override
  String get addressWhenConnected => 'Conecte à rede para ver os endereços';

  @override
  String get done => 'Concluído';

  @override
  String get manualConnection => 'Conexão manual';

  @override
  String get findPeerAddress =>
      'Veja o endereço nas informações locais do outro dispositivo.';

  @override
  String get deviceAddress => 'Endereço do dispositivo';

  @override
  String get addressSeparator =>
      'Separe o endereço e a porta com dois-pontos :';

  @override
  String get next => 'Avançar';

  @override
  String get connecting => 'Conectando…';

  @override
  String get connectionFailed =>
      'Não foi possível conectar. Confira o endereço e a rede.';

  @override
  String sendToPeer(String arg0) {
    return 'Enviar para $arg0';
  }

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get settings => 'Configurações';

  @override
  String get thisDevice => 'Este dispositivo';

  @override
  String get discoverable => 'Visível para dispositivos próximos';

  @override
  String get starting => 'Iniciando…';

  @override
  String nearbyDevices(String arg0) {
    return 'Dispositivos próximos: $arg0';
  }

  @override
  String get refreshDevices => 'Atualizar dispositivos';

  @override
  String get findingDevices => 'Buscando dispositivos próximos…';

  @override
  String get noDevices => 'Nenhum dispositivo encontrado';

  @override
  String get verifiedSelected => 'Verificado · Selecionado';

  @override
  String get verifiedOffline => 'Verificado · Desconectado';

  @override
  String get unverified => 'Não verificado';

  @override
  String get receivingContent => 'Recebendo';

  @override
  String get sendingContent => 'Enviar conteúdo';

  @override
  String get directTransfer =>
      'Arquivos e textos são transferidos diretamente entre dispositivos.';

  @override
  String sendTo(String arg0) {
    return 'Enviar para$arg0';
  }

  @override
  String get codeVerified => 'Identidade do dispositivo verificada';

  @override
  String get viewVerification => 'Ver código do dispositivo';

  @override
  String get file => 'Arquivo';

  @override
  String get text => 'Texto';

  @override
  String get betweenDevices =>
      'O conteúdo é transferido apenas entre estes dois dispositivos.';

  @override
  String get encryptedLan => 'LAN direta · Criptografado';

  @override
  String get statusPrefix => 'Concluído';

  @override
  String get preparingIdentity => 'Preparando identidade…';

  @override
  String get noNearbyDevices => 'Nenhum dispositivo próximo';

  @override
  String get selectDevice => 'Selecione um dispositivo para começar';

  @override
  String get sameWifiHint =>
      'Conecte os dois dispositivos ao mesma rede\ne abra o Dukto2 no outro dispositivo.';

  @override
  String get selectVerifyHint => 'Selecione um dispositivo e compare o código.';

  @override
  String get enterAddress => 'Conexão manual';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get copyFailed => 'Não foi possível copiar. Tente novamente.';

  @override
  String get textContent => 'Conteúdo do texto';

  @override
  String filePreviewHint(String arg0) {
    return 'Apenas prévia. Tamanho total: $arg0. Abra o arquivo para ver todo o texto.';
  }

  @override
  String get textPreviewHint =>
      'Apenas prévia. Copiar texto copia todo o conteúdo.';

  @override
  String get close => 'Fechar';

  @override
  String get openFullText => 'Abrir texto completo';

  @override
  String get copyPreview => 'Copiar prévia';

  @override
  String get copyText => 'Copiar texto';

  @override
  String get emptyClipboard => 'Não há texto na área de transferência';

  @override
  String get editorLimit =>
      'O editor aceita 1 MiB. Carregue textos maiores de um arquivo (até 16 MiB).';

  @override
  String get clipboardFailed =>
      'Não foi possível ler a área de transferência. Tente novamente.';

  @override
  String get textPlaceholder => 'Digite um texto ou cole um link';

  @override
  String get textFileLoaded =>
      'Texto UTF-8 carregado. O arquivo completo será transmitido.';

  @override
  String get textLimit => 'Até 16 MiB · Requer aprovação';

  @override
  String get textUnsupported =>
      'Este dispositivo não aceita texto. Atualize o aplicativo dele.';

  @override
  String get waitingText => 'Aguardando o destinatário…';

  @override
  String get sendingText => 'Enviando e verificando texto…';

  @override
  String get textSent => 'Texto enviado e verificado';

  @override
  String get textCancelled => 'Envio cancelado. Texto mantido.';

  @override
  String get pasteText => 'Colar texto';

  @override
  String get moreTextActions => 'Mais ações de texto';

  @override
  String get loadTextFile => 'Carregar arquivo de texto';

  @override
  String get clearText => 'Limpar conteúdo';

  @override
  String get cancelTransfer => 'Cancelar transferência';

  @override
  String get sendText => 'Enviar texto';

  @override
  String get send => 'Enviar';

  @override
  String get chooseFileHint => 'Escolha arquivos para enviar';

  @override
  String get approvalBeforeTransfer =>
      'A transferência começa após a aprovação';

  @override
  String get picking => 'Escolhendo…';

  @override
  String get chooseFiles => 'Escolher arquivos';

  @override
  String get multiSelectHint => 'Seleção múltipla · Envio em ordem';

  @override
  String get waitingBatch => 'Aguardando envio do lote…';

  @override
  String get waitingUpload => 'Aguardando o remetente…';

  @override
  String get verifyingFile => 'Verificando arquivo…';

  @override
  String get receiving => 'Recebendo';

  @override
  String get ready => 'Pronto';

  @override
  String get waitingReceiver => 'Aguardando aprovação';

  @override
  String get sending => 'Enviando';

  @override
  String get waitingVerification => 'Aguardando verificação…';

  @override
  String get sentVerified => 'Enviado e verificado';

  @override
  String get sendCancelled => 'Envio cancelado';

  @override
  String get sendFailedRetry => 'Falha no envio. Tente novamente.';

  @override
  String get batchSent => 'Todos os arquivos enviados e verificados';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Arquivo $arg0 / $arg1 · $arg2';
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
      other: '$arg0 arquivos',
      one: '$arg0 arquivo',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Remover arquivos selecionados';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Remover $arg0';
  }

  @override
  String get receiveProgress => 'Progresso do recebimento';

  @override
  String get sendProgress => 'Progresso do envio';

  @override
  String get sendOtherFiles => 'Enviar outros arquivos';

  @override
  String get chooseAgain => 'Escolher novamente';

  @override
  String get continueSending => 'Continuar';

  @override
  String get resend => 'Reenviar';

  @override
  String get sendFiles => 'Enviar arquivos';

  @override
  String get recentTransfers => 'Transferências recentes';

  @override
  String get allDevices => 'Todos os dispositivos';

  @override
  String get otherDevice => 'Outro dispositivo';

  @override
  String get emptyHistory => 'Arquivos e textos concluídos aparecerão aqui.';

  @override
  String get textMessage => 'Mensagem de texto';

  @override
  String get received => 'Recebido';

  @override
  String get sent => 'Enviado';

  @override
  String durationLabel(String arg0) {
    return 'Duração: $arg0';
  }

  @override
  String get viewText => 'Ver texto';

  @override
  String get openFolderHint => 'Abrir pasta do arquivo local';

  @override
  String get noLocalFile => 'Local do arquivo indisponível';

  @override
  String get openFolder => 'Abrir pasta';

  @override
  String get about => 'Sobre o Dukto2';

  @override
  String get aboutTribute =>
      'Uma homenagem ao Dukto e ao seu criador Emanuele Colombo. Obrigado a xuzhen e à comunidade pela manutenção contínua.';

  @override
  String get aboutAi =>
      'Código, interface, testes e documentação criados com OpenAI Codex sob orientação humana.';

  @override
  String get aboutProject =>
      'Uma reescrita independente que mantém a experiência simples e direta do Dukto.';

  @override
  String get licenses => 'Licenças de terceiros';

  @override
  String get notificationsAllowed => 'Notificações permitidas';

  @override
  String get notificationsDenied => 'Notificações desativadas';

  @override
  String get notificationsUndetermined => 'Ainda não autorizado';

  @override
  String get notificationsManaged => 'Notificações gerenciadas pelo sistema';

  @override
  String get notificationsUnavailable => 'Status de notificações indisponível';

  @override
  String get notificationsChecking => 'Verificando notificações…';

  @override
  String get folderBusy =>
      'Não é possível mudar a pasta durante uma transferência.';

  @override
  String get receiveLocation => 'Local de recebimento';

  @override
  String get changeFolder => 'Mudar pasta';

  @override
  String get restoreDefault => 'Restaurar padrão';

  @override
  String get readingDeviceName => 'Lendo nome do dispositivo…';

  @override
  String get notifications => 'Notificações';

  @override
  String get completionNotifications => 'Notificações de conclusão';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get systemNotificationSettings => 'Configurações de notificações';

  @override
  String get ongoingNotificationHint =>
      'A notificação da transferência em andamento continua ativa.';

  @override
  String get appearance => 'Aparência';

  @override
  String get followSystem => 'Seguir o sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get chooseFolder => 'Escolher pasta de recebimento';

  @override
  String get appStorage => 'Armazenamento do aplicativo';

  @override
  String get backgroundIos =>
      'Mantenha o aplicativo em primeiro plano. Trocar de app ou bloquear a tela pode interromper a transferência.';

  @override
  String get backgroundAndroid =>
      'Transferências aprovadas podem continuar em segundo plano. Não force a parada do aplicativo.';

  @override
  String get backgroundDesktop =>
      'Mantenha o aplicativo aberto e evite a suspensão durante transferências.';

  @override
  String get backgroundStopped => 'Transferência em segundo plano interrompida';

  @override
  String get downloadsUnavailable => 'Pasta Downloads indisponível';

  @override
  String get discoveryUnavailable =>
      'Descoberta indisponível. Tente conectar manualmente.';

  @override
  String get readyLan => 'Pronto · Mesma rede';

  @override
  String get startupFailed =>
      'Não foi possível iniciar. Confira as permissões de rede.';

  @override
  String get checkNetworkPermissions =>
      'Confira as permissões de rede e reabra o app';

  @override
  String get networkRecoveryFailed =>
      'Não foi possível restaurar a rede. Atualize novamente.';

  @override
  String get settingsSaveFailed =>
      'Não foi possível salvar as configurações. Tente novamente.';

  @override
  String get notificationRequestFailed =>
      'Não foi possível solicitar permissão. Confira as configurações do sistema.';

  @override
  String get notificationSettingsFailed =>
      'Não foi possível abrir as configurações. Confira as permissões de notificação do Dukto2.';

  @override
  String get receiveComplete => 'Recebimento concluído';

  @override
  String get sendComplete => 'Envio concluído';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 recebido e verificado';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 enviado e verificado';
  }

  @override
  String get folderUnavailable =>
      'Pasta de recebimento indisponível. Selecione novamente.';

  @override
  String get authorizedFolder => 'Pasta autorizada';

  @override
  String get folderUpdated => 'Local de recebimento atualizado';

  @override
  String get folderChangeFailed =>
      'Não foi possível mudar o local de recebimento';

  @override
  String get folderReset => 'Local padrão de recebimento restaurado';

  @override
  String get folderResetFailed => 'Não foi possível restaurar o local';

  @override
  String receivingName(String arg0) {
    return 'Recebendo $arg0';
  }

  @override
  String get textReceived => 'Texto recebido e verificado';

  @override
  String receivedName(String arg0) {
    return '$arg0 recebido e verificado';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Falha no recebimento: $arg0';
  }

  @override
  String get receiveCancelled => 'Recebimento cancelado';

  @override
  String get waitingFiles => 'Aguardando arquivos';

  @override
  String get newRequest => 'Nova solicitação de recebimento';

  @override
  String get receiveDeclined => 'Recebimento recusado';

  @override
  String receivingBatchName(String arg0) {
    return 'Recebendo arquivo do lote: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Selecionado: $arg0';
  }

  @override
  String get receivingFiles => 'Recebendo arquivos';

  @override
  String get sendingFiles => 'Enviando arquivos';

  @override
  String sendingName(String arg0) {
    return 'Enviando $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Não foi possível ler o tamanho. Baixe o arquivo para este dispositivo primeiro.';

  @override
  String preparingFiles(String arg0) {
    return 'Preparando $arg0';
  }

  @override
  String get filePickerFailed => 'Não foi possível escolher arquivos';

  @override
  String get textFileLimit => 'Escolha um arquivo UTF-8 de até 16 MiB';

  @override
  String get textLoadFailed =>
      'Não foi possível carregar o texto. Confira o arquivo e a codificação UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Aguardando $arg0 aceitar $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Enviando arquivo $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Aguardando $arg0 aceitar…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 enviado e verificado';
  }

  @override
  String sendFailed(String arg0) {
    return 'Falha no envio: $arg0';
  }

  @override
  String get canResend => 'Você pode enviar novamente';

  @override
  String get fileMissing => 'Arquivo movido ou excluído';

  @override
  String get folderOpenUnavailable =>
      'Não foi possível abrir a pasta do arquivo';

  @override
  String get folderOpenFailed => 'Não foi possível abrir a pasta';

  @override
  String savedCopy(String arg0) {
    return 'Cópia de $arg0 salva';
  }

  @override
  String get finderFailed => 'Não foi possível mostrar o arquivo no Finder';

  @override
  String get exportFailed => 'Não foi possível exportar o arquivo';

  @override
  String get failurePlatform =>
      'Não foi possível iniciar a transferência. Confira as permissões.';

  @override
  String get failureCancelled => 'Transferência cancelada';

  @override
  String get failureDeclined =>
      'O destinatário recusou ou o prazo de aprovação expirou';

  @override
  String get failureBusy => 'O destinatário está ocupado. Tente mais tarde.';

  @override
  String get failureExpired => 'Transferência expirada. Envie novamente.';

  @override
  String get failureTimeout =>
      'Tempo limite de conexão ou transferência. Confira a rede.';

  @override
  String get failureNetwork =>
      'Conexão interrompida. Confira os dois dispositivos.';

  @override
  String get failureCertificate =>
      'Falha na verificação. Compare os códigos novamente.';

  @override
  String get failureData => 'Dados inválidos ou versão incompatível';

  @override
  String get failureIntegrity => 'Tamanho ou soma de verificação divergente';

  @override
  String get failureStorage =>
      'Falha de leitura ou gravação. Confira permissões e espaço livre.';

  @override
  String get failureUnexpected => 'Transferência incompleta. Tente novamente.';

  @override
  String get addressRequired => 'Insira um endereço IPv4 e porta';

  @override
  String get addressInvalid => 'Insira um IPv4 válido e uma porta de 1 a 65535';

  @override
  String get language => 'Idioma';

  @override
  String get languageChoice => 'Idioma';

  @override
  String get downloadsLocation => 'Downloads / Dukto2';

  @override
  String get iosLocation => 'Arquivos / Dukto2 / Recebidos';

  @override
  String get transferChannel => 'Transferências de arquivos';

  @override
  String get transferNotification => 'Transferência do Dukto2';

  @override
  String get preparingTransfer => 'Preparando transferência…';

  @override
  String get backgroundExpired =>
      'Tempo em segundo plano esgotado. Volte ao app e envie novamente.';

  @override
  String get notificationCancelled => 'Cancelado pela notificação';

  @override
  String get networkPermission =>
      'O Dukto2 descobre e conecta dispositivos na rede local para transferir arquivos e textos que você escolher enviar ou receber.';

  @override
  String get qrSelf =>
      'Este é o código deste dispositivo. Escaneie o de outro.';

  @override
  String get qrConnecting => 'Tentando os endereços do código QR…';

  @override
  String get qrConnectionFailed =>
      'Não foi possível conectar. Confira se o app está aberto, a rede permite comunicação e o QR é válido.';

  @override
  String get showQr => 'Mostrar código QR';

  @override
  String get scanQr => 'Escanear para conectar';

  @override
  String get qrInstructions =>
      'Abra o Dukto2 no outro dispositivo.\nNo mesma rede com sub-redes diferentes, tente o código QR.';

  @override
  String get connectionQr => 'Código QR de conexão';

  @override
  String get qrAfterWifi => 'Conecte à rede para mostrar o QR';

  @override
  String get qrSemantic => 'Código QR de conexão do Dukto2';

  @override
  String get qrVerify =>
      'Na mesma rede, mesmo em sub-redes diferentes, se os dispositivos puderem se comunicar diretamente, toque em “Escanear para conectar” e leia este código QR.';

  @override
  String get cameraUnavailable =>
      'Câmera indisponível. Permita o acesso nas configurações do sistema e reabra o leitor.';

  @override
  String get backToConnection => 'Voltar à conexão';

  @override
  String get qrAim =>
      'Aponte para o QR em “Este dispositivo” no outro aparelho.';

  @override
  String get subnetHint =>
      'O QR funciona entre sub-redes no mesma rede se os dispositivos puderem se comunicar diretamente.';

  @override
  String get qrExpected => 'Escaneie um código QR do Dukto2';

  @override
  String get qrInvalid =>
      'QR inválido. Reabra as informações locais no outro dispositivo.';

  @override
  String get qrUnreachable =>
      'Não foi possível conectar ou verificar. Confira o Dukto2 e a comunicação de rede e escaneie novamente.';

  @override
  String get qrNoCamera =>
      'Nenhuma câmera encontrada. Você pode escolher uma imagem QR.';

  @override
  String get qrCamera => 'Câmera';

  @override
  String get qrChooseImage => 'Escolher imagem QR';

  @override
  String get qrOpenCamera => 'Abrir câmera';

  @override
  String get qrImageNotFound =>
      'Nenhum código QR encontrado. Escolha uma imagem mais nítida.';

  @override
  String get qrImageTooLarge =>
      'Imagem muito grande. Use menos de 20 MiB e 16 megapixels.';

  @override
  String get qrImageUnreadable =>
      'Não foi possível ler a imagem. Escolha PNG, JPEG ou BMP.';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get deviceChecking => 'A verificar ligação…';

  @override
  String get deviceIdentityChanged => 'A identidade do dispositivo mudou';

  @override
  String get deviceOnline => 'Online · Identidade verificada';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String todayTime(String arg0) {
    return 'Hoje $arg0';
  }

  @override
  String yesterdayTime(String arg0) {
    return 'Ontem $arg0';
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
  String get phone => 'Celular';

  @override
  String get tablet => 'Tablet';

  @override
  String get computer => 'Computador';

  @override
  String get device => 'Dispositivo';

  @override
  String incomingOffer(String arg0, String arg1) {
    return '$arg0 quer enviar $arg1';
  }

  @override
  String get batchConsent => 'Confirme uma vez para receber este lote';

  @override
  String get textConsent => 'Receber este texto?';

  @override
  String get fileConsent => 'Receber este arquivo?';

  @override
  String approvalWarning(String arg0) {
    return 'O nome não foi verificado. Aceite apenas conteúdo conhecido. Expira em $arg0 minutos.';
  }

  @override
  String receiveAt(String arg0) {
    return 'Salvar em: $arg0';
  }

  @override
  String get decline => 'Recusar';

  @override
  String get receiveAll => 'Receber tudo';

  @override
  String get receiveText => 'Receber texto';

  @override
  String get receiveFile => 'Receber arquivo';

  @override
  String verifyPeer(String arg0) {
    return 'Verificar $arg0';
  }

  @override
  String get verificationInstructions =>
      'Abra as informações locais no outro dispositivo e compare o código.';

  @override
  String get verificationWarning =>
      'O nome não comprova a identidade. Confira a outra tela antes de confirmar.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirmConnection => 'Códigos iguais, conectar';

  @override
  String get localInfo => 'Informações locais';

  @override
  String get showLocalCode =>
      'Compare este código nas conexões manuais. A leitura verifica a identidade automaticamente.';

  @override
  String get generating => 'Gerando…';

  @override
  String get deviceName => 'Nome do dispositivo';

  @override
  String get preparing => 'Preparando…';

  @override
  String get connectionAddress => 'Endereço de conexão';

  @override
  String get addressWhenConnected => 'Conecte à rede para ver os endereços';

  @override
  String get done => 'Concluído';

  @override
  String get manualConnection => 'Conexão manual';

  @override
  String get findPeerAddress =>
      'Veja o endereço nas informações locais do outro dispositivo.';

  @override
  String get deviceAddress => 'Endereço do dispositivo';

  @override
  String get addressSeparator =>
      'Separe o endereço e a porta com dois-pontos :';

  @override
  String get next => 'Avançar';

  @override
  String get connecting => 'Conectando…';

  @override
  String get connectionFailed =>
      'Não foi possível conectar. Confira o endereço e a rede.';

  @override
  String sendToPeer(String arg0) {
    return 'Enviar para $arg0';
  }

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get settings => 'Configurações';

  @override
  String get thisDevice => 'Este dispositivo';

  @override
  String get discoverable => 'Visível para dispositivos próximos';

  @override
  String get starting => 'Iniciando…';

  @override
  String nearbyDevices(String arg0) {
    return 'Dispositivos próximos: $arg0';
  }

  @override
  String get refreshDevices => 'Atualizar dispositivos';

  @override
  String get findingDevices => 'Buscando dispositivos próximos…';

  @override
  String get noDevices => 'Nenhum dispositivo encontrado';

  @override
  String get verifiedSelected => 'Verificado · Selecionado';

  @override
  String get verifiedOffline => 'Verificado · Desconectado';

  @override
  String get unverified => 'Não verificado';

  @override
  String get receivingContent => 'Recebendo';

  @override
  String get sendingContent => 'Enviar conteúdo';

  @override
  String get directTransfer =>
      'Arquivos e textos são transferidos diretamente entre dispositivos.';

  @override
  String sendTo(String arg0) {
    return 'Enviar para$arg0';
  }

  @override
  String get codeVerified => 'Identidade do dispositivo verificada';

  @override
  String get viewVerification => 'Ver código do dispositivo';

  @override
  String get file => 'Arquivo';

  @override
  String get text => 'Texto';

  @override
  String get betweenDevices =>
      'O conteúdo é transferido apenas entre estes dois dispositivos.';

  @override
  String get encryptedLan => 'LAN direta · Criptografado';

  @override
  String get statusPrefix => 'Concluído';

  @override
  String get preparingIdentity => 'Preparando identidade…';

  @override
  String get noNearbyDevices => 'Nenhum dispositivo próximo';

  @override
  String get selectDevice => 'Selecione um dispositivo para começar';

  @override
  String get sameWifiHint =>
      'Conecte os dois dispositivos ao mesma rede\ne abra o Dukto2 no outro dispositivo.';

  @override
  String get selectVerifyHint => 'Selecione um dispositivo e compare o código.';

  @override
  String get enterAddress => 'Conexão manual';

  @override
  String get textCopied => 'Texto copiado';

  @override
  String get copyFailed => 'Não foi possível copiar. Tente novamente.';

  @override
  String get textContent => 'Conteúdo do texto';

  @override
  String filePreviewHint(String arg0) {
    return 'Apenas prévia. Tamanho total: $arg0. Abra o arquivo para ver todo o texto.';
  }

  @override
  String get textPreviewHint =>
      'Apenas prévia. Copiar texto copia todo o conteúdo.';

  @override
  String get close => 'Fechar';

  @override
  String get openFullText => 'Abrir texto completo';

  @override
  String get copyPreview => 'Copiar prévia';

  @override
  String get copyText => 'Copiar texto';

  @override
  String get emptyClipboard => 'Não há texto na área de transferência';

  @override
  String get editorLimit =>
      'O editor aceita 1 MiB. Carregue textos maiores de um arquivo (até 16 MiB).';

  @override
  String get clipboardFailed =>
      'Não foi possível ler a área de transferência. Tente novamente.';

  @override
  String get textPlaceholder => 'Digite um texto ou cole um link';

  @override
  String get textFileLoaded =>
      'Texto UTF-8 carregado. O arquivo completo será transmitido.';

  @override
  String get textLimit => 'Até 16 MiB · Requer aprovação';

  @override
  String get textUnsupported =>
      'Este dispositivo não aceita texto. Atualize o aplicativo dele.';

  @override
  String get waitingText => 'Aguardando o destinatário…';

  @override
  String get sendingText => 'Enviando e verificando texto…';

  @override
  String get textSent => 'Texto enviado e verificado';

  @override
  String get textCancelled => 'Envio cancelado. Texto mantido.';

  @override
  String get pasteText => 'Colar texto';

  @override
  String get moreTextActions => 'Mais ações de texto';

  @override
  String get loadTextFile => 'Carregar arquivo de texto';

  @override
  String get clearText => 'Limpar conteúdo';

  @override
  String get cancelTransfer => 'Cancelar transferência';

  @override
  String get sendText => 'Enviar texto';

  @override
  String get send => 'Enviar';

  @override
  String get chooseFileHint => 'Escolha arquivos para enviar';

  @override
  String get approvalBeforeTransfer =>
      'A transferência começa após a aprovação';

  @override
  String get picking => 'Escolhendo…';

  @override
  String get chooseFiles => 'Escolher arquivos';

  @override
  String get multiSelectHint => 'Seleção múltipla · Envio em ordem';

  @override
  String get waitingBatch => 'Aguardando envio do lote…';

  @override
  String get waitingUpload => 'Aguardando o remetente…';

  @override
  String get verifyingFile => 'Verificando arquivo…';

  @override
  String get receiving => 'Recebendo';

  @override
  String get ready => 'Pronto';

  @override
  String get waitingReceiver => 'Aguardando aprovação';

  @override
  String get sending => 'Enviando';

  @override
  String get waitingVerification => 'Aguardando verificação…';

  @override
  String get sentVerified => 'Enviado e verificado';

  @override
  String get sendCancelled => 'Envio cancelado';

  @override
  String get sendFailedRetry => 'Falha no envio. Tente novamente.';

  @override
  String get batchSent => 'Todos os arquivos enviados e verificados';

  @override
  String batchCurrent(String arg0, String arg1, String arg2) {
    return 'Arquivo $arg0 / $arg1 · $arg2';
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
      other: '$arg0 arquivos',
      one: '$arg0 arquivo',
    );
    return '$_temp0';
  }

  @override
  String get removeFiles => 'Remover arquivos selecionados';

  @override
  String fileSummary(String arg0, String arg1, String arg2) {
    return '$arg0 · $arg1$arg2';
  }

  @override
  String removeFile(String arg0) {
    return 'Remover $arg0';
  }

  @override
  String get receiveProgress => 'Progresso do recebimento';

  @override
  String get sendProgress => 'Progresso do envio';

  @override
  String get sendOtherFiles => 'Enviar outros arquivos';

  @override
  String get chooseAgain => 'Escolher novamente';

  @override
  String get continueSending => 'Continuar';

  @override
  String get resend => 'Reenviar';

  @override
  String get sendFiles => 'Enviar arquivos';

  @override
  String get recentTransfers => 'Transferências recentes';

  @override
  String get allDevices => 'Todos os dispositivos';

  @override
  String get otherDevice => 'Outro dispositivo';

  @override
  String get emptyHistory => 'Arquivos e textos concluídos aparecerão aqui.';

  @override
  String get textMessage => 'Mensagem de texto';

  @override
  String get received => 'Recebido';

  @override
  String get sent => 'Enviado';

  @override
  String durationLabel(String arg0) {
    return 'Duração: $arg0';
  }

  @override
  String get viewText => 'Ver texto';

  @override
  String get openFolderHint => 'Abrir pasta do arquivo local';

  @override
  String get noLocalFile => 'Local do arquivo indisponível';

  @override
  String get openFolder => 'Abrir pasta';

  @override
  String get about => 'Sobre o Dukto2';

  @override
  String get aboutTribute =>
      'Uma homenagem ao Dukto e ao seu criador Emanuele Colombo. Obrigado a xuzhen e à comunidade pela manutenção contínua.';

  @override
  String get aboutAi =>
      'Código, interface, testes e documentação criados com OpenAI Codex sob orientação humana.';

  @override
  String get aboutProject =>
      'Uma reescrita independente que mantém a experiência simples e direta do Dukto.';

  @override
  String get licenses => 'Licenças de terceiros';

  @override
  String get notificationsAllowed => 'Notificações permitidas';

  @override
  String get notificationsDenied => 'Notificações desativadas';

  @override
  String get notificationsUndetermined => 'Ainda não autorizado';

  @override
  String get notificationsManaged => 'Notificações gerenciadas pelo sistema';

  @override
  String get notificationsUnavailable => 'Status de notificações indisponível';

  @override
  String get notificationsChecking => 'Verificando notificações…';

  @override
  String get folderBusy =>
      'Não é possível mudar a pasta durante uma transferência.';

  @override
  String get receiveLocation => 'Local de recebimento';

  @override
  String get changeFolder => 'Mudar pasta';

  @override
  String get restoreDefault => 'Restaurar padrão';

  @override
  String get readingDeviceName => 'Lendo nome do dispositivo…';

  @override
  String get notifications => 'Notificações';

  @override
  String get completionNotifications => 'Notificações de conclusão';

  @override
  String get allowNotifications => 'Permitir notificações';

  @override
  String get systemNotificationSettings => 'Configurações de notificações';

  @override
  String get ongoingNotificationHint =>
      'A notificação da transferência em andamento continua ativa.';

  @override
  String get appearance => 'Aparência';

  @override
  String get followSystem => 'Seguir o sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get chooseFolder => 'Escolher pasta de recebimento';

  @override
  String get appStorage => 'Armazenamento do aplicativo';

  @override
  String get backgroundIos =>
      'Mantenha o aplicativo em primeiro plano. Trocar de app ou bloquear a tela pode interromper a transferência.';

  @override
  String get backgroundAndroid =>
      'Transferências aprovadas podem continuar em segundo plano. Não force a parada do aplicativo.';

  @override
  String get backgroundDesktop =>
      'Mantenha o aplicativo aberto e evite a suspensão durante transferências.';

  @override
  String get backgroundStopped => 'Transferência em segundo plano interrompida';

  @override
  String get downloadsUnavailable => 'Pasta Downloads indisponível';

  @override
  String get discoveryUnavailable =>
      'Descoberta indisponível. Tente conectar manualmente.';

  @override
  String get readyLan => 'Pronto · Mesma rede';

  @override
  String get startupFailed =>
      'Não foi possível iniciar. Confira as permissões de rede.';

  @override
  String get checkNetworkPermissions =>
      'Confira as permissões de rede e reabra o app';

  @override
  String get networkRecoveryFailed =>
      'Não foi possível restaurar a rede. Atualize novamente.';

  @override
  String get settingsSaveFailed =>
      'Não foi possível salvar as configurações. Tente novamente.';

  @override
  String get notificationRequestFailed =>
      'Não foi possível solicitar permissão. Confira as configurações do sistema.';

  @override
  String get notificationSettingsFailed =>
      'Não foi possível abrir as configurações. Confira as permissões de notificação do Dukto2.';

  @override
  String get receiveComplete => 'Recebimento concluído';

  @override
  String get sendComplete => 'Envio concluído';

  @override
  String receivedVerified(String arg0) {
    return '$arg0 recebido e verificado';
  }

  @override
  String sentContentVerified(String arg0) {
    return '$arg0 enviado e verificado';
  }

  @override
  String get folderUnavailable =>
      'Pasta de recebimento indisponível. Selecione novamente.';

  @override
  String get authorizedFolder => 'Pasta autorizada';

  @override
  String get folderUpdated => 'Local de recebimento atualizado';

  @override
  String get folderChangeFailed =>
      'Não foi possível mudar o local de recebimento';

  @override
  String get folderReset => 'Local padrão de recebimento restaurado';

  @override
  String get folderResetFailed => 'Não foi possível restaurar o local';

  @override
  String receivingName(String arg0) {
    return 'Recebendo $arg0';
  }

  @override
  String get textReceived => 'Texto recebido e verificado';

  @override
  String receivedName(String arg0) {
    return '$arg0 recebido e verificado';
  }

  @override
  String receiveFailed(String arg0) {
    return 'Falha no recebimento: $arg0';
  }

  @override
  String get receiveCancelled => 'Recebimento cancelado';

  @override
  String get waitingFiles => 'Aguardando arquivos';

  @override
  String get newRequest => 'Nova solicitação de recebimento';

  @override
  String get receiveDeclined => 'Recebimento recusado';

  @override
  String receivingBatchName(String arg0) {
    return 'Recebendo arquivo do lote: $arg0';
  }

  @override
  String selectedPeer(String arg0) {
    return 'Selecionado: $arg0';
  }

  @override
  String get receivingFiles => 'Recebendo arquivos';

  @override
  String get sendingFiles => 'Enviando arquivos';

  @override
  String sendingName(String arg0) {
    return 'Enviando $arg0';
  }

  @override
  String get fileSizeUnavailable =>
      'Não foi possível ler o tamanho. Baixe o arquivo para este dispositivo primeiro.';

  @override
  String preparingFiles(String arg0) {
    return 'Preparando $arg0';
  }

  @override
  String get filePickerFailed => 'Não foi possível escolher arquivos';

  @override
  String get textFileLimit => 'Escolha um arquivo UTF-8 de até 16 MiB';

  @override
  String get textLoadFailed =>
      'Não foi possível carregar o texto. Confira o arquivo e a codificação UTF-8.';

  @override
  String waitingPeerFile(String arg0, String arg1) {
    return 'Aguardando $arg0 aceitar $arg1…';
  }

  @override
  String sendingBatchIndex(String arg0, String arg1) {
    return 'Enviando arquivo $arg0 / $arg1';
  }

  @override
  String waitingPeer(String arg0) {
    return 'Aguardando $arg0 aceitar…';
  }

  @override
  String sentName(String arg0) {
    return '$arg0 enviado e verificado';
  }

  @override
  String sendFailed(String arg0) {
    return 'Falha no envio: $arg0';
  }

  @override
  String get canResend => 'Você pode enviar novamente';

  @override
  String get fileMissing => 'Arquivo movido ou excluído';

  @override
  String get folderOpenUnavailable =>
      'Não foi possível abrir a pasta do arquivo';

  @override
  String get folderOpenFailed => 'Não foi possível abrir a pasta';

  @override
  String savedCopy(String arg0) {
    return 'Cópia de $arg0 salva';
  }

  @override
  String get finderFailed => 'Não foi possível mostrar o arquivo no Finder';

  @override
  String get exportFailed => 'Não foi possível exportar o arquivo';

  @override
  String get failurePlatform =>
      'Não foi possível iniciar a transferência. Confira as permissões.';

  @override
  String get failureCancelled => 'Transferência cancelada';

  @override
  String get failureDeclined =>
      'O destinatário recusou ou o prazo de aprovação expirou';

  @override
  String get failureBusy => 'O destinatário está ocupado. Tente mais tarde.';

  @override
  String get failureExpired => 'Transferência expirada. Envie novamente.';

  @override
  String get failureTimeout =>
      'Tempo limite de conexão ou transferência. Confira a rede.';

  @override
  String get failureNetwork =>
      'Conexão interrompida. Confira os dois dispositivos.';

  @override
  String get failureCertificate =>
      'Falha na verificação. Compare os códigos novamente.';

  @override
  String get failureData => 'Dados inválidos ou versão incompatível';

  @override
  String get failureIntegrity => 'Tamanho ou soma de verificação divergente';

  @override
  String get failureStorage =>
      'Falha de leitura ou gravação. Confira permissões e espaço livre.';

  @override
  String get failureUnexpected => 'Transferência incompleta. Tente novamente.';

  @override
  String get addressRequired => 'Insira um endereço IPv4 e porta';

  @override
  String get addressInvalid => 'Insira um IPv4 válido e uma porta de 1 a 65535';

  @override
  String get language => 'Idioma';

  @override
  String get languageChoice => 'Idioma';

  @override
  String get downloadsLocation => 'Downloads / Dukto2';

  @override
  String get iosLocation => 'Arquivos / Dukto2 / Recebidos';

  @override
  String get transferChannel => 'Transferências de arquivos';

  @override
  String get transferNotification => 'Transferência do Dukto2';

  @override
  String get preparingTransfer => 'Preparando transferência…';

  @override
  String get backgroundExpired =>
      'Tempo em segundo plano esgotado. Volte ao app e envie novamente.';

  @override
  String get notificationCancelled => 'Cancelado pela notificação';

  @override
  String get networkPermission =>
      'O Dukto2 descobre e conecta dispositivos na rede local para transferir arquivos e textos que você escolher enviar ou receber.';

  @override
  String get qrSelf =>
      'Este é o código deste dispositivo. Escaneie o de outro.';

  @override
  String get qrConnecting => 'Tentando os endereços do código QR…';

  @override
  String get qrConnectionFailed =>
      'Não foi possível conectar. Confira se o app está aberto, a rede permite comunicação e o QR é válido.';

  @override
  String get showQr => 'Mostrar código QR';

  @override
  String get scanQr => 'Escanear para conectar';

  @override
  String get qrInstructions =>
      'Abra o Dukto2 no outro dispositivo.\nNo mesma rede com sub-redes diferentes, tente o código QR.';

  @override
  String get connectionQr => 'Código QR de conexão';

  @override
  String get qrAfterWifi => 'Conecte à rede para mostrar o QR';

  @override
  String get qrSemantic => 'Código QR de conexão do Dukto2';

  @override
  String get qrVerify =>
      'Na mesma rede, mesmo em sub-redes diferentes, se os dispositivos puderem se comunicar diretamente, toque em “Escanear para conectar” e escaneie este código QR.';

  @override
  String get cameraUnavailable =>
      'Câmera indisponível. Permita o acesso nas configurações do sistema e reabra o leitor.';

  @override
  String get backToConnection => 'Voltar à conexão';

  @override
  String get qrAim =>
      'Aponte para o QR em “Este dispositivo” no outro aparelho.';

  @override
  String get subnetHint =>
      'O QR funciona entre sub-redes no mesma rede se os dispositivos puderem se comunicar diretamente.';

  @override
  String get qrExpected => 'Escaneie um código QR do Dukto2';

  @override
  String get qrInvalid =>
      'QR inválido. Reabra as informações locais no outro dispositivo.';

  @override
  String get qrUnreachable =>
      'Não foi possível conectar ou verificar. Confira o Dukto2 e a comunicação de rede e escaneie novamente.';

  @override
  String get qrNoCamera =>
      'Nenhuma câmera encontrada. Você pode escolher uma imagem QR.';

  @override
  String get qrCamera => 'Câmera';

  @override
  String get qrChooseImage => 'Escolher imagem QR';

  @override
  String get qrOpenCamera => 'Abrir câmera';

  @override
  String get qrImageNotFound =>
      'Nenhum código QR encontrado. Escolha uma imagem mais nítida.';

  @override
  String get qrImageTooLarge =>
      'Imagem muito grande. Use menos de 20 MiB e 16 megapixels.';

  @override
  String get qrImageUnreadable =>
      'Não foi possível ler a imagem. Escolha PNG, JPEG ou BMP.';

  @override
  String get deviceOffline => 'Offline';

  @override
  String get deviceChecking => 'Verificando conexão…';

  @override
  String get deviceIdentityChanged => 'A identidade do dispositivo mudou';

  @override
  String get deviceOnline => 'Online · Identidade verificada';
}
