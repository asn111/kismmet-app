//
//  EditProfileSetupExt.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 22/02/2023.
//

import Foundation
import UIKit
import MultiSlider
import RealmSwift

class EditProfileSetupExt: MainViewController {
    
    @IBOutlet weak var profileExtTV: UITableView!
    
    var placeholderArray = ["","","","","","","Public Email","Phone",""]
    var dataArray = ["","","","","","","tamara@gmail.com","23456789",""]
    
    var isFromSetting = true
    var isProfileVisible = false
    var isShadowMode = false
    var proximity = 150
    var email = ""
    var phoneCode = ""
    var phoneNum = ""
    var name = ""

    var userdbModel = UserDBModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser().first!
        }
        
        proximity = userdbModel.proximity
        name = userdbModel.userName
        isProfileVisible = userdbModel.isProfileVisible
        isShadowMode = userdbModel.shadowMode
        email = userdbModel.email
        phoneCode = userdbModel.countryCode
        phoneNum = userdbModel.phone
        
        registerCells()
    }
    
    func registerCells() {
        
        profileExtTV.tableFooterView = UIView()
        profileExtTV.separatorStyle = .none
        profileExtTV.delegate = self
        profileExtTV.dataSource = self
        
        profileExtTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileExtTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        
        profileExtTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileExtTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")

        profileExtTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileExtTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }

    
    @objc func picBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        updateConfig()
    }
    
    func updateConfig() {
        let pram = ["proximity": "\(proximity)",
                    "shadowMode":"\(isShadowMode)",
                    "isProfileVisible":"\(isProfileVisible)"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        SignalRService.connection.invoke(method: "UpdateUserConfigurations", pram) {  error in            Logs.show(message: "\(pram)")
            self.navigationController?.popViewController(animated: true)
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    
    @objc func toolTipBtnPressed(sender:UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Turning off your profile visibility will make your account private, which means you won't appear in other people's feeds. However, please note that you also won't be able to search for other people on the app when your profile visibility is off."
        } else if sender.tag == 002 {
            msg = "Shadow mode lets you view profiles privately without appearing on the 'viewed by' page. This feature is only available for premium users."
        } else if sender.tag == 004 {
            msg = "Please note that the email and phone number fields on this page are private and will not be visible to other users. These fields are for account verification purposes only and will not be shared on your profile page, where you can add a separate email for networking."
        } else if sender.tag == 003 {
            msg = "The lock icon next to your phone number indicates that this number cannot be changed."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
    }
    
    @objc func sliderChanged(slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)")
        
        if slider.draggedThumbIndex == 1 {
            let cell : MixHeaderTVCell = profileExtTV.cellForRow(at: IndexPath(row: 1, section: 0)) as! MixHeaderTVCell
            cell.proximeterLbl.text = "\(Int(round(slider.value[1]))) m"
            profileExtTV.rectForRow(at: IndexPath(row: 1, section: 0))
            proximity = Int(round(slider.value[1]))
        }
    }
    
    @objc func toggleButtonPressed(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = profileExtTV.cellForRow(at: indexPath) as? MixHeaderTVCell {
            
            if cell.toggleBtn.tag == 3 {
                isProfileVisible = cell.toggleBtn.isOn
                //AppFunctions.setIsProfileVisble(value: cell.toggleBtn.isOn)
            } else {
                isShadowMode = cell.toggleBtn.isOn
                //AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
            }
        }
    }
    
    fileprivate func convertToDate(dateStr: String) -> Date {
        var theDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: dateStr) {
            theDate = date
        } else {
            print("Error: Unable to convert date string.")
        }
        
        return theDate
    }
    
}
//MARK: TableView Extention
extension EditProfileSetupExt : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0: // Header
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "Hi, \(name)"
                cell.headerLbl.textAlignment = .left
                cell.searchView.isHidden = false
                cell.swipeTxtLbl.isHidden = true
                cell.headerView.isHidden = false
                cell.notifBtn.isHidden = true
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)


                
                return cell
            case 1: // Proximity Lbl View
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.proximeterLbl.isHidden = false
                cell.headerLbl.text = "Set Proximity"
                cell.proximeterLbl.text = "\(proximity) m"
                
                return cell
            case 2: // Slider
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.sliderView.isHidden = false
                cell.slider.addTarget(self, action: #selector(sliderChanged(slider:)), for: .valueChanged) /// continuous changes
                return cell
            case 3: // Visibilty 1
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Profile Visibility"
                cell.toggleBtn.isOn = isProfileVisible
                cell.toggleBtn.tag = indexPath.row
                cell.toggleTooltipBtn.tag = 001
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                
                
                return cell
            case 4: // Visibility 2
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Shadow Mode"
                cell.toggleBtn.isOn = isShadowMode
                cell.toggleBtn.isEnabled = AppFunctions.isPremiumUser()
                cell.toggleBtn.tag = indexPath.row
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
                cell.toggleTooltipBtn.tag = 002
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                return cell
            case placeholderArray.count - 4: // Empty View
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell

                return cell
            case placeholderArray.count - 1: // Done Btn
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                cell.genBtn.tag = indexPath.row
                cell.arrowView.isHidden = true
                if isFromSetting {
                    cell.genBtn.setTitle("Update", for: .normal)
                } else {
                    cell.genBtn.setTitle("Save and Continue", for: .normal)
                }
                cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            default:
                
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                if placeholderArray[indexPath.row] == "Phone" {
                    cell.numberView.isHidden = false
                    cell.numberTF.isUserInteractionEnabled = false
                    cell.countryPickerView.isUserInteractionEnabled = false
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode(code: phoneCode)
                    cell.numberTF.text = phoneNum
                    cell.numberTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])
                    cell.lockTipBtn.tag = 003
                    
                    cell.lockTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                } else {
                    cell.numberView.isHidden = true
                    cell.generalTF.isUserInteractionEnabled = false
                    cell.generalTFView.isHidden = false
                    cell.toolTipBtn.isHidden = false
                    cell.generalTF.text = email
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
                    
                    cell.toolTipBtn.tag = 004
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                    
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        } else if indexPath.row == placeholderArray.count - 4 {
            return 30.0
        } else {
            return UITableView.automaticDimension
        }
    }
}

