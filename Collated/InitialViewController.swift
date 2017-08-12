//
//  InitialViewController.swift
//  Collated-Share
//
//  Created by Miles Dunne on 10/08/2017.
//  Copyright © 2017 Collated Services Ltd. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    // MARK: - UIViewController
    
    override func viewDidAppear(_ animated: Bool) {
        if CollatedClient.shared.isAuthenticated {
            self.showAuthenticationComplete()
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton,
            let navigationController = segue.destination as? UINavigationController,
            let authenticationController = navigationController.viewControllers.first as? AuthenticationViewController
            else { return }
        
        authenticationController.completionHandler = {
            self.showAuthenticationComplete()
        }
        
        authenticationController.authenticationURL
            = authenticationURL(forService: serviceName(forTag: button.tag))
    }
    
    // MARK: - General
    
    func showAuthenticationComplete() {
        performSegue(withIdentifier: "authenticationCompleted", sender: nil)
    }
    
    func serviceName(forTag tag: Int) -> String {
        switch tag {
        case 0:
            return "facebook"
        case 1:
            return "twitter"
        default:
            return "slack"
        }
    }
    
    func authenticationURL(forService name: String) -> URL? {
        return URL(string: "https://app.collated.net/api/users/auth/\(name)/callback")
    }

}
