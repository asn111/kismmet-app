//
//  SplashVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SplashVC: MainViewController {

    @IBAction func continueBtnPressed(_ sender: Any) {
        self.navigateVC(id: "SignInVC") { (vc:SignInVC) in }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
  

}
