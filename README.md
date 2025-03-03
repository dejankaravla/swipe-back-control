# swipe-back-control

Capacitor plugin to enable or disable the swipe back gesture on iOS devices for specific pages in your app.

## Features

- 🔄 Control swipe-to-go-back gesture on a per-page basis
- 📱 Works with iOS and provides fallback for Android and web
- 🧩 Simple API with React Hook example
- ⚡ Lightweight and performant
- 🔧 Custom edge gesture implementation (no UINavigationController dependency)

## Install

```bash
npm install swipe-back-control
npx cap sync
```

## Usage

### Basic Example

```typescript
import { SwipeBackControl } from 'swipe-back-control';

// Enable swipe back for current page
await SwipeBackControl.enableSwipeBack({
  enabled: true,
  currentPage: '/current-path',
});

// Disable swipe back for current page
await SwipeBackControl.enableSwipeBack({
  enabled: false,
  currentPage: '/current-path',
});

// Alternative way to disable swipe back
await SwipeBackControl.disableSwipeBack();
```

### React Hook Example

Create a custom hook to manage swipe back functionality:

```typescript
// useSwipeBack.ts
import { useEffect, useCallback } from 'react';
import { useLocation } from 'react-router-dom';
import { SwipeBackControl } from 'swipe-back-control';

export const useSwipeBack = () => {
  const location = useLocation();
  const currentPath = location.pathname;

  const updateSwipeBack = useCallback(async (path: string) => {
    try {
      console.log(`SwipeBack: Updating for path "${path}"`);

      if (path === '/home') {
        // Disable swipe back for home page
        console.log('SwipeBack: Disabling for home page');
        await SwipeBackControl.enableSwipeBack({
          enabled: false,
          currentPage: path,
        });
      } else {
        // Enable swipe back for all other pages
        console.log(`SwipeBack: Enabling for path "${path}"`);
        await SwipeBackControl.enableSwipeBack({
          enabled: true,
          currentPage: path,
        });
      }
    } catch (error) {
      console.error('SwipeBack: Failed to update swipe back:', error);
    }
  }, []);

  // Update swipe back when route changes
  useEffect(() => {
    updateSwipeBack(currentPath);

    // Cleanup when component unmounts
    return () => {
      // Re-enable swipe back on unmount to be safe
      SwipeBackControl.enableSwipeBack({
        enabled: true,
        currentPage: currentPath,
      }).catch((error) => {
        console.error('SwipeBack: Failed to cleanup swipe back:', error);
      });
    };
  }, [currentPath, updateSwipeBack]);
};
```

Then use this hook in your layout component:

```tsx
// Layout.tsx
import { Outlet } from 'react-router-dom';
import { useSwipeBack } from '../hooks/useSwipeBack';

export default function Layout() {
  // Initialize swipe back control
  useSwipeBack();

  return (
    <div>
      <Outlet />
    </div>
  );
}
```

## How It Works

This plugin creates a custom edge gesture recognizer for iOS that allows handling swipe-from-left-edge gestures, which is the standard iOS gesture for navigating back.

The plugin maintains a set of disabled pages, and when a swipe gesture is detected, it checks if the current page is in this set. If not, it triggers a JavaScript back navigation using `window.history.back()`.

On Android and web platforms, a fallback implementation is provided that simply manages the disabled pages set and prevents back navigation when needed.

## Technical Implementation

- iOS: Custom `UIScreenEdgePanGestureRecognizer` implementation that directly interfaces with the WebView's JavaScript context
- Android: Manages disabled pages and interfaces with Android's back button handling
- Web: Uses the history API to manage back navigation

## Troubleshooting

### Swipe Back Not Working on iOS

1. Make sure you've installed the plugin correctly with `npx cap sync ios`
2. Check console logs for any errors related to "SwipeBackControlPlugin"
3. Verify that your app's paths are correctly normalized (e.g., all start with "/")
4. Ensure the plugin is properly initialized by checking for the initialization message in logs

### JavaScript Navigation Issues

If the swipe gesture is detected but navigation doesn't work:

1. Make sure your app's router is using the browser history API
2. Check if your app intercepts or prevents the default back behavior
3. Ensure there's an actual page to go back to in the history stack

## API

<docgen-index>

- [`enableSwipeBack(...)`](#enableswipeback)
- [`disableSwipeBack()`](#disableswipeback)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### enableSwipeBack(...)

```typescript
enableSwipeBack(options: { enabled: boolean; currentPage: string; }) => Promise<void>
```

Enable or disable swipe back gesture for the current page

| Param         | Type                                                    | Description                                  |
| ------------- | ------------------------------------------------------- | -------------------------------------------- |
| **`options`** | <code>{ enabled: boolean; currentPage: string; }</code> | Configuration options for swipe back control |

---

### disableSwipeBack()

```typescript
disableSwipeBack() => Promise<void>
```

Disable swipe back gesture for the current page

---

</docgen-api>
