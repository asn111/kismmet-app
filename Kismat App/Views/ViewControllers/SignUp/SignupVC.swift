//
//  SignupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SignupVC: MainViewController {

    
    
    @IBAction func signUpBtnPressed(_ sender: Any) {
        self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
    }
    
    
    @IBOutlet weak var emailTF: FormTextField!
    
    @IBOutlet weak var passwordTF: FormTextField!
    @IBOutlet weak var confirmPassword: FormTextField!
    
    @IBOutlet weak var loginLbl: fullyCustomLbl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTF.addDoneButtonOnKeyboard()
        passwordTF.addDoneButtonOnKeyboard()
        confirmPassword.addDoneButtonOnKeyboard()
        
        setupLbl()
        
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

    @objc func handleTap() {
        self.presentVC(id: "SignInVC") { (vc:SignInVC) in }
    }
}
