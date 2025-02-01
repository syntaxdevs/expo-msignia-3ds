import UIKit
import uSDK

class ExpoMsignia3dsViewController: UIViewController {
    private var splitSdkClient: SplitSdkClient = SplitSdkClientImpl()
    
    // Closure para enviar la respuesta al módulo
    var onCompletion: (([String: Any]) -> Void)?

    // Variables para almacenar los parámetros
    private var userId: String
    private var cardId: String
    private var orderId: String
    private var exchangeTransactionDetailsUrl: String
    private var transactionResultUrl: String
    private var splitSdkServerUrl: String

    // Objeto del servicio 3DS (asegúrate de que esté correctamente inicializado)
    private var threeDS2Service: ThreeDS2Service!

    // Inicializador con los parámetros
    init(
        userId: String, 
        cardId: String, orderId: String, 
        exchangeTransactionDetailsUrl: String, 
        transactionResultUrl: String, 
        splitSdkServerUrl: String
    ) {
        self.userId = userId
        self.cardId = cardId
        self.orderId = orderId
        self.exchangeTransactionDetailsUrl = exchangeTransactionDetailsUrl
        self.transactionResultUrl = transactionResultUrl
        self.splitSdkServerUrl = splitSdkServerUrl
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        do {
            let spec = InitializeSpec() // Asegúrate de que esté correctamente configurado
            try splitSdkClient.initialize(spec: spec) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    NSLog("SDK initialized successfully!")
                    self.authenticate(self)

                case .failure(let error):
                    self.onCompletion?([
                        "msg": "Failed to initialize SDK: \(error)",  
                        "code": "",                           
                        "error": true                              
                    ])
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } catch {
            self.onCompletion?([
                "msg": "Error during SDK initialization: \(error.localizedDescription)",  
                "code": "",                           
                "error": true                              
            ])
            dismiss(animated: true, completion: nil)
        }
    }

    // Función @IBAction para manejar la autenticación
    @IBAction func authenticate(_ sender: Any) {
        do {                
             let authSpec = AuthenticateSpec(
                viewController: self,
                cardId: self.cardId,
                orderId: self.orderId,
                exchangeTransactionDetailsUrl:  self.exchangeTransactionDetailsUrl,
                transactionResultUrl: self.transactionResultUrl ,
                splitSdkServerUrl:  self.splitSdkServerUrl,
                userId: self.userId
             )

              do {
                    NSLog("SDK authenticate...")
                    // Usamos el servicio para autenticar
                    try splitSdkClient.authenticate(spec: authSpec) { result in
                      switch result {
                      case .success(let authResult):
                            NSLog("Authenticated response:")
                            switch authResult {
                                case .authenticated(let authenticationResult):
                                    NSLog("authenticated: \(authenticationResult)")
                                    self.onCompletion?([
                                        "msg": "\(authenticationResult)",  
                                        "code": "AUTHENTICATED",                           
                                        "error": false                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)

                                case .notAuthenticated(let authenticationResult):
                                    NSLog("notAuthenticated: \(authenticationResult)")
                                    self.onCompletion?([
                                        "msg": "\(authenticationResult)",  
                                        "code": "NOT_AUTHENTICATED",                           
                                        "error": true                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)

                                case .cancelled(let authenticationResult):
                                    NSLog("cancelled: \(authenticationResult)")
                                    self.onCompletion?([
                                        "msg": "\(authenticationResult)",  
                                        "code": "CANCELLED",                           
                                        "error": true                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)

                                case .decoupledAuthBeingPerformed(let authenticationResult):
                                    NSLog("decoupledAuthBeingPerformed: \(authenticationResult)")
                                    self.onCompletion?([
                                        "msg": "\(authenticationResult)",  
                                        "code": "DECOUPLED_AUTH_BEGIN_PERFORMED",                           
                                        "error": true                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)

                                case .error(let authenticationResult):
                                    NSLog("notAuthenticated: \(authenticationResult)")
                                    self.onCompletion?([
                                        "msg": "\(authenticationResult)",  
                                        "code": "ERROR",                           
                                        "error": true                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)

                                @unknown default:
                                    NSLog("Unknown authentication result")
                                    self.onCompletion?([
                                        "msg": "Unknown authentication result",  
                                        "code": "",                           
                                        "error": true                              
                                    ])
                                    self.dismiss(animated: true, completion: nil)
                          }
                      case .failure(let error):
                        NSLog("Authentication failed: \(error)")
                        self.onCompletion?([
                            "msg": "Authentication failed: \(error)",  
                            "code": "",                           
                            "error": true                              
                        ])
                        self.dismiss(animated: true, completion: nil)
                      }
                  }
              } catch {
                    NSLog("Error during authentication: \(error)")
                    self.onCompletion?([
                        "msg": "Error during authentication: \(error)",  
                        "code": "",                           
                        "error": true                              
                    ])
                    self.dismiss(animated: true, completion: nil)
              }
       
        } catch {
            NSLog("An exception caught during `authenticate` call")
            self.onCompletion?([
                "msg": "An exception caught during `authenticate` call",  
                "code": "",                           
                "error": true                              
            ])
            self.dismiss(animated: true, completion: nil)
        }
    }
}