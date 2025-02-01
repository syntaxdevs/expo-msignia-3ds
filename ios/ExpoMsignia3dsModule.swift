import ExpoModulesCore
import UIKit

public class ExpoMsignia3dsModule: Module {
 
  public func definition() -> ModuleDefinition {
    Name("ExpoMsignia3ds")

    Events("onSdkInitialized")

    // Eventos que pueden ser escuchados desde JS
    Events("onSplitSdkInitialized", "onSplitSdkError")


    // Definir la función asincrónica que maneja la inicialización
    AsyncFunction("setupSession") { (
        userId: String, 
        cardId: String, 
        orderId: String, 
        exchangeTransactionDetailsUrl: String, 
        transactionResultUrl: String, 
        splitSdkServerUrl: String
      ) in await self.presentMsignia3dsViewController(
        userId: userId, 
        cardId: cardId, 
        orderId: orderId,  
        exchangeTransactionDetailsUrl: exchangeTransactionDetailsUrl, 
        transactionResultUrl: transactionResultUrl, 
        splitSdkServerUrl: splitSdkServerUrl
    )}
  }

  // Función asincrónica para presentar el ViewController
  func presentMsignia3dsViewController(
      userId: String, 
      cardId: String, 
      orderId: String,  
      exchangeTransactionDetailsUrl: String, 
      transactionResultUrl: String, 
      splitSdkServerUrl: String
    ) async ->  [String: Any] {
    return await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        if let rootViewController = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first?.windows
          .first(where: { $0.isKeyWindow })?.rootViewController {
            
          let viewController = ExpoMsignia3dsViewController(
            userId: userId, 
            cardId: cardId,
            orderId: orderId,
            exchangeTransactionDetailsUrl: exchangeTransactionDetailsUrl, 
            transactionResultUrl: transactionResultUrl, 
            splitSdkServerUrl: splitSdkServerUrl
          )
          
          // Flag para evitar múltiples llamadas
          var hasResumed = false

          // Establecer el closure de finalización para cuando el ViewController termine
          viewController.onCompletion = { result in
            guard !hasResumed else { return } // Evita llamadas duplicadas
            hasResumed = true

            // Llamamos a la continuación con el resultado del ViewController
            continuation.resume(returning: result)
          }

          // Presentamos el ViewController a pantalla completa
          viewController.modalPresentationStyle = .fullScreen
          // viewController.modalTransitionStyle = .coverVertical // Deslizar hacia arriba

          // // Presentamos el ViewController como una hoja
          // viewController.modalPresentationStyle = .pageSheet
          // viewController.sheetPresentationController?.detents = [ .large()]
          // viewController.sheetPresentationController?.prefersGrabberVisible = false

          // Presentamos el ViewController
          rootViewController.present(viewController, animated: true, completion: nil)
         
        } else {
          // Si no conseguimos el rootViewController, llamamos a la continuación con un error
          continuation.resume(returning: [
            "msg": "Failed to retrieve root view controller",
            "code": "",
            "error": true
          ])
        }
      }
    }
  }
}
