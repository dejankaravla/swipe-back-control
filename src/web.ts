import { WebPlugin } from '@capacitor/core';

import type { SwipeBackControlPlugin } from './definitions';

export class SwipeBackControlWeb extends WebPlugin implements SwipeBackControlPlugin {
  private disabledPages: Set<string> = new Set();

  constructor() {
    super();
    // Listen for back navigation attempts
    window.addEventListener('popstate', this.handlePopState.bind(this));
  }

  async enableSwipeBack(options: { enabled: boolean; currentPage: string }): Promise<void> {
    const { enabled, currentPage } = options;

    if (enabled) {
      this.disabledPages.delete(currentPage);
    } else {
      this.disabledPages.add(currentPage);
    }

    // Update navigation state if needed
    if (!enabled) {
      history.pushState(null, document.title, location.href);
    }
  }

  async disableSwipeBack(): Promise<void> {
    const currentPage = window.location.pathname;
    await this.enableSwipeBack({ enabled: false, currentPage });
  }

  private handlePopState(event: PopStateEvent): void {
    const currentPage = window.location.pathname;

    if (this.disabledPages.has(currentPage)) {
      // Prevent back navigation by pushing a new state
      history.pushState(null, document.title, location.href);
    }
  }

  // The echo function can be used for debugging or testing purposes
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
