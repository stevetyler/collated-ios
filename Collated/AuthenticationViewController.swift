//
//  AuthenticationViewController.swift
//  Collated
//
//  Created by Miles Dunne on 10/08/2017.
//  Copyright © 2017 Collated Services Ltd. All rights reserved.
//

import UIKit
import WebKit

class AuthenticationViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    /// The name of the WebKit message handler used to receive the API token.
    let tokenHandlerName = "tokenHandler"
    
    /// The URL of the authentication flow that should be used.
    var authenticationURL: URL?
    
    /// Called when authentication process completes successfully.
    var completionHandler: (() -> Void)?
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
    }
    
    // MARK: - General
    
    func setupWebView() {
        let userContentController = WKUserContentController()
        // Add message handler, this is then called from:
        // webkit.messageHandlers.tokenHandler.postMessage("token here");
        userContentController.add(self, name: tokenHandlerName)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        let webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        
        view.addSubview(webView)
        
        guard let url = authenticationURL else { return }
        webView.load(URLRequest(url: url))
    }
    
    /// Presents an error within a `UIAlertController`.
    func handleError(_ error: Error) {
        let action = UIAlertAction(
            title: "OK",
            style: .default) { (_) in
                self.dismiss(animated: true)
        }
        
        let alertController = UIAlertController(
            title: "Authentication Failed",
            message: error.localizedDescription,
            preferredStyle: .alert)
        
        alertController.addAction(action)
        
        present(alertController, animated: true)
    }

    // MARK: - Interface Builder Actions
    
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == tokenHandlerName,
            let token = message.body as? String
            else { return }
        
        CollatedClient.shared.token = token
        
        completionHandler?()
        
        // Dismiss the view controller as the auth process is now complete
        dismiss(animated: true)
    }

    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        navigationItem.title = "Loading…"
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigationItem.title = nil
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }
}
