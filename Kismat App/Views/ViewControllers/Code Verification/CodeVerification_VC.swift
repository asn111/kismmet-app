//
//  CodeVerification_VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 07/06/2023.
//

import UIKit
import CDAlertView

class CodeVerification_VC: MainViewController {
    
    //MARK: OUTLETS
    @IBOutlet weak var numberLbl: fullyCustomLbl!
    
    @IBOutlet weak var firstTF: FormTextField!
    @IBOutlet weak var secondTF: FormTextField!
    @IBOutlet weak var thirdTF: FormTextField!
    @IBOutlet weak var fourthTF: FormTextField!
    @IBOutlet weak var fifthTF: FormTextField!
    @IBOutlet weak var sixthTF: FormTextField!
    
    @IBOutlet weak var verifyBtn: RoundCornerButton!
    
    @IBOutlet weak var resendCodeLbl: fullyCustomLbl!
    
    @IBOutlet weak var numberView: RoundCornerView!
    @IBOutlet weak var codeView: RoundCornerView!
    
    @IBOutlet weak var phoneNumTF: FormTextField!
    
    @IBOutlet weak var backBtn: RoundCornerButton!
    @IBAction func backBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func logOutBtn(_ sender: Any) {
        showAlert()
    }
    
    //MARK: PROPERTIES
    var email = ""
    var verificationCode = 0
    var fromSignup = false
    var emailSent = false
    
    //MARK: VC CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupThings()
        setupButtons()
        setupTextFeilds()
        
        
    }

    
    //MARK: Objc Functions
    
    @objc func action() {
        view.endEditing(true)
    }
    
    @objc
    func resendCode() {
        if email != "" {
            view.endEditing(true)
            sendEmail()
        }
    }
    
    @objc
    func verifyBtnPressed(sender:UIButton) {
        
        if !emailSent {
            email = phoneNumTF.text?.isValidEmail ?? false ? phoneNumTF.text! : ""
            if email != "" {
                sendEmail()
            } else {
                AppFunctions.showSnackBar(str: "Empty or invalid email address")
            }
        } else {
            if verificationCode != 0 {
                verifyCode()
            } else {
                AppFunctions.showSnackBar(str: "Empty or invalid Verification Code")
            }
        }
    }
    
    @objc func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty{
            Logs.show(message: "empty String")
            return true
        }
        //----------------------------------------------------------------
        
        if Int(string) == nil {
            Logs.show(message: "no Int")
            return false
        }
        //----------------------------------------------------------------
        
        if string.count == 6 {
            
            Logs.show(message: "String: \(string)")
            
            firstTF.text = "\(string[0])"
            secondTF.text = "\(string[1])"
            thirdTF.text = "\(string[2])"
            fourthTF.text = "\(string[3])"
            fifthTF.text = "\(string[4])"
            sixthTF.text = "\(string[5])"
            
            DispatchQueue.main.async {
                self.view.endEditing(true)
                Logs.show(message: "S1: \(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")")
                self.verificationCode = Int("\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")") ?? 0
            }
        }
        //----------------------------------------------------------------
        
        if string.count == 1 {
            Logs.show(message: "String2: \(string)")
            if (textField.text?.count ?? 0) == 1 && textField == firstTF {
                if (secondTF.text?.count ?? 0) == 1{
                    if (thirdTF.text?.count ?? 0) == 1{
                        if (fourthTF.text?.count ?? 0) == 1{
                            if (fifthTF.text?.count ?? 0) == 1{
                                sixthTF.text = string
                                DispatchQueue.main.async {
                                    self.view.endEditing(true)
                                    Logs.show(message: "S2: \(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")")
                                    self.verificationCode = Int("\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")") ?? 0
                                }
                                return false
                            }else{
                                fifthTF.text = string
                                return false
                            }
                        }else{
                            fourthTF.text = string
                            return false
                        }
                    }else{
                        thirdTF.text = string
                        return false
                    }
                }else{
                    secondTF.text = string
                    return false
                }
            }
        }
        //----------------------------------------------------------------
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        
        if count == 1{
            if textField == firstTF {
                DispatchQueue.main.async {
                    self.secondTF.becomeFirstResponder()
                }
            } else if textField == secondTF {
                DispatchQueue.main.async {
                    self.thirdTF.becomeFirstResponder()
                }
            } else if textField == thirdTF {
                DispatchQueue.main.async {
                    self.fourthTF.becomeFirstResponder()
                }
            } else if textField == fourthTF {
                DispatchQueue.main.async {
                    self.fifthTF.becomeFirstResponder()
                }
            } else if textField == fifthTF {
                DispatchQueue.main.async {
                    self.sixthTF.becomeFirstResponder()
                }
            } else {
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                    Logs.show(message: "S3: \(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")")
                    self.verificationCode = Int("\(self.firstTF.text ?? "")\(self.secondTF.text ?? "")\(self.thirdTF.text ?? "")\(self.fourthTF.text ?? "")\(self.fifthTF.text ?? "")\(self.sixthTF.text ?? "")") ?? 0
                }
            }
        }
        
        return count <= 1
        //----------------------------------------------------------------
        
    }
    
    
    //MARK: Other Functions
    
    func setupThings() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(resendCode))
        resendCodeLbl.isUserInteractionEnabled = true
        resendCodeLbl.addGestureRecognizer(tap)
        phoneNumTF.addDoneButtonOnKeyboard()

        if fromSignup {
            emailSent = true
            email = AppFunctions.getEmail()
            backBtn.isHidden = true
            numberView.isHidden = true
            codeView.isHidden = false
            numberLbl.isHidden = false
            numberLbl.text = "Code Sent on email: \(email)"
            verifyBtn.setTitle("Verify Code", for: .normal)
        } else {
            numberView.isHidden = false
            self.codeView.isHidden = true
            numberLbl.text = "Add email assosiated with your Kismmet account"
            verifyBtn.setTitle("Submit", for: .normal)
        }
        
        
    }
    
    func setupButtons() {
        verifyBtn.addTarget(self, action: #selector(verifyBtnPressed(sender:)), for: .touchUpInside)
    }
    
    func setupTextFeilds() {
        firstTF.delegate = self
        secondTF.delegate = self
        thirdTF.delegate = self
        fourthTF.delegate = self
        fifthTF.delegate = self
        sixthTF.delegate = self
        firstTF.textContentType = .oneTimeCode
        dismissTextFeild(textFiled: sixthTF)
    }

    
    func dismissTextFeild(textFiled: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(action))
        toolBar.setItems([cancelButton], animated: true)
        toolBar.isUserInteractionEnabled = true
        textFiled.inputAccessoryView = toolBar
    }
    
    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to exit the setup?", type: .warning)
        let action = CDAlertViewAction(title: "Yes",
                                       handler: {[weak self] action in
            AppFunctions.resetDefaults2()
            DBService.removeCompletedDB()
            self?.navigateVC(id: "SplashVC") { (vc:SplashVC) in }
            return true
        })
        let cancel = CDAlertViewAction(title: "Cancel",
                                       handler: { action in
            print("CANCEL PRESSED")
            return true
        })
        alert.isTextFieldHidden = true
        alert.add(action: action)
        alert.add(action: cancel)
        alert.hideAnimations = { (center, transform, alpha) in
            transform = .identity
            alpha = 0
        }
        alert.show() { (alert) in
            print("completed")
        }
    }
    
    //MARK: Web Calls
    
    func sendEmail() {
        self.showPKHUD(WithMessage: "")
        
        let pram : [String : Any] = ["email": email]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .sendEmailToVerify(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.emailSent = true
                            self.view.endEditing(true)
                            self.numberView.isHidden = true
                            self.codeView.isHidden = false
                            self.numberLbl.isHidden = false
                            self.numberLbl.text = "Code Sent on email: \(self.email)"
                            self.verifyBtn.setTitle("Verify Code", for: .normal)
                            
                            self.hidePKHUD()
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
    
    func verifyCode() {
        self.showPKHUD(WithMessage: "Verifying Code")
        
        let pram : [String : Any] = [ "email":email,
                "verificationCode": "\(verificationCode)",
                "isEmailValidationCode": true
        ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        self.hidePKHUD()
        
        APIService
            .singelton
            .codeVerificationNLogin(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.hidePKHUD()
                            AppFunctions.saveEmail(name: "")
                            if self.fromSignup {
                                self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
                            } else {
                                self.presentVC(id: "ChangePassVC") { (vc:ChangePassVC) in
                                    vc.isForgotPass = true
                                }
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
