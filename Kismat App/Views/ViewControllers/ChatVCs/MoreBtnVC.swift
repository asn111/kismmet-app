//
//  MoreBtnVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 29/09/2024.
//

import UIKit

class MoreBtnVC: MainViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.layer.cornerRadius = 16
        self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]

    }

}
