//
//  ImportanDialogVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 19/02/2023.
//

import UIKit

class ImportantDialogVC: MainViewController {

    @IBOutlet weak var importantLbl: fullyCustomLbl!
    @IBOutlet weak var yesBtn: RoundCornerButton!
    @IBOutlet weak var cancelBtn: RoundCornerButton!
    
    
    @IBAction func yesBtnPressed(_ sender: Any) {
        
        switch dialogType {
            case "Deactivate" :
                ApiService.updateAccountStatus(val: statusID)
                
                AppFunctions.resetDefaults2()
                DBService.removeCompletedDB()
                self.navigateVC(id: "SplashVC") { (vc:SplashVC) in }
            case "Delete" :
                ApiService.updateAccountStatus(val: statusID)
                
                AppFunctions.resetDefaults2()
                DBService.removeCompletedDB()
                self.navigateVC(id: "SplashVC") { (vc:SplashVC) in }
            case "DeleteChat" :
                ApiService.deleteChatUsers(chatID: chatId)
                if let presentingVC = self.presentingViewController {
                    presentingVC.dismiss(animated: true) {
                        if let navigationController = presentingVC as? UINavigationController {
                            navigationController.popViewController(animated: true)
                        } else {
                            presentingVC.navigationController?.popViewController(animated: true)
                        }
                    }
                }

            default:
                break
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var dialogType = ""
    var statusID = 0
    var chatId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch dialogType {
            case "Deactivate" :
                importantLbl.text = "Are you certain that you wish to deactivate your account? Please note that you may reactivate your account at any time by simply logging in again."
                statusID = deactivedAccountStatusId
            case "Delete" :
                importantLbl.text = "Please confirm if you would like to proceed with account deletion. Please note that once the account is deleted, it cannot be recovered and a new account cannot be created using the same email address."
                statusID = deletedAccountStatusId
            case "DeleteChat" :
                importantLbl.text = "Are you sure you want to delete this chat?."
                yesBtn.backgroundColor = UIColor(hexFromString: "FD7575")
                cancelBtn.backgroundColor = UIColor(hexFromString: "EBEDF0")
                
                yesBtn.setTitle("Yes, Delete", for: .normal)
                cancelBtn.setTitle("No, Keep", for: .normal)
                
                
                
            default :
                print("default")
        }
        
    }

}
