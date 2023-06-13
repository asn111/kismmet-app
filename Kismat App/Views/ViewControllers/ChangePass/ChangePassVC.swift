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
    @IBOutlet weak var personIcon: UIButton!
    @IBOutlet weak var backBtn: RoundCornerButton!
    
    @IBOutlet weak var oldPassView: RoundCornerView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if isForgotPass {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        updatePass()
    }
    
    var isForgotPass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isForgotPass {
            personIcon.isHidden = true
            oldPassView.isHidden = true
        }

        AppFunctions.colorPlaceholder(tf: oldPasTF, s: "Old Password")
        AppFunctions.colorPlaceholder(tf: newPassTF, s: "New Password")
        AppFunctions.colorPlaceholder(tf: confirmNewPassTF, s: "Confirm New Password")
        oldPasTF.addDoneButtonOnKeyboard()
        newPassTF.addDoneButtonOnKeyboard()
        confirmNewPassTF.addDoneButtonOnKeyboard()

        // Do any additional setup after loading the view.
    }
    
    func updatePass() {
        self.showPKHUD(WithMessage: "Signing up")
        
        var newPassword = ""
        if isForgotPass {
            if let newPass = newPassTF.text,
               let confirmNewPass = confirmNewPassTF.text,
               newPass.caseInsensitiveCompare(confirmNewPass) == .orderedSame {
                // Passwords match
                newPassword = newPass
            } else {
                AppFunctions.showSnackBar(str: "Passwords dosen't match")
                self.hidePKHUD()
                return
            }
        } else {
            if !(oldPasTF.text?.isTFBlank ?? false) {
                if let newPass = newPassTF.text,
                   let confirmNewPass = confirmNewPassTF.text,
                   newPass.caseInsensitiveCompare(confirmNewPass) == .orderedSame {
                    // Passwords match
                    newPassword = newPass

                } else {
                    AppFunctions.showSnackBar(str: "Passwords dosen't match")
                    self.hidePKHUD()
                    return
                }
            } else {
                AppFunctions.showSnackBar(str: "Old password can not be empty")
                self.hidePKHUD()
                return
            }
        }
        
        let pram : [String : Any] = [ "oldPassword": oldPasTF.text ?? "",
                                      "newPassword": newPassword,
                                      "isForgotPassword": isForgotPass
        ]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        
        APIService
            .singelton
            .changePassword(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.hidePKHUD()
                            AppFunctions.showSnackBar(str: "Passwords updated successfully")
                            if self.isForgotPass {
                                self.navigateVC(id: "SignInVC") { (vc:SignInVC) in }
                            } else {
                                self.navigationController?.popViewController(animated: true)
                            }
                        } else {
                            self.hidePKHUD()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
    }
    

}
