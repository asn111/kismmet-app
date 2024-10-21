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
    
    var img = UIImage(named: "placeholder")

    var socialAccounts = [SocialAccDBModel()]

    var isFromBlock = false
    var isFromMessage = false
    
    var canCancelReq = ""
    var contactId = 0
    
    var starValue = false

    var overlayView: UIView?

    //var markView = false
    var userModel = UserModel()
    var userId = ""
    var socialAccModel = [SocialAccModel]()
    
    var isFromReq = false
    
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfile(id: userId)

        getReasons()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        
        
        Logs.show(message: "User ID: \(userId)")
        
        //if markView {
            ApiService.markViewedUser(val: userId)
        //}
        
        
        registerCells()
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "exitView" {
                //self?.navigationController?.popViewController(animated: true)
                self?.userProfile(id: self?.userId ?? "")
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})

      
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
        
        //otherProfileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        otherProfileTV.register(UINib(nibName: "ProfileHeaderNewTVCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderNewTVCell")
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

    func showAlertCancel(undo: Bool){
        var message = ""
        
        if undo {
            message = "Are you sure you want to undo this sent request?"
        } else {
            message = "Are you sure you want to disconnect this contact?"
        }
        
        let alert = CDAlertView(title: "Alert!", message: message, type: .warning)
        let action = CDAlertViewAction(title: undo ? "Undo" : "Disconnect",
                                       handler: {[weak self] action in
            self?.deleteContact(isNavigateToFeed: !undo)
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
        
        if isFromReq {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func sendMessagePressed(sender: UIButton) {
        
        if isFromMessage {
            if let navigationController = self.navigationController {
                // If the view is part of a navigation stack, pop it
                self.navigationController?.popViewController(animated: true)
            } else if self.presentingViewController != nil {
                // If the view is presented modally, dismiss it
                self.dismiss(animated: true, completion: nil)
            }

            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            let user = userModel
            
            vc.userId = user.userId
            //vc.chatId = user.chatId
            //vc.isOnline = user.isOnline
            vc.workTitle = user.workTitle
            vc.userName = user.userName
            vc.userProfilePic = user.profilePicture
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.fade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func sendContactRocket(sender: UIButton) {
        
        switch canCancelReq {
            case "":
                self.presentVC(id: "SendReqVC", presentFullType: "over" ) { (vc:SendReqVC) in
                    vc.userModel = userModel
                }
            case "cancel":
                showAlertCancel(undo: true)
            case "already":
                self.dismiss(animated: true)
            case "discon":
                showAlertCancel(undo: false)
            case "a/d":
                self.presentVC(id: "ReqAcceptVC", presentFullType: "over" ) { (vc:ReqAcceptVC) in
                    vc.userModel = userModel
                }
            default:
                break
        }
        
        /*if canCancelReq {
            showAlertCancel()
        } else {
            self.presentVC(id: "SendReqVC", presentFullType: "over" ) { (vc:SendReqVC) in
                vc.userModel = userModel
            }
        }*/
    }
    
    @objc
    func starTapFunction(sender: UIButton) {
        
        markUserStar(userId: userModel.userId)
        /*let cell = otherProfileTV.cellForRow(at: IndexPath(row: sender.tag - 1 , section: 0)) as? GeneralHeaderTVCell
        
        
        // Safely unwrap the current image and compare its name
        if let currentImage = cell?.rattingBtn.imageView?.image, currentImage.isEqual(UIImage(systemName: "star.fill")) {
            cell?.rattingBtn.setImage(UIImage(systemName: "star"), for: .normal)
            markUserStar(userId: userModel.userId)
        } else {
            cell?.rattingBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }*/
    }

    
    func markUserStar(userId: String) {
        TimeTracker.shared.startTracking(for: "markUserStar")
        
        let pram = ["userId": "\(userId)"]
        Logs.show(message: "PRAM: \(pram)")
        SignalRManager.singelton.connection.invoke(method: "StarUser", pram) {  error in
            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
            self.userProfile(id: userId)
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
    
    func userProfile(id: String) {
        //self.showPKHUD(WithMessage: "fetching notification")
        
        APIService
            .singelton
            .getUserById(userId: id, isOtherUser: true)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            self.userModel = val
                            
                            if userModel.socialAccounts != nil {
                                socialAccModel = userModel.socialAccounts
                            }
                            
                            let linkTypesInSocialAccModel = Set(socialAccModel.map { $0.linkType })
                            
                            socialAccounts.sort { (account1, account2) -> Bool in
                                let isAccount1Matched = linkTypesInSocialAccModel.contains(account1.linkType)
                                let isAccount2Matched = linkTypesInSocialAccModel.contains(account2.linkType)
                                
                                if isAccount1Matched && !isAccount2Matched {
                                    return true
                                } else if !isAccount1Matched && isAccount2Matched {
                                    return false
                                } else {
                                    return false
                                }
                            }
                            self.canCancelReq = ""
                            self.otherProfileTV.reloadData()
                            TimeTracker.shared.stopTracking(for: "markUserStar")
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
    
    func deleteContact(isNavigateToFeed : Bool = false ) {
        self.showPKHUD(WithMessage: "")
        
        let pram : [String : Any] = [ "contactId": contactId ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .deleteContactReq(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            if isNavigateToFeed {
                                AppFunctions.showSnackBar(str: "Contact reset")
                                self.hidePKHUD()
                                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                    vc.selectedIndex = 2
                                }
                            } else {
                                self.userProfile(id: userId)
                                self.canCancelReq = ""
                                AppFunctions.showSnackBar(str: "Contact reset")
                                self.hidePKHUD()
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
extension OtherUserProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialAccounts.count + 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderNewTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderNewTVCell", for: indexPath) as! ProfileHeaderNewTVCell
                
                cell.backBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.starBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)
                cell.starBtn.tag = indexPath.row
                
                if userModel.isStarred != nil {
                    if userModel.isStarred {
                        cell.starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
                    } else {
                        cell.starBtn.setImage(UIImage(systemName: "star"), for: .normal)
                    }
                }
                
                cell.nameLbl.text = userModel.userName
                cell.proffLbl.text = userModel.workTitle
                cell.workLbl.text = userModel.workAddress
                
                if userModel.profilePicture != "" && userModel.profilePicture != nil {
                    let imageUrl = URL(string: userModel.profilePicture)
                    cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                } else {
                    cell.profilePicBtn.setImage(img, for: .normal)
                }
                
                if userModel.status != nil {
                    cell.statusLbl.text = userModel.status.isEmpty ? "currently no active status..." : userModel.status
                    cell.clockIV.isHidden = !userModel.disappearingStatus
                } else {
                    cell.statusLbl.text = "currently no active status..."
                    cell.clockIV.isHidden = true
                }
                
                if userModel.userContacts == nil {
                    cell.requestBtn.setTitle("Request ", for: .normal)
                    cell.requestBtn2.setTitle("Request ", for: .normal)
                    cell.requestBtn.setTitleColor(UIColor.white, for: .normal)
                    cell.requestBtn2.setTitleColor(UIColor.white, for: .normal)
                    cell.requestBtn.backgroundColor = UIColor(named: "Secondary Grey")
                    cell.requestBtn2.backgroundColor = UIColor(named: "Secondary Grey")
                    cell.requestBtn.layer.borderColor = UIColor.lightGray.cgColor
                    cell.requestBtn2.layer.borderColor = UIColor.lightGray.cgColor
                    cell.requestBtn.layer.borderWidth = 0
                    cell.requestBtn2.layer.borderWidth = 0
                    
                    cell.btnsView.isHidden = true
                    
                    
                    //cell.requestBtn.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                } else {
                    if userModel.userContacts.contactStatus == "Pending" {
                        if let userContact = userModel.userContacts {
                            if userContact.isSentByCurrentUsers {
                                canCancelReq = "cancel"
                                contactId = userContact.id
                                cell.requestBtn.setTitle("Pending ", for: .normal)
                                cell.requestBtn2.setTitle("Pending ", for: .normal)

                            } else {
                                cell.requestBtn.setTitle("Accept/Decline ", for: .normal)
                                cell.requestBtn2.setTitle("Accept/Decline ", for: .normal)
                                
                                if isFromReq {
                                    canCancelReq = "already"
                                } else {
                                    canCancelReq = "a/d"
                                }
                            }
                        }
                        cell.requestBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn2.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn.layer.borderWidth = 0
                        cell.requestBtn2.layer.borderWidth = 0
                        cell.requestBtn.backgroundColor = UIColor(named: "warning")
                        cell.requestBtn2.backgroundColor = UIColor(named: "warning")
                        cell.requestBtn.setTitleColor(UIColor(named: "Text Grey"), for: .normal)
                        cell.requestBtn2.setTitleColor(UIColor(named: "Text Grey"), for: .normal)

                        cell.btnsView.isHidden = true

                    } else if userModel.userContacts.contactStatus == "Accepted" {
                        cell.requestBtn.setTitle("Connected ", for: .normal)
                        cell.requestBtn2.setTitle("Connected ", for: .normal)
                        cell.requestBtn.backgroundColor = UIColor(named: "Success")
                        cell.requestBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn2.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn.setTitleColor(UIColor(named: "Text Grey"), for: .normal)
                        cell.requestBtn2.setTitleColor(UIColor(named: "Text Grey"), for: .normal)
                        cell.requestBtn.layer.borderWidth = 0
                        cell.requestBtn2.layer.borderWidth = 0
                        canCancelReq = "discon"
                        if let userContact = userModel.userContacts {
                            contactId = userContact.id
                        }
                        cell.btnsView.isHidden = false

                    } else {
                        cell.requestBtn.setTitle("Request ", for: .normal)
                        cell.requestBtn2.setTitle("Request ", for: .normal)
                        cell.requestBtn.setTitleColor(UIColor.white, for: .normal)
                        cell.requestBtn2.setTitleColor(UIColor.white, for: .normal)
                        cell.requestBtn.backgroundColor = UIColor(named: "Secondary Grey")
                        cell.requestBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn2.layer.borderColor = UIColor.lightGray.cgColor
                        cell.requestBtn.layer.borderWidth = 0
                        cell.requestBtn2.layer.borderWidth = 0
                        cell.btnsView.isHidden = true
                    }
                }
                
                cell.requestBtn.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                cell.requestBtn2.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                cell.messageBtn.addTarget(self, action: #selector(sendMessagePressed(sender:)), for: .touchUpInside)
                cell.profilePicBtn.addTarget(self, action: #selector(profilePicBtnPressed(sender:)), for: .touchUpInside)
                return cell

                /*cell.toolTipBtn.isHidden = true
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
                    cell.rocketBtn.setTitle("Request ", for: .normal)
                    cell.rocketBtn.backgroundColor = UIColor(named: "Secondary Grey")
                    cell.rocketBtn.layer.borderColor = UIColor.lightGray.cgColor
                    cell.rocketBtn.layer.borderWidth = 1
                    cell.rocketBtn.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                } else {
                    if userModel.userContacts.contactStatus == "Pending" {
                        if let userContact = userModel.userContacts {
                            if userContact.isSentByCurrentUsers {
                                canCancelReq = "cancel"
                                contactId = userContact.id
                                cell.rocketBtn.setTitle("Pending ", for: .normal)
                                
                            } else {
                                cell.rocketBtn.setTitle("Accept/Decline ", for: .normal)
                                if isFromReq {
                                    canCancelReq = "already"
                                } else {
                                    canCancelReq = "a/d"
                                }
                            }
                        }
                        cell.rocketBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.rocketBtn.layer.borderWidth = 1
                        cell.rocketBtn.backgroundColor = UIColor(named: "warning")
                    } else if userModel.userContacts.contactStatus == "Accepted" {
                        cell.rocketBtn.setTitle("Connected ", for: .normal)
                        cell.rocketBtn.backgroundColor = UIColor(named: "Success")
                        cell.rocketBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.rocketBtn.layer.borderWidth = 1
                        canCancelReq = "discon"
                        if let userContact = userModel.userContacts {
                            contactId = userContact.id
                        }
                    } else {
                        cell.rocketBtn.setTitle("Request ", for: .normal)
                        cell.rocketBtn.backgroundColor = UIColor(named: "Secondary Grey")
                        cell.rocketBtn.layer.borderColor = UIColor.lightGray.cgColor
                        cell.rocketBtn.layer.borderWidth = 1
                        cell.rocketBtn.addTarget(self, action: #selector(sendContactRocket(sender:)), for: .touchUpInside)
                    }
                }
                */
                    
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                    cell.aboutTxtView.text = userModel.about
                

                return cell
            /*case 2:
                let cell : StatusTVCell = tableView.dequeueReusableCell(withIdentifier: "StatusTVCell", for: indexPath) as! StatusTVCell
                
                if userModel.status != nil {
                    cell.statusLbl.text = userModel.status.isEmpty ? "currently no active status..." : userModel.status
                    cell.clockIV.isHidden = !userModel.disappearingStatus
                } else {
                    cell.statusLbl.text = "currently no active status..."
                    cell.clockIV.isHidden = true
                }
                
                return cell*/
                
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
            case 5: // social heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                if !socialAccounts.isEmpty {
                    cell.headerLblView.isHidden = false
                    cell.headerLbl.text = "Social accounts"
                } else {
                    cell.headerLblView.isHidden = true
                }
                
                return cell
                
            case socialAccounts.count + 6: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case socialAccounts.count + 7: // button
                let cell : BlockBtnTVCell = tableView.dequeueReusableCell(withIdentifier: "BlockBtnTVCell", for: indexPath) as! BlockBtnTVCell
                if isFromBlock {
                    cell.blockBtn.isHidden = true
                }
                cell.blockBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)

                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                if socialAccounts[indexPath.row - 6].linkImage != "" {
                    let imageUrl = URL(string: socialAccounts[indexPath.row - 6].linkImage)
                    cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                } else {
                    //cell.profilePicBtn.setImage(img, for: .normal)
                }
                if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 6].linkType }).count > 0 {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                } else {
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
                }
                
                cell.socialLbl.text = socialAccounts[indexPath.row - 6].linkType.capitalized
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
            
        } else  if indexPath.row == 5 {
            
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
        } else if indexPath.row > 5 && indexPath.row < socialAccounts.count + 6 {
            if socialAccModel.filter({$0.linkType == socialAccounts[indexPath.row - 6].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.isFromOther = true
                    vc.userId = userModel.userId
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

