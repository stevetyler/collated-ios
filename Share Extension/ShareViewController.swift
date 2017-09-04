//
//  ShareViewController.swift
//  Share Extension
//
//  Created by Miles Dunne on 12/08/2017.
//  Copyright © 2017 Collated. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        placeholder = "Title"
    }
    
    // MARK: - SLComposeServiceViewController
    
    override func isContentValid() -> Bool {
        return CollatedClient.shared.isAuthenticated
            && !contentText.isEmpty
            && urlItemProvider != nil
    }
    
    override func didSelectPost() {
        urlItemProvider?.loadItem(
            forTypeIdentifier: kUTTypeURL as String,
            completionHandler: { (item, error) -> Void in
                if let url = item as? URL {
                    CollatedClient.shared.submit(
                        url: url.absoluteString,
                        title: self.contentText)
                }
                super.didSelectPost()
        })
    }
    
    // MARK: - General
    
    /// Returns the first `NSItemProvider` with an item conforming to the 
    /// `kUTTypeURL` type identifier.
    var urlItemProvider: NSItemProvider? {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProviders = item.attachments as? [NSItemProvider]
            else { return nil }
        
        return itemProviders.filter({
            $0.hasItemConformingToTypeIdentifier(kUTTypeURL as String)
        }).first
    }
    
}
