package expo.modules.msignia3ds

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import android.util.Log

import expo.modules.kotlin.Promise

import  com.usdk.android.SplitSdkClient
import  com.usdk.android.SplitSdkClientImpl
import  com.usdk.android.AuthenticateCallback
import  com.usdk.android.InitializeCallback
import  com.usdk.android.AuthenticationResult
import  com.usdk.android.AuthenticateSpec
import  com.usdk.android.InitializeSpec

class ExpoMsignia3dsModule : Module() {

  override fun definition() = ModuleDefinition {

    Name("ExpoMsignia3ds")

    AsyncFunction("setupSession") { userId: String, cardId: String, orderId: String, promise: Promise ->
      val activity = appContext.activityProvider?.currentActivity
      if (activity == null) {
        promise.reject("AUTHENTICATION_ERROR", "No Activity available for authentication", null)
        return@AsyncFunction
      }

      val splitSdkClient: SplitSdkClient = SplitSdkClientImpl()

      // Verificar y realizar inicialización si es necesario
      try {
        val initializeSpec = InitializeSpec(activity) // Usar la actividad actual
        splitSdkClient.initialize(initializeSpec, object : InitializeCallback {
          override fun onSuccess() {
            Log.i("ExpoMsignia3ds", "SDK inicializado correctamente, procediendo a autenticar")

            val splitSdkServerUrl = "https://emv3ds.elrosado.com"
            val exchangeTransactionDetailsUrl = "https://3ds.hercules.ec:50002/api/Transaction/Exchange"
            val transactionResultUrl = "https://3ds.hercules.ec:50002/api/Transaction/Result"

            // Proceder con la autenticación después de la inicialización
            val authSpec = AuthenticateSpec().apply {
              setActivity(activity)
              setUserId(userId)
              setCardId(cardId)
              setOrderId(orderId)
              setSplitSdkServerUrl(splitSdkServerUrl)
              setExchangeTransactionDetailsUrl(exchangeTransactionDetailsUrl)
              setTransactionResultUrl(transactionResultUrl)
            }

            splitSdkClient.authenticate(authSpec, object : AuthenticateCallback {
              override fun authenticated(authenticationResult: AuthenticationResult) {
                Log.i("ExpoMsignia3ds", "authenticated: $authenticationResult")
                promise.resolve("Authentication successful")
              }

              override fun notAuthenticated(authenticationResult: AuthenticationResult) {
                Log.i("ExpoMsignia3ds", "notAuthenticated: $authenticationResult")
                promise.resolve("Authentication failed")
              }

              override fun decoupledAuthBeingPerformed(authenticationResult: AuthenticationResult) {
                Log.i("ExpoMsignia3ds", "decoupledAuthBeingPerformed: $authenticationResult")
                promise.resolve("Decoupled authentication in progress")
              }

              override fun cancelled(authenticationResult: AuthenticationResult) {
                Log.i("ExpoMsignia3ds", "cancelled: $authenticationResult")
                promise.resolve("Authentication cancelled")
              }

              override fun error(authenticationResult: AuthenticationResult) {
                Log.i("ExpoMsignia3ds", "error: $authenticationResult")
                promise.reject(
                  "AUTHENTICATION_ERROR",
                  "Authentication error", null
                )
              }
            })
          }

          override fun onFailure(e: Exception) {
            Log.e("ExpoMsignia3ds", "Error al inicializar el SDK", e)
            promise.reject("SDK_INITIALIZATION_ERROR", "Failed to initialize SDK: ${e.message}", e)
          }
        })
      } catch (e: Exception) {
        Log.e("ExpoMsignia3ds", "Error during SDK initialization", e)
        promise.reject("SDK_INITIALIZATION_ERROR", "Error during SDK initialization: ${e.message}", e)
      }
    }

  }
}
