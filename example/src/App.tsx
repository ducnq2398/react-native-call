import * as React from 'react';

import {StyleSheet, View, Text, Button, TouchableOpacity} from 'react-native';
import Sipcall from 'react-native-sipcall';

export default function App() {
  const sipCall = new Sipcall();

  React.useEffect(() => {

    // sipCall.login("110", "BKMB!eq8aHQ9", '42.112.25.68:5082');
    // sipCall.addListener((event: any) =>{
    //   console.log(event)
    // });


  }, []);
  const call = ()=>{
    sipCall.call(
      "0898572528",
      "",
      "101",
    );
  }
  const init = ()=>{
    sipCall.ide();
  }

  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={{padding: 16}}
        onPress={init}
      >
        <Text>init</Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={{padding: 16}}
        onPress={call}
      >
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
