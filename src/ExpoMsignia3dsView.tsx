import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoMsignia3dsViewProps } from './ExpoMsignia3ds.types';

const NativeView: React.ComponentType<ExpoMsignia3dsViewProps> =
  requireNativeView('ExpoMsignia3ds');

export default function ExpoMsignia3dsView(props: ExpoMsignia3dsViewProps) {
  return <NativeView {...props} />;
}
