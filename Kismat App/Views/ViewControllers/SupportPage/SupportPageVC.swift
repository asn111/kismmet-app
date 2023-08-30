//
//  SupportPageVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 27/08/2023.
//

import UIKit

class SupportPageVC: MainViewController {

    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    @IBOutlet weak var emailLbl: fullyCustomLbl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "support@kismmet.com")
        attributeString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        emailLbl.attributedText = attributeString

        
        let tap = UITapGestureRecognizer(target: self, action: #selector(emailTapFunction(sender:)))
        emailLbl.isUserInteractionEnabled = true
        emailLbl.addGestureRecognizer(tap)
    }
    @objc
    func emailTapFunction(sender:UITapGestureRecognizer) {
        if let url = URL(string: "mailto:support@kismmet.com") {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }

}
