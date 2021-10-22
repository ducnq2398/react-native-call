import * as React from 'react';

import {
  StyleSheet,
  View,
  Text,
  Button,
  TouchableOpacity,
  Animated,
} from 'react-native';
import sipCallStore from './SipCallStore';

export default function App() {
  React.useEffect(() => {
    // sipCall.addListener((event: any) => {
    //   console.log(event);
    // });
  }, []);
  const call = () => {
    sipCallStore.sipCall.call('0898572528', '', '101');
  };
  const init = () => {
    sipCallStore.init((event: any) => {
      console.log(event);
    });
    sipCallStore.sipCall.login('110', 'BKMB!eq8aHQ9', '42.112.25.68:5082');
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity style={{ padding: 16 }} onPress={init}>
        <Text>init</Text>
      </TouchableOpacity>
      <TouchableOpacity style={{ padding: 16 }} onPress={call}>
        <Text>call</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
