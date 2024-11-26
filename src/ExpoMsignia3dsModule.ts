import { NativeModule, requireNativeModule } from 'expo';

import { ExpoMsignia3dsModuleEvents } from './ExpoMsignia3ds.types';

declare class ExpoMsignia3dsModule extends NativeModule<ExpoMsignia3dsModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoMsignia3dsModule>('ExpoMsignia3ds');
