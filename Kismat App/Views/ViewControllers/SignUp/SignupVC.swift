//
//  SignupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SignupVC: MainViewController {

    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.pushVC(id: "SignInVC") { (vc:SignInVC) in }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
