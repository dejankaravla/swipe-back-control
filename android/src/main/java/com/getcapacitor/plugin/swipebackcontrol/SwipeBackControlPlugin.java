package com.getcapacitor.plugin.swipebackcontrol;

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
        Boolean enabled = call.getBoolean("enabled", true);
        String currentPage = call.getString("currentPage", "");

        if (enabled) {
            disabledPages.remove(currentPage);
        } else {
            disabledPages.add(currentPage);
        }

        // On Android, we can disable the back gesture by overriding the activity's onBackPressed
        // This is handled in the activity itself
        updateBackGestureState(currentPage);
        call.resolve();
    }

    @PluginMethod
    public void disableSwipeBack(PluginCall call) {
        String currentPage = getCurrentPage();
        disabledPages.add(currentPage);
        updateBackGestureState(currentPage);
        call.resolve();
    }

    private String getCurrentPage() {
        if (getActivity() != null && getActivity().getTitle() != null) {
            return getActivity().getTitle().toString();
        }
        return "";
    }

    private void updateBackGestureState(String currentPage) {
        if (getActivity() != null) {
            boolean isEnabled = !disabledPages.contains(currentPage);
            // For Android 10+ (API level 29+), we can use the following:
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                getActivity().getWindow().setNavigationBarColor(
                    isEnabled ? android.graphics.Color.TRANSPARENT : 
                              android.graphics.Color.BLACK
                );
            }
        }
    }
} 