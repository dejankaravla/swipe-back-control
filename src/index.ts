import { registerPlugin } from '@capacitor/core';

import type { SwipeBackControlPlugin } from './definitions';

const SwipeBackControl = registerPlugin<SwipeBackControlPlugin>('SwipeBackControl', {
  web: () => import('./web').then((m) => new m.SwipeBackControlWeb()),
});

export * from './definitions';
export { SwipeBackControl };
