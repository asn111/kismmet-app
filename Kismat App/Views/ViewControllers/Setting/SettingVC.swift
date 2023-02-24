//
//  SettingVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit
import CDAlertView

class SettingVC: MainViewController {

    
    @IBOutlet weak var settingTV: UITableView!
    
    var lblTxt = ["","","Edit Profile","Edit Privacy Options","Notifications","Change Password","Membership","Privacy Policy","About Kismmet","Account Status","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        settingTV.tableFooterView = UIView()
        settingTV.separatorStyle = .none
        settingTV.delegate = self
        settingTV.dataSource = self
        settingTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        settingTV.register(UINib(nibName: "SettingTVCell", bundle: nil), forCellReuseIdentifier: "SettingTVCell")
    }
    
    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to Logout?", type: .warning)
        let action = CDAlertViewAction(title: "Logout",
                                       handler: {[weak self] action in
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
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
                cell.notifBtn.isHidden = true
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.ratingView.isHidden = true
                cell.headerView.isHidden = false
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                
                cell.nameLbl.text = "Tamara"
                cell.educationLbl.text = "tamara@gmail.com"
                cell.professionLbl.text = "+123456789"
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
                
            default:
                let cell : SettingTVCell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
                cell.txtLbl.text = lblTxt[indexPath.row]
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 2:
                self.pushVC(id: "EditProfileSetup") { (vc:EditProfileSetup) in }
            case 3:
                self.pushVC(id: "EditProfileSetupExt") { (vc:EditProfileSetupExt) in
                    vc.isFromSetting = true
                }
            case 4:
                self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
            case 5:
                self.pushVC(id: "ChangePassVC") { (vc:ChangePassVC) in }
            case 6:
                self.pushVC(id: "MembershipVC") { (vc:MembershipVC) in }
            case 9:
                self.pushVC(id: "AccountStatusVC") { (vc:AccountStatusVC) in }
            case 10:
                showAlert()
            default:
                print("")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

