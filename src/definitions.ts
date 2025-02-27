export interface SwipeBackControlPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
