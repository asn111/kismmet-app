//
//  NotificationVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 15/02/2023.
//

import UIKit

class NotificationVC: MainViewController {

    @IBOutlet weak var notifTV: UITableView!
    
    var notifList = [NotificationModel]()
    
    var readNotifList = [NotificationModel]()
    var unreadNotifList = [NotificationModel]()
    
    var img = UIImage(named: "placeholder")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getNotifs()
    }
    
    func registerCells() {
        
        notifTV.tableFooterView = UIView()
        notifTV.separatorStyle = .none
        notifTV.delegate = self
        notifTV.dataSource = self
        notifTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        notifTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        notifTV.register(UINib(nibName: "NotifTVCell", bundle: nil), forCellReuseIdentifier: "NotifTVCell")
    }
    
    func convertDateFormat(inputDateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        if let date = inputFormatter.date(from: inputDateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
            return outputFormatter.string(from: date)
        }
        return nil
    }


    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func notifBtnPressed(sender: UIButton) {
        
        if AppFunctions.isNotifEnable() {
            UIApplication.shared.unregisterForRemoteNotifications()
            AppFunctions.setNotifEnable(value: false)
            AppFunctions.showSnackBar(str: "Notifications are paused")
        } else {
            UIApplication.shared.registerForRemoteNotifications()
            AppFunctions.setNotifEnable(value: true)
            AppFunctions.showSnackBar(str: "Notifications are enabled")
        }
        
        notifTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
    
//MARK: API METHODS
    
    func updateNotif(id: Int) {
        let pram = ["notificationId": "\(id)",
                    "isRead":"\(true)"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        SignalRService.connection.invoke(method: "UpdateUserNotificationStatus", pram) {  error in            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
            self.getNotifs()
        }
    }
    
    func getNotifs() {
        
        self.showPKHUD(WithMessage: "fetching notification")
        
        APIService
            .singelton
            .getNotif()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        AppFunctions.setIsNotifCheck(value: false)
                        if val.count > 0 {
                            self.notifList.removeAll()
                            self.readNotifList.removeAll()
                            self.unreadNotifList.removeAll()
                            
                            self.notifList = val
                            self.readNotifList = self.notifList.filter({$0.isRead}).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })
                            self.unreadNotifList = self.notifList.filter({$0.isRead == false}).sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedDescending })
                            self.notifTV.reloadData()
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
        self.showPKHUD(WithMessage: "fetching notification")

        APIService
            .singelton
            .getUserById(userId: id, isOtherUser: true)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= AppFunctions.getMaxProfViewedCount() {
                                    AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
                                } else {
                                    self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                                        vc.userModel = val
                                    }
                                }
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
extension NotificationVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 1 // Main Header
            case 1:
                return unreadNotifList.count > 0 ? unreadNotifList.count + 1 : 0 // Unread notifications
            case 2:
                return readNotifList.count + 1 // Read notifications
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0: // Main Header
                let cell: GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "NOTIFICATIONS"
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.headerView.isHidden = false
                cell.notifBtn.isHidden = false
                
                if AppFunctions.isNotifEnable() {
                    cell.notifBtn.setImage(UIImage(systemName: "bell.badge.fill"), for: .normal)
                } else {
                    cell.notifBtn.setImage(UIImage(systemName: "bell.slash.fill"), for: .normal)
                }
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
            case 1: // Unread notifications
                if indexPath.row == 0 { // Subheader
                    let cell: MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                    cell.notifHeaderView.isHidden = false
                    cell.notifHeaderLbl.text = "New"
                    return cell
                } else { // Unread notification cells
                    let cell: NotifTVCell = tableView.dequeueReusableCell(withIdentifier: "NotifTVCell", for: indexPath) as! NotifTVCell
                    let notif = unreadNotifList[indexPath.row - 1]
                    // Configure cell with notif
                    
                    cell.notifView.backgroundColor = UIColor(named: "Cell BG Base Grey")
                    cell.notifView.shadowColor = UIColor(named: "Cell BG Base Grey")
                    
                    cell.nameLbl.text = notif.userName != nil ? notif.userName : "---"
                    cell.notifLbl.text = notif.notificationMessage != nil ? notif.notificationMessage : "---"
                    cell.timeLbl.text = notif.createdAt != nil ? convertDateFormat(inputDateString: notif.createdAt) : "---"
                    
                    if notif.profilePicture != nil && notif.profilePicture != "" {
                        let imageUrl = URL(string: notif.profilePicture)
                        cell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: img) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.profilePicIV.image = img
                    }
                    
                    return cell
                }
            case 2: // Read notifications
                if indexPath.row == 0 { // Subheader
                    let cell: MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                    cell.notifHeaderView.isHidden = false
                    cell.notifHeaderLbl.text = readNotifList.count > 0 && unreadNotifList.count > 0 ? "Earlier" : "You haven't received any notifications yet."
                    return cell
                } else { // Read notification cells
                    let cell: NotifTVCell = tableView.dequeueReusableCell(withIdentifier: "NotifTVCell", for: indexPath) as! NotifTVCell
                    let notif = readNotifList[indexPath.row - 1]
                    
                    // Configure cell with notif
                    cell.notifView.backgroundColor = UIColor(named: "Base White")
                    cell.notifView.shadowColor = UIColor.lightGray
                    
                    cell.nameLbl.text = notif.userName != nil ? notif.userName : "---"
                    cell.notifLbl.text = notif.notificationMessage != nil ? notif.notificationMessage : "---"
                    cell.timeLbl.text = notif.createdAt != nil ? convertDateFormat(inputDateString: notif.createdAt) : "---"

                    if notif.profilePicture != nil && notif.profilePicture != "" {
                        let imageUrl = URL(string: notif.profilePicture)
                        cell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: img) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.profilePicIV.image = img
                    }
                    
                    return cell
                }
            default:
                return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 1 {
            if indexPath.row != 0 {
                updateNotif(id: unreadNotifList[indexPath.row - 1].notificationId)
                userProfile(id: unreadNotifList[indexPath.row - 1].notifiedUserId)
            }
        } else {
            if indexPath.row != 0 {
                userProfile(id: readNotifList[indexPath.row - 1].notifiedUserId)
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if indexPath.section == 0 {
            return 100
        } else {
            return UITableView.automaticDimension
        }
    }
}

