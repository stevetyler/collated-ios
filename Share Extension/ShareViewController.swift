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
        return CollatedClient.shared.isAuthenticated && !contentText.isEmpty
    }
    
    override func didSelectPost() {
        guard let context = extensionContext,
            let item = context.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String)
            else { return }
        
        itemProvider.loadItem(
            forTypeIdentifier: kUTTypeURL as String,
            completionHandler: { (url, error) -> Void in
                
                if let url = url as? URL {
                    CollatedClient.shared.submit(
                        url: url.absoluteString,
                        title: self.contentText)
                }
                
                context.completeRequest(returningItems: [])
        })
    }
    
}
