//
//  ProfileVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit
import RxRealm
import RxSwift
import RealmSwift
import SDWebImage

class ProfileVC: MainViewController {

    @IBOutlet weak var profileTV: UITableView!
    
    //var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccArray = [String]()
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var tempSocialAccImgArray = [String()]
    var socialAccounts = [SocialAccDBModel()]

    var img = UIImage(named: "placeholder")
    var isOtherProfile = false
    
    var userModel = UserModel()

    var userdbModel : Results<UserDBModel>!
    var socialAccModel = [SocialAccModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        tempSocialAccImgArray = socialAccounts.compactMap { $0.linkType }
        
        registerCells()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userProfile()
        if DBService.fetchloggedInUser().count > 0 {
            userdbModel = DBService.fetchloggedInUser()
            DBUpdateUserdb()
        }
        
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        profileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        profileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
    }
    
    /*func setupSocialArray() {
        
        let socialAccTypes = ["LinkedIn", "Twitter", "Instagram", "Snapchat", "Website"]
        let placeholderValues = ["LinkedIn not connected", "Twitter not linked", "No Instagram handle", "No Snapchat shared", "No website link"]

        if let socialAccdbModel = socialAccdbModel, !socialAccdbModel.isEmpty {
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
    }*/
    
    func DBUpdateUserdb() {
        
        Observable.changeset(from: userdbModel)
            .subscribe(onNext: { [weak self] _, changes in
                if let changes = changes {
                    Logs.show(message: "CHANGES: \(changes)")
                    if DBService.fetchloggedInUser().count > 0 {
                        self?.userdbModel = DBService.fetchloggedInUser()
                    }
                    self?.profileTV.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    /*func DBUpdateSocialAcc() {
        
        Observable.changeset(from: socialAccdbModel)
            .subscribe(onNext: { [weak self] _, changes in
                if let changes = changes {
                    Logs.show(message: "CHANGES: \(changes)")
                    /*if DBService.fetchSocialAccList().count > 0 {
                        self?.socialAccdbModel = DBService.fetchSocialAccList()
                        self?.socialAccArray = self!.socialAccdbModel.compactMap { $0.linkTitle }
                        if self?.socialAccArray.count != self?.socialAccImgArray.count {
                            switch self?.socialAccArray.count {
                                case 1:
                                    self?.socialAccArray = self!.socialAccArray + ["Add your Twitter account","your Instagram handle","Snapchat","Link your Website"]
                                case 2:
                                    self?.socialAccArray = self!.socialAccArray + ["Share your Instagram handle","Snapchat","Link your Website"]
                                case 3:
                                    self?.socialAccArray = self!.socialAccArray + ["Snapchat","Link your Website"]
                                case 4:
                                    self?.socialAccArray = self!.socialAccArray + ["Link your Website"]
                                case 5:
                                    print("5")
                                default:
                                    print("default")
                            }
                        }
                    }*/
                    self?.setupSocialArray()
                    self?.profileTV.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }*/
    
    @objc func picBtnPressed(sender: UIButton) {
        if isOtherProfile {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.tabBarController?.selectedIndex = 2
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
    
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    func setupLbl(textLbl: UITextField, completeText: String, textToHighlight: String) {
        let remainingText = completeText.replacingOccurrences(of: textToHighlight, with: "")
        
        let remainingLabel = UILabel()
        remainingLabel.text = remainingText
        remainingLabel.font = UIFont(name: "Roboto", size: 14)
        remainingLabel.textColor = UIColor(hexFromString: "4E6E81")
        
        let textToHighlightLabel = UILabel()
        textToHighlightLabel.attributedText = attributedStringForLbl(completeText: completeText, textToHighlight: textToHighlight)
    
        textLbl.leftView = remainingLabel
        textLbl.leftViewMode = .always
        textLbl.rightView = textToHighlightLabel
        textLbl.rightViewMode = .always
        textLbl.rightView?.contentMode = .right
    }

    func attributedStringForLbl(completeText: String, textToHighlight: String) -> NSAttributedString {
        
        let attributedText = NSMutableAttributedString(string: textToHighlight)
        
        let highlightRange = NSRange(location: 0, length: textToHighlight.count)
                
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.light , range: highlightRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81") , range: highlightRange)
        
        return attributedText
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
                            self.socialAccModel = val.socialAccounts
                            
                            /*var imageIndices = [String: Int]()
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
                            }*/
                            
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
    
    func userSocialAcc() {
        
        APIService
            .singelton
            .getUserSocialAccounts()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            
                            //Logs.show(message: "SOCIAL ACC: 👉🏻 \(String(describing: self.socialAccdbModel))")
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
extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tempSocialAccImgArray.isEmpty {
            return 5
        }
        return tempSocialAccImgArray.count + 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = true
                cell.toolTipBtn.isHidden = true
                cell.ratingView.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.headerView.isHidden = false
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "MY PROFILE"
                
                if isOtherProfile {
                    cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                    cell.notifBtn.isHidden = true
                } else {
                    cell.picBtn.borderWidth = 0
                }
                
                cell.profilePicBtn.addTarget(self, action: #selector(profilePicBtnPressed(sender:)), for: .touchUpInside)
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                if isOtherProfile {
                    if userModel.profilePicture != "" {
                        let imageUrl = URL(string: userModel.profilePicture)
                        cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.profilePicBtn.setImage(img, for: .normal)
                    }
                    cell.nameLbl.text = userModel.userName
                    cell.professionLbl.text = userModel.workTitle
                    cell.educationLbl.text = userModel.workAddress
                } else {
                    if let userDb = userdbModel {
                        if let user = userDb.first {
                            cell.nameLbl.text = user.userName
                            cell.professionLbl.text = user.workTitle
                            cell.educationLbl.text = user.workAddress
                            
                            if user.profilePicture != "" {
                                let imageUrl = URL(string: user.profilePicture)
                                cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                             } else {
                                 cell.profilePicBtn.setImage(img, for: .normal)
                             }
                        }
                    }
                }
                

                return cell
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                
                if isOtherProfile {
                    cell.aboutTxtView.text = userModel.about
                } else {
                    if let userDb = userdbModel {
                        if let user = userDb.first {
                            cell.aboutTxtView.text = user.about
                        }
                    }
                }
                
                return cell
            case 2:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                
                cell.numberView.isHidden = true
                cell.generalTFView.isHidden = false
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.generalTF.text = user.publicEmail
                    }
                }
                cell.generalTF.isUserInteractionEnabled = false
                
                return cell
            case 3:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 4:
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                
                if isOtherProfile {
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
                } else {
                    if let userDb = userdbModel {
                        if let user = userDb.first {
                            if user.tags != "" {
                                if !user.tags.contains(",") {
                                    cell.tagLbl1.text = user.tags
                                    cell.tagView1.isHidden = false
                                } else {
                                    let split = user.tags.split(separator: ",")
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

                if socialAccounts[indexPath.row - 6].linkImage != "" {
                 let imageUrl = URL(string: socialAccounts[indexPath.row - 6].linkImage)
                 cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                 }
                
                //var countTxt = socialAccModel.filter {$0.linkType == socialAccounts[indexPath.row - 6].linkType}.count
                
                cell.socialLbl.text = socialAccounts[indexPath.row - 6].linkType.capitalized
                
                //setupLbl(textLbl: cell.socialLbl, completeText: "\(socialAccounts[indexPath.row - 6].linkType.capitalized)   \(countTxt) Accounts", textToHighlight: " \(countTxt) Accounts")

                cell.socialLbl.isUserInteractionEnabled = false
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 5 {
            
            if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 6].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.socialAccModel = socialAccModel.filter {$0.linkType == socialAccounts[indexPath.row - 6].linkType }
                    vc.linkType = socialAccounts[indexPath.row - 6].linkType
                }
            } else {
                AppFunctions.showSnackBar(str: "No social account found")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

