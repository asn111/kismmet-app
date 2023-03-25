//
//  EditProfileSetupExt.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 22/02/2023.
//

import Foundation
import UIKit
import MultiSlider

class EditProfileSetupExt: MainViewController {
    
    @IBOutlet weak var profileExtTV: UITableView!
    
    var placeholderArray = ["","","","","","","Public Email","Phone",""]
    var dataArray = ["","","","","","","tamara@gmail.com","23456789",""]
    
    var isFromSetting = true
    
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
        profileExtTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")

        profileExtTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileExtTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func toolTipBtnPressed(sender:UIButton) {
        AppFunctions.showToolTip(str: "This is your personal email address, not visible to app users.", btn: sender)
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
extension EditProfileSetupExt : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0: // Header
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "Hi, Tamara"
                cell.headerLbl.textAlignment = .left
                cell.searchView.isHidden = false
                cell.swipeTxtLbl.isHidden = true
                cell.headerView.isHidden = false
                cell.notifBtn.isHidden = true
                cell.picBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)


                
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
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode()
                    cell.numberTF.text = dataArray[indexPath.row]
                    cell.numberTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])
                    
                } else {
                    cell.numberView.isHidden = true
                    cell.generalTFView.isHidden = false
                    cell.toolTipBtn.isHidden = false
                    cell.generalTF.text = dataArray[indexPath.row]
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
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

