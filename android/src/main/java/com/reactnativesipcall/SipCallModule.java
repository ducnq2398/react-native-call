package com.reactnativesipcall;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Expose Java to JavaScript. Methods annotated with {@link ReactMethod} are exposed.
 */
public class SipCallModule extends ReactContextBaseJavaModule {
    static SipCall sipCall = null;

    SipCallModule(ReactApplicationContext reactContext) {
        super(reactContext);
        if(sipCall == null){
          sipCall = new SipCall(reactContext);
          sipCall.init(reactContext);
        }
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from JavaScript.
     */
    @Override
    public String getName() {
        return "SipCall";
    }

    @ReactMethod
    void login(@NonNull String username,@NonNull String password,@NonNull String domain) {
        sipCall.login(
                username,
                password,
                domain
        );
    }

    @ReactMethod
    void call(@NonNull String number,@NonNull String call_id,@NonNull String user_id) {
        sipCall.call(number, call_id, user_id);
    }

    @ReactMethod
    void accept() {
        sipCall.accept();
    }

    @ReactMethod
    void decline() {
        sipCall.decline();
    }

    @ReactMethod
    void endCall() {
        sipCall.endCall();
    }

    @ReactMethod
    void logout() {
        sipCall.logout();
    }

}
