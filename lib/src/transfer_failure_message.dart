import 'package:dukto2_core/dukto2_core.dart';

String transferFailureMessage(TransferFailure failure) =>
    switch (failure.kind) {
      TransferFailureKind.platform => '系统未能启动传输，请检查应用权限后重试',
      TransferFailureKind.cancelled => '传输已取消',
      TransferFailureKind.declined => '对方未同意接收，或确认已超时',
      TransferFailureKind.busy => '对方正在处理其他传输，请稍后重试',
      TransferFailureKind.expired => '本次传输已过期，请重新发送',
      TransferFailureKind.timeout => '连接或传输超时，请检查网络后重试',
      TransferFailureKind.network => '网络连接中断，请检查设备连接',
      TransferFailureKind.certificate => '设备身份核验失败，请重新核对设备',
      TransferFailureKind.invalidData => '传输数据无效或版本不兼容',
      TransferFailureKind.integrity => '文件大小或校验不一致，请重新发送',
      TransferFailureKind.storage => '无法读写文件，请检查目录权限和可用空间',
      TransferFailureKind.unexpected => '传输未完成，请稍后重试',
    };
