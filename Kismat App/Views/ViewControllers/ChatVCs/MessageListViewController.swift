
import UIKit
import SwiftDate

class MessageListViewController: MainViewController {

    @IBOutlet weak var tableView: UITableView!

    var chatsUsers = [ChatUsersModel]()
    
    var searchString = ""

    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        
        fabTapAction = { [weak self] in
            if !(self?.chatsUsers.isEmpty ?? false) {
                self?.presentVC(id: "ChatUsersListVC", presentFullType: "over" ) { (vc:ChatUsersListVC) in }
            }
        }
        
        _ = generalPublisherChat.subscribe(onNext: {[weak self] val in
            
            self?.getChatUsers()
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getChatUsers()
    }
    
    func registerCells() {
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        tableView.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        tableView.register(UINib(nibName: "EmptyChatView", bundle: nil), forCellReuseIdentifier: "EmptyChatView")
        tableView.register(UINib(nibName: "ChatUsersTVCell", bundle: nil), forCellReuseIdentifier: "ChatUsersTVCell")
        
    }
    
    //MARK:- UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Browse your blocked users.", btn: sender)
    }
    
    @objc func emptyChatBtnPressed(sender: UIButton) {
        self.presentVC(id: "ChatUsersListVC", presentFullType: "over" ) { (vc:ChatUsersListVC) in }
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            //getBlockedUsers(load: true)
            return
        }
        //getBlockedUsers(load: true)
    }
    
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //getBlockedUsers(load: true)
        return true
    }
    
    func fancyStyleDate(dateStr: String) -> DateInRegion {
        
        let currentRegion = Region.current
        
        let locale = currentRegion.locale
        let timeZone = currentRegion.timeZone
        
        let region = Region(calendar: Calendars.gregorian, zone: timeZone, locale: locale)
        let date = DateInRegion(dateStr, format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", region: region)!
        
        return date
    }
    
    func timeElapsed(from dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Parse as GMT/UTC
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = dateFormatter.date(from: dateString) else {
            print("Error: Could not parse the date string.")
            return nil
        }
        
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        // Debugging output
        print("Parsed date:", date)
        print("Current date:", now)
        print("Time interval in seconds:", timeInterval)
        
        if timeInterval < 60 {
            // Less than a minute
            return "few sec ago"
        } else if timeInterval < 3600 {
            // Less than an hour
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if timeInterval < 86400 {
            // Less than a day
            let hours = Int(timeInterval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if timeInterval < 2592000 {
            // Less than 30 days (about 1 month)
            let days = Int(timeInterval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            // More than 30 days (count as months)
            let months = Int(timeInterval / 2592000)
            return "\(months) month\(months == 1 ? "" : "s") ago"
        }
    }

    
    func getChatUsers() {
        
        APIService
            .singelton
            .getChatUsers()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.chatsUsers.removeAll()
                            self.chatsUsers = val
                            self.tableView.reloadData()
                            self.hidePKHUD()
                            self.showHideFabBtn(shouldShow: true)

                        } else {
                            self.hidePKHUD()
                            self.chatsUsers.removeAll()
                            self.tableView.reloadData()
                            self.showHideFabBtn(shouldShow: false)

                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.chatsUsers.removeAll()
                        self.tableView.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.tableView.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
}

extension MessageListViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsUsers.count > 0 ? chatsUsers.count + 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
            cell.headerLbl.isHidden = false
            cell.headerLbl.text = "CHATS"
            cell.searchView.isHidden = false
            cell.swipeTxtLbl.isHidden = false
            cell.headerView.isHidden = false
            cell.swipeTxtLbl.text = "Please swipe left to remove from chat list."
            
            cell.searchTF.delegate = self
            cell.searchTF.placeholder = "Search through your chat users"
            cell.searchTF.returnKeyType = .search
            cell.searchTF.tag = 010
            cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)
            
            if searchString != "" {
                cell.searchBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
            } else {
                cell.searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                cell.searchTF.text = ""
            }
            
            cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
            
            
            cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
            cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
            cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
            
            cell.picBtn.borderWidth = 0
            cell.chatBtn.isHidden = true
            
            
            if AppFunctions.isShadowModeOn() {
                if AppFunctions.isNotifEnable() {
                    if AppFunctions.isNotifNotCheck() {
                        cell.notifBtn.setImage(UIImage(named: "shadowWN"), for: .normal)
                        cell.notifBtn.tintColor = UIColor(named: "Text grey")
                    } else {
                        cell.notifBtn.setImage(UIImage(named: "shadowWON"), for: .normal)
                        cell.notifBtn.tintColor = UIColor(named: "Text grey")
                    }
                } else {
                    cell.notifBtn.setImage(UIImage(systemName: "bell.slash.fill"), for: .normal)
                    cell.notifBtn.tintColor = UIColor(named: "warning")
                }
            } else {
                if AppFunctions.isNotifEnable() {
                    if AppFunctions.isNotifNotCheck() {
                        cell.notifBtn.setImage(UIImage(named: "regularWN"), for: .normal)
                        cell.notifBtn.tintColor = UIColor(named: "Text grey")
                    } else {
                        cell.notifBtn.setImage(UIImage(named: "regular"), for: .normal)
                        cell.notifBtn.tintColor = UIColor(named: "Text grey")
                    }
                } else {
                    cell.notifBtn.setImage(UIImage(systemName: "bell.slash.fill"), for: .normal)
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
                }
            }
            
            return cell
            
            
        } else {
            if chatsUsers.isEmpty {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyChatView", for: indexPath) as! EmptyChatView
                
                cell.emptyViewBtn.addTarget(self, action: #selector(emptyChatBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsersTVCell", for: indexPath) as! ChatUsersTVCell
                
                let user = chatsUsers[indexPath.row - 1]
                
                cell.nameLbl.text = user.userName
                cell.proffLbl.text = user.userWorkTitle
                cell.lastMsgTimeLbl.text = timeElapsed(from: user.lastMessage.createdAt) //fancyStyleDate(dateStr: user.lastLoginTime).toRelative(since: DateInRegion(), dateTimeStyle: .numeric, unitsStyle: .full)
                
                if let url = URL(string: user.userProfilePicture) {
                    cell.profileIcon.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
                }
                
                if user.isOnline {
                    cell.onlineView.isHidden = false
                } else {
                    cell.onlineView.isHidden = true
                }
                
                if user.unReadCount > 0 {
                    cell.countLbl.text = "\(user.unReadCount ?? 0)"
                    cell.countView.isHidden = false
                } else {
                    cell.countView.isHidden = true
                }
                
                if user.lastMessage.isLastMessageByMe {
                    
                    let text = "You: " + user.lastMessage.chatMessage
                    let textRange = NSRange(location: 0, length: 4)
                    let attributedText = NSMutableAttributedString(string: text)
                    
                    // Safely unwrap the font
                    if let mediumFont = UIFont(name: "Roboto", size: 14)?.medium {
                        attributedText.addAttribute(NSAttributedString.Key.font, value: mediumFont, range: textRange)
                    }
                    
                    // Safely unwrap the color
                    if let textGreyColor = UIColor(named: "Text Grey") {
                        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: textGreyColor, range: textRange)
                    }
                    
                    // Assign to the label
                    cell.msgLbl.attributedText = attributedText
                    
                    
                } else {
                    if user.unReadCount > 0 {
                        
                        let text = user.lastMessage.chatMessage ?? "--"
                        let textRange = NSRange(location: 0, length: user.lastMessage.chatMessage.count)
                        let attributedText = NSMutableAttributedString(string: text)
                        
                        // Safely unwrap the font
                        if let mediumFont = UIFont(name: "Roboto", size: 14)?.semibold {
                            attributedText.addAttribute(NSAttributedString.Key.font, value: mediumFont, range: textRange)
                        }
                        
                        // Safely unwrap the color
                        if let textGreyColor = UIColor(named: "Text Grey") {
                            attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: textGreyColor, range: textRange)
                        }
                        
                        // Assign to the label
                        cell.msgLbl.text = nil
                        cell.msgLbl.attributedText = attributedText
                        
                    } else {
                        cell.msgLbl.attributedText = nil
                        cell.msgLbl.text = user.lastMessage.chatMessage
                    }
                }
                
                return cell
            }
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        if chatsUsers.isEmpty { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let user = chatsUsers[indexPath.row - 1]

        if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
            //vc.chatModel = chatsUsers[indexPath.row]
            let transition = CATransition()
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.fade
            
            vc.userId = user.userId
            vc.chatId = user.chatId
            vc.isOnline = user.isOnline
            vc.userName = user.userName
            vc.workTitle = user.userWorkTitle
            vc.userProfilePic = user.userProfilePicture
            
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
             completionHandler(true)
            ApiService.deleteChatUsers(chatID: self.chatsUsers[indexPath.row - 1].chatId)
            self.chatsUsers.remove(at: indexPath.row - 1)
            if self.chatsUsers.count == 0 {
                self.showHideFabBtn(shouldShow: false)
            }
            tableView.reloadData()
            
        }
        deleteAction.image = UIImage(systemName: "x.circle")
        deleteAction.image?.withTintColor(UIColor.white)
        
        //deleteAction.backgroundColor = UIColor(named: "Text Grey")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}
