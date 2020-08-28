//
//  EditNodeViewController.swift
//  Ode
//
//  Created by Luqmaan Khan on 8/27/20.
//  Copyright © 2020 Luqmaan Khan. All rights reserved.
//

import UIKit

class EditNodeViewController: UIViewController {

    var movieURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func dropButtonTapped(_ sender: UIButton) {
        let dropVC = DropOdeViewController()
        dropVC.movieURL = self.movieURL
        self.navigationController?.pushViewController(dropVC, animated: true)
    }
}
