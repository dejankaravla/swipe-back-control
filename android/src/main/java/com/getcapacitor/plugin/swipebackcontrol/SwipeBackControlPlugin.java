package com.getcapacitor.plugin.swipebackcontrol;

import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebView;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.util.HashSet;
import java.util.Set;

@CapacitorPlugin(name = "SwipeBackControl")
public class SwipeBackControlPlugin extends Plugin {
    private Set<String> disabledPages = new HashSet<>();

    @PluginMethod
    public void enableSwipeBack(PluginCall call) {
        try {
            Boolean enabled = call.getBoolean("enabled", true);
            String currentPage = call.getString("currentPage", "");

            if (enabled) {
                disabledPages.remove(currentPage);
            } else {
                disabledPages.add(currentPage);
            }

            updateBackGestureState(currentPage);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to enable/disable swipe back: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void disableSwipeBack(PluginCall call) {
        try {
            String currentPage = getCurrentPage();
            disabledPages.add(currentPage);
            updateBackGestureState(currentPage);
            call.resolve();
        } catch (Exception e) {
            call.reject("Failed to disable swipe back: " + e.getMessage(), e);
        }
    }

    private String getCurrentPage() {
        WebView webView = getBridge().getWebView();
        if (webView != null && webView.getUrl() != null) {
            String url = webView.getUrl();
            return url.substring(url.lastIndexOf("/"));
        }
        return "";
    }

    private void updateBackGestureState(String currentPage) {
        if (getActivity() != null) {
            boolean isEnabled = !disabledPages.contains(currentPage);
            Window window = getActivity().getWindow();

            // For Android 10+ (API level 29+), handle system gesture navigation
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Set system gesture exclusion rects when disabled
                View decorView = window.getDecorView();
                if (!isEnabled) {
                    // Disable system gesture navigation from the left edge
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
                        WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
                    );
                    // Visual indicator that swipe back is disabled
                    window.setNavigationBarColor(android.graphics.Color.BLACK);
                } else {
                    // Re-enable system gesture navigation
                    window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
                    window.setNavigationBarColor(android.graphics.Color.TRANSPARENT);
                }
            }
        }
    }
} 