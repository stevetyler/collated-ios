//
//  CollatedClient.swift
//  Collated
//
//  Created by Miles Dunne on 10/08/2017.
//  Copyright © 2017 Collated Services Ltd. All rights reserved.
//

import Foundation
import KeychainSwift

class CollatedClient {
    
    static let shared = CollatedClient()
    
    // MARK: - Keychain
    
    private let tokenKey = "CollatedToken"
    
    private let keychain: KeychainSwift = {
        let keychain = KeychainSwift()
        keychain.accessGroup = "KQQJ9HW7KF.net.collated.ios"
        return keychain
    }()
    
    /// The token used for authentication against the web API.
    /// This value is stored in the keychain.
    var token: String? {
        get {
            return keychain.get(tokenKey)
        }
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: tokenKey)
            } else {
                keychain.delete(tokenKey)
            }
        }
    }
    
    /// Returns `true` when an API token is available for use.
    var isAuthenticated: Bool {
        return token != nil
    }
    
    // MARK: - General
    
    /// Provides a `URLSessionConfiguration` with a randomized identifier.
    private var backgroundConfiguration: URLSessionConfiguration {
        let identifier = "net.collated.ios.background"
        let configuration = URLSessionConfiguration
            .background(withIdentifier: "\(identifier).\(UUID().uuidString)")
        configuration.sharedContainerIdentifier = "group.net.collated.ios"
        return configuration
    }
    
    /// Submits the specified `url` and `title` to the web API.
    func submit(url: String, title: String) {
        guard let token = token else {
            NSLog("Submission failed: A token is required.")
            return
        }
        
        let parameters: [String: Any] = [
            "token": token,
            "titleArr": [title],
            "urlArr": [url]
        ]
        
        let apiURLString = "https://app.collated.net/api/v1/items/chrome"
        guard let url = URL(string: apiURLString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization
                .data(withJSONObject: parameters)
        } catch let error {
            NSLog("Submission failed: \(error.localizedDescription)")
            return
        }

        URLSession(configuration: backgroundConfiguration)
            .uploadTask(withStreamedRequest: request).resume()
    }
    
}
