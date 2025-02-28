import { WebPlugin } from '@capacitor/core';

import type { SwipeBackControlPlugin } from './definitions';

export class SwipeBackControlWeb extends WebPlugin implements SwipeBackControlPlugin {
  private disabledPages: Set<string> = new Set();

  constructor() {
    super();
    try {
      // Listen for back navigation attempts
      window.addEventListener('popstate', this.handlePopState.bind(this));
    } catch (error) {
      console.error('Failed to initialize SwipeBackControl:', error);
    }
  }

  async enableSwipeBack(options: { enabled: boolean; currentPage: string }): Promise<void> {
    try {
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
    } catch (error) {
      console.error('Failed to enable/disable swipe back:', error);
      throw error;
    }
  }

  async disableSwipeBack(): Promise<void> {
    try {
      const currentPage = window.location.pathname;
      await this.enableSwipeBack({ enabled: false, currentPage });
    } catch (error) {
      console.error('Failed to disable swipe back:', error);
      throw error;
    }
  }

  private handlePopState(): void {
    try {
      const currentPage = window.location.pathname;

      if (this.disabledPages.has(currentPage)) {
        // Prevent back navigation by pushing a new state
        history.pushState(null, document.title, location.href);
      }
    } catch (error) {
      console.error('Error handling pop state:', error);
    }
  }

  // The echo function can be used for debugging or testing purposes
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
