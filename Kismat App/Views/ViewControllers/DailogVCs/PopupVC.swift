//
//  PopupVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 22/08/2023.
//

import UIKit

class PopupVC: MainViewController {

    
    @IBAction func okayBtnPressed(_ sender: Any) {
        if isProfilePicDialog {
            self.presentVC(id: "EditProfileSetup") { (vc:EditProfileSetup) in
                vc.isPicUpdateOnly = true
            }
        } else if isVersionUpdateDialog || isVersionMandatoryDialog {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1673236769") {
                UIApplication.shared.open(url)
            }
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        if !AppFunctions.isEmailVerified(){
            self.presentVC(id: "CodeVerification_VC") { (vc:CodeVerification_VC) in
                vc.fromSignup = true
            }
        } else if !AppFunctions.IsProfileUpdated(){
            self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
        } else {
            self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                vc.selectedIndex = 2
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1673236769") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBOutlet weak var textLbl: fullyCustomLbl!
    @IBOutlet weak var importantLbl: fullyCustomLbl!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var okayBtn: RoundCornerButton!
    @IBOutlet weak var cancelBtn: RoundCornerButton!
    @IBOutlet weak var doneBtn: RoundCornerButton!
    
    var isProfilePicDialog = false
    var isVersionUpdateDialog = false
    var isVersionMandatoryDialog = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isProfilePicDialog {
            importantLbl.text = "Update Your Profile Picture!"
            textLbl.text = "Your profile picture is currently not set. \nA complete profile helps others recognize you and enhances your app experience.\nTake a moment to upload a new picture today! Simply click update button below, choose your favorite photo, and update it now. Let’s make your profile stand out!"
            okayBtn.setTitle("Update Picture", for: .normal)
            okayBtn.backgroundColor = UIColor(named: "Danger")

        }
        
        if isVersionUpdateDialog {
            importantLbl.text = "New Version Alert!"
            textLbl.text = "The latest version of our app is now live on the App Store, and it’s packed with exciting improvements!\nEnjoy enhanced performance, bug fixes, new features, and improved security for a smoother, safer, and more enjoyable experience.\nTo update, simply click the update button below or visit the App Store, search for our app, and tap “Update.”"
            
            btnView.isHidden = false
            okayBtn.isHidden = true
            cancelBtn.setTitle("Maybe later", for: .normal)
            doneBtn.setTitle("Update now", for: .normal)
            
        }
        
        if isVersionMandatoryDialog {
            importantLbl.text = "New Version Alert!"
            textLbl.text = "The latest version of our app is now live on the App Store, and it’s packed with exciting improvements!\nEnjoy enhanced performance, bug fixes, new features, and improved security for a smoother, safer, and more enjoyable experience.\nTo update, simply click the update button below or visit the App Store, search for our app, and tap “Update.”"
            btnView.isHidden = true
            okayBtn.isHidden = false
            okayBtn.setTitle("Update Now", for: .normal)
            okayBtn.backgroundColor = UIColor(named: "Danger")
            
        }
    }
    
}
