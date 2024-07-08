//
//  ProfileVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit
//import RxRealm
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
    
    var overlayView: UIView?

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
            //DBUpdateUserdb()
        }
        
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        profileTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        profileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        profileTV.register(UINib(nibName: "StatusTVCell", bundle: nil), forCellReuseIdentifier: "StatusTVCell")
        profileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        profileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
    }
    
    /*func DBUpdateUserdb() {
        
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
    
    @objc func handleOverlayTap(_ sender: UITapGestureRecognizer) {
        guard let overlayView = overlayView else { return }
        
        // Animate the overlay view to fade out, then remove it
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            overlayView.removeFromSuperview()
            self.overlayView = nil
        }
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
                            
                            let linkTypesInSocialAccModel = Set(socialAccModel.map { $0.linkType })
                            
                            socialAccounts.sort { (account1, account2) -> Bool in
                                // Check if either account has a linkType present in socialAccModel
                                let isAccount1Matched = linkTypesInSocialAccModel.contains(account1.linkType)
                                let isAccount2Matched = linkTypesInSocialAccModel.contains(account2.linkType)
                                
                                // Move matched accounts to the front
                                if isAccount1Matched && !isAccount2Matched {
                                    return true
                                } else if !isAccount1Matched && isAccount2Matched {
                                    return false
                                } else {
                                    // Keep original order for unmatched or both matched/unmatched pairs
                                    return false
                                }
                            }
                            
                            self.profileTV.reloadData()
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
                            self.profileTV.reloadData()
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
        return tempSocialAccImgArray.count + 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = true
                cell.toolTipBtn.isHidden = true
                cell.rattingBtn.isHidden = true
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
                
                if AppFunctions.isNotifNotCheck() {
                    cell.notifBtn.tintColor = UIColor(named:"Danger")
                } else if AppFunctions.isShadowModeOn() {
                    cell.notifBtn.tintColor = UIColor(named: "Primary Yellow")
                } else {
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
                }
                
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
                let cell : StatusTVCell = tableView.dequeueReusableCell(withIdentifier: "StatusTVCell", for: indexPath) as! StatusTVCell
                
                if isOtherProfile {
                    cell.statusLbl.text = userModel.status.isEmpty ? "currently no active status..." : userModel.status
                } else {
                    if let userDb = userdbModel {
                        if let user = userDb.first {
                            cell.statusLbl.text = user.status.isEmpty ? "currently no active status..." : user.status
                            cell.clockIV.isHidden = !user.disappearingStatus
                        }
                    }
                }

                                
                return cell
            case 3:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                
                cell.numberView.isHidden = true
                cell.generalTFView.isHidden = false
                if isOtherProfile {
                    cell.generalTF.text = userModel.publicEmail
                } else {
                    if let userDb = userdbModel {
                        if let user = userDb.first {
                            cell.generalTF.text = user.publicEmail
                        }
                    }
                }
                
                cell.generalTF.isUserInteractionEnabled = false
                
                return cell
            case 4:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 5:
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
            case 6:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Social accounts"
                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell

                if socialAccounts[indexPath.row - 7].linkImage != "" {
                 let imageUrl = URL(string: socialAccounts[indexPath.row - 7].linkImage)
                 cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                 }
                
                
                
                cell.socialLbl.text = socialAccounts[indexPath.row - 7].linkType.capitalized
                
                if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 7].linkType }).count > 0 {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                } else {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
                }
                //setupLbl(textLbl: cell.socialLbl, completeText: "\(socialAccounts[indexPath.row - 6].linkType.capitalized)   \(countTxt) Accounts", textToHighlight: " \(countTxt) Accounts")

                cell.socialLbl.isUserInteractionEnabled = false
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            
            guard let cell = tableView.cellForRow(at: indexPath) as? AboutTVCell,
                  let textView = cell.aboutTxtView else { return }
            
            let clonedTextView = UITextView(frame: textView.frame)
            clonedTextView.text = textView.text
            clonedTextView.font = textView.font
            clonedTextView.textColor = textView.textColor
            clonedTextView.backgroundColor = UIColor.systemGray4
            clonedTextView.clipsToBounds = true
            clonedTextView.layer.cornerRadius = 6
            clonedTextView.isUserInteractionEnabled = false
            clonedTextView.isEditable = false
            
            // Create an overlay view that covers the entire screen
            overlayView = UIView(frame: self.view.bounds)
            overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            let newView = UIView()
            newView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 60, height: 350)
            newView.center = overlayView!.center
            newView.backgroundColor = UIColor.systemGray4
            newView.clipsToBounds = true
            newView.layer.cornerRadius = 5
            newView.isUserInteractionEnabled = false
            
            overlayView?.addSubview(newView)
            
            // Ensure the cloned UITextView fits within the newView
            clonedTextView.translatesAutoresizingMaskIntoConstraints = false
            newView.addSubview(clonedTextView)
            
            // Set constraints to position the cloned UITextView within the newView
            NSLayoutConstraint.activate([
                clonedTextView.leadingAnchor.constraint(equalTo: newView.leadingAnchor, constant: 20),
                clonedTextView.trailingAnchor.constraint(equalTo: newView.trailingAnchor, constant: -20),
                clonedTextView.topAnchor.constraint(equalTo: newView.topAnchor, constant: 20),
                clonedTextView.bottomAnchor.constraint(equalTo: newView.bottomAnchor, constant: -20)
            ])
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap(_:)))
            overlayView?.addGestureRecognizer(tapGestureRecognizer)
            
            overlayView?.bringSubviewToFront(newView)
            
            view.addSubview(overlayView!)
            
            // Animate the overlay view to expand from the cell's frame to the center of the screen
            overlayView?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.overlayView?.alpha = 1
            }
            
        } else  if indexPath.row == 2 && !AppFunctions.isPremiumUser() {
            AppFunctions.showSnackBar(str: "Upgrade to premium to broadcast a status.")
            
        } else if indexPath.row == 5 {
            
            var tagList = [String]()
            if isOtherProfile {
                if userModel.tags != "" {
                    if !userModel.tags.contains(",") {
                        tagList.append(userModel.tags)
                    } else {
                        let split = userModel.tags.split(separator: ",")
                        tagList = split.map { String($0) } // Convert Substring to String
                    }
                }
            } else {
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        if user.tags != "" {
                            if !user.tags.contains(",") {
                                tagList.append(userModel.tags)
                            } else {
                                let split = user.tags.split(separator: ",")
                                tagList = split.map { String($0) } // Convert Substring to String
                                }
                            }
                        }
                    }
                }
            
            
            self.presentVC(id: "TagsView_VC",presentFullType: "not") { (vc:TagsView_VC) in
                vc.tagList = tagList
            }
        } else if indexPath.row > 6 {
            
            if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 7].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.socialAccModel = socialAccModel.filter {$0.linkType == socialAccounts[indexPath.row - 7].linkType }
                    vc.linkType = socialAccounts[indexPath.row - 7].linkType
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

