//
//  OtherUserProfile.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 27/03/2023.
//

import UIKit
//RxRealmimport RxRealm
import RxSwift
import RealmSwift
import CDAlertView
import UIMultiPicker

class OtherUserProfile: MainViewController {
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
        AppFunctions.showSnackBar(str: "Thanks for taking time to let us know.\nYour report is submitted")
    }
    
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var otherProfileTV: UITableView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    
    var socialAccArray = [String]()
    //var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    var img = UIImage(named: "placeholder")

    var tempSocialAccImgArray = [String()]
    var socialAccounts = [SocialAccDBModel()]

    var isFromBlock = false
    
    var markView = false
    var userModel = UserModel()
    var socialAccModel = [SocialAccModel]()
    
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupSocialArray()
        getReasons()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        
        tempSocialAccImgArray = socialAccounts.compactMap { $0.linkType }
        
        Logs.show(message: "User ID: \(userModel)")
        
        if markView {
            ApiService.markViewedUser(val: userModel.userId)
        }
        
        socialAccModel = userModel.socialAccounts
        
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
        
        registerCells()

        
    }
    
    func registerCells() {
        
        otherProfileTV.tableFooterView = UIView()
        otherProfileTV.separatorStyle = .none
        otherProfileTV.delegate = self
        otherProfileTV.dataSource = self
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        otherProfileTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        otherProfileTV.addGestureRecognizer(longPressRecognizer)
        
        otherProfileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        otherProfileTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        otherProfileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        otherProfileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        otherProfileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        otherProfileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        otherProfileTV.register(UINib(nibName: "StatusTVCell", bundle: nil), forCellReuseIdentifier: "StatusTVCell")
        otherProfileTV.register(UINib(nibName: "BlockBtnTVCell", bundle: nil), forCellReuseIdentifier: "BlockBtnTVCell")
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: otherProfileTV)
            if let indexPath = otherProfileTV.indexPathForRow(at: touchPoint) {
                // Get the cell and label text
                if let cell : ProfileTVCell = otherProfileTV.cellForRow(at: indexPath) as? ProfileTVCell {
                    if let labelText = cell.generalTF.text {
                        // Copy the label text to the clipboard
                        UIPasteboard.general.string = labelText
                        AppFunctions.showSnackBar(str: "Email copied to clipboard...")
                    }
                }
            }
        }
    }

    
    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Take action against this user: Block or Report?", type: .warning)
        let action = CDAlertViewAction(title: "Block",
                                       handler: {[weak self] action in
            ApiService.markBlockUser(val: (self?.userModel.userId)!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppFunctions.showSnackBar(str: "User Blocked")
                
                self?.navigationController?.popViewController(animated: true)
            }
            return true
        })
        let action2 = CDAlertViewAction(title: "Report",
                                       handler: {[weak self] action in
            //self?.setupMultiPickerView()
            self?.userReport()
            return true
        })
//        let cancel = CDAlertViewAction(title: "Cancel",
//                                       handler: { action in
//            print("CANCEL PRESSED")
//            return true
//        })
        alert.isTextFieldHidden = true
        alert.canHideWhenTapBack = true
        alert.add(action: action)
        alert.add(action: action2)
        alert.hideAnimations = { (center, transform, alpha) in
            transform = .identity
            alpha = 0
        }
        alert.show() { (alert) in
            print("completed")
        }
    }
    
    func setupMultiPickerView() {
        
        pickerView.isHidden = false
        multiPickerView.options = reasonsListName
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .darkGray
        multiPickerView.tintColor = .black
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedReasonsAray = sender.selectedIndexes
        Logs.show(message: "Selected REASONS: \(selectedReasonsAray)")
        
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func sendContactRocket(sender: UIButton) {
        
        self.presentVC(id: "SendReqVC", presentFullType: "over" ) { (vc:SendReqVC) in
            vc.userModel = userModel
        }
    }
    
    @objc
    func starTapFunction(sender:UIButton) {
        
        let cell = otherProfileTV.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? GeneralHeaderTVCell
        
        if cell?.rattingBtn.imageView?.image == UIImage(systemName: "star.fill") {
            cell?.rattingBtn.setImage(UIImage(systemName: "star"), for: .normal)
            ApiService.markStarUser(val: userModel.userId)
        } else {
            cell?.rattingBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
            ApiService.markStarUser(val: userModel.userId)
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
        showAlert()
    }
    
    
    //MARK: API METHODS
    
    func getReasons() {
        
        
        APIService
            .singelton
            .getReportReasons()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        AppFunctions.setIsNotifCheck(value: false)
                        if val.count > 0 {
                            self.reasonsList = val
                            self.reasonsListName = self.reasonsList.map({$0.reason})
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
    
    func userReport() {
        self.showPKHUD(WithMessage: "")
        
        let pram : [String : Any] = [ "reportedUser": userModel.userId ?? "",
                                      "reportReasons": "1",
                                      "reportDetails": ""
        ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .reportUser(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            AppFunctions.showSnackBar(str: "Your report has been submitted for review")
                            self.hidePKHUD()
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
extension OtherUserProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialAccounts.count + 9
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
                cell.rattingBtn.isHidden = false

                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                
                cell.profilePicBtn.addTarget(self, action: #selector(profilePicBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.rattingBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)
                cell.rattingBtn.tag = indexPath.row
                
                if userModel.isStarred != nil {
                    if userModel.isStarred {
                        cell.rattingBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } else {
                        cell.rattingBtn.setImage(UIImage(systemName: "star"), for: .normal)
                    }
                }
                
                
                cell.nameLbl.text = userModel.userName
                cell.professionLbl.text = userModel.workTitle
                cell.educationLbl.text = userModel.workAddress
                
                if AppFunctions.isNotifNotCheck() {
                    cell.notifBtn.tintColor = UIColor(named:"Danger")
                } else if AppFunctions.isShadowModeOn() {
                    cell.notifBtn.tintColor = UIColor(named: "Primary Yellow")
                } else {
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
                }
                    
                if userModel.profilePicture != "" && userModel.profilePicture != nil {
                    let imageUrl = URL(string: userModel.profilePicture)
                    cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                } else {
                    cell.profilePicBtn.setImage(img, for: .normal)
                }
                
                cell.notifBtn.isHidden = true

                cell.rocketBtn.isHidden = false

                if userModel.userContacts == nil {
                    cell.rocketBtn.tintColor = UIColor(named: "Secondary Grey")
                    cell.rocketBtn.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                } else {
                    if userModel.userContacts.contactStatus == "Pending" {
                        cell.rocketBtn.tintColor = UIColor(named: "warning")
                    } else if userModel.userContacts.contactStatus == "Accepted" {
                        cell.rocketBtn.tintColor = UIColor(named: "Success")
                    } else {
                        cell.rocketBtn.tintColor = UIColor(named: "Secondary Grey")
                    }
                }
                    
                return cell
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                    cell.aboutTxtView.text = userModel.about
                return cell
            case 2:
                let cell : StatusTVCell = tableView.dequeueReusableCell(withIdentifier: "StatusTVCell", for: indexPath) as! StatusTVCell
                
                if userModel.status != nil {
                    cell.statusLbl.text = userModel.status.isEmpty ? "currently no active status..." : userModel.status
                    cell.clockIV.isHidden = !userModel.disappearingStatus
                } else {
                    cell.statusLbl.text = "currently no active status..."
                    cell.clockIV.isHidden = true
                }
                
                return cell
                
            case 3:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                
                cell.numberView.isHidden = true
                cell.generalTFView.isHidden = false
                cell.generalTF.text = userModel.publicEmail
                cell.generalTF.isUserInteractionEnabled = false
                
                return cell
            case 4:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 5:
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
            case 6: // social heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                if !socialAccounts.isEmpty {
                    cell.headerLblView.isHidden = false
                    cell.headerLbl.text = "Social accounts"
                } else {
                    cell.headerLblView.isHidden = true
                }
                
                return cell
                
            case socialAccounts.count + 7: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case socialAccounts.count + 8: // button
                let cell : BlockBtnTVCell = tableView.dequeueReusableCell(withIdentifier: "BlockBtnTVCell", for: indexPath) as! BlockBtnTVCell
                if isFromBlock {
                    cell.blockBtn.isHidden = true
                }
                cell.blockBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)

                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                if socialAccounts[indexPath.row - 7].linkImage != "" {
                    let imageUrl = URL(string: socialAccounts[indexPath.row - 7].linkImage)
                    cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                } else {
                    //cell.profilePicBtn.setImage(img, for: .normal)
                }
                if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 7].linkType }).count > 0 {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                } else {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
                }
                
                cell.socialLbl.text = socialAccounts[indexPath.row - 7].linkType.capitalized
                cell.socialLbl.isUserInteractionEnabled = false
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            
            var tagList = [String]()
                if userModel.tags != "" {
                    if !userModel.tags.contains(",") {
                        tagList.append(userModel.tags)
                    } else {
                        let split = userModel.tags.split(separator: ",")
                        tagList = split.map { String($0) } // Convert Substring to String
                    }
                }
            
            self.presentVC(id: "TagsView_VC",presentFullType: "not") { (vc:TagsView_VC) in
                vc.isFromOther = true
                vc.userId = userModel.userId
                vc.tagList = tagList
            }
        } else if indexPath.row > 6 && indexPath.row < socialAccounts.count + 7 {
            if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 7].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.isFromOther = true
                    vc.userId = userModel.userId
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

