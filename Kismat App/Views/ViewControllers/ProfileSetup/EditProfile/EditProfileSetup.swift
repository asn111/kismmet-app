//
//  EditProfileSetup.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 22/02/2023.
//

import Foundation
import UIKit

class EditProfileSetup: MainViewController {
    
    @IBOutlet weak var profileTV: UITableView!
    
    var placeholderArray = ["","Full Name","Date of Birth"
                            ,"Work Email","Where do you work / study?","Title","Tell us about your self..",""]
    var dataArray = ["","Tamara Pensiero ","Feb 25, 1993","tamar@kismet.org.com","Rice University, Houston TX","Professor","Chemistry professor, having a decade of experience in teaching chemistry. Completed PHD from Rich University, Houston TX. Nobel prize winner in....",""]
    
    var socialAccArray = ["","Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: ""),UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Insta"),UIImage(named: "snapchat"),UIImage(named: "website")]
    
    
    var isfromExtProf = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "ProfileHeaderTVCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        
        profileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        
        profileTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")
        profileTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    @objc func removeBtnPressed(sender:UIButton) {
        switch sender.tag {
            case placeholderArray.count:
                print("1")
            case placeholderArray.count + 1:
                print("2")
            case placeholderArray.count + 2:
                print("3")
            case placeholderArray.count + 3:
                print("4")
            case placeholderArray.count + 4:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
            default:
                print("")
        }
        
    }
    
    @objc func genBtnPressedForDone(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func genBtnPressedForProfile(sender:UIButton) {
        self.pushVC(id: "ProfileVC") { (vc:ProfileVC) in
            vc.isOtherProfile = true
        }
    }
    @objc func backBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: TableView Extention
extension EditProfileSetup : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count + socialAccArray.count + 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTVCell", for: indexPath) as! ProfileHeaderTVCell
                if isfromExtProf {
                    cell.backBtn.isHidden = false
                    cell.backBtn.addTarget(self, action: #selector(backBtnPressed(sender:)), for: .touchUpInside)
                }
                return cell
                
            case placeholderArray.count - 2 :
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                
                    cell.generalTV.text = dataArray[indexPath.row]
                    cell.generalTV.textColor = UIColor(named: "Text grey")

                return cell
                
            case placeholderArray.count - 1 :
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Link your social accounts"
                
                return cell
                
            case (placeholderArray.count + socialAccArray.count) - 1: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                
                return cell
                
            case placeholderArray.count + socialAccArray.count : // Tags Heading
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                cell.addBtn.isHidden = false
                
                return cell
                
            case placeholderArray.count + socialAccArray.count + 1 : // Tags view Btn
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                cell.isForEditing = true
                Logs.show(message: "INDEX Tags:  \(indexPath.row)")
                
                return cell
                
            case placeholderArray.count + socialAccArray.count + 2 : // Tags Count view
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "You can maximum add five tags."
                Logs.show(message: "INDEX Counts:  \(indexPath.row)")
                
                return cell
                
            case placeholderArray.count + socialAccArray.count + 3: // Profile Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                                
                
                cell.arrowView.isHidden = true
                cell.genBtn.titleLabel?.font = UIFont(name: "Work Sans", size: 14)?.medium
                cell.genBtn.setTitle("Preview profile", for: .normal)
                cell.genBtn.backgroundColor = UIColor.clear
                cell.genBtn.tintColor = UIColor(named: "Secondary Grey")
                cell.genBtn.underline()
                cell.genBtn.isWork = true
                cell.genBtn.addTarget(self, action: #selector(genBtnPressedForProfile(sender:)), for: .touchUpInside)
                
                
                return cell
                
                
            case placeholderArray.count + socialAccArray.count + 4: // Done Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                cell.genBtn.setTitle("Done", for: .normal)
                cell.arrowView.isHidden = true
                
                
                cell.genBtn.addTarget(self, action: #selector(genBtnPressedForDone(sender:)), for: .touchUpInside)
                return cell
                
            default:
                if indexPath.row <= placeholderArray.count - 1 {
                    let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                    
                    if placeholderArray[indexPath.row] == "Phone" {
                        cell.numberView.isHidden = false
                        cell.generalTFView.isHidden = true
                        cell.setupCountryCode()
                        cell.numberTF.placeholder = placeholderArray[indexPath.row]
                        AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])
                        if isfromExtProf {
                            cell.numberTF.text = dataArray[indexPath.row]
                        }
                    } else {
                        cell.numberView.isHidden = true
                        cell.generalTFView.isHidden = false
                        cell.generalTF.placeholder = placeholderArray[indexPath.row]
                        AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
                        if isfromExtProf {
                            cell.generalTF.text = dataArray[indexPath.row]
                        }
                    }
                    if placeholderArray[indexPath.row] == "Work Email" {
                        cell.toolTipBtn.isHidden = false
                    } else if placeholderArray[indexPath.row] == "Date of Birth" {
                        cell.toolTipBtn.isHidden = false
                    } else {
                        cell.toolTipBtn.isHidden = true
                    }
                    return cell
                    
                } else {
                    let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                    cell.removeBtn.isHidden = false
                    cell.socialImgView.image = socialAccImgArray[(indexPath.row - placeholderArray.count) + 1]
                    cell.socialLbl.text = socialAccArray[(indexPath.row - placeholderArray.count) + 1]
                    if socialAccArray[(indexPath.row - placeholderArray.count) + 1] == "My Website" {
                        cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                        cell.removeBtn.cornerRadius = 4
                        cell.removeBtn.tag = indexPath.row
                    }
                    cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                    return cell
                }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == (placeholderArray.count + socialAccArray.count) - 1 {
            return 20.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccArray.count + 2 {
            return 30.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccArray.count + 3 {
            return 30.0 // profile btn
        } else {
            return UITableView.automaticDimension
        }
    }
}

