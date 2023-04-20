//
//  ImportanDialogVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 19/02/2023.
//

import UIKit

class ImportantDialogVC: MainViewController {

    @IBOutlet weak var importantLbl: fullyCustomLbl!
    
    
    @IBAction func yesBtnPressed(_ sender: Any) {
        
        ApiService.updateAccountStatus(val: statusID)
        
        AppFunctions.resetDefaults2()
        DBService.removeCompletedDB()
        self.navigateVC(id: "SplashVC") { (vc:SplashVC) in }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var dialogType = ""
    var statusID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch dialogType {
            case "Deactivate" :
                importantLbl.text = "Are you certain that you wish to deactivate your account? Please note that you may reactivate your account at any time by simply logging in again."
                statusID = deactivedAccountStatusId
            case "Delete" :
                importantLbl.text = "Please confirm if you would like to proceed with account deletion. Please note that once the account is deleted, it cannot be recovered and a new account cannot be created using the same email address."
                statusID = deletedAccountStatusId
            default :
                print("default")
        }
        
    }

}
