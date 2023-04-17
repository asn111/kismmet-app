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
    var tempSocialAccArray = ["Network via LinkedIn","Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var isFromSetting = false
    var proximity = 150
    var tags = [String]()
    var addedSocialArray = [String]()
    var isProfileVisible = false
    
    var profileDict = [String: Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        Logs.show(message: "Profile: \(profileDict)")
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "tagsAdded" {
                Logs.show(message: val)
                if AppFunctions.getTagsArray().count > 0 {
                    self?.tags = AppFunctions.getTagsArray()
                    self?.profileExtTV.reloadRows(at: [IndexPath(row: (self?.socialAccImgArray.count)! + 8, section: 0)], with: .none)
                }
                
            } else if val.contains("socialAdded") {
                Logs.show(message: val)
                
                if AppFunctions.getSocialArray().count > 0 {
                    switch AppFunctions.getSocialArray().count {
                        case 1:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
                        case 2:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Your Instagram handle","Snapchat","Link your Website"]
                        case 3:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Snapchat","Link your Website"]
                        case 4:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Link your Website"]
                        case 5:
                            self?.socialAccArray = AppFunctions.getSocialArray()
                        default:
                            print("default")
                    }
                    var indexPaths: [IndexPath] = []
                    
                    for i in 6...10 {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self?.profileExtTV.reloadRows(at: indexPaths, with: .none)
                }
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppFunctions.removeFromDefaults(key: tagsArray)
        AppFunctions.removeFromDefaults(key: socialArray)
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
    
    func removeFromTagArray(index: Int) {
        var arr = AppFunctions.getTagsArray()
        arr.remove(at: (index/100 - 1))
        AppFunctions.setTagsArray(value: arr)
        self.tags.removeAll()
        self.tags = AppFunctions.getTagsArray()
        profileExtTV.reloadRows(at: [IndexPath(row: socialAccImgArray.count + 8, section: 0)], with: .fade)
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
                let arr = AppFunctions.getTagsArray()
                if arr.count >= 5 {
                    AppFunctions.showSnackBar(str: "Maximum tags added, remove to add new")
                    return
                }
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "tags"
                }
        }
        
    }
    
    @objc func removeBtnPressed(sender:UIButton) {
        switch sender.tag {
            case 6:
                socialAccArray[0] = tempSocialAccArray[0]
                profileExtTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 7:
                socialAccArray[1] = tempSocialAccArray[1]
                profileExtTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 8:
                socialAccArray[2] = tempSocialAccArray[2]
                profileExtTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 9:
                socialAccArray[3] = tempSocialAccArray[3]
                profileExtTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 10:
                socialAccArray[4] = tempSocialAccArray[4]
                profileExtTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 100:
                removeFromTagArray(index: sender.tag)
            case 200:
                removeFromTagArray(index: sender.tag)
            case 300:
                removeFromTagArray(index: sender.tag)
            case 400:
                removeFromTagArray(index: sender.tag)
            case 500:
                removeFromTagArray(index: sender.tag)
            default:
                print("default")
        }
    }
    
    @objc func toolTipBtnPressed(sender:UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Turning off your profile visibility will make your account private, which means you won't appear in other people's feeds. However, please note that you also won't be able to search for other people on the app when your profile visibility is off."
        } else if sender.tag == 002 {
            msg = "Shadow mode lets you view profiles privately without appearing on the 'viewed by' page. This feature is only available for premium users."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        
        Logs.show(message: "\(isProfileVisible), \(AppFunctions.isShadowModeOn()), \(proximity), \(tags)")
        
        if !tags.isEmpty {
            profileDict["tags"] = tags.joined(separator: ",")
            profileDict["proximity"] = proximity
            profileDict["isProfileVisible"] = isProfileVisible
            userProfileUpdate()
        } else {
            AppFunctions.showSnackBar(str: "Tags are important part of profile, please add at least one.")
        }
        
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
                AppFunctions.setIsProfileVisble(value: cell.toggleBtn.isOn)
            } else {
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
            }
        }
    }
    
    //MARK: API Functions
    
    func userProfileUpdate() {
        self.showPKHUD(WithMessage: "Signing up")
        
        Logs.show(message: "SKILLS PRAM: \(profileDict)")
        
        APIService
            .singelton
            .userProfileUpdate(pram: profileDict)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                vc.selectedIndex = 2
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
                cell.toggleTooltipBtn.tag = 001
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)

                return cell
            case 4: // Shadow mode 2
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Shadow Mode"
                cell.toggleBtn.isOn = false
                cell.toggleBtn.isEnabled = false
                cell.toggleBtn.tag = indexPath.row
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
                cell.toggleTooltipBtn.tag = 002
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
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
                                
                cell.removeBtn1.tag = 100
                cell.removeBtn2.tag = 200
                cell.removeBtn3.tag = 300
                cell.removeBtn4.tag = 400
                cell.removeBtn5.tag = 500
                
                cell.removeBtn1.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn2.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn3.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn4.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn5.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)

                cell.tagView1.isHidden = true
                cell.tagView2.isHidden = true
                cell.tagView3.isHidden = true
                cell.tagView4.isHidden = true
                cell.tagView5.isHidden = true
                
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
                
                
                cell.socialImgView.image = socialAccImgArray[indexPath.row - 6]
                cell.socialLbl.text = socialAccArray[indexPath.row - 6]
                cell.socialLbl.isUserInteractionEnabled = false
                
                if socialAccArray[indexPath.row - 6].isEqual(tempSocialAccArray[indexPath.row - 6]) {
                    cell.removeBtn.removeTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                    cell.removeBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                    cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                    cell.removeBtn.cornerRadius = 4
                    
                } else {
                    cell.removeBtn.removeTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                    cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                    cell.removeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
                    cell.removeBtn.cornerRadius = 10
                }
                
                cell.removeBtn.tag = indexPath.row

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

