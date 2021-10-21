import Foundation


@objc(SipCall)
class SipCall : RCTEventEmitter {
  
  override func supportedEvents() -> [String]! {
      return ["SipCall"]
    }


  
  @objc func initialize() {
    DispatchQueue.main.async {
      LinphoneManager.shared.registerEventEmitter(eventEmitter: self)
      LinphoneManager.shared.initialize()
//      LinphoneManager.shared.demo()
//      self.sendEvent(withName: "SipCall", body: "Init")
    }
  }
  
 
  
  // Reference to use main thread
  @objc func login(_ options: NSDictionary) -> Void {
    print("login: %s %s %s", options["username"], options["password"], options["domain"])

    let username = options["username"] as! String
    let password = options["password"] as! String
    let domain = options["domain"] as! String

//    let identity = "sip:" + username + "@" + domain
    DispatchQueue.main.async {
      LinphoneManager.shared.login(username: username, password: password, domain: domain)
    }
  }


  
  @objc func logout() -> Void {
    DispatchQueue.main.async {
      LinphoneManager.shared.logout()
    }
  }
  
  @objc func call(_ options: NSDictionary) -> Void {
    let phoneNumber = options["phoneNumber"] as! String
    let callId = options["callId"] as! String
    let userId = options["userId"] as! String
    DispatchQueue.main.async {
      LinphoneManager.shared.call(phone_number: phoneNumber, user_id: userId, call_id: callId)
    }
  }
  
  
  @objc func endCall() -> Void {
    DispatchQueue.main.async {
      LinphoneManager.shared.endCall()
    }
  }
  
}
