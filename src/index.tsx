import {NativeModules, NativeEventEmitter, Platform} from 'react-native';

class SipCall {

  constructor() {}

  addListener(callback?) {
    const eventEmitter = new NativeEventEmitter(NativeModules.SipCall);
    eventEmitter.addListener('SipCall', event => {
      console.log(event);
      callback(event);
      // if (event === 'RegistrationState.Ok' && this.registerSuccess) {
      //   this.registerSuccess();
      // }
    });
  }

  ide() {
    if (Platform.OS === 'ios') {
      NativeModules.SipCall.initialize();
    }
  }

  login(username, password, domain, registerSuccess) {
    this.registerSuccess = registerSuccess;
    if (Platform.OS === 'ios') {
      NativeModules.SipCall.login({
        username: username,
        password: password,
        domain: domain,
      });
    } else {
      NativeModules.SipCall.login(username, password, domain);
    }
  }

  call(phoneNumber, callId, userId) {
    if (Platform.OS === 'ios') {
      NativeModules.SipCall.call({
        phoneNumber: phoneNumber,
        callId: callId,
        userId: userId,
      });
    } else {
      NativeModules.SipCall.call(phoneNumber, callId, userId);
    }
  }

  endCall() {
    NativeModules.SipCall.endCall();
  }

  accept() {
    NativeModules.SipCall.accept();
  }

  logout() {
    NativeModules.SipCall.logout();
  }
}

export default SipCall;
