//
//  FeedVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import Combine
import CoreLocation
import SDWebImage

class FeedVC: MainViewController {

    
    @IBOutlet weak var feedTV: UITableView!
    
    //MARK: PROPERTIES
    
    var users = [UserModel]()
    var userdbModel = UserDBModel()

    var localStarredStatus: [String: Bool] = [:] // Key: userId, Value: isStarred

    //var viewedCount = 0
    var searchString = ""
    
    var isProfileVisible = false
    var isShadowMode = false
    var proximity = 5000
    var profilePic = ""

    private let refresher = UIRefreshControl()

    
    var nameArray = ["Zoya Grey","James Nio","Kris Burner","Nesa Node","Mark Denial"]
    var profArray = ["Professor","Bachelor, Student","Entrepreneur","Chemist","Professor"]
    var imageArray = [UIImage(named: "girl"),UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "teacher"),UIImage(named: "professor")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser().first!
        }
        
        proximity = userdbModel.proximity
        isProfileVisible = userdbModel.isProfileVisible
        isShadowMode = userdbModel.shadowMode
        profilePic = userdbModel.profilePicture
        
        if isFromProfile {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.presentVC(id: "PopupVC", presentFullType: "over" ) { (vc:PopupVC) in }
            }
        }
        
        getProxUsers(load: true)
        registerCells()
        
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "notif" {
                self?.feedTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getProxUsers(load: false)
        feedTV.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchString = ""
    }
    
    func registerCells() {
        
        feedTV.tableFooterView = UIView()
        feedTV.separatorStyle = .none
        feedTV.delegate = self
        feedTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        feedTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        feedTV.alwaysBounceVertical = true
        refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        feedTV.alwaysBounceVertical = true
        feedTV.refreshControl = refresher // iOS 10
        feedTV.addSubview(refresher)
        
        feedTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        feedTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        feedTV.register(UINib(nibName: "FeedItem2TVCell", bundle: nil), forCellReuseIdentifier: "FeedItem2TVCell")
        feedTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")
    }


    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func updateBtnPressed(sender: UIButton) {
        updateConfig()
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        // Do you your api calls in here, and then a
        self.showPKHUD(WithMessage: "")
        feedTV.refreshControl?.beginRefreshing()
        getProxUsers(load: false)
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            getProxUsers(load: true)
            return
        }
        getProxUsers(load: true)
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    func updateConfig() {
        let pram = ["proximity": "\(proximity)",
                    "shadowMode":"\(isShadowMode)",
                    "isProfileVisible":"\(isProfileVisible)"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        SignalRManager.singelton.connection.invoke(method: "UpdateUserConfigurations", pram) {  error in            Logs.show(message: "\(pram)")
            AppFunctions.setIsProfileVisble(value: self.isProfileVisible)
            self.getProxUsers(load: true)
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Search for people or hashtags in your proximity!"
        } else if sender.tag == 002 {
            if AppFunctions.getRole() == "Admin" {
                msg = "This will take you to the app users that are deatcivated in the app!"
            } else {
                msg = "Upgrade to premium for unlimited profile views and to unlock Shadow Mode!"
            }
            
        } else if sender.tag == 005 {
            msg = "Toggle off to go completely offline.\nOthers won't see you, and you won't see them.Toggle on to rejoin the community."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.pushVC(id: "ViewedByMeVC") { (vc:ViewedByMeVC) in }
    }
    
    func stopRefresher() {
        self.hidePKHUD()
        feedTV.refreshControl?.endRefreshing()
    }
    
    @objc func toggleButtonPressed(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = feedTV.cellForRow(at: indexPath) as? VisibilityOffTVCell {
            //AppFunctions.setIsProfileVisble(value: cell.toggleBtn.isOn)
            isProfileVisible = cell.toggleBtn.isOn
        }
    }
    
    
    /*@objc
    func starTapFunction(sender:UITapGestureRecognizer) {
        if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItem2TVCell {
                guard let indexPath = self.feedTV.indexPath(for: cell) else {return}
                print("index path = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    //ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)

                    //ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                }
            } else if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.feedTV.indexPath(for: cell) else {return}
                print("index path Else = \(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                    markUserStar(userId: users[indexPath.row - 1].userId)

                    //ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    markUserStar(userId: users[indexPath.row - 1].userId)
                    //ApiService.markStarUser(val: users[indexPath.row - 1].userId)
                }
            }
        }
    }*/
    
    @objc func chatBtnPressed(sender: UIButton) {
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
        feedTV.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
        getProxUsers(load: true)
        return true
    }
    
    func showActionSheet(userId: String, indexPath : IndexPath) {
        let alert = UIAlertController(title: "Title", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Deactivate", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            ApiService.updateAccountStatus(val: deactivedAccountStatusId, userId: userId)
            
            if self.users[indexPath.row - 1].userId == self.users.last?.userId {
                self.tabBarController?.selectedIndex = 2
                return
            }
            self.users.remove(at: indexPath.row - 1)
            self.feedTV.performBatchUpdates({
                self.feedTV.deleteRows(at: [indexPath], with: .automatic)
            }, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{ (UIAlertAction)in
            print("User click Delete button")
            ApiService.updateAccountStatus(val: deletedAccountStatusId, userId: userId)
            
            if self.users[indexPath.row - 1].userId == self.users.last?.userId {
                self.tabBarController?.selectedIndex = 2
                return
            }
            self.users.remove(at: indexPath.row - 1)
            self.feedTV.performBatchUpdates({
                self.feedTV.deleteRows(at: [indexPath], with: .automatic)
            }, completion: nil)

        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        
        
        //uncomment for iPad Support
        alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            print("completion block")
            
        })
    }
    
    //MARK: API METHODS
    
    func getProxUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }

        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getproximityUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        AppFunctions.saveviewedCount(count: val.profilesViewed)
                        if val.users.count > 0 {
                            self.users.removeAll()
                            self.users = val.users
                            self.feedTV.reloadData()
                            self.hidePKHUD()
                            self.stopRefresher()
                        } else {
                            self.stopRefresher()
                            self.hidePKHUD()
                            self.users.removeAll()
                            self.feedTV.reloadData()
                            self.stopRefresher()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.feedTV.reloadData()
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
extension FeedVC : UITableViewDelegate, UITableViewDataSource {
    
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
                cell.headerLogo.isHidden = false
                cell.viewCountsLbl.isHidden = !AppFunctions.isProfileVisble()
                cell.searchView.isHidden = false
                cell.headerView.isHidden = false
                cell.viewedToolTipBtn.isHidden = !AppFunctions.isProfileVisble()
                cell.swipeTxtLbl.isHidden = false
                
                cell.searchTF.delegate = self
                cell.searchTF.returnKeyType = .search
                cell.searchTF.tag = 010
                cell.searchBtn.addTarget(self, action: #selector(searchBtnPressed(sender:)), for: .touchUpInside)

                if searchString != "" {
                    cell.searchBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                } else {
                    cell.searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
                    cell.searchTF.text = ""
                }
                
                cell.toolTipBtn.tag = 001
                cell.viewedToolTipBtn.tag = 002
                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                cell.viewedToolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                
                
                if profilePic != "" {
                    let imageUrl = URL(string: profilePic)
                    cell.picBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                } else {
                    cell.picBtn.setImage(UIImage(named: "placeholder"), for: .normal)
                }

                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
                cell.chatBtn.addTarget(self, action: #selector(chatBtnPressed(sender:)), for: .touchUpInside)

                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)

                
                if AppFunctions.isPremiumUser() {
                    cell.viewCountsLbl.isHidden = true
                    cell.viewedToolTipBtn.isHidden = true
                } else {
                    cell.viewCountsLbl.isHidden = false
                    cell.viewedToolTipBtn.isHidden = false
                }
                if AppFunctions.getRole() == "Admin" {
                    cell.viewCountsLbl.attributedText = NSAttributedString(string: "Deactivated Users here", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                    
                    cell.swipeTxtLbl.text = "Total number of active users are \(users.count)"

                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
                    cell.viewCountsLbl.isUserInteractionEnabled = true
                    cell.viewCountsLbl.addGestureRecognizer(tap)
                } else {
                    cell.viewCountsLbl.isHidden = true
                    cell.viewedToolTipBtn.isHidden = true
                    cell.swipeTxtLbl.text = "Refresh & Connect"

                    //cell.viewCountsLbl.attributedText = NSAttributedString(string: "\(AppFunctions.getviewedCount()) out of \(AppFunctions.getMaxProfViewedCount()) profiles viewed", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                }
                
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
                    
                    visiblityCell.toggleBtn.isOn = false
                    visiblityCell.toggleBtn.tag = indexPath.row
                    visiblityCell.toolTipBtn.tag = 005
                   
                    
                    visiblityCell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                    visiblityCell.updateBtn.addTarget(self, action: #selector(updateBtnPressed(sender:)), for: .touchUpInside)
                    visiblityCell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                    
                    if users.isEmpty && AppFunctions.isProfileVisble() {
                        visiblityCell.visibiltyView.isHidden = true
                        visiblityCell.updateBtn.isHidden = true
                        visiblityCell.textLbl.text = "Refresh & Connect!\n \nYou may be the only one in your area at this moment!\nPlease be patient as we are growing the network! 🙂"
                    } else {
                        visiblityCell.visibiltyView.isHidden = false
                        visiblityCell.updateBtn.isHidden = false
                        visiblityCell.textLbl.text = "You are completely offline... \nToggle back to rejoin the community and interact with others"
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
                    
                    
                    if user.profilePicture != "" && user.profilePicture != nil {
                        let imageUrl = URL(string: user.profilePicture)
                        feedCell.profilePicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        feedCell.profilePicIV.image = UIImage(named: "placeholder")
                    }
                    
//                    feedCell.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
//                    
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
//                    feedCell.starLbl.isUserInteractionEnabled = true
//                    feedCell.starLbl.addGestureRecognizer(tap)
                    
                    
                    
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
                    
                    if user.tags != nil && user.tags != "" {
                        if !user.tags.contains(",") {
                            feedCell2.tagLbl.text = user.tags
                            feedCell2.tagMoreView.isHidden = true
                            
                            //feedCell2.tagsWidthConst.constant = feedCell2.firstTagView.frame.width + 20
                        } else {
                            feedCell2.tagMoreView.isHidden = false
                            let split = user.tags.split(separator: ",")
                            feedCell2.tagLbl.text = "\(split[0])"
                            feedCell2.tagMoreLbl.text = "\(split.count - 1) more"
                            
                           // feedCell2.tagsWidthConst.constant = 125
                            
                        }
                    }

                    feedCell2.noteIcon.isHidden = true
                    
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
                    
//                    feedCell2.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
//                    
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
//                    feedCell2.starLbl.isUserInteractionEnabled = true
//                    feedCell2.starLbl.addGestureRecognizer(tap)
                    
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
                    //vc.markView = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if AppFunctions.getRole() == "Admin" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            showActionSheet(userId: users[indexPath.row - 1].userId ?? "", indexPath: indexPath)
            
            /*let pram : [String : Any] = ["userId": users[indexPath.row - 1].userId ?? "",
                                         "reason" : "",
                                         "isActive": false]
            
            ApiService.markUserActiveOrDeactive(param: pram)
            if users[indexPath.row - 1].userId == users.last?.userId {
                self.tabBarController?.selectedIndex = 2
                return
            }
            users.remove(at: indexPath.row - 1)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: nil)*/
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove" // Replace "Your Custom Text" with the desired button text
    }
    
}

