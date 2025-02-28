import Foundation
import Capacitor
import UIKit

@objc(SwipeBackControlPlugin)
public class SwipeBackControlPlugin: CAPPlugin {
    private var disabledPages: Set<String> = []
    private var originalDelegate: UIGestureRecognizerDelegate?
    private var navigationController: UINavigationController?
    
    @objc public override func load() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(handleBridgeReady),
                                             name: Notification.Name(rawValue: "capacitorBridgeReady"),
                                             object: nil)
        setupNavigationController()
    }
    
    private func setupNavigationController() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let bridge = self.bridge,
                  let viewController = bridge.viewController else {
                return
            }
            
            // If we're already in a navigation controller, use that
            if let navController = viewController.navigationController {
                self.navigationController = navController
                self.originalDelegate = navController.interactivePopGestureRecognizer?.delegate
                navController.setNavigationBarHidden(true, animated: false)
                return
            }
            
            // If not, we need to create one and embed the view controller
            if viewController.parent == nil {
                let navController = UINavigationController(rootViewController: viewController)
                navController.setNavigationBarHidden(true, animated: false)
                
                // Store the original delegate
                self.originalDelegate = navController.interactivePopGestureRecognizer?.delegate
                self.navigationController = navController
                
                // If we have a window, set its root view controller
                if let window = UIApplication.shared.windows.first {
                    window.rootViewController = navController
                }
            }
        }
    }
    
    @objc private func handleBridgeReady() {
        setupNavigationController()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc public func enableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance is deallocated")
                return
            }
            
            // Try to get or setup navigation controller
            if self.navigationController == nil {
                self.setupNavigationController()
            }
            
            guard let navigationController = self.navigationController else {
                call.reject("Navigation controller is not available")
                return
            }
            
            let enabled = call.getBool("enabled") ?? true
            let currentPage = call.getString("currentPage") ?? ""
            
            if enabled {
                self.disabledPages.remove(currentPage)
            } else {
                self.disabledPages.insert(currentPage)
            }
            
            let isEnabled = !self.disabledPages.contains(currentPage)
            
            // Configure the gesture recognizer
            let gestureRecognizer = navigationController.interactivePopGestureRecognizer
            gestureRecognizer?.isEnabled = isEnabled
            
            if isEnabled {
                // Restore original delegate when enabled
                gestureRecognizer?.delegate = self.originalDelegate
            } else {
                // Remove delegate when disabled to prevent swipe
                gestureRecognizer?.delegate = nil
            }
            
            call.resolve()
        }
    }
    
    @objc public func disableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance is deallocated")
                return
            }
            
            // Try to get or setup navigation controller
            if self.navigationController == nil {
                self.setupNavigationController()
            }
            
            guard let navigationController = self.navigationController else {
                call.reject("Navigation controller is not available")
                return
            }
            
            if let webView = self.webView,
               let url = webView.url {
                let currentPath = url.path
                self.disabledPages.insert(currentPath)
                
                // Disable the gesture recognizer
                let gestureRecognizer = navigationController.interactivePopGestureRecognizer
                gestureRecognizer?.isEnabled = false
                gestureRecognizer?.delegate = nil
                
                call.resolve()
            } else {
                call.reject("WebView URL is not available")
            }
        }
    }
} 