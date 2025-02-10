package expo.modules.msignia3ds

import android.util.Log
import com.usdk.android.AuthenticateCallback
import com.usdk.android.AuthenticateSpec
import com.usdk.android.AuthenticationResult
import com.usdk.android.InitializeCallback
import com.usdk.android.InitializeSpec
import com.usdk.android.SplitSdkClient
import com.usdk.android.SplitSdkClientImpl
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class ExpoMsignia3dsModule : Module() {
    override fun definition() =
        ModuleDefinition {
            Name("ExpoMsignia3ds")

            // Correct the AsyncFunction signature to explicitly define the params and promise types
            AsyncFunction("setupSession") {
                userId: String,
                cardId: String,
                orderId: String,
                exchangeTransactionDetailsUrl: String,
                transactionResultUrl: String,
                splitSdkServerUrl: String,
                promise: Promise,
                ->

                val activity = appContext.activityProvider?.currentActivity
                if (activity == null) {
                    promise.resolve(
                        createResponseMap("No Activity available for authentication", "", true, null),
                    )
                    return@AsyncFunction
                }

                val splitSdkClient: SplitSdkClient = SplitSdkClientImpl()

                try {
                    val initializeSpec = InitializeSpec(activity) // Use the current activity
                    splitSdkClient.initialize(
                        initializeSpec,
                        object : InitializeCallback {
                            override fun onSuccess() {
                                Log.i("ExpoMsignia3ds", "SDK initialized successfully, proceeding with authentication")

                                // Proceed with authentication after initialization
                                val authSpec =
                                    AuthenticateSpec().apply {
                                        setActivity(activity)
                                        setUserId(userId)
                                        setCardId(cardId)
                                        setOrderId(orderId)
                                        setSplitSdkServerUrl(splitSdkServerUrl)
                                        setExchangeTransactionDetailsUrl(exchangeTransactionDetailsUrl)
                                        setTransactionResultUrl(transactionResultUrl)
                                    }

                                splitSdkClient.authenticate(
                                    authSpec,
                                    object : AuthenticateCallback {
                                        override fun authenticated(authenticationResult: AuthenticationResult) {
                                            Log.i("ExpoMsignia3ds", "authenticated: $authenticationResult")
                                            promise.resolve(
                                                createResponseMap("Authenticated successfully", "AUTHENTICATED", false, null),
                                            )
                                        }

                                        override fun notAuthenticated(authenticationResult: AuthenticationResult) {
                                            Log.i("ExpoMsignia3ds", "notAuthenticated: $authenticationResult")
                                            promise.resolve(
                                                createResponseMap("Not authenticated", "NOT_AUTHENTICATED", true, null),
                                            )
                                        }

                                        override fun decoupledAuthBeingPerformed(authenticationResult: AuthenticationResult) {
                                            Log.i("ExpoMsignia3ds", "decoupledAuthBeingPerformed: $authenticationResult")
                                            promise.resolve(
                                                createResponseMap(
                                                    "Decoupled auth in progress",
                                                    "DECOUPLED_AUTH_BEGIN_PERFORMED",
                                                    true,
                                                    null,
                                                ),
                                            )
                                        }

                                        override fun cancelled(authenticationResult: AuthenticationResult) {
                                            Log.i("ExpoMsignia3ds", "cancelled: $authenticationResult")
                                            promise.resolve(
                                                createResponseMap("Authentication cancelled", "CANCELLED", true, null),
                                            )
                                        }

                                        override fun error(authenticationResult: AuthenticationResult) {
                                            Log.i("ExpoMsignia3ds", "error: $authenticationResult")
                                            val resultMap = convertToJsonDictionary(authenticationResult)

                                            promise.resolve(
                                                createResponseMap("Authentication error", "ERROR", true, resultMap),
                                            )
                                        }
                                    },
                                )
                            }

                            override fun onFailure(e: Exception) {
                                Log.e("ExpoMsignia3ds", "Error initializing SDK", e)
                                promise.resolve(
                                    createResponseMap("Failed to initialize SDK: ${e.message}", "", true, null),
                                )
                            }
                        },
                    )
                } catch (e: Exception) {
                    Log.e("ExpoMsignia3ds", "Error during SDK initialization", e)
                    promise.resolve(
                        createResponseMap("Error during SDK initialization: ${e.message}", "", true, null),
                    )
                }
            }
        }

    private fun createResponseMap(
        msg: String,
        code: String,
        error: Boolean,
        result: Map<String, Any>?,
    ): Map<String, Any> {
        val resultMap = result ?: emptyMap<String, Any>()
        return mapOf(
            "msg" to msg,
            "code" to code,
            "error" to error,
            "result" to resultMap,
        )
    }

    private fun convertToJsonDictionary(authenticationResult: AuthenticationResult): Map<String, Any> {
        val errorDetails =
            authenticationResult.error?.let { error ->
                mapOf(
                    "errorCode" to (error.errorCode ?: ""),
                    "errorDescription" to (error.message ?: ""), // Usa `message` si `getErrorDescription()` no existe
                    "errorDetails" to (error.toString()), // O usa `toString()` para ver todos los detalles
                )
            } ?: emptyMap()

        return mapOf(
            "threeDSServerTransID" to (authenticationResult.threeDSServerTransID ?: ""),
            "splitSdkServerTransID" to (authenticationResult.splitSdkServerTransID ?: ""),
            "status" to (authenticationResult.status?.name ?: ""), // Convierte enum a String
            "cardholderInfo" to (authenticationResult.cardholderInfo ?: ""),
            "error" to errorDetails,
        )
    }
}
