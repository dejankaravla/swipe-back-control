import Foundation
import Capacitor

@objc(SwipeBackControlPlugin)
public class SwipeBackControlPlugin: CAPPlugin {
    private var disabledPages: Set<String> = []
    
    @objc func enableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let enabled = call.getBool("enabled") ?? true
            let currentPage = call.getString("currentPage") ?? ""
            
            if enabled {
                self.disabledPages.remove(currentPage)
            } else {
                self.disabledPages.insert(currentPage)
            }
            
            self.updateSwipeBackGesture()
            call.resolve()
        }
    }
    
    @objc func disableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if let viewController = self.bridge?.viewController {
                let currentPath = viewController.navigationController?.topViewController?.navigationItem.title ?? ""
                self.disabledPages.insert(currentPath)
                self.updateSwipeBackGesture()
            }
            call.resolve()
        }
    }
    
    private func updateSwipeBackGesture() {
        if let viewController = self.bridge?.viewController {
            let currentPath = viewController.navigationController?.topViewController?.navigationItem.title ?? ""
            let isEnabled = !self.disabledPages.contains(currentPath)
            
            viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = isEnabled
            // Also disable the swipe back gesture for the navigation controller if needed
            if !isEnabled {
                viewController.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            }
        }
    }
}
