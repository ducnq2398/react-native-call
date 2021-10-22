import Foundation
import linphonesw

protocol Callback {
    func send(message: String)
}

class LinphoneManager: NSObject {
    
    
    public static let shared = LinphoneManager()
    
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
    
    
    var lc: Core!
    var proxy_cfg: ProxyConfig!
    var call: Call!
    var mIterateTimer: Timer?
    
    let coreManager1 = LinphoneCoreManager()
    let coreManager2 = LinphoneCoreManager2()
    
    
    
    func initialize() {
        print("initialize")
        
        do {
            if lc == nil {
                lc = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            }

        } catch {
            print(error)
        }
        
        
    }
    
    func end() {
        print("Shutting down...\n")
        print("Exited\n")
    }
    
    
    @objc func iterate() {
        lc.iterate()
    }
    
    func startIterateTimer() {
        if (mIterateTimer?.isValid ?? false) {
            print("Iterate timer is already started, skipping ...")
            return
        }
        mIterateTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.iterate), userInfo: nil, repeats: true)
        print("start iterate timer")
        
    }
    
    func stopIterateTimer() {
        if let timer = mIterateTimer {
            print("stop iterate timer")
            timer.invalidate()
        }
    }
    
    
    fileprivate func bundleFile(_ name: String, _ ext: String? = nil) -> String? {
        return Bundle.main.path(forResource: name, ofType: ext)
    }
    
    fileprivate func documentFile(_ file: NSString) -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        
        let documentsPath: NSString = paths[0] as NSString
        return documentsPath.appendingPathComponent(file as String) as NSString
    }
    
    func login(username: String, password: String, domain: String) {
        print("login")
        loginInfo = ["username": username, "password": password, "domain": domain]
        
        let factory = Factory.Instance
        do {
            lc.addDelegate(delegate: coreManager1)
            
            
            try! lc.start()
            /*create proxy config*/
            proxy_cfg = try lc.createProxyConfig()
            /*parse identity*/
            let from = try factory.createAddress(addr: "sip:"+username+"@"+domain)
            
            let info = try factory.createAuthInfo(username: from.username, userid: "", passwd: password, ha1: "", realm: "", domain: "") /*create authentication structure from identity*/
            lc!.addAuthInfo(info: info) /*add authentication info to LinphoneCore*/
            
            // configure proxy entries
            try proxy_cfg.setIdentityaddress(newValue: from) /*set identity with user name and domain*/
            let server_addr = domain /*extract domain address from identity*/
            try proxy_cfg.setServeraddr(newValue: server_addr) /* we assume domain = proxy server address*/
            proxy_cfg.registerEnabled = true /*activate registration for this proxy config*/
            
            try lc.addProxyConfig(config: proxy_cfg!) /*add proxy config to linphone core*/
            lc.defaultProxyConfig = proxy_cfg /*set to default proxy*/
            
            
            /* main loop for receiving notifications and doing background linphonecore work: */
            startIterateTimer()
        } catch {
            print(error)
            end()
        }
    }
    
    func call(phone_number: String, user_id: String, call_id: String) {
        
        let log = LoggingService.Instance /*enable liblinphone logs.*/
        let logManager = LinphoneLoggingServiceManager()
        log.addDelegate(delegate: logManager)
        log.logLevel = LogLevel.Debug
        Factory.Instance.enableLogCollection(state: LogCollectionState.Enabled)
        
        
        lc.addDelegate(delegate: coreManager2)
        
        
        
        let addressToCall: Address = lc.interpretUrl(url: phone_number)!
        let params: CallParams? = try! lc.createCallParams(call: nil)
        params?.audioEnabled = true
        
        params?.addCustomHeader(headerName: "X-Call-Id", headerValue: call_id)
        params?.addCustomHeader(headerName: "X-User-Id", headerValue: user_id)
        
        
        /*
         Place an outgoing call
         */
        call = lc.inviteAddressWithParams(addr: addressToCall, params: params!)
        //      call = lc.invite(url: phone_number)
        if (call == nil) {
            print("Could not place call to )\n")
            end()
        } else {
            print("Call to  ) is in progress...")
        }
        
        
        startIterateTimer()
    }
    
    
    
    func accept() {
        do{
            try lc.currentCall?.accept()
        } catch {
            print(error)
            end()
        }
    }
    
    func endCall() {
        stopIterateTimer()
        if (self.call != nil && self.call!.state != Call.State.End){
            /* terminate the call */
            print("Terminating the call...\n")
            do {
                try self.call?.terminate()
            } catch {
                print(error)
            }
        }
        
        self.lc.removeDelegate(delegate: self.coreManager2)
        self.lc.stop()
        end()
    }
    
    func logout() {
        stopIterateTimer()
        if (self.call != nil && self.call!.state != Call.State.End){
            /* terminate the call */
            print("Terminating the call...\n")
            do {
                try self.call?.terminate()
            } catch {
                print(error)
            }
        }
        
        self.lc.removeDelegate(delegate: self.coreManager2)
        self.lc.stop()
        end()
    }
    
    
    
    
    fileprivate func setTimer(){
        type(of: self).iterateTimer = Timer.scheduledTimer (
            timeInterval: 0.02, target: self, selector: #selector(iterate), userInfo: nil, repeats: true)
    }
}
class LinphoneCoreManager: CoreDelegate {
    override func onRegistrationStateChanged(lc: Core, cfg: ProxyConfig, cstate: RegistrationState, message: String?) {
        print("New registration state \(cstate) for user id \( String(describing: cfg.identityAddress?.asString()))\n")
        switch cstate{
        case .None:
                   print("registrationStateChanged -> LinphoneRegistrationNone -> \(message)")
            LinphoneManager.shared.dispatch(message: "RegistrationState.None")
        case .Progress:
                   print("registrationStateChanged -> LinphoneRegistrationProgress -> \(message)")
            LinphoneManager.shared.dispatch(message: "RegistrationState.Progress")
        case .Ok:
                   print("registrationStateChanged -> LinphoneRegistrationOk -> \(message)")
            LinphoneManager.shared.dispatch(message: "RegistrationState.Ok")
        case .Cleared:
                   print("registrationStateChanged -> LinphoneRegistrationCleared -> \(message)")
            LinphoneManager.shared.dispatch(message: "RegistrationState.Cleared")
        case .Failed:
                   print("registrationStateChanged -> LinphoneRegistrationFailed -> \(message)")
            LinphoneManager.shared.dispatch(message: "RegistrationState.Failed")
               default:
                   return
               }

    }
}

class LinphoneLoggingServiceManager: LoggingServiceDelegate {
    override func onLogMessageWritten(logService: LoggingService, domain: String, lev: LogLevel, message: String) {
        print("Logging service log: \(message)s\n")
    }
}

class LinphoneCoreManager2: CoreDelegate {
    override func onCallStateChanged(lc: Core, call: Call, cstate: Call.State, message: String) {
//        switch cstate {
//        case .OutgoingRinging:
//            print("It is now ringing remotely !\n")
//            LinphoneManager.shared.dispatch(message: "It is now ringing remotely !\n")
//        case .OutgoingEarlyMedia:
//            print("Receiving some early media\n")
//            LinphoneManager.shared.dispatch(message: "OutgoingEarlyMedia")
//        case .Connected:
//            print("We are connected !\n")
//        case .StreamsRunning:
//            print("Media streams established !\n")
//        case .End:
//            print("Call is terminated.\n")
//        case .Error:
//            LinphoneManager.shared.dispatch(message: "Error")
//            print("Call failure !")
//        default:
//            print("Unhandled notification \(cstate)\n")
//        }
        
        var stateMessage = message
                switch cstate {
                case .Idle:
                    print("callStateChanged -> .Idle -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Idle")
                case .IncomingReceived:
                    print("callStateChanged -> .IncomingReceived -> \(stateMessage)")
//                    currentCall = call
        //            ms_usleep(3 * 1000 * 1000); // Wait 3 seconds to pickup
        //            linphone_call_accept(call)
                    LinphoneManager.shared.dispatch(message: "Call.State.IncomingReceived")
                  
                LinphoneManager.shared.dispatch(message: "Call.State.IncomingReceived")
                case .OutgoingInit:
                    print("callStateChanged -> .OutgoingInit -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.OutgoingInit")
                case .OutgoingProgress:
                    print("callStateChanged -> .OutgoingProgress -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.OutgoingProgress")
                case .OutgoingRinging:
                    print("callStateChanged -> .OutgoingRinging -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.OutgoingRinging")
                case .OutgoingEarlyMedia:
                    print("callStateChanged -> .OutgoingEarlyMedia -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.OutgoingEarlyMedia")
                case .Connected:
                    print("callStateChanged -> .Connected -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Connected")
                case .StreamsRunning:
                    print("callStateChanged -> .StreamsRunning -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.StreamsRunning")
                case .Pausing:
                    print("callStateChanged -> .Pausing -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Pausing")
                case .Paused:
                    print("callStateChanged -> .Paused -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Paused")
                case .Resuming:
                    print("callStateChanged -> .Resuming -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Resuming")
                case .Referred:
                    print("callStateChanged -> .Referred -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Referred")
                case .Error:
                    print("callStateChanged -> .Error -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Error")
                case .End:
                    print("callStateChanged -> .End -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.End")
                case .PausedByRemote:
                    print("callStateChanged -> .PausedByRemote -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.PausedByRemote")
                case .UpdatedByRemote:
                    print("callStateChanged -> .UpdatedByRemote -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.UpdatedByRemote")
                case .IncomingEarlyMedia:
                    print("callStateChanged -> .IncomingEarlyMedia -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.IncomingEarlyMedia")
                case .Updating:
                    print("callStateChanged -> .Updating -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Updating")
                case .Released:
                    print("callStateChanged -> .Released -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.Released")
                case .EarlyUpdatedByRemote:
                    print("callStateChanged -> .EarlyUpdatedByRemote -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.EarlyUpdatedByRemote")
                case .EarlyUpdating:
                    print("callStateChanged -> .EarlyUpdating -> \(stateMessage)")
                LinphoneManager.shared.dispatch(message: "Call.State.EarlyUpdating")
                default:
                    return
                }

    }
}
