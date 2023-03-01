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
    
    var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Insta"),UIImage(named: "snapchat"),UIImage(named: "website")]
    
    var isFromSetting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        profileExtTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        profileExtTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileExtTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    @objc func removeBtnPressed(sender:UIButton) {
        switch sender.tag {
            case 6:
                print("")
            case 7:
                print("")
            case 8:
                print("")
            case 9:
                print("")
            case 10:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
            default:
                print("")
        }
        
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        if sender.tag == socialAccImgArray.count + 11 {
            if isFromSetting {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                    vc.selectedIndex = 2
                }
            }
            
        } else {
            self.pushVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in
                vc.isfromExtProf = true
            }
        }
        
    }
    
    @objc func sliderChanged(slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)")
        if slider.draggedThumbIndex == 0 {
            //minValue = Int(round(slider.value[0]))
            //sliderStartLbl.text = "$\(Int(round(slider.value[0])))"
        } else if slider.draggedThumbIndex == 1 {
            //maxValue = Int(round(slider.value[1]))
            //sliderEndLbl.text = "$\(Int(round(slider.value[1])))"
            let cell : MixHeaderTVCell = profileExtTV.cellForRow(at: IndexPath(row: 1, section: 0)) as! MixHeaderTVCell
            cell.proximeterLbl.text = "\(Int(round(slider.value[1]))) m"
            profileExtTV.rectForRow(at: IndexPath(row: 1, section: 0))
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
                
                cell.welcomeHeaderLbl.text = "Hi, Tamara"
                
                
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
                return cell
            case 4: // Visibility 2
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Shadow Mode"
                return cell
            case 5: // Social Accounts Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Social accounts"
                if isFromSetting {
                    cell.headerLbl.text = "Link your social accounts"
                } else {
                    cell.addBtn.isHidden = false
                    cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                }
                
                return cell
                
            case socialAccImgArray.count + 6: // EmptyView
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                
                return cell
                
            case socialAccImgArray.count + 7: // Tags Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                cell.addBtn.isHidden = false
                cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            case socialAccImgArray.count + 8: // Tags view
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                cell.isForEditing = true

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
                if isFromSetting {
                    cell.removeBtn.isHidden = false
                }
                cell.socialImgView.image = socialAccImgArray[indexPath.row - 6]
                cell.socialLbl.text = socialAccArray[indexPath.row - 6]
                if socialAccArray[indexPath.row - 6] == "My Website" {
                    cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                    cell.removeBtn.cornerRadius = 4
                    cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                    cell.removeBtn.tag = indexPath.row
                }
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

