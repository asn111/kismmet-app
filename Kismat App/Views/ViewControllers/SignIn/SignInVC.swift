//
//  SignInVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class SignInVC: MainViewController {

    @IBAction func SignInBtnPressed(_ sender: Any) {
        if email != "" && password != "" {
            isKeyBoardShown = false
            view.endEditing(true)
            userLogin()
        } else {
            AppFunctions.showSnackBar(str: "Invalid or Empty Feilds")
        }
    }
    
    @IBOutlet weak var emailTF: FormTextField!
    @IBOutlet weak var passwordTF: FormTextField!
    
    @IBOutlet weak var signUpLbl: fullyCustomLbl!
    
    var isKeyBoardShown = false
    var email = ""
    var password = ""
    weak var activeTextField: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTF.delegate = self
        passwordTF.delegate = self
        emailTF.addDoneButtonOnKeyboard()
        passwordTF.addDoneButtonOnKeyboard()
        
        setupLbl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }

    func setupLbl() {
        let text = "Don’t have an account? Sing Up"
        let textRange = NSRange(location: 23, length: 7)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.medium , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81") , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: textRange)
        signUpLbl.attributedText = attributedText
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        signUpLbl.addGestureRecognizer(tapGesture)
        signUpLbl.isUserInteractionEnabled = true
    }
    
    //MARK: objc Functions

    @objc func handleTap() {
        self.presentVC(id: "SignupVC") { (vc:SignupVC) in }
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        Logs.show(message: "\(textField.text ?? "nil")")
        activeTextField = textField

        if textField == emailTF {
            email = textField.text!.isValidEmail ? textField.text! : ""
        } else if textField == passwordTF {
            password = !textField.text!.isTFBlank ? textField.text! : ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        var activeView: UIView?
        if let activeTextField = activeTextField {
            activeView = activeTextField
        }
        
        if let activeView = activeView {
            let frameInWindow = activeView.superview?.convert(activeView.frame, to: nil)
            let bottomOfTextField = frameInWindow?.maxY ?? 0
            let topOfKeyboard = UIScreen.main.bounds.height - keyboardSize.height
            
            if bottomOfTextField > topOfKeyboard {
                self.view.frame.origin.y -= bottomOfTextField - topOfKeyboard
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyBoardShown = false
        self.view.frame.origin.y = 0
    }
    
    //MARK: API Functions
    
    func userLogin() {
        self.showPKHUD(WithMessage: "Logging In")
        
        let pram : [String : Any] = ["email": email,
                                     "password": password,
                                     "deviceId":UIDevice.current.identifierForVendor!.uuidString,
                                     "deviceName":UIDevice.modelName,
                                     "devicePlatform":"iOS"]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userLogin(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.userProfile()
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
    
    
    func userProfile() {
        
        APIService
            .singelton
            .getUserById(userId: "")
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            if AppFunctions.IsProfileUpdated(){
                                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                    vc.selectedIndex = 2
                                }
                            } else {
                                self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
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
