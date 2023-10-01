//
//  SplashVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SplashVC: MainViewController {

    @IBAction func continueBtnPressed(_ sender: Any) {
        
        self.navigateVC(id: "SignupVC") { (vc:SignupVC) in }
    }

    @IBAction func signInBtn(_ sender: Any) {
        self.navigateVC(id: "SignupVC") { (vc:SignupVC) in }
    }
    
    @IBAction func loginBtn(_ sender: Any) {
        self.navigateVC(id: "SignInVC") { (vc:SignInVC) in }
    }
    
    @IBOutlet weak var lBtn: RoundCornerButton!
    
    @IBOutlet weak var sBtn: RoundCornerButton!
    
    
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var animateThisView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppFunctions.isLoggedIn() {
            
            self.startUpCall()
            self.getSocialAccounts()
            APIService.singelton.registerDeviceToken(token: AppFunctions.getDevToken())

        } else {
            //btnView.isHidden = false
            sBtn.isHidden = false
            lBtn.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func startUpCall() {
        
        APIService
            .singelton
            .startUpCall()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.accountStatusId != 0 {
                            
                            if let subs = val.subscription {
                                if subs == "Premium Plan" {
                                    AppFunctions.setIsPremiumUser(value: true)
                                } else {
                                    AppFunctions.setIsPremiumUser(value: false)
                                }
                            }
                            
                            if let shadowMode = val.shadowMode {
                                AppFunctions.setIsShadowMode(value: shadowMode)
                                
                            }
                            
                            if let profVis = val.isProfileVisible {
                                AppFunctions.setIsProfileVisble(value: profVis)
                                
                            }
                            
                            if let profVis = val.isProfileVisible {
                                AppFunctions.setIsProfileVisble(value: profVis)
                                
                            }
                            
                            if let emailVerifed = val.isEmailVarified {
                                AppFunctions.setIsEmailVerified(value: emailVerifed)
                                
                            }
                            
                            if let profCount = val.profileCountForSubscription {
                                AppFunctions.saveMaxProfViewedCount(count: profCount)
                            }
                            
                            if let accStatus = val.accountStatusId {
                                if accStatus == deactivedAccountStatusId {
                                    AppFunctions.resetDefaults2()
                                    DBService.removeCompletedDB()
                                    self.btnView.isHidden = false
                                    AppFunctions.showSnackBar(str: "Your Account is deactivated, please login again to get back in the app.")
                                } else if accStatus == deletedAccountStatusId {
                                    AppFunctions.resetDefaults2()
                                    DBService.removeCompletedDB()
                                    self.btnView.isHidden = false
                                    AppFunctions.showSnackBar(str: "Your Account is deleted, please create a new using different email to login back.")
                                } else if accStatus == activeAccountStatusId {
                                    self.userProfile()
                                }
                                
                            }
                            
                            
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
    
    func userProfile() {
        
        APIService
            .singelton
            .getUserById(userId: "")
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
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
    
    func getSocialAccounts() {
        
        APIService
            .singelton
            .getSocialAccounts()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            
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


