import { NativeModules } from 'react-native';

type SipcallType = {
  multiply(a: number, b: number): Promise<number>;
};

const { Sipcall } = NativeModules;

export default Sipcall as SipcallType;
