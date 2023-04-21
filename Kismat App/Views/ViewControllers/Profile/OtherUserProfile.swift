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
import CDAlertView

class OtherUserProfile: MainViewController {
    

    @IBOutlet weak var otherProfileTV: UITableView!
    
    var socialAccArray = [String]()
    //var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    var img = UIImage(named: "placeholder")

    var tempSocialAccImgArray = ["LinkedIn","Twitter","Insta","snapchat","Website"]

    var isFromBlock = false
    
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
        
        socialAccModel = userModel.socialAccounts
        
        for i in 0..<socialAccModel.count {
            Logs.show(message: "NOT SORTED: \(self.socialAccModel[i].linkType)")
        }

        
        var imageIndices = [String: Int]()
        for (index, imageName) in self.tempSocialAccImgArray.enumerated() {
            imageIndices[imageName.lowercased()] = index
        }
        
        self.socialAccModel.sort { (model1, model2) -> Bool in
            if let imageName1 = model1.linkImage.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "").lowercased(),
               let imageName2 = model2.linkImage.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "").lowercased(),
               let index1 = imageIndices[imageName1],
               let index2 = imageIndices[imageName2] {
                return index1 < index2
            } else {
                // If there is any error in extracting the image name or index, keep the original order
                return false
            }
        }
        
        for i in 0..<socialAccModel.count {
            Logs.show(message: "SORTED: \(self.socialAccModel[i].linkType)")
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
    
    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to block this user?", type: .warning)
        let action = CDAlertViewAction(title: "Block",
                                       handler: {[weak self] action in
            ApiService.markBlockUser(val: (self?.userModel.userId)!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppFunctions.showSnackBar(str: "User Blocked")
                
                self?.navigationController?.popViewController(animated: true)
            }
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
    @objc func notifBtnPressed(sender: UIButton) {
        showAlert()
        
    }
    
    
    //MARK: API METHODS
    
    
}
//MARK: TableView Extention
extension OtherUserProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if socialAccModel.isEmpty {
            return 5
        }
        return socialAccModel.count + 6
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
                    
                if userModel.profilePicture != "" && userModel.profilePicture != nil {
                    let imageUrl = URL(string: userModel.profilePicture)
                    cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                } else {
                    cell.profilePicBtn.setImage(img, for: .normal)
                }
                
                if isFromBlock {
                    cell.notifBtn.isHidden = true
                }
                    
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
                if socialAccModel[indexPath.row - 6].linkImage != "" && socialAccModel[indexPath.row - 6].linkImage != nil {
                    let imageUrl = URL(string: socialAccModel[indexPath.row - 6].linkImage)
                    cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                } else {
                    //cell.profilePicBtn.setImage(img, for: .normal)
                }
                cell.socialLbl.text = socialAccModel[indexPath.row - 6].linkTitle.capitalized
                cell.socialLbl.isUserInteractionEnabled = false
                return cell

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 5 {
            //AppFunctions.showSnackBar(str: "\(indexPath.row)")
            switch userModel.socialAccounts[indexPath.row - 6].linkType {
                case "LinkedIn":
                    AppFunctions.openLinkedIn(userName: socialAccModel[indexPath.row - 6].linkUrl)
                case "Twitter":
                    AppFunctions.openTwitter(userName: socialAccModel[indexPath.row - 6].linkUrl)
                case "Instagram":
                    AppFunctions.openInstagram(userName: socialAccModel[indexPath.row - 6].linkUrl)
                case "Snapchat":
                    AppFunctions.openSnapchat(userName: socialAccModel[indexPath.row - 6].linkUrl)
                case "Website":
                    AppFunctions.openWebLink(link: socialAccModel[indexPath.row - 6].linkUrl, vc: self)
                default:
                    print("default")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

