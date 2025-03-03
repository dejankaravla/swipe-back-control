import Foundation
import Capacitor
import UIKit

@objc(SwipeBackControlPlugin)
public class SwipeBackControlPlugin: CAPPlugin {
    private var disabledPages: Set<String> = []
    private var customGestureRecognizer: UIScreenEdgePanGestureRecognizer?
    private var isInitialized = false
    
    @objc public override func load() {
        print("SwipeBackControlPlugin: Plugin loading...")
        DispatchQueue.main.async { [weak self] in
            self?.initializeGestureRecognizer()
        }
    }
    
    private func initializeGestureRecognizer() {
        print("SwipeBackControlPlugin: Initializing custom gesture recognizer")
        
        guard let viewController = bridge?.viewController else {
            print("SwipeBackControlPlugin: No view controller available")
            
            // Retry after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.initializeGestureRecognizer()
            }
            return
        }
        
        // Remove any existing gesture recognizer
        if let existingGesture = customGestureRecognizer {
            viewController.view.removeGestureRecognizer(existingGesture)
            customGestureRecognizer = nil
        }
        
        // Create a new edge pan gesture recognizer for the left edge
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
        edgePanGesture.edges = .left
        viewController.view.addGestureRecognizer(edgePanGesture)
        customGestureRecognizer = edgePanGesture
        
        print("SwipeBackControlPlugin: Custom gesture recognizer added to view controller: \(String(describing: type(of: viewController)))")
        isInitialized = true
    }
    
    @objc private func handleEdgePanGesture(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard let webView = webView, let url = webView.url else {
            print("SwipeBackControlPlugin: No WebView URL available")
            return
        }
        
        let currentPath = normalizePath(url.path)
        let isEnabled = !disabledPages.contains(currentPath)
        
        if !isEnabled {
            // Gesture is disabled for this page
            gestureRecognizer.isEnabled = false
            DispatchQueue.main.async {
                gestureRecognizer.isEnabled = true
            }
            return
        }
        
        if gestureRecognizer.state == .began {
            print("SwipeBackControlPlugin: Edge pan gesture began on path: \(currentPath)")
        } else if gestureRecognizer.state == .ended {
            print("SwipeBackControlPlugin: Edge pan gesture ended, triggering back navigation")
            
            // Get the translation and velocity
            let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
            let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
            
            // Determine if the gesture was significant enough to trigger navigation
            if translation.x > 50 || velocity.x > 300 {
                // Execute JavaScript to navigate back
                webView.evaluateJavaScript("window.history.back();", completionHandler: { (result, error) in
                    if let error = error {
                        print("SwipeBackControlPlugin: Error triggering back navigation: \(error)")
                    } else {
                        print("SwipeBackControlPlugin: Successfully triggered back navigation")
                    }
                })
            }
        }
    }
    
    private func normalizePath(_ path: String) -> String {
        // Remove trailing slash if present
        var normalized = path
        if normalized.hasSuffix("/") {
            normalized = String(normalized.dropLast())
        }
        // Ensure path starts with /
        if !normalized.hasPrefix("/") {
            normalized = "/" + normalized
        }
        return normalized
    }
    
    private func getCurrentPath() -> String? {
        guard let webView = webView, let url = webView.url else {
            print("SwipeBackControlPlugin: No WebView URL available")
            return nil
        }
        
        return normalizePath(url.path)
    }
    
    @objc public func enableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                print("SwipeBackControlPlugin: Self is nil during enable")
                call.reject("Plugin instance is deallocated")
                return
            }
            
            // If gesture recognizer wasn't initialized, try again now
            if !self.isInitialized {
                print("SwipeBackControlPlugin: Gesture recognizer not initialized yet, initializing now...")
                self.initializeGestureRecognizer()
            }
            
            let enabled = call.getBool("enabled") ?? true
            let rawPath = call.getString("currentPage") ?? ""
            let currentPage = self.normalizePath(rawPath)
            
            print("SwipeBackControlPlugin: Configuring swipe back for page: \(currentPage), enabled: \(enabled)")
            
            if enabled {
                self.disabledPages.remove(currentPage)
                print("SwipeBackControlPlugin: Swipe back enabled for path: \(currentPage)")
            } else {
                self.disabledPages.insert(currentPage)
                print("SwipeBackControlPlugin: Swipe back disabled for path: \(currentPage)")
            }
            
            call.resolve()
        }
    }
    
    @objc public func disableSwipeBack(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                print("SwipeBackControlPlugin: Self is nil during disable")
                call.reject("Plugin instance is deallocated")
                return
            }
            
            guard let currentPath = self.getCurrentPath() else {
                call.reject("Cannot determine current path")
                return
            }
            
            print("SwipeBackControlPlugin: Disabling swipe back for path: \(currentPath)")
            self.disabledPages.insert(currentPath)
            
            call.resolve()
        }
    }
    
    deinit {
        print("SwipeBackControlPlugin: Plugin deinitializing")
        
        // Remove gesture recognizer if it exists
        if let gesture = customGestureRecognizer, let viewController = bridge?.viewController {
            viewController.view.removeGestureRecognizer(gesture)
        }
    }
} 