//
//  WebViewController.swift
//  Collated
//
//  Created by Miles Dunne on 13/08/2017.
//  Copyright © 2017 Collated. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class WebViewController: UIViewController {
    
    let collatedSiteURLString = "https://app.collated.net/"
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = webView
        
        CollatedClient.shared.authenticationDelegate = self
        
        loadDefaultPage()
    }
    
    // MARK: - Web View
    
    /// The web view, configured to inject the user script after the document
    /// finishes loading.
    lazy var webView: WKWebView = {
        guard let scriptURL = Bundle.main
            .url(forResource: "CollatedUserScript", withExtension: "js"),
            let source = try? String(contentsOf: scriptURL) else {
                // The application would not function correctly without the
                // user script, so it's probably best to fail here.
                fatalError("Failed to load user script")
        }
        
        let userScript = WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true)
        
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)
        userContentController.add(self, name: "shouldShowSidebarButton")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.allowsLinkPreview = false
        
        return webView
    }()
    
    /// Clears all stored website data, including cookies.
    ///
    /// - Parameter completionHandler: The block to be invoked upon completion.
    func clearWebsiteData(completionHandler: @escaping () -> Void) {
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast,
            completionHandler: completionHandler)
    }
    
    /// Loads the sign in page, only allowing access to resources within the
    /// same directory.
    func loadSignInPage() {
        let resourceDirectoryName = "Sign In"
        
        let fileURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html",
            subdirectory: resourceDirectoryName)
        
        let resourceURL = Bundle.main.url(
            forResource: resourceDirectoryName,
            withExtension: nil)
        
        if let fileURL = fileURL, let resourceURL = resourceURL {
            webView.loadFileURL(fileURL, allowingReadAccessTo: resourceURL)
        }
    }
    
    /// Loads the default page. If the user is signed in, this would be the
    /// main site, otherwise it would be the sign in page.
    func loadDefaultPage() {
        if let token = CollatedClient.shared.token {
            load(urlString: collatedSiteURLString
                + "api/users/auth/ios-app?token=" + token)
        } else {
            loadSignInPage()
        }
    }
    
    /// Loads the supplied URL in the web view.
    ///
    /// - Precondition: The supplied `urlString` must be a valid URL.
    /// - Parameter urlString: The URL to load.
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
    /// Determines whether the supplied URL is allowed to be loaded in the web
    /// view. Only the collated site and sign in page should be allowed,
    /// however an exception must be made for the sign in page authentication
    /// links which should not be allowed to load in the web view.
    ///
    /// - Parameter navigationURL: The URL to be navigated to.
    /// - Returns: `true` if the URL is permitted in the web view.
    func isPermittedURL(_ navigationURL: URL) -> Bool {
        if navigationURL.absoluteString.hasPrefix(collatedSiteURLString) {
            if let currentURL = webView.url, currentURL.isFileURL {
                // Prevent sign in page links from being opened in the web view
                return false
            }
            // Allow all app.collated.net links
            return true
        }
        // Allow all local file URLs such as the sign in page
        return navigationURL.isFileURL
    }
    
    // MARK: - UIBarButtonItems
    
    lazy var sidebarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(named: "SidebarIcon"),
            style: .plain,
            target: self,
            action: #selector(sidebarButtonAction))
    }()
    
    lazy var signOutButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: UIImage(named: "SignOutIcon"),
            style: .plain,
            target: self,
            action: #selector(signOutButtonAction))
    }()
    
    /// Displays the appropriate `UIBarButtonItem`s in the navigation bar,
    /// with respect to the supplied URL.
    ///
    /// - Parameter url: The URL for which the
    func updateNavigationBarButtons(for url: URL) {
        let isCollatedSite = url.absoluteString
            .hasPrefix(collatedSiteURLString)
        
        navigationItem.setLeftBarButton(
            isCollatedSite ? sidebarButton : nil,
            animated: true)
        
        navigationItem.setRightBarButton(
            isCollatedSite ? signOutButton : nil,
            animated: true)
    }
    
    // MARK: - UIBarButtonItem Actions
    
    func signOutButtonAction() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let signOutAction = UIAlertAction(
            title: "Sign Out",
            style: .destructive) { (_) in
                self.clearWebsiteData() {
                    CollatedClient.shared.token = nil
                    self.loadSignInPage()
                }
        }
        
        let alertController = UIAlertController(
            title: "Are you sure you want to sign out?",
            message: nil,
            preferredStyle: .alert)
        alertController.addAction(cancelAction)
        alertController.addAction(signOutAction)
        
        present(alertController, animated: true)
    }
    
    func sidebarButtonAction() {
        webView.evaluateJavaScript("CollatedUserScript.toggleSidebar()")
    }
    
    // MARK: - Overlay View Controllers
    
    /// Presents an error within a `UIAlertController`.
    ///
    /// - Parameter error: The error to display.
    func presentError(_ error: Error) {
        let alertAction = UIAlertAction(
            title: "Retry",
            style: .default) { (_) in
                // Attempt to reload
                self.loadDefaultPage()
        }
        
        let alertController = UIAlertController(
            title: "Failed to Load",
            message: error.localizedDescription,
            preferredStyle: .alert)
        alertController.addAction(alertAction)
        
        present(alertController, animated: true)
    }
    
    /// Presents a `SFSafariViewController` for the supplied URL, which is
    /// appropriately styled on iOS 10 and above.
    ///
    /// - Parameter url: The URL to load.
    func presentSafariViewController(forURL url: URL) {
        guard let scheme = url.scheme,
            scheme == "https" || scheme == "http" else {
                NSLog("SFSafariViewController cannot open URL: \(url)")
                return
        }
        
        let safariViewController = SFSafariViewController(url: url)
        
        if #available(iOS 10.0, *),
            let navigationBar = navigationController?.navigationBar,
            let barTintColor = navigationBar.barTintColor {
            safariViewController.preferredControlTintColor = barTintColor
        }
        
        present(safariViewController, animated: true)
    }
    
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        presentError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        presentError(error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, !isPermittedURL(url) {
            presentSafariViewController(forURL: url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url { updateNavigationBarButtons(for: url) }
    }
    
}

// MARK: - CollatedClientAuthenticationDelegate
extension WebViewController: CollatedClientAuthenticationDelegate {
    
    func authenticationDidComplete(withToken token: String) {
        if let safariViewController = presentedViewController
            as? SFSafariViewController {
            safariViewController.dismiss(animated: true)
        }
        
        loadDefaultPage()
    }
    
}

// MARK: - WKScriptMessageHandler
extension WebViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "shouldShowSidebarButton",
            let shouldShowSidebarButton = message.body as? Bool
            else { return }
        
        navigationItem.setLeftBarButton(
            shouldShowSidebarButton ? sidebarButton : nil,
            animated: true)
    }
    
}
