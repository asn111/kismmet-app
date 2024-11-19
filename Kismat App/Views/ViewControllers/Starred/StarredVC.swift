//
//  StarredVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 12/02/2023.
//

import UIKit

class StarredVC: MainViewController {

    @IBOutlet weak var starredTV: UITableView!
    
    var nameArray = ["James Nio","Nesa Node"]
    var profArray = ["Bachelor, Student","Chemist"]
    var imageArray = [UIImage(named: "guy"),UIImage(named: "teacher")]
    
    var users = [UserModel]()
    var searchString = ""
    
    private let refresher = UIRefreshControl()
    var localStarredStatus: [String: Bool] = [:] // Key: userId, Value: isStarred


    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getStarUsers(load: true)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "notif" {
                self?.starredTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStarUsers(load: false)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchString = ""
    }
    
    func registerCells() {
        
        starredTV.tableFooterView = UIView()
        starredTV.separatorStyle = .none
        starredTV.delegate = self
        starredTV.dataSource = self
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        starredTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        starredTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        starredTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        starredTV.register(UINib(nibName: "FeedItem2TVCell", bundle: nil), forCellReuseIdentifier: "FeedItem2TVCell")
        starredTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

        
        starredTV.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        starredTV.alwaysBounceVertical = true
        starredTV.refreshControl = refresher // iOS 10
        starredTV.addSubview(refresher)
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then a
        self.showPKHUD(WithMessage: "")
        starredTV.refreshControl?.beginRefreshing()
        getStarUsers(load: false)
    }
    
    func stopRefresher() {
        self.hidePKHUD()
        starredTV.refreshControl?.endRefreshing()
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func notifBtnPressed(sender: UIButton) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Search Users that you marked starred.", btn: sender)
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            getStarUsers(load: true)
            return
        }
        getStarUsers(load: true)
    }
    
    @objc func chatBtnPressed(sender: UIButton) {
        Logs.show(message: "ChatBtnPressed")
        self.pushVC(id: "MessageListViewController") { (vc:MessageListViewController) in }
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
        starredTV.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getStarUsers(load: true)
        return true
    }
    
    //MARK: API METHODS
    
    func getStarUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getStarredUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users.removeAll()
                            self.users = val
                            self.starredTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                        } else {
                            self.users.removeAll()
                            self.hidePKHUD()
                            self.starredTV.reloadData()
                            self.stopRefresher()
                        }
                    case .error(let error):
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.starredTV.reloadData()
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
extension StarredVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.isEmpty {
            return 2
        }
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "STARRED"
                cell.searchView.isHidden = false
                cell.swipeTxtLbl.isHidden = false
                cell.headerView.isHidden = false
                
                cell.toolTipBtn.isHidden = true
                cell.searchContraint.constant = 10
                
                cell.searchTF.delegate = self
                cell.searchTF.returnKeyType = .search
                cell.searchTF.tag = 010
                
                cell.swipeTxtLbl.text = "Swipe left or click the star to remove a user from list."
                cell.searchTF.placeholder = "Search through users you starred.."

                
                cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)

                if searchString != "" {
                    cell.searchBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                } else {
                    cell.searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    cell.searchTF.text = ""
                }

                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                cell.notifBtn.setImage(UIImage(named: "wifi man grey 2"), for: .normal)
                
                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.chatBtn.addTarget(self, action: #selector(chatBtnPressed(sender:)), for: .touchUpInside)

                cell.picBtn.borderWidth = 0

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
                    
                    visiblityCell.visibiltyView.isHidden = true
                    visiblityCell.updateBtn.isHidden = true
                    visiblityCell.textLbl.text = "At this time, there are no users that you have marked starred or matching your search criteria."
                    
                    
                    
                } else if let feedCell = cell as? FeedItemsTVCell {
                    
                    feedCell.nameLbl.text = user.userName
                    feedCell.professionLbl.text = user.workTitle
                    feedCell.educationLbl.text = user.workAddress
                    feedCell.starLbl.image = UIImage(systemName: "star.fill")
                    
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
                    
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
//                    feedCell.starLbl.isUserInteractionEnabled = true
//                    feedCell.starLbl.addGestureRecognizer(tap)
                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
                    let isStarred = localStarredStatus[user.userId] ?? user.isStarred
                    
                    let imageName = isStarred ?? false ? "star.fill" : "star"
                    feedCell.starBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    
                    feedCell.starBtn.tag = indexPath.row
                    feedCell.starBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)
                    
                    feedCell.isViewBHidden = false
                    feedCell.statusLbl.text = user.status.isEmpty ? "currently no active status..." : user.status
                    feedCell.clockIV.isHidden = !user.disappearingStatus
                    
                    
                    
                } else if let feedCell2 = cell as? FeedItem2TVCell {
                    
                    feedCell2.nameLbl.text = user.userName
                    feedCell2.professionLbl.text = user.workTitle
                    feedCell2.educationLbl.text = user.workAddress
                    feedCell2.starLbl.image = UIImage(systemName: "star.fill")
                    
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
                    
                    let isStarred = localStarredStatus[user.userId] ?? user.isStarred
                    
                    let imageName = isStarred ?? false ? "star.fill" : "star"
                    feedCell2.starBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    
                    feedCell2.starBtn.tag = indexPath.row
                    feedCell2.starBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)
                    
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
//                    feedCell2.starLbl.isUserInteractionEnabled = true
//                    feedCell2.starLbl.addGestureRecognizer(tap)
//                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell2.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell2.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
                }
                
                
                
                return cell
                
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 && AppFunctions.isProfileVisble() {
            //if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= AppFunctions.getMaxProfViewedCount() {
                //AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
            if !users.isEmpty {
                self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                    vc.userId = users[indexPath.row - 1].userId
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            ApiService.markStarUser(val: users[indexPath.row - 1].userId)
            if users[indexPath.row - 1].userId == users.last?.userId {
                self.tabBarController?.selectedIndex = 2
                return
            }
            users.remove(at: indexPath.row - 1)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: nil)
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove" // Replace "Your Custom Text" with the desired button text
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

