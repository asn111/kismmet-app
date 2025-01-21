//
//  ConnectedUserProfile.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit
//RxRealmimport RxRealm
import RxSwift
import RealmSwift
import CDAlertView
import UIMultiPicker

class ConnectedUserProfile: MainViewController {
    
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
    
    //var socialAccounts = [ContactTypesModel()]
    
    var isFromBlock = false
    
    var isFromReq = false
    
    var markView = false
    var userModel = UserModel()
    var userId = ""
    var contactId = 0
    var socialAccModel = [ContactInformations]()
    
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getReasons()
        
        //userProfile(id: userId)

        Logs.show(message: "User ID: \(String(describing: userModel.userId))")
        Logs.show(message: "User: \(userModel)")
        
        registerCells()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
        otherProfileTV.register(UINib(nibName: "ConnectedBtnsTVCell", bundle: nil), forCellReuseIdentifier: "ConnectedBtnsTVCell")
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
    
    func showAlertCancel(){
        var message = ""
        
        message = "Are you sure you want to delete this contact?"
        
        
        let alert = CDAlertView(title: "Alert!", message: message, type: .error)
        let action = CDAlertViewAction(title: "Delete",
                                       handler: {[weak self] action in
            self?.deleteContact()
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
    
    func readThisProfile() {
        
        let pram = ["contactId": "\(userModel.contactId ?? 0)",
                    "isRead":"\(true)"
        ]
        
        SignalRManager.singelton.connection.invoke(method: "ReadContactRequest", pram) {  error in
            if let e = error {
                Logs.show(message: "Error: \(e)")
                AppFunctions.showSnackBar(str: "Error in updating values")
                return
            }
        }
    }
    
    @objc
    func starTapFunction(sender:UIButton) {
        markUserStar(userId: userModel.userId)

//        let cell = otherProfileTV.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? GeneralHeaderTVCell
//        
//        if cell?.rattingBtn.imageView?.image == UIImage(systemName: "star.fill") {
//            cell?.rattingBtn.setImage(UIImage(systemName: "star"), for: .normal)
//        } else {
//            cell?.rattingBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
//            markUserStar(userId: userModel.userId)
//        }
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
            TimeTracker.shared.stopTracking(for: "markUserStar")
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
    
    @objc func deleteBtnPressed(sender: UIButton) {
        showAlertCancel()
    }
    
    @objc func msgBtnPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            let user = userModel
            
            vc.userId = user.userId
            vc.workTitle = user.workTitle
            vc.userName = user.firstName + " " + (user.lastName ?? "")
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
    
    @objc func genBtnPressedForProfile(sender:UIButton) {
        self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
            vc.userId = userModel.userId
            //vc.markView = true
        }
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
    
    
    func userProfile(id: String) {
        
        APIService
            .singelton
            .getUserById(userId: id, isOtherUser: true)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            self.userModel = val
                            
                            if isFromReq {
                                if let userContacts = userModel.userContacts {
                                    if let contacts = userContacts.contactInformationsSharedByUser {
                                        socialAccModel = contacts
                                    }
                                }
                            } else {
                                if let userContacts = userModel.userContacts {
                                    if let contacts = userContacts.contactInformationsSharedByOther {
                                        socialAccModel = contacts
                                    }
                                }
                            }
                            
                            self.otherProfileTV.reloadData()
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
    
    func deleteContact() {
        self.showPKHUD(WithMessage: "")
        
        let pram : [String : Any] = [ "contactId": userModel.contactId ?? 0 ]
        
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
                            AppFunctions.showSnackBar(str: "Contact deleted successfully")
                            self.hidePKHUD()
                            self.navigationController?.popViewController(animated: true)
                            
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
extension ConnectedUserProfile : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.headerLogo.isHidden = true
                cell.headerLbl.text = "Contacts".uppercased()
                
                cell.headerLbl.isHidden = false
                cell.profileView.isHidden = false
                cell.headerView.isHidden = false
                cell.rattingBtn.isHidden = false
                
            
                
                cell.notifBtn.isHidden = true
                cell.chatBtn.isHidden = true
                cell.rocketBtn.isHidden = true
                
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
                
                
                cell.nameLbl.text = userModel.firstName + " " + (userModel.lastName ?? "")
                cell.professionLbl.text = userModel.workTitle
                cell.educationLbl.text = userModel.workAddress
                
                
                if userModel.profilePicture != "" && userModel.profilePicture != nil {
                    let imageUrl = URL(string: userModel.profilePicture)
                    cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                } else {
                    cell.profilePicBtn.setImage(img, for: .normal)
                }
                
              

                
                return cell
//            case 1:
//                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
//                
//                cell.genBtnView.isHidden = true
//                cell.newBtnView.isHidden = false
//                cell.newBtn.tag = indexPath.row
//                cell.newBtn.addTarget(self, action: #selector(genBtnPressedForProfile(sender:)), for: .touchUpInside)
//                
//                cell.newBtn.titleLabel?.font = UIFont(name: "Work Sans", size: 14)?.regular
//                cell.newBtn.setTitle("View full profile", for: .normal)
//                cell.newBtn.backgroundColor = UIColor.clear
//                cell.newBtn.tintColor = UIColor(named: "Secondary Grey")
//                cell.newBtn.underline()
//                cell.newBtn.isWork = true
//                
//                return cell
               
                
            default:
                let cell : ConnectedBtnsTVCell = tableView.dequeueReusableCell(withIdentifier: "ConnectedBtnsTVCell", for: indexPath) as! ConnectedBtnsTVCell
                
                cell.viewProfileBtn.addTarget(self, action: #selector(genBtnPressedForProfile(sender:)), for: .touchUpInside)
                cell.msgBtn.addTarget(self, action: #selector(msgBtnPressed(sender:)), for: .touchUpInside)
                
                cell.blockBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                cell.deleteContactBtn.addTarget(self, action: #selector(deleteBtnPressed(sender:)), for: .touchUpInside)

                
                return cell
                
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

