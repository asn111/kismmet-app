//
//  ReqConVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 18/06/2024.
//

import UIKit

class ReqConVC: MainViewController {

    
    @IBOutlet weak var reqTV: UITableView!
    
    var users = [UserModel]()
    var chatsUsers = [ChatUsersModel]()

    private let refresher = UIRefreshControl()
    
    var localStarredStatus: [String: Bool] = [:] // Key: userId, Value: isStarred

    
    var selectedUsertype = "req"
    var searchString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getReqUsers(load: false)
        registerCells()
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "roloadList" {
                if self?.selectedUsertype == "con" {
                    self?.getContUsers(load: false)
                } else {
                    self?.getReqUsers(load: false)
                }
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.selectedUsertype == "con" {
            self.getContUsers(load: false)
        } else {
            self.getReqUsers(load: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchString = ""
    }
    
    func registerCells() {
        
        reqTV.tableFooterView = UIView()
        reqTV.separatorStyle = .none
        reqTV.delegate = self
        reqTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        reqTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        reqTV.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        reqTV.alwaysBounceVertical = true
        reqTV.refreshControl = refresher // iOS 10
        reqTV.addSubview(refresher)
        
        reqTV.register(UINib(nibName: "TabsHeaderTVCell", bundle: nil), forCellReuseIdentifier: "TabsHeaderTVCell")
        reqTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        reqTV.register(UINib(nibName: "FeedItem2TVCell", bundle: nil), forCellReuseIdentifier: "FeedItem2TVCell")
        reqTV.register(UINib(nibName: "ChatUsersTVCell", bundle: nil), forCellReuseIdentifier: "ChatUsersTVCell")
        reqTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

    }
    
    @objc func chatBtnPressed(sender: UIButton) {
        self.pushVC(id: "MessageListViewController") { (vc:MessageListViewController) in }
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            if selectedUsertype == "con" {
                getContUsers(load: true)
            } else {
                getReqUsers(load: true)
            }
            return
        }
        if selectedUsertype == "con" {
            getContUsers(load: true)
        } else {
            getReqUsers(load: true)
        }
    }
    
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .search
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if selectedUsertype == "con" {
            getContUsers(load: false)
        } else {
            getReqUsers(load: false)
        }
        return true
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc
    func settingsTap(sender:UITapGestureRecognizer) {
        self.pushVC(id: "ContactInformainVC") { (vc:ContactInformainVC) in
            vc.isSetting = true
        }
    }
    
    @objc
    func starTapFunction(sender: UIButton) {
        let index = sender.tag
        let user = users[index - 1]
        
        let currentStatus = (localStarredStatus[user.userId] ?? user.isStarred) ?? false
        let newStatus = !currentStatus
        
        // Update local state
        localStarredStatus[user.userId] = newStatus
        
        // Update UI immediately
        sender.setImage(UIImage(systemName: newStatus ? "star.fill" : "star"), for: .normal)
        
        // Perform the server update
        markUserStar(userId: user.userId)
        
        // Optional: Reload the specific row to ensure consistency
        reqTV.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
    }

    
    /*@objc
    func starTapFunction(sender:UIButton) {
        
        markUserStar(userId: users[sender.tag - 1].userId)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        
        /*if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItem2TVCell {
                guard let indexPath = self.reqTV.indexPath(for: cell) else {return}
                print("index path = \(indexPath)")
                if cell.starLbl.image?.isEqual(UIImage(systemName: "star.fill")) == true {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
            } else if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.reqTV.indexPath(for: cell) else {return}
                print("index path Else = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
            }
        }*/
    }*/
    
    func markUserStar(userId: String) {
        TimeTracker.shared.startTracking(for: "markUserStar")
        
        let pram = ["userId": "\(userId)"]
        Logs.show(message: "PRAM: \(pram)")
        SignalRService.connection.invoke(method: "StarUser", pram) {  error in
            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
            TimeTracker.shared.stopTracking(for: "markUserStar")
        }
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then a
        self.showPKHUD(WithMessage: "")
        reqTV.refreshControl?.beginRefreshing()
        if selectedUsertype == "con" {
            getContUsers(load: false)
        } else {
            getReqUsers(load: false)
        }
    }
    func stopRefresher() {
        self.hidePKHUD()
        reqTV.refreshControl?.endRefreshing()
    }
    
    //MARK: API METHODS
    
    func getReqUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString, "contactStatus": 0]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getUserRequests(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users.removeAll()
                            self.users = val
                            self.reqTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                        } else {
                            self.stopRefresher()
                            self.hidePKHUD()
                            self.users.removeAll()
                            self.reqTV.reloadData()
                            self.stopRefresher()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.reqTV.reloadData()
                        self.stopRefresher()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.stopRefresher()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    func getContUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString, "contactStatus": 0]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getUserContacts(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users.removeAll()
                            self.users = val
                            self.reqTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                         } else {
                             self.stopRefresher()
                             self.hidePKHUD()
                             self.users.removeAll()
                             self.reqTV.reloadData()
                             self.stopRefresher()
                         }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.reqTV.reloadData()
                        self.stopRefresher()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.stopRefresher()
                }
            })
            .disposed(by: dispose_Bag)
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
                            self.reqTV.reloadData()
                            self.hidePKHUD()
                        } else {
                            self.hidePKHUD()
                            self.chatsUsers.removeAll()
                            self.reqTV.reloadData()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.chatsUsers.removeAll()
                        self.reqTV.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.reqTV.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
}

//MARK: TableView Extention
extension ReqConVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedUsertype == "chat" {
            if chatsUsers.isEmpty {
                return 2
            }
            return chatsUsers.count + 1

        } else {
            if users.isEmpty {
                return 2
            }
            return users.count + 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           
            let cell : TabsHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "TabsHeaderTVCell", for: indexPath) as! TabsHeaderTVCell
            
            cell.notifbtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
            cell.wifiManBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                        
            cell.onReqBtnTap = {
                
                self.getReqUsers(load: false)
                cell.headerLbl.text = "RESPOND"
                self.selectedUsertype = "req"
                UIView.transition(with: cell.btnsImg,
                                  duration: 0.1, // Adjust the duration as needed
                                  options:.transitionCrossDissolve,
                                  animations: { cell.btnsImg.image = UIImage(named: "reqSelected") },
                                  completion: nil)
            }
            
            cell.onConBtnTap = {
                self.getContUsers(load: false)
                cell.headerLbl.text = "FRIENDS"
                self.selectedUsertype = "con"
                UIView.transition(with: cell.btnsImg,
                                  duration: 0.1, // Adjust the duration as needed
                                  options:.transitionCrossDissolve,
                                  animations: { cell.btnsImg.image = UIImage(named: "conSelected") },
                                  completion: nil)
            }
            
            cell.onChatBtnTap = {
                self.getChatUsers()
                cell.headerLbl.text = "CHATS"
                self.selectedUsertype = "chat"
                UIView.transition(with: cell.btnsImg,
                                  duration: 0.1, // Adjust the duration as needed
                                  options:.transitionCrossDissolve,
                                  animations: { cell.btnsImg.image = UIImage(named: "chatSelected") },
                                  completion: nil)
            }
            
           
            cell.settingsLbl.attributedText = NSAttributedString(string: "Settings", attributes:
                                                                    [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont(name: "Roboto", size: 14)!.bold, .foregroundColor: UIColor(hexFromString: "4E6E81")])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(settingsTap(sender:)))
            cell.settingsLbl.isUserInteractionEnabled = true
            cell.settingsLbl.addGestureRecognizer(tap)
            
            cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)
            cell.chatBtn.addTarget(self, action: #selector(chatBtnPressed(sender:)), for: .touchUpInside)

            cell.searchTF.delegate = self
            cell.searchTF.placeholder = selectedUsertype == "con" ? "Search through your contacts" : "Search through your requests"
            cell.searchTF.returnKeyType = .search
            cell.searchTF.tag = 010
            if searchString != "" {
                cell.searchBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
            } else {
                cell.searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                cell.searchTF.text = ""
            }
            
            return cell
            
        } else {
            
            var cell = UITableViewCell()
            
            if selectedUsertype == "chat" {
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsersTVCell", for: indexPath) as! ChatUsersTVCell

                let user = chatsUsers[indexPath.row - 1]

                if let chatUserCell = cell as? ChatUsersTVCell {
                    chatUserCell.nameLbl.text = user.userName.capitalized
                    chatUserCell.proffLbl.text = user.userWorkTitle.capitalized
                    
                    if user.isOnline {
                        chatUserCell.onlineView.isHidden = false
                    } else {
                        chatUserCell.onlineView.isHidden = true
                    }
                    
                    if user.unReadCount > 0 {
                        chatUserCell.countLbl.text = "\(user.unReadCount ?? 0)"
                        chatUserCell.countView.isHidden = false
                    } else {
                        chatUserCell.countView.isHidden = true
                    }
                    
                    if user.lastMessage.isLastMessageByMe {
                        chatUserCell.msgLbl.text = "You: " + user.lastMessage.chatMessage.capitalized
                    } else {
                        chatUserCell.msgLbl.text = user.lastMessage.chatMessage.capitalized
                    }
                }
                
                
                return cell
                
            } else {
                
                var user = UserModel()
                if users.count > 0 {
                    user = users[indexPath.row - 1]
                }
                
                if users.isEmpty {
                    cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem2TVCell", for: indexPath) as! FeedItem2TVCell
                }
                
                if let visiblityCell = cell as? VisibilityOffTVCell {
                    
                    visiblityCell.visibiltyView.isHidden = true
                    visiblityCell.updateBtn.isHidden = true
                    if selectedUsertype == "req" {
                        visiblityCell.textLbl.text = "At this time, there are no users in your requests."
                    } else {
                        visiblityCell.textLbl.text = "At this time, there are no users in your contacts."
                    }
                    
                    
                } else if let feedCell2 = cell as? FeedItem2TVCell {
                    
                    feedCell2.nameLbl.text = user.userName
                    feedCell2.professionLbl.text = user.workTitle
                    feedCell2.educationLbl.text = user.workAddress
                    
                    feedCell2.noteIcon.isHidden = false
                    
                    if user.tags != nil && user.tags != "" {
                        if !user.tags.contains(",") {
                            feedCell2.tagLbl.text = user.tags
                            feedCell2.tagMoreView.isHidden = true
                            
                            feedCell2.tagsWidthConst.constant = feedCell2.firstTagView.frame.width + 20
                        } else {
                            feedCell2.tagMoreView.isHidden = false
                            let split = user.tags.split(separator: ",")
                            feedCell2.tagLbl.text = "\(split[0])"
                            feedCell2.tagMoreLbl.text = "\(split.count - 1) more"
                            
                            feedCell2.tagsWidthConst.constant = 125
                            
                        }
                    }
                    
                    
                    if user.isRead {
                        feedCell2.nonBlurView.backgroundColor = UIColor(named: "Base White")
                        feedCell2.nonBlurView.shadowColor = UIColor.systemGray2
                    } else {
                        feedCell2.nonBlurView.backgroundColor = UIColor(named: "Cell BG Base Grey")
                        feedCell2.nonBlurView.shadowColor = UIColor(named: "Cell BG Base Grey")
                    }
                    
                    feedCell2.profilePicIV.borderWidth = 3
                    
                    if user.contactStatus == "Pending" {
                        feedCell2.profilePicIV.borderColor = UIColor(named: "warning")
                    } else if user.contactStatus == "Accepted" {
                        feedCell2.profilePicIV.borderColor = UIColor(named: "Success")
                    } else {
                        feedCell2.profilePicIV.borderColor = UIColor(named: "Secondary Grey")
                        //feedCell2.profilePicIV.borderWidth = 0
                    }
                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell2.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell2.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
                    let isStarred = localStarredStatus[user.userId] ?? user.isStarred
                    
                    let imageName = isStarred ?? false ? "star.fill" : "star"
                    feedCell2.starBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    
                    feedCell2.starBtn.tag = indexPath.row
                    feedCell2.starBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)
                    
                }
                
                return cell
                
            }
            
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if !users.isEmpty {
                if selectedUsertype == "con" {
                    //self.pushVC(id: "MessageListViewController") { (vc:MessageListViewController) in }

                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController {
                        let user = users[indexPath.row - 1]
                        
                        vc.userId = user.userId
                        //vc.chatId = user.chatId
                        //vc.isOnline = user.isOnline
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
                    
                    /*self.pushVC(id: "ConnectedUserProfile") { (vc:ConnectedUserProfile) in
                        vc.userModel = users[indexPath.row - 1]
                        vc.userId = users[indexPath.row - 1].userId
                    }*/
                } else if selectedUsertype == "con" {
                    
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
                        vc.userProfilePic = user.userProfilePicture
                        
                        self.navigationController?.view.layer.add(transition, forKey: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                } else {
                    if users[indexPath.row - 1].contactStatus == "Pending" {
                        self.presentVC(id: "ReqAcceptVC", presentFullType: "over" ) { (vc:ReqAcceptVC) in
                            vc.userModel = users[indexPath.row - 1]
                        }
                    } else if users[indexPath.row - 1].contactStatus != "Denied" {
                        self.pushVC(id: "ConnectedUserProfile") { (vc:ConnectedUserProfile) in
                            vc.userModel = users[indexPath.row - 1]
                            vc.userId = users[indexPath.row - 1].userId
                            vc.isFromReq = true
                        }
                    } else {
                        self.presentVC(id: "OtherUserProfile", presentFullType: "over" ) { (vc:OtherUserProfile) in
                            vc.userModel = users[indexPath.row - 1]
                            vc.isFromReq = true
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

