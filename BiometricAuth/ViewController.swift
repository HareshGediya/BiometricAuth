//
//  ViewController.swift
//  BiometricAuth
//
//  Created by Haresh Gediya on 15/04/20.
//  Copyright © 2020 Haresh Gediya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocalAuth.shared.authentication(success: {
            DispatchQueue.main.async() {
                let alert = UIAlertController(title: "Success", message: "Authenticated succesfully!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }, failure: { error in
            #if DEBUG
            print(error)
            #endif
        })
    }


}

