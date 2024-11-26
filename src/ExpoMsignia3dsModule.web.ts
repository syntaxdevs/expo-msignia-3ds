import { registerWebModule, NativeModule } from 'expo';

import { ExpoMsignia3dsModuleEvents } from './ExpoMsignia3ds.types';

class ExpoMsignia3dsModule extends NativeModule<ExpoMsignia3dsModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoMsignia3dsModule);
