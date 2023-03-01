//
//  SignInVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class SignInVC: MainViewController {

    @IBAction func SignInBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    @IBOutlet weak var emailTF: FormTextField!
    @IBOutlet weak var passwordTF: FormTextField!
    
    @IBOutlet weak var signUpLbl: fullyCustomLbl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTF.addDoneButtonOnKeyboard()
        passwordTF.addDoneButtonOnKeyboard()
        
        setupLbl()
        
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
    
    @objc func handleTap() {
        self.presentVC(id: "SignupVC") { (vc:SignupVC) in }
    }

}
