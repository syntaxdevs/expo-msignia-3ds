import * as React from 'react';

import { ExpoMsignia3dsViewProps } from './ExpoMsignia3ds.types';

export default function ExpoMsignia3dsView(props: ExpoMsignia3dsViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
