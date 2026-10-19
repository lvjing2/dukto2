import 'localization.dart';

import 'package:dukto2_core/dukto2_core.dart';

String transferFailureMessage(
  TransferFailure failure, {
  AppLocalizations? localization,
}) {
  final messages = localization ?? fallbackMessages;
  return switch (failure.kind) {
    TransferFailureKind.platform => messages.failurePlatform,
    TransferFailureKind.cancelled => messages.failureCancelled,
    TransferFailureKind.declined => messages.failureDeclined,
    TransferFailureKind.busy => messages.failureBusy,
    TransferFailureKind.expired => messages.failureExpired,
    TransferFailureKind.timeout => messages.failureTimeout,
    TransferFailureKind.network => messages.failureNetwork,
    TransferFailureKind.certificate => messages.failureCertificate,
    TransferFailureKind.invalidData => messages.failureData,
    TransferFailureKind.integrity => messages.failureIntegrity,
    TransferFailureKind.storage => messages.failureStorage,
    TransferFailureKind.unexpected => messages.failureUnexpected,
  };
}
