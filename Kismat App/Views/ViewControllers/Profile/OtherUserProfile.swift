//
//  OtherUserProfile.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 27/03/2023.
//

import UIKit
import RxRealm
import RxSwift
import RealmSwift

class OtherUserProfile: MainViewController {
    

    @IBOutlet weak var otherProfileTV: UITableView!
    
    var socialAccArray = [String]()
    //var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    var img = UIImage(named: "placeholder")

    var markView = false
    var userModel = UserModel()
    var socialAccModel = [SocialAccModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupSocialArray()
        registerCells()
        if markView {
            ApiService.markViewedUser(val: userModel.userId)
        }
    }
    
    func setupSocialArray() {
        
        let socialAccTypes = ["LinkedIn", "Twitter", "Instagram", "Snapchat", "Website"]
        let placeholderValues = ["LinkedIn not connected", "Twitter not linked", "No Instagram handle", "No Snapchat shared", "No website link"]
        
        if let socialAccdbModel = userModel.socialAccounts, !userModel.socialAccounts.isEmpty {
            let socialAccTitles = socialAccdbModel.compactMap{ $0.linkTitle }
            let socialAccTypesSet = Set(socialAccdbModel.compactMap{ $0.linkType })
            let missingTypes = Set(socialAccTypes).subtracting(socialAccTypesSet)
            socialAccArray = zip(socialAccTypes, placeholderValues).map { type, placeholder in
                if missingTypes.contains(type) {
                    return placeholder
                } else if let index = socialAccdbModel.firstIndex(where: { $0.linkType == type }) {
                    return socialAccTitles[index]
                } else {
                    return ""
                }
            }
        } else {
            socialAccArray = placeholderValues
        }
    }
    
    func setupSocialArrayd() {
        
        if userModel.socialAccounts != nil && userModel.socialAccounts.count > 0 {
            socialAccArray = userModel.socialAccounts.compactMap{ $0.linkTitle }
            for i in 0...socialAccArray.count {
                let placeholderValues = ["LinkedIn not connected","Twitter not linked","No Instagram handle","No Snapchat Shared","No Website Link"]
            
                socialAccArray[i] = placeholderValues[i]
            }
            
        } else {
            socialAccArray = ["LinkedIn not connected","Twitter not linked","No Instagram handle","No Snapchat Shared","No Website Link"]
        }
    }
    
    func registerCells() {
        
        otherProfileTV.tableFooterView = UIView()
        otherProfileTV.separatorStyle = .none
        otherProfileTV.delegate = self
        otherProfileTV.dataSource = self
        otherProfileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        otherProfileTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        otherProfileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        otherProfileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        otherProfileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        otherProfileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @objc func notifBtnPressed(sender: UIButton) {
        ApiService.markBlockUser(val: userModel.userId)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AppFunctions.showSnackBar(str: "User Blocked")
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    //MARK: API METHODS
    
    
}
//MARK: TableView Extention
extension OtherUserProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userModel.socialAccounts.isEmpty {
            return 5
        }
        return userModel.socialAccounts.count + 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.headerLogo.isHidden = false
                cell.headerView.isHidden = false

                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                cell.notifBtn.setImage(UIImage(systemName: "hand.raised.brakesignal.slash"), for: .normal)
                cell.notifBtn.tintColor = UIColor(named: "Danger")
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                    cell.profilePicBtn.setImage(img, for: .normal)
                    cell.nameLbl.text = userModel.userName
                    cell.professionLbl.text = userModel.workTitle
                    cell.educationLbl.text = userModel.workAddress
                    
                    /*if user. != "" {
                     let imageUrl = URL(string: userdbModel.profilePicture)
                     cell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: img) { (image, error, imageCacheType, url) in }
                     } else {
                     cell.profilePicBtn.setImage(img, for: .normal)
                     }*/
                    
                return cell
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                    cell.aboutTxtView.text = userModel.about
                return cell
            case 2:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                
                cell.numberView.isHidden = true
                cell.generalTFView.isHidden = false
                cell.generalTF.text = userModel.publicEmail
                cell.generalTF.isUserInteractionEnabled = false
                
                return cell
            case 3:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 4:
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell

                    if userModel.tags != "" {
                        if !userModel.tags.contains(",") {
                            cell.tagLbl1.text = userModel.tags
                            cell.tagView1.isHidden = false
                        } else {
                            let split = userModel.tags.split(separator: ",")
                            for i in 0...split.count - 1 {
                                switch i {
                                    case 0:
                                        cell.tagLbl1.text = "\(split[i])"
                                        cell.tagView1.isHidden = false
                                    case 1:
                                        cell.tagLbl2.text = "\(split[i])"
                                        cell.tagView2.isHidden = false
                                    case 2:
                                        cell.tagLbl3.text = "\(split[i])"
                                        cell.tagView3.isHidden = false
                                    case 3:
                                        cell.tagLbl4.text = "\(split[i])"
                                        cell.tagView4.isHidden = false
                                    case 4:
                                        cell.tagLbl5.text = "\(split[i])"
                                        cell.tagView5.isHidden = false
                                    default:
                                        print("default")
                                }
                            }
                    }
                }
                return cell
            case 5:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Social accounts"
                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                if userModel.socialAccounts[indexPath.row - 6].linkImage != "" && userModel.socialAccounts[indexPath.row - 6].linkImage != nil {
                    let imageUrl = URL(string: userModel.socialAccounts[indexPath.row - 6].linkImage)
                    cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                } else {
                    //cell.profilePicBtn.setImage(img, for: .normal)
                }
                cell.socialLbl.text = userModel.socialAccounts[indexPath.row - 6].linkTitle.capitalized
                cell.socialLbl.isUserInteractionEnabled = false
                return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 5 {
            //AppFunctions.showSnackBar(str: "\(indexPath.row)")
            switch userModel.socialAccounts[indexPath.row - 6].linkType {
                case "LinkedIn":
                    AppFunctions.openLinkedIn(userName: userModel.socialAccounts[indexPath.row - 6].linkUrl)
                case "Twitter":
                    AppFunctions.openTwitter(userName: userModel.socialAccounts[indexPath.row - 6].linkUrl)
                case "Instagram":
                    AppFunctions.openInstagram(userName: userModel.socialAccounts[indexPath.row - 6].linkUrl)
                case "Snapchat":
                    AppFunctions.openSnapchat(userName: userModel.socialAccounts[indexPath.row - 6].linkUrl)
                case "Website":
                    AppFunctions.openWebLink(link: userModel.socialAccounts[indexPath.row - 6].linkUrl)
                default:
                    print("default")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

