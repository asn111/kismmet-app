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
    private let refresher = UIRefreshControl()
    
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
        getMyContacts()

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
        reqTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

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
    func starTapFunction(sender:UITapGestureRecognizer) {
        if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItem2TVCell {
                guard let indexPath = self.reqTV.indexPath(for: cell) else {return}
                print("index path = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                }
            } else if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.reqTV.indexPath(for: cell) else {return}
                print("index path Else = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                }
            }
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
    
    func getMyContacts() {
        
        
        APIService
            .singelton
            .getConnectedContactsAccTypes()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            if val.isEmpty {
                                val.forEach { contact in
                                    if contact.isShared {
                                        AppFunctions.setSelectedCheckValue(value: contact.contactTypeId)
                                    }
                                }
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
extension ReqConVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.isEmpty {
            return 2
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
           
            let cell : TabsHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "TabsHeaderTVCell", for: indexPath) as! TabsHeaderTVCell
            
            cell.notifbtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
            cell.wifiManBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                        
            cell.onReqBtnTap = {
                
                self.getReqUsers(load: false)
                cell.headerLbl.text = "REQUESTS"
                self.selectedUsertype = "req"
                UIView.transition(with: cell.btnsImg,
                                  duration: 0.1, // Adjust the duration as needed
                                  options:.transitionCrossDissolve,
                                  animations: { cell.btnsImg.image = UIImage(named: "conSelected") },
                                  completion: nil)
            }
            
            cell.onConBtnTap = {
                self.getContUsers(load: false)
                cell.headerLbl.text = "CONTACTS"
                self.selectedUsertype = "con"
                UIView.transition(with: cell.btnsImg,
                                  duration: 0.1, // Adjust the duration as needed
                                  options:.transitionCrossDissolve,
                                  animations: { cell.btnsImg.image = UIImage(named: "reqSelected") },
                                  completion: nil)
            }
            
           
            cell.settingsLbl.attributedText = NSAttributedString(string: "Settings", attributes:
                                                                    [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont(name: "Roboto", size: 14)!.bold, .foregroundColor: UIColor(hexFromString: "4E6E81")])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(settingsTap(sender:)))
            cell.settingsLbl.isUserInteractionEnabled = true
            cell.settingsLbl.addGestureRecognizer(tap)
            
            cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)

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
            var user = UserModel()
            if users.count > 0 {
                user = users[indexPath.row - 1]
            }
            
            if users.isEmpty {
                cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
            } else if user.status != nil && user.status != "" {
                cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
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
                
                
            } else if let feedCell = cell as? FeedItemsTVCell {
                
                feedCell.nameLbl.text = user.userName
                feedCell.professionLbl.text = user.workTitle
                feedCell.educationLbl.text = user.workAddress
                
                if user.tags != nil && user.tags != "" {
                    if !user.tags.contains(",") {
                        feedCell.tagLbl.text = user.tags
                        feedCell.tagMoreView.isHidden = true
                    } else {
                        feedCell.tagMoreView.isHidden = false
                        let split = user.tags.split(separator: ",")
                        feedCell.tagLbl.text = "\(split[0])"
                        feedCell.tagMoreLbl.text = "\(split.count - 1) more"
                        
                    }
                }
                
                feedCell.profilePicIV.borderWidth = 3
                
                if user.contactStatus == "Pending" {
                    feedCell.profilePicIV.borderColor = UIColor(named: "warning")
                } else if user.contactStatus == "Accepted" {
                    feedCell.profilePicIV.borderColor = UIColor(named: "Success")
                } else {
                    feedCell.profilePicIV.borderColor = UIColor(named: "Secondary Grey")
                    //feedCell.profilePicIV.borderWidth = 0
                }
                
                if user.profilePicture != "" && user.profilePicture != nil {
                    let imageUrl = URL(string: user.profilePicture)
                    feedCell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                } else {
                    feedCell.profilePicIV.image = UIImage(named: "placeholder")
                }
                
                if user.isRead {
                    feedCell.nonBlurView.backgroundColor = UIColor(named: "Base White")
                    feedCell.nonBlurView.shadowColor = UIColor.systemGray2
                } else {
                    feedCell.nonBlurView.backgroundColor = UIColor(named: "Cell BG Base Grey")
                    feedCell.nonBlurView.shadowColor = UIColor(named: "Cell BG Base Grey")
                }
                
                feedCell.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
                feedCell.starLbl.isUserInteractionEnabled = true
                feedCell.starLbl.addGestureRecognizer(tap)
                
                feedCell.isViewBHidden = false
                feedCell.statusLbl.text = user.status.isEmpty ? "currently no active status..." : user.status
                feedCell.clockIV.isHidden = !user.disappearingStatus
                
                
                
            } else if let feedCell2 = cell as? FeedItem2TVCell {
                
                feedCell2.nameLbl.text = user.userName
                feedCell2.professionLbl.text = user.workTitle
                feedCell2.educationLbl.text = user.workAddress
                
                if user.tags != nil && user.tags != "" {
                    if !user.tags.contains(",") {
                        feedCell2.tagLbl.text = user.tags
                        feedCell2.tagMoreView.isHidden = true
                    } else {
                        feedCell2.tagMoreView.isHidden = false
                        let split = user.tags.split(separator: ",")
                        feedCell2.tagLbl.text = "\(split[0])"
                        feedCell2.tagMoreLbl.text = "\(split.count - 1) more"
                        
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
                
                feedCell2.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
                feedCell2.starLbl.isUserInteractionEnabled = true
                feedCell2.starLbl.addGestureRecognizer(tap)
                
            }
            
            return cell
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            if !users.isEmpty {
                if selectedUsertype == "con" {
                    self.pushVC(id: "ConnectedUserProfile") { (vc:ConnectedUserProfile) in
                        vc.userModel = users[indexPath.row - 1]
                        vc.userId = users[indexPath.row - 1].userId
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

