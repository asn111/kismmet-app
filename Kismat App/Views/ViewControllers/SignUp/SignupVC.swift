//
//  SignupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SignupVC: MainViewController {
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        if email != "" && password != "" {
            isKeyBoardShown = false
            view.endEditing(true)
            userSignup()
        } else {
            AppFunctions.showSnackBar(str: "Invalid or Empty Feilds")
        }
        //self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
    }
    
    
    @IBOutlet weak var emailTF: FormTextField!
    
    @IBOutlet weak var passwordTF: FormTextField!
    @IBOutlet weak var confirmPassword: FormTextField!
    
    @IBOutlet weak var loginLbl: fullyCustomLbl!
    
    
    var isKeyBoardShown = false
    var email = ""
    var tempPass = ""
    var password = ""
    weak var activeTextField: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTF.delegate = self
        passwordTF.delegate = self
        confirmPassword.delegate = self
        emailTF.addDoneButtonOnKeyboard()
        passwordTF.addDoneButtonOnKeyboard()
        confirmPassword.addDoneButtonOnKeyboard()
        
        setupLbl()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func setupLbl() {
        let text = "Already have account? Login"
        let textRange = NSRange(location: 22, length: 5)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.medium , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81") , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: textRange)
        loginLbl.attributedText = attributedText
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        loginLbl.addGestureRecognizer(tapGesture)
        loginLbl.isUserInteractionEnabled = true
    }
    
    //MARK: objc Functions

    @objc func handleTap() {
        self.presentVC(id: "SignInVC") { (vc:SignInVC) in }
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        Logs.show(message: "\(textField.text ?? "nil")")
        activeTextField = textField

        if textField == emailTF {
            email = textField.text!.isValidEmail ? textField.text! : ""
        } else if textField == passwordTF {
            tempPass = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField == confirmPassword {
            password = textField.text!.caseInsensitiveCompare(tempPass) == .orderedSame ? textField.text! : ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    /*@objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyBoardShown {
                isKeyBoardShown = true
                self.view.frame.origin.y -= keyboardSize.height - 250
            }
        }
    }*/
    
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
    
    func userSignup() {
        self.showPKHUD(WithMessage: "Signing up")
        
        let pram : [String : Any] = [ "email": email,
                                     "password": password,
                                     "roleId": 1,
                                      "deviceId":UIDevice.current.identifierForVendor!.uuidString,
                                      "deviceName":UIDevice.modelName,
                                      "devicePlatform":"iOS"
        ]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userSignUp(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
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
