import { WebPlugin } from '@capacitor/core';

import type { SwipeBackControlPlugin } from './definitions';

export class SwipeBackControlWeb extends WebPlugin implements SwipeBackControlPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
