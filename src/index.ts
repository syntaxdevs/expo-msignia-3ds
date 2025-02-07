// Reexport the native module. On web, it will be resolved to ExpoMsignia3dsModule.web.ts
// and on native platforms to ExpoMsignia3dsModule.ts

import ExpoMsignia3dsModule from "./ExpoMsignia3dsModule";


// Inicializar y autenticar el SDK
export async function setupSession(
  userId: string,
  cardId: string,
  orderId: string,
  exchangeTransactionDetailsUrl: string,
  transactionResultUrl: string,
  splitSdkServerUrl: string
): Promise<{ msg: string; code: string; error: boolean, result: string }> {
  return await ExpoMsignia3dsModule.setupSession(
    userId,
    cardId,
    orderId,
    exchangeTransactionDetailsUrl,
    transactionResultUrl,
    splitSdkServerUrl);
}

