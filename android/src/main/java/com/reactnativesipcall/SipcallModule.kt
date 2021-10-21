package com.reactnativesipcall

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class SipcallModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  var sipCall: SipCall? = null

  fun SipCallModule(reactContext: ReactApplicationContext?) {
    super(reactContext)
    sipCall = SipCall(reactContext)
    sipCall.init(reactContext)
  }

  /**
   * @return the name of this module. This will be the name used to `require()` this module
   * from JavaScript.
   */
  @Override
  fun getName(): String? {
    return "SipCall"
  }

  @ReactMethod
  fun login(@NonNull username: String?, @NonNull password: String?, @NonNull domain: String?) {
    sipCall.login(
      username,
      password,
      domain
    )
  }

  @ReactMethod
  fun call(@NonNull number: String?, @NonNull call_id: String?, @NonNull user_id: String?) {
    sipCall.call(number, call_id, user_id)
  }

  @ReactMethod
  fun accept() {
    sipCall.accept()
  }

  @ReactMethod
  fun decline() {
    sipCall.decline()
  }

  @ReactMethod
  fun endCall() {
    sipCall.endCall()
  }

  @ReactMethod
  fun logout() {
    sipCall.logout()
  }

}
