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
    
    var titleName = "TAMARA PENSIERO"
    var img = UIImage(named: "placeholder")
    var prof = "Professor"
    var isOtherProfile = false
    
    var userdbModel : Results<UserDBModel>!
    var socialAccModel = [SocialAccModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userProfile()
        //userSocialAcc()
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
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
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
        return socialAccModel.count + 5
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
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.profilePicBtn.setImage(img, for: .normal)
                        cell.nameLbl.text = user.userName
                        cell.professionLbl.text = user.workTitle
                        cell.educationLbl.text = user.workAddress
                        
                        /*if user. != "" {
                         let imageUrl = URL(string: userdbModel.profilePicture)
                         cell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: img) { (image, error, imageCacheType, url) in }
                         } else {
                         cell.profilePicBtn.setImage(img, for: .normal)
                         }*/
                    }
                  
                }

                return cell
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.aboutTxtView.text = user.about
                    }
                }
                return cell
            case 2:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 3:
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
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
                return cell
            case 4:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Social accounts"
                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                //cell.socialImgView.image = socialAccImgArray[indexPath.row - 5]

                if socialAccModel[indexPath.row - 5].linkImage != "" && socialAccModel[indexPath.row - 5].linkImage != nil {
                 let imageUrl = URL(string: socialAccModel[indexPath.row - 5].linkImage)
                 cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                 } else {
                 //cell.profilePicBtn.setImage(img, for: .normal)
                 }
                cell.socialLbl.text = socialAccModel[indexPath.row - 5].linkTitle.capitalized
                cell.socialLbl.isUserInteractionEnabled = false
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 4 {
            //AppFunctions.showSnackBar(str: "\(indexPath.row)")
            switch socialAccModel[indexPath.row - 5].linkType {
                case "LinkedIn":
                    AppFunctions.openLinkedIn(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Twitter":
                    AppFunctions.openTwitter(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Instagram":
                    AppFunctions.openInstagram(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Snapchat":
                    AppFunctions.openSnapchat(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Website":
                    AppFunctions.openWebLink(link: socialAccModel[indexPath.row - 5].linkUrl)
                default:
                    print("default")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

