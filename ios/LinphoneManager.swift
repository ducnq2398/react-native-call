import Foundation

protocol Callback {
  func send(message: String)
}

class LinphoneManager: NSObject {
   
  
    static let shared = LinphoneManager()
    
    private var linphoneCore: OpaquePointer?
    private var linphoneLoggingService: OpaquePointer?
    private static var iterateTimer: Timer?
    private var configLinphone: OpaquePointer?
    private var currentCall: OpaquePointer?
    private  var loginInfo: NSDictionary?
  
    private static var eventEmitter: SipCall!
  
    public override init() {
      
    }
    func registerEventEmitter(eventEmitter: SipCall) {
      LinphoneManager.eventEmitter = eventEmitter
    }
  
      func dispatch(message: String) {
        LinphoneManager.eventEmitter.sendEvent(withName: "SipCall", body: message)
      }

      /// All Events which must be support by React Native.
      lazy var allEvents: [String] = {
          var allEventNames: [String] = []

          // Append all events here
          
          return allEventNames
      }()

  

    private let registrationStateChanged: LinphoneCoreRegistrationStateChangedCb  = {
        (lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) in

        LinphoneManager.shared.registrationStateChanged(lc: lc, proxyConfig: proxyConfig, state: state, message: message)
    } as LinphoneCoreRegistrationStateChangedCb

    private let callStateChanged: LinphoneCoreCallStateChangedCb = {
        (lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, state: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) in

        LinphoneManager.shared.callStateChanged(lc: lc, call: call, state: state, message: message)
    }

    private func registrationStateChanged(lc: Optional<OpaquePointer>, proxyConfig: Optional<OpaquePointer>, state: LinphoneRegistrationState, message: Optional<UnsafePointer<Int8>>) {
        var stateMessage = ""
        if let message = message {
            stateMessage = String(cString: message)
        }
        
        switch state{
        case LinphoneRegistrationNone:
            print("registrationStateChanged -> LinphoneRegistrationNone -> \(stateMessage)")
          dispatch(message: "RegistrationState.None")
        case LinphoneRegistrationProgress:
            print("registrationStateChanged -> LinphoneRegistrationProgress -> \(stateMessage)")
          dispatch(message: "RegistrationState.Progress")
        case LinphoneRegistrationOk:
            print("registrationStateChanged -> LinphoneRegistrationOk -> \(stateMessage)")
          dispatch(message: "RegistrationState.Ok")
        case LinphoneRegistrationCleared:
            print("registrationStateChanged -> LinphoneRegistrationCleared -> \(stateMessage)")
          dispatch(message: "RegistrationState.Cleared")
        case LinphoneRegistrationFailed:
            print("registrationStateChanged -> LinphoneRegistrationFailed -> \(stateMessage)")
          dispatch(message: "RegistrationState.Failed")
        default:
            return
        }
    }
    
    private func callStateChanged(lc: Optional<OpaquePointer>, call: Optional<OpaquePointer>, state: LinphoneCallState,  message: Optional<UnsafePointer<Int8>>) {
        var stateMessage = ""
        if let message = message {
            stateMessage = String(cString: message)
        }
        switch state {
        case LinphoneCallStateIdle:
            print("callStateChanged -> LinphoneCallStateIdle -> \(stateMessage)")
          dispatch(message: "Call.State.Idle")
        case LinphoneCallStateIncomingReceived:
            print("callStateChanged -> LinphoneCallStateIncomingReceived -> \(stateMessage)")
            currentCall = call
//            ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
//            linphone_call_accept(call)
          
          dispatch(message: "Call.State.IncomingReceived")
        case LinphoneCallStateOutgoingInit:
            print("callStateChanged -> LinphoneCallStateOutgoingInit -> \(stateMessage)")
          dispatch(message: "Call.State.OutgoingInit")
        case LinphoneCallStateOutgoingProgress:
            print("callStateChanged -> LinphoneCallStateOutgoingProgress -> \(stateMessage)")
          dispatch(message: "Call.State.OutgoingProgress")
        case LinphoneCallStateOutgoingRinging:
            print("callStateChanged -> LinphoneCallStateOutgoingRinging -> \(stateMessage)")
          dispatch(message: "Call.State.OutgoingRinging")
        case LinphoneCallStateOutgoingEarlyMedia:
            print("callStateChanged -> LinphoneCallStateOutgoingEarlyMedia -> \(stateMessage)")
          dispatch(message: "Call.State.OutgoingEarlyMedia")
        case LinphoneCallStateConnected:
            print("callStateChanged -> LinphoneCallStateConnected -> \(stateMessage)")
          dispatch(message: "Call.State.Connected")
        case LinphoneCallStateStreamsRunning:
            print("callStateChanged -> LinphoneCallStateStreamsRunning -> \(stateMessage)")
          dispatch(message: "Call.State.StreamsRunning")
        case LinphoneCallStatePausing:
            print("callStateChanged -> LinphoneCallStatePausing -> \(stateMessage)")
          dispatch(message: "Call.State.Pausing")
        case LinphoneCallStatePaused:
            print("callStateChanged -> LinphoneCallStatePaused -> \(stateMessage)")
          dispatch(message: "Call.State.Paused")
        case LinphoneCallStateResuming:
            print("callStateChanged -> LinphoneCallStateResuming -> \(stateMessage)")
          dispatch(message: "Call.State.Resuming")
        case LinphoneCallStateReferred:
            print("callStateChanged -> LinphoneCallStateReferred -> \(stateMessage)")
          dispatch(message: "Call.State.Referred")
        case LinphoneCallStateError:
            print("callStateChanged -> LinphoneCallStateError -> \(stateMessage)")
          dispatch(message: "Call.State.Error")
        case LinphoneCallStateEnd:
            print("callStateChanged -> LinphoneCallStateEnd -> \(stateMessage)")
          dispatch(message: "Call.State.End")
        case LinphoneCallStatePausedByRemote:
            print("callStateChanged -> LinphoneCallStatePausedByRemote -> \(stateMessage)")
          dispatch(message: "Call.State.PausedByRemote")
        case LinphoneCallStateUpdatedByRemote:
            print("callStateChanged -> LinphoneCallStateUpdatedByRemote -> \(stateMessage)")
          dispatch(message: "Call.State.UpdatedByRemote")
        case LinphoneCallStateIncomingEarlyMedia:
            print("callStateChanged -> LinphoneCallStateIncomingEarlyMedia -> \(stateMessage)")
          dispatch(message: "Call.State.IncomingEarlyMedia")
        case LinphoneCallStateUpdating:
            print("callStateChanged -> LinphoneCallStateUpdating -> \(stateMessage)")
          dispatch(message: "Call.State.Updating")
        case LinphoneCallStateReleased:
            print("callStateChanged -> LinphoneCallStateReleased -> \(stateMessage)")
          dispatch(message: "Call.State.Released")
        case LinphoneCallStateEarlyUpdatedByRemote:
            print("callStateChanged -> LinphoneCallStateEarlyUpdatedByRemote -> \(stateMessage)")
          dispatch(message: "Call.State.EarlyUpdatedByRemote")
        case LinphoneCallStateEarlyUpdating:
            print("callStateChanged -> LinphoneCallStateEarlyUpdating -> \(stateMessage)")
          dispatch(message: "Call.State.EarlyUpdating")
        default:
            return
        }
    }
  
        
    
  func initialize() {
    linphoneLoggingService = linphone_logging_service_get()
    linphone_logging_service_set_log_level(linphoneLoggingService, LinphoneLogLevelFatal)
    
    let config = linphone_config_new_with_factory("", "")
  
    let factory = linphone_factory_get()
    let callBacks = linphone_factory_create_core_cbs(factory)
    linphone_core_cbs_set_registration_state_changed(callBacks, registrationStateChanged)
    linphone_core_cbs_set_call_state_changed(callBacks, callStateChanged)
    
    linphoneCore = linphone_factory_create_core_with_config_3(factory, config, nil)
    linphone_core_add_callbacks(linphoneCore, callBacks)
    linphone_core_start(linphoneCore)

    linphone_core_cbs_unref(callBacks)
    linphone_config_unref(config)

    }
    
    fileprivate func bundleFile(_ name: String, _ ext: String? = nil) -> String? {
        return Bundle.main.path(forResource: name, ofType: ext)
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    func demo() {
        makeCall()
//        receiveCall()
        idle()
    }
  
    func login(username: String, password: String, domain: String) {
    
      loginInfo = ["username": username, "password": password, "domain": domain]
      guard let _ = setIdentify() else {
          print("no identity")
          return;
      }
      idle()
    }
  
  func call(phone_number: String, user_id: String, call_id: String) {
    guard let _ = setIdentify() else {
        print("no identity")
        return;
    }
      
    let address = linphone_core_interpret_url(linphoneCore, phone_number)
    let params = linphone_core_create_call_params(linphoneCore, nil)
    linphone_call_params_add_custom_header(params, "X-Call-Id", call_id)
    linphone_call_params_add_custom_header(params, "X-User-Id", user_id)
  
    linphone_core_invite_address_with_params(linphoneCore, address, params)
    
    setTimer()
  }
    
    func makeCall(){
        let calleeAccount = "0898572528"
        
        guard let _ = setIdentify() else {
            print("no identity")
            return;
        }
        linphone_event_add_custom_header(linphoneCore, "X-Call-Id", "2bfcf300-6756-4447-b775-57cd3e284458")
        linphone_event_add_custom_header(linphoneCore, "X-User-Id", "111")
        linphone_core_invite(linphoneCore, calleeAccount)
        setTimer()
    }
  
  func accept() {
    linphone_call_accept(currentCall)
  }
  
  func endCall() {
      linphone_core_terminate_all_calls(linphoneCore)
  }
  
  func logout() {
    type(of: self).iterateTimer = nil

    guard let linphoneCore = linphoneCore else { return } // just in case application terminate before linphone core initialization
    
    let config = linphone_core_get_default_proxy_config(linphoneCore)
    linphone_proxy_config_edit(config)
    linphone_proxy_config_enable_register(config, 0)
    linphone_proxy_config_done(config)
    
    while(linphone_proxy_config_get_state(config) != LinphoneRegistrationCleared) {
        linphone_core_iterate(linphoneCore)
        ms_usleep(50000);
    }
    
    linphone_core_unref(linphoneCore)
  }
    
    func receiveCall(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
    }
    
    func idle(){
        guard let proxyConfig = setIdentify() else {
            print("no identity")
            return;
        }
        register(proxyConfig)
        setTimer()
    }
    
    func setIdentify() -> OpaquePointer? {

        let username = loginInfo?["username"] as! String
        let password = loginInfo?["password"] as! String
        let domain = loginInfo?["domain"] as! String

        
        let identity = "sip:" + username + "@" + domain
            
        guard let temp_address = linphone_address_new(identity) else {
            print("\(identity) not a valid sip uri, must be like sip:toto@sip.linphone.org")
            return nil
        }

        let address = linphone_address_new(nil)
        linphone_address_set_username(address, linphone_address_get_username(temp_address))
        linphone_address_set_domain(address, linphone_address_get_domain(temp_address))
        linphone_address_set_port(address, linphone_address_get_port(temp_address))
        linphone_address_set_transport(address, linphone_address_get_transport(temp_address))
        
        let config = linphone_core_create_proxy_config(linphoneCore)
        linphone_proxy_config_set_identity_address(config, address)
        linphone_proxy_config_set_route(config, "\(domain)")
        linphone_proxy_config_set_server_addr(config, "\(domain)")
        linphone_proxy_config_enable_register(config, 0)
        linphone_proxy_config_enable_publish(config, 0)
                
        linphone_core_add_proxy_config(linphoneCore, config)
        linphone_core_set_default_proxy_config(linphoneCore, config)
        
        let info = linphone_auth_info_new(username, nil, password, nil, nil, nil)
        linphone_core_add_auth_info(linphoneCore, info)
        
        linphone_proxy_config_unref(config)
        linphone_auth_info_unref(info)
        linphone_address_unref(address)
        
        return config
    }
    
    func register(_ proxy_cfg: OpaquePointer){
        linphone_proxy_config_enable_register(proxy_cfg, 1); /* activate registration for this proxy config*/
    }
    
    func shutdown(){
        print("Shutdown..")
        
        type(of: self).iterateTimer = nil

        guard let linphoneCore = linphoneCore else { return } // just in case application terminate before linphone core initialization
        
        let config = linphone_core_get_default_proxy_config(linphoneCore)
        linphone_proxy_config_edit(config)
        linphone_proxy_config_enable_register(config, 0)
        linphone_proxy_config_done(config)
        
        while(linphone_proxy_config_get_state(config) != LinphoneRegistrationCleared) {
            linphone_core_iterate(linphoneCore)
            ms_usleep(50000);
        }
        
        linphone_core_unref(linphoneCore)
    }
    
    @objc private func iterate(){
        if let linphoneCore = linphoneCore {
            linphone_core_iterate(linphoneCore); /* first iterate initiates registration */
        }
    }
    
    fileprivate func setTimer(){
        type(of: self).iterateTimer = Timer.scheduledTimer (
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
