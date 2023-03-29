//
//  ProfileSetupExtend.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 15/02/2023.
//

import UIKit
import MultiSlider

class ProfileSetupExtend: MainViewController {
    
    @IBOutlet weak var profileExtTV: UITableView!
    
    var socialAccArray = ["Network via LinkedIn","Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var isFromSetting = false
    var proximity = 0
    var tags = [String]()
    var isProfileVisible = false
    
    var profileDict = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        Logs.show(message: "Profile: \(profileDict)")
    }
    
    func registerCells() {
        
        profileExtTV.tableFooterView = UIView()
        profileExtTV.separatorStyle = .none
        profileExtTV.delegate = self
        profileExtTV.dataSource = self
        profileExtTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileExtTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        profileExtTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileExtTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        profileExtTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileExtTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        switch sender.tag {
            case 6:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "linkedIn"
                }
            case 7:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "twitter"
                }
            case 8:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "instagram"
                }
            case 9:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "snapchat"
                }
            case 10:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "website"
                }
            default:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "tags"
                }
        }
        
    }
    
    /*@objc func addBtnPressed(sender:UIButton) {
        self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
    }*/
    
    @objc func genBtnPressed(sender:UIButton) {
        
        Logs.show(message: "\(isProfileVisible), \(AppFunctions.isShadowModeOn()), \(proximity), \(tags)")
        
        /*if sender.tag == socialAccImgArray.count + 11 {
            if isFromSetting {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                    vc.selectedIndex = 2
                }
            }
            
        } else {
            self.pushVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
        }*/
        
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
            } else {
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
            }
        }
    }
}
//MARK: TableView Extention
extension ProfileSetupExtend : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialAccImgArray.count + 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0: // Header
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = false
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.welcomeView.isHidden = false
                
                cell.welcomeHeaderLbl.text = "Hi, \(profileDict["fullName"] ?? "")"
                
                
                return cell
            case 1: // Proximity Lbl View
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.proximeterLbl.isHidden = false
                cell.headerLbl.text = "Set Proximity"
                cell.proximeterLbl.text = "\(cell.maxValue/2) m"
                
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
                cell.toggleBtn.isOn = true
                cell.toggleBtn.tag = indexPath.row
                isProfileVisible = cell.toggleBtn.isOn
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)

                return cell
            case 4: // Visibility 2
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Shadow Mode"
                cell.toggleBtn.isOn = false
                cell.toggleBtn.tag = indexPath.row
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)

                return cell
            case 5: // Social Accounts Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Link your social accounts"
                
                return cell
                
            case socialAccImgArray.count + 6: // EmptyView
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                
                return cell
                
            case socialAccImgArray.count + 7: // Tags Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                cell.addBtn.isHidden = false
                cell.addBtn.tag = indexPath.row
                if tags.count == 5 {
                    cell.addBtn.isHidden = true
                } else {
                    cell.addBtn.isHidden = false
                }
                
                cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            case socialAccImgArray.count + 8: // Tags view
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                cell.isForEditing = true
                
                if tags.count > 0 {
                    for i in 0...tags.count - 1 {
                        switch i {
                            case 0:
                                cell.tagLbl1.text = "\(tags[i])"
                                cell.tagView1.isHidden = false
                            case 1:
                                cell.tagLbl2.text = "\(tags[i])"
                                cell.tagView2.isHidden = false
                            case 2:
                                cell.tagLbl3.text = "\(tags[i])"
                                cell.tagView3.isHidden = false
                            case 3:
                                cell.tagLbl4.text = "\(tags[i])"
                                cell.tagView4.isHidden = false
                            case 4:
                                cell.tagLbl5.text = "\(tags[i])"
                                cell.tagView5.isHidden = false
                            default:
                                print("default")
                        }
                    }
                }
                
                return cell
                
            case socialAccImgArray.count + 9: // Tags count
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "You can maximum add five tags."
                
                return cell
                
            case socialAccImgArray.count + 10: // Profile Btn
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                
                if isFromSetting {
                    cell.arrowView.isHidden = true
                    cell.genBtn.titleLabel?.font = UIFont(name: "Work Sans", size: 14)?.medium
                    cell.genBtn.setTitle("Preview profile", for: .normal)
                    cell.genBtn.backgroundColor = UIColor.clear
                    cell.genBtn.tintColor = UIColor(named: "Secondary Grey")
                    cell.genBtn.underline()
                    cell.genBtn.isWork = true
                    cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                } else {
                    cell.arrowView.isHidden = true
                    cell.genBtn.isHidden = true
                }
                
                
                return cell
                
            case socialAccImgArray.count + 11: // Update Btn
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                cell.genBtn.tag = indexPath.row
                if isFromSetting {
                    cell.genBtn.setTitle("Update", for: .normal)
                } else {
                    cell.genBtn.setTitle("Save and Continue", for: .normal)
                }
                cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                return cell
                 
            default: // Social Links
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                
                cell.removeBtn.isHidden = false
                cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                cell.removeBtn.cornerRadius = 4
                cell.removeBtn.tag = indexPath.row
                
                cell.socialImgView.image = socialAccImgArray[indexPath.row - 6]
                cell.socialLbl.text = socialAccArray[indexPath.row - 6]
                
                cell.removeBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        } else if indexPath.row == socialAccImgArray.count + 10 && !isFromSetting {
            return 0.0
        }else if indexPath.row == socialAccImgArray.count + 6 {
            return 20.0
        } else {
            return UITableView.automaticDimension
        }
    }
}

