//
//  SettingVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit
import CDAlertView
import RealmSwift
import SafariServices

class SettingVC: MainViewController {

    
    @IBOutlet weak var settingTV: UITableView!
    
    var lblTxt = ["","Edit Profile","Preferences","Starred User","Social Links","Notifications","Change Password","Membership","Privacy Policy","Terms of Services","About Kismmet","Account Status","Support","How to Kismmet","Blocked Users","Logout"]
    
    var userdbModel : Results<UserDBModel>!
    var img = UIImage(named: "placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser()
        }
        registerCells()
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "notif" {
                self?.settingTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userProfile()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppFunctions.removeFromDefaults(key: tagsArray)
    }

    
    func registerCells() {
        
        settingTV.tableFooterView = UIView()
        settingTV.separatorStyle = .none
        settingTV.delegate = self
        settingTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        settingTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        
        settingTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        settingTV.register(UINib(nibName: "SettingTVCell", bundle: nil), forCellReuseIdentifier: "SettingTVCell")
    }
    
    func sendLocationForLogout() {
        let pram = ["lat": "",
                    "long":""
        ]
        SignalRService.connection.invoke(method: "UpdateUserLocation", pram) {  error in
            Logs.show(message: "\(pram)")
            //AppFunctions.showSnackBar(str: "loc killed")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }

    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to Logout?", type: .warning)
        let action = CDAlertViewAction(title: "Logout",
                                       handler: {[weak self] action in
            self?.sendLocationForLogout()
            AppFunctions.logoutUser()
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
    
    @objc func profilePicBtnPressed(sender: UIButton) {
        
        if sender.currentImage == img {
            return
        }
        self.presentVC(id: "EnlargedIV_VC", presentFullType: "over" ) { (vc:EnlargedIV_VC) in
            vc.profileImage = sender.currentImage ?? img!
        }
    }
    
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    //MARK: API METHODS
    
    func userProfile() {
        
        APIService
            .singelton
            .getUserById(userId: "")
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            Logs.show(message: "PROFILE: 👉🏻 \(String(describing: self.userdbModel))")
                            if DBService.fetchloggedInUser().count > 0 {
                                self.userdbModel = DBService.fetchloggedInUser()
                            }
                            self.settingTV.reloadData()
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
//MARK: TableView Extention
extension SettingVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lblTxt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "SETTINGS"
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.rattingBtn.isHidden = true
                cell.headerView.isHidden = false
                
                cell.picBtn.borderWidth = 0
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.nameLbl.text = user.userName
                        cell.educationLbl.text = user.email
                        cell.professionLbl.text = "\(user.countryCode)\(user.phone)"
                        
                        if user.profilePicture != "" {
                            let imageUrl = URL(string: user.profilePicture)
                            cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                        } else {
                            cell.profilePicBtn.setImage(img, for: .normal)
                        }
                        
                    }
                    
                }
                
                cell.profilePicBtn.addTarget(self, action: #selector(profilePicBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)

                if AppFunctions.isNotifNotCheck() {
                    cell.notifBtn.tintColor = UIColor(named:"Danger")
                } else if AppFunctions.isShadowModeOn() {
                    cell.notifBtn.tintColor = UIColor(named: "Primary Yellow")
                } else {
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
                }
                
                return cell
                
            default:
                let cell : SettingTVCell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
                cell.txtLbl.text = lblTxt[indexPath.row]
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 1:
                self.pushVC(id: "EditProfileSetup") { (vc:EditProfileSetup) in }
            case 2:
                self.pushVC(id: "EditProfileSetupExt") { (vc:EditProfileSetupExt) in
                    vc.isFromSetting = true
                }
            case 3:
                self.pushVC(id: "StarredVC") { (vc:StarredVC) in }
            case 4:
                self.pushVC(id: "SocialLinkVC") { (vc:SocialLinkVC) in }
            case 5:
                self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
            case 6:
                self.pushVC(id: "ChangePassVC") { (vc:ChangePassVC) in }
            case 7:
                self.pushVC(id: "MembershipVC") { (vc:MembershipVC) in }
            case 8:
                if let privacyPolicyURL = URL(string: "https://www.kismmet.com/privacypolicy") {
                    let safariVC = SFSafariViewController(url: privacyPolicyURL)
                    present(safariVC, animated: true)
                } ///pp
            case 9:
                if let tosUrl = URL(string: "https://www.kismmet.com/termsofservices") {
                    let safariVC = SFSafariViewController(url: tosUrl)
                    present(safariVC, animated: true)
                } ///tos
            case 10:
                if let privacyPolicyURL = URL(string: "https://www.kismmet.com/") {
                    let safariVC = SFSafariViewController(url: privacyPolicyURL)
                    present(safariVC, animated: true)
                } ///about
            case 11:
                self.pushVC(id: "AccountStatusVC") { (vc:AccountStatusVC) in }
            case 12:
                self.pushVC(id: "SupportPageVC") { (vc:SupportPageVC) in } ///support
            case 13:
                self.pushVC(id: "HowToUseVC") { (vc:HowToUseVC) in }///howToUse
            case 14:
                self.pushVC(id: "BlockedVC") { (vc:BlockedVC) in }
            case 15:
                showAlert()
            default:
                print("")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

