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
    
    var sectionHeading = ["","Account","Features","Notifications","Help & Support",""]
    
    var accSecTxt = ["Edit Profile","Preferences","Change Password","Membership","Account Status"]
    var accSecImg = ["person.circle.fill","slider.horizontal.3","rectangle.and.pencil.and.ellipsis","creditcard","checkmark.seal"]
    
    var featuresSecTxt = ["Social Links","Starred Users","Blocked Users"]
    var featuresSecImg = ["link","star.fill","minus.circle"]
    
    var notifSecTxt = ["Notifications"]
    var notifSecImg = ["bell.badge.fill"]
    
    var helpNsupportTxt = ["Privacy Policy","Terms of Services","About Kismmet","Support","How to Kismmet"]
    var helpNsupportImg = ["newspaper.fill","book.pages","exclamationmark.circle.fill","person.2.badge.gearshape.fill","apps.iphone"]
    
    var logoutTxt = ["Logout"]
    var logoutImg = ["rectangle.portrait.and.arrow.forward"]
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionHeading.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 1
            case 1:
                return accSecTxt.count
            case 2:
                return featuresSecTxt.count
            case 3:
                return notifSecTxt.count
            case 4:
                return helpNsupportTxt.count
            case 5:
                return logoutTxt.count
            default:
                return 0
        }
        //return lblTxt.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        
        // code for adding centered title
        headerView.backgroundColor = UIColor.clear
        
        let headerLabel = fullyCustomLbl(frame: CGRect(x: 18, y: 0, width: tableView.bounds.size.width, height: 28))
        headerLabel.font = UIFont(name: "Roboto", size: 16)?.regular
        headerLabel.textColor = UIColor(named: "Text grey")
        headerLabel.text = sectionHeading[section]
        headerLabel.textAlignment = .left
        
        // Vertically center the label within the header view
        let headerViewHeight = headerView.frame.size.height
        let labelHeight = headerLabel.frame.size.height
        let labelYPosition = (headerViewHeight - labelHeight) / 2
        
        headerLabel.frame = CGRect(x: 18, y: labelYPosition + 2, width: tableView.bounds.size.width, height: 28)
        
        headerView.addSubview(headerLabel)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
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
        } else {
            
            let cell : SettingTVCell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
                        
            switch indexPath.section {
                case 1:
                    cell.txtLbl.text = accSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: accSecImg[indexPath.row])
                case 2:
                    cell.txtLbl.text = featuresSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: featuresSecImg[indexPath.row])
                case 3:
                    cell.txtLbl.text = notifSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: notifSecImg[indexPath.row])
                case 4:
                    cell.txtLbl.text = helpNsupportTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: helpNsupportImg[indexPath.row])
                case 5:
                    cell.txtLbl.text = logoutTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: logoutImg[indexPath.row])
                default:
                    break
            }
            
            // Reset corner radius
            cell.mainView.layer.cornerRadius = 0
            cell.mainView.layer.maskedCorners = []
            
            let numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
            
            if numberOfRowsInSection == 1 {
                // Apply both top and bottom corner radii if the section has only one row
                cell.mainView.layer.cornerRadius = 8
                cell.mainView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else {
                // Apply top corner radius
                if indexPath.row == 0 {
                    cell.mainView.layer.cornerRadius = 8
                    cell.mainView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
                }
                
                // Apply bottom corner radius
                if indexPath.row == numberOfRowsInSection - 1 {
                    cell.mainView.layer.cornerRadius = 8
                    cell.mainView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                }
            }
            
            return cell
            
            /*switch indexPath.section {
                case 1:
                    cell.txtLbl.text = accSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: accSecImg[indexPath.row])
                    
                    if indexPath.row == 0 {
                        cell.mainView.topLimitedCornerRadius = 8
                    } else if indexPath.row == accSecTxt.count - 1 {
                        cell.mainView.botLimitedCornerRadius = 8
                    } else {
                        //cell.mainView.cornerRadius = 0
                    }
                    
                case 2:
                    cell.txtLbl.text = featuresSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: featuresSecImg[indexPath.row])

                    if indexPath.row == 0 {
                        cell.mainView.topLimitedCornerRadius = 8
                    } else if indexPath.row == featuresSecTxt.count - 1 {
                        cell.mainView.botLimitedCornerRadius = 8
                    } else {
                        //cell.mainView.cornerRadius = 0
                    }
                    
                case 3:
                    cell.txtLbl.text = notifSecTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: notifSecImg[indexPath.row])
                    cell.mainView.cornerRadius = 8

                    /*if indexPath.row == 0 {
                        cell.mainView.topLimitedCornerRadius = 8
                    } else if indexPath.row == notifSecTxt.count - 1 {
                        cell.mainView.botLimitedCornerRadius = 8
                    } else {
                        //cell.mainView.cornerRadius = 0
                    }*/
                    
                case 4:
                    cell.txtLbl.text = helpNsupportTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: helpNsupportImg[indexPath.row])

                    if indexPath.row == 0 {
                        cell.mainView.topLimitedCornerRadius = 8
                    } else if indexPath.row == helpNsupportTxt.count - 1 {
                        cell.mainView.botLimitedCornerRadius = 8
                    } else {
                        //cell.mainView.cornerRadius = 0
                    }
                    
                case 5:
                    cell.txtLbl.text = logoutTxt[indexPath.row]
                    cell.ivIcon.image = UIImage(systemName: logoutImg[indexPath.row])
                    cell.mainView.cornerRadius = 8

                    /*if indexPath.row == 0 {
                        cell.mainView.topLimitedCornerRadius = 8
                    } else if indexPath.row == logoutTxt.count - 1 {
                        cell.mainView.botLimitedCornerRadius = 8
                    } else {
                        //cell.mainView.cornerRadius = 0
                    }*/
                    
                default:
                    print("")
            }
            
            return cell*/
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            case 1:
                switch indexPath.row {
                    case 0:
                        self.pushVC(id: "EditProfileSetup") { (vc:EditProfileSetup) in }
                    case 1:
                        self.pushVC(id: "EditProfileSetupExt") { (vc:EditProfileSetupExt) in
                            vc.isFromSetting = true
                        }
                    case 2:
                        self.pushVC(id: "ChangePassVC") { (vc:ChangePassVC) in }
                    case 3:
                        self.pushVC(id: "MembershipVC") { (vc:MembershipVC) in }
                    case 4:
                        self.pushVC(id: "AccountStatusVC") { (vc:AccountStatusVC) in }
                    default:
                        print("")
                }
            case 2:
                switch indexPath.row {
                    case 0:
                        self.pushVC(id: "SocialLinkVC") { (vc:SocialLinkVC) in }
                    case 1:
                        self.pushVC(id: "StarredVC") { (vc:StarredVC) in }
                    case 2:
                        self.pushVC(id: "BlockedVC") { (vc:BlockedVC) in }
                    default:
                        print("")
                }
            case 3:
                switch indexPath.row {
                    case 0:
                        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
                    default:
                        print("")
                }
            case 4:
                switch indexPath.row {
                    case 0:
                        if let privacyPolicyURL = URL(string: "https://www.kismmet.com/privacypolicy") {
                            let safariVC = SFSafariViewController(url: privacyPolicyURL)
                            present(safariVC, animated: true)
                        } ///pp
                    case 1:
                        if let tosUrl = URL(string: "https://www.kismmet.com/termsofservices") {
                            let safariVC = SFSafariViewController(url: tosUrl)
                            present(safariVC, animated: true)
                        } ///tos
                    case 2:
                        if let privacyPolicyURL = URL(string: "https://www.kismmet.com/") {
                            let safariVC = SFSafariViewController(url: privacyPolicyURL)
                            present(safariVC, animated: true)
                        } ///about
                    case 3:
                        self.pushVC(id: "SupportPageVC") { (vc:SupportPageVC) in } ///support
                    case 4:
                        self.pushVC(id: "HowToUseVC") { (vc:HowToUseVC) in }///howToUse
                    default:
                        print("")
                }
            case 5:
                switch indexPath.row {
                    case 0:
                        showAlert()
                    default:
                        print("")
                }
                
            default:
                print("")
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 30 // Adjust height as needed
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

