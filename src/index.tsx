import { NativeModules, NativeEventEmitter, Platform } from 'react-native';

class SipCall {
  constructor() {}

  addListener(callback: any) {
    const eventEmitter = new NativeEventEmitter(NativeModules.SipCall);
    eventEmitter.addListener('SipCall', (event) => {
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

  login(username: string, password: string, domain: string) {
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

  call(phoneNumber: string, callId: string, userId: string) {
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
