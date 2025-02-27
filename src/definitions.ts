export interface SwipeBackControlPlugin {
  /**
   * Enable or disable swipe back gesture for the current page
   * @param options Configuration options for swipe back control
   * @returns Promise that resolves when the operation is completed
   */
  enableSwipeBack(options: { enabled: boolean; currentPage: string }): Promise<void>;

  /**
   * Disable swipe back gesture for the current page
   * @returns Promise that resolves when the operation is completed
   */
  disableSwipeBack(): Promise<void>;
}
