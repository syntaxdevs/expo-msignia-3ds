import { useEvent } from 'expo';
import {  useState } from "react";

import { Button, SafeAreaView, ScrollView, Text, View } from 'react-native';

import * as MSignia3ds from "expo-msignia-3ds";

export default function App() {
const [message, setMessage] = useState<string>("");

  async function setupSession() {
    try {
      const result = await MSignia3ds.setupSession(
        "pavlo-elrosado-demo@msignia.com", // userId
        "519209", // cardId
        "420e1eea-84d3-4f74-8c11-776cec65a047", // orderId
        "https://3ds.hercules.ec:50002/api/Transaction/Exchange", // exchangeTransactionDetailsUrl
        "https://3ds.hercules.ec:50002/api/Transaction/Result", //transactionResultUrl
        "https://emv3ds.elrosado.com/split-sdk-client/v1", //splitSdkServerUrl
      );
      const { msg, code , error} = result
      setMessage(code ?? "")
      console.log(result); 
    } catch (error) {
      console.error("Error setupSession :", error);
    }
  }

  

  return (
    <View
      style={{
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <Text>
        Estado: {message}
      </Text>
       <Button
        title="Iniciar uSDK"
        onPress={setupSession}
      />
     
    </View>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = {
  header: {
    fontSize: 30,
    margin: 20,
  },
  groupHeader: {
    fontSize: 20,
    marginBottom: 20,
  },
  group: {
    margin: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: '#eee',
  },
  view: {
    flex: 1,
    height: 200,
  },
};
