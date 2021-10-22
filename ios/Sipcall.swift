import Foundation


@objc(SipCall)
class SipCall : RCTEventEmitter {
    
    
    @objc override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    override func supportedEvents() -> [String]! {
        return ["SipCall"]
    }
    
    
    
    @objc func initialize() {
        DispatchQueue.main.async {
            LinphoneManager.shared.registerEventEmitter(eventEmitter: self)
            LinphoneManager.shared.initialize()
        }
    }
    
//    @objc func setup() {
//        DispatchQueue.main.async {
//            LinphoneManager.shared.registerEventEmitter(eventEmitter: self)
//            LinphoneManager.shared.initialize()
//        }
//    }
//
    
    // Reference to use main thread
    @objc func login(_ options: NSDictionary) -> Void {
        print("login")
        DispatchQueue.main.async {
            let username = options["username"] as! String
            let password = options["password"] as! String
            let domain = options["domain"] as! String
            
            LinphoneManager.shared.login(username: username, password: password, domain: domain)
        }
    }
    
    
    
    @objc func logout() -> Void {
        DispatchQueue.main.async {
            LinphoneManager.shared.logout()
        }
    }
    
    @objc func call(_ options: NSDictionary) -> Void {
        DispatchQueue.main.async {
            let phoneNumber = options["phoneNumber"] as! String
            let callId = options["callId"] as! String
            let userId = options["userId"] as! String
            LinphoneManager.shared.call(phone_number: phoneNumber, user_id: userId, call_id: callId)
        }
    }
    
    
    @objc func endCall() -> Void {
        DispatchQueue.main.async {
            LinphoneManager.shared.endCall()
        }
    }
    
}
