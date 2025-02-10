import {  useState } from "react";

import { Button,  Text, View } from 'react-native';

import * as MSignia3ds from "expo-msignia-3ds";

const Home =() => { 
  const [message, setMessage] = useState<string>("");

  async function setupSession() {
    try {
      const resultAuthenticate = await MSignia3ds.setupSession(
        "pavlo-elrosado-demo@msignia.com", // userId
        "519209", // cardId
        "420e1eea-84d3-4f74-8c11-776cec65a047", // orderId
        "https://3ds.hercules.ec:50002/api/Transaction/Exchange", // exchangeTransactionDetailsUrl
        "https://3ds.hercules.ec:50002/api/Transaction/Result", //transactionResultUrl
        "https://emv3ds.elrosado.com/split-sdk-client/v1", //splitSdkServerUrl
      );
      const { msg, code , error, result} = resultAuthenticate
            console.log(" resultAuthenticate :", resultAuthenticate);

      setMessage(code ?? "")
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
  )
}

export default function App() {
  return <Home />
}
