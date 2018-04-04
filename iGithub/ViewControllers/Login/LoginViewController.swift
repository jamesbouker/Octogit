//
//  LoginViewController.swift
//  iGithub
//
//  Created by Chan Hocheung on 7/20/16.
//  Copyright © 2016 Hocheung. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var authorizeButton: UIButton! {
        didSet {
            authorizeButton.layer.borderColor = UIColor(netHex: 0x6CC644).cgColor
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
