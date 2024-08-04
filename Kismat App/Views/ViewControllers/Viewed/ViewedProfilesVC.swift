//
//  ViewedProfilesVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 12/02/2023.
//

import UIKit

class ViewedProfilesVC: MainViewController {

    @IBOutlet weak var viewedListTV: UITableView!
    
    var nameArray = ["James Nio","Kris Burner","Mark Denial"]
    var profArray = ["Bachelor, Student","Entrepreneur","Professor"]
    var imageArray = [UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "professor")]
        
    var users = [UserModel]()
    var userdbModel = UserDBModel()
    var searchString = ""

    var isProfileVisible = false
    var isShadowMode = false
    var proximity = 150
    
    private let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getViewedByUsers(load: true)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "notif" {
                self?.viewedListTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getViewedByUsers(load: false)
    }
    
    func registerCells() {
        
        viewedListTV.tableFooterView = UIView()
        viewedListTV.separatorStyle = .none
        viewedListTV.delegate = self
        viewedListTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        viewedListTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        viewedListTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        viewedListTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        viewedListTV.register(UINib(nibName: "FeedItem2TVCell", bundle: nil), forCellReuseIdentifier: "FeedItem2TVCell")
        viewedListTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

        viewedListTV.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        viewedListTV.alwaysBounceVertical = true
        viewedListTV.refreshControl = refresher // iOS 10
        viewedListTV.addSubview(refresher)
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then a
        self.showPKHUD(WithMessage: "")
        viewedListTV.refreshControl?.beginRefreshing()
        getViewedByUsers(load: false)
    }
    
    func stopRefresher() {
        self.hidePKHUD()
        viewedListTV.refreshControl?.endRefreshing()
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Toggle off to go completely offline.\nOthers won't see you, and you won't see them.Toggle on to rejoin the community.", btn: sender)
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            getViewedByUsers(load: true)
            return
        }
        getViewedByUsers(load: true)
    }
    
    @objc func updateBtnPressed(sender: UIButton) {
        updateConfig()
    }
    
    @objc func toggleButtonPressed(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = viewedListTV.cellForRow(at: indexPath) as? VisibilityOffTVCell {
            isProfileVisible = cell.toggleBtn.isOn
        }
    }
    
    func updateConfig() {
        let pram = ["proximity": "\(proximity)",
                    "shadowMode":"\(isShadowMode)",
                    "isProfileVisible":"\(isProfileVisible)"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        SignalRService.connection.invoke(method: "UpdateUserConfigurations", pram) {  error in            Logs.show(message: "\(pram)")
            AppFunctions.setIsProfileVisble(value: self.isProfileVisible)
            self.getViewedByUsers(load: true)
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getViewedByUsers(load: true)
        return true
    }
    
    @objc
    func starTapFunction(sender:UITapGestureRecognizer) {
        if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItem2TVCell {
                guard let indexPath = self.viewedListTV.indexPath(for: cell) else {return}
                print("index path = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                }
            } else if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.viewedListTV.indexPath(for: cell) else {return}
                print("index path Else = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                }
            }
        }
    }
    
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
    
    //MARK: API METHODS
    
    func getViewedByUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getViewedByUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users.removeAll()
                            self.users = val
                            self.viewedListTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                        } else {
                            self.users.removeAll()
                            self.viewedListTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.viewedListTV.reloadData()
                        self.stopRefresher()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.stopRefresher()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
}
//MARK: TableView Extention
extension ViewedProfilesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !AppFunctions.isProfileVisble(){
            return 2
        } else if users.isEmpty {
            return 2
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "VIEWED BY"
                cell.searchView.isHidden = false
                cell.headerView.isHidden = false
                cell.swipeTxtLbl.isHidden = false

                cell.swipeTxtLbl.text = "Who's Interested!"

                //Seen Your Profile
                cell.toolTipBtn.isHidden = true
                cell.searchContraint.constant = 10
                
                cell.swipeTxtLbl.isHidden = false
                cell.swipeTxtLbl.text = "Who's Interested!"

                
                cell.searchTF.delegate = self
                cell.searchTF.placeholder = "Search through users who viewed you.."
                cell.searchTF.returnKeyType = .search
                cell.searchTF.tag = 010
                if searchString != "" {
                    cell.searchBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                } else {
                    cell.searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    cell.searchTF.text = ""
                }
                cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)
                
                
                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
                cell.picBtn.borderWidth = 0
                
                if AppFunctions.isNotifNotCheck() {
                    cell.notifBtn.tintColor = UIColor(named:"Danger")
                } else if AppFunctions.isShadowModeOn() {
                    cell.notifBtn.tintColor = UIColor(named: "Primary Yellow")
                } else {
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
                }
                
                return cell
                
                
                
            default:
                
                var cell = UITableViewCell()
                var user = UserModel()
                if users.count > 0 {
                    user = users[indexPath.row - 1]
                }
                
                if !AppFunctions.isProfileVisble(){
                    cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                } else {
                    if users.isEmpty {
                        cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                    } else if user.status != nil && user.status != "" {
                        cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem2TVCell", for: indexPath) as! FeedItem2TVCell
                    }
                }
                
                if let visiblityCell = cell as? VisibilityOffTVCell {
                    
                    visiblityCell.toggleBtn.isOn = false
                    visiblityCell.toggleBtn.tag = indexPath.row
                    visiblityCell.toolTipBtn.tag = 005
                    
                    
                    visiblityCell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                    visiblityCell.updateBtn.addTarget(self, action: #selector(updateBtnPressed(sender:)), for: .touchUpInside)
                    visiblityCell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                    
                    if users.isEmpty && AppFunctions.isProfileVisble() {
                        visiblityCell.visibiltyView.isHidden = true
                        visiblityCell.updateBtn.isHidden = true
                        visiblityCell.textLbl.text = "At this time, there are no users within your proximity range or matching your search criteria."
                    } else {
                        visiblityCell.visibiltyView.isHidden = false
                        visiblityCell.updateBtn.isHidden = false
                        visiblityCell.textLbl.text = "You are completely offline... Toggle back to rejoin the community and interact with others"
                    }
                    
                } else if let feedCell = cell as? FeedItemsTVCell {
                    
                    feedCell.nameLbl.text = user.userName
                    feedCell.professionLbl.text = user.workTitle
                    feedCell.educationLbl.text = user.workAddress
                    feedCell.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    
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
                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
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
                    feedCell2.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    
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
                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell2.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell2.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
                    feedCell2.starLbl.isUserInteractionEnabled = true
                    feedCell2.starLbl.addGestureRecognizer(tap)
                    
                    
                }
                
                
                
                return cell
                
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 && AppFunctions.isProfileVisble() {
            //if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= 15 {
               // AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
             if !users.isEmpty {
                self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                    vc.userId = users[indexPath.row - 1].userId
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
}

