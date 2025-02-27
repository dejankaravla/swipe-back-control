# swipe-back-control

Capacitor plugin to enable or disable the swipe back gesture on iOS devices for specific pages.

## Install

```bash
npm install swipe-back-control
npx cap sync
```

## API

<docgen-index>

* [`enableSwipeBack(...)`](#enableswipeback)
* [`disableSwipeBack()`](#disableswipeback)

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

--------------------


### disableSwipeBack()

```typescript
disableSwipeBack() => Promise<void>
```

Disable swipe back gesture for the current page

--------------------

</docgen-api>
