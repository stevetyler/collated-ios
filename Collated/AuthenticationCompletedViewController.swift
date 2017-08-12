//
//  AuthenticationCompletedViewController.swift
//  Collated-Share
//
//  Created by Miles Dunne on 11/08/2017.
//  Copyright © 2017 Collated Services Ltd. All rights reserved.
//

import UIKit

class AuthenticationCompletedViewController: UIViewController {
    
    // MARK: - Interface Builder Actions
    
    @IBAction func signOutAction(_ sender: UIButton) {
        CollatedClient.shared.token = nil
        dismiss(animated: true)
    }

}
