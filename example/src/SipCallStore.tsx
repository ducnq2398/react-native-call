import Sipcall from 'react-native-sipcall';

class Store {
  sipCall = new Sipcall();

  init(callback: any) {
    if (!this.sipCall) {
      this.sipCall = new Sipcall();
      this.sipCall.ide();
    }
    this.sipCall.addListener(callback);
  }
}

const sipCallStore = new Store();

export default sipCallStore;
