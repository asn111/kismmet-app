//
//  ChangePassVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit

class ChangePassVC: MainViewController {
    
    @IBOutlet weak var oldPasTF: FormTextField!
    @IBOutlet weak var newPassTF: FormTextField!
    @IBOutlet weak var confirmNewPassTF: FormTextField!
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        AppFunctions.colorPlaceholder(tf: oldPasTF, s: "Old Password")
        AppFunctions.colorPlaceholder(tf: newPassTF, s: "New Password")
        AppFunctions.colorPlaceholder(tf: confirmNewPassTF, s: "Confirm New Password")
        oldPasTF.addDoneButtonOnKeyboard()
        newPassTF.addDoneButtonOnKeyboard()
        confirmNewPassTF.addDoneButtonOnKeyboard()

        // Do any additional setup after loading the view.
    }

}
