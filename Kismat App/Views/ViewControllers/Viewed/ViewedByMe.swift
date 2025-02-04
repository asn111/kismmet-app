//
//  ViewedByMe.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 27/03/2023.
//

import UIKit

class ViewedByMeVC: MainViewController {
    
    
    @IBOutlet weak var viewedListTV: UITableView!
    
    var nameArray = ["James Nio","Kris Burner","Mark Denial"]
    var profArray = ["Bachelor, Student","Entrepreneur","Professor"]
    var imageArray = [UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "professor")]
    
    var users = [UserModel]()
    var searchString = ""
    
    var localStarredStatus: [String: Bool] = [:] // Key: userId, Value: isStarred


    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getViewedByMe(load: true)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "notif" {
                self?.viewedListTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getViewedByMe(load: false)
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
        viewedListTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Search Users that are viewed by you.", btn: sender)
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            getViewedByMe(load: true)
            return
        }
        getViewedByMe(load: true)
    }
    
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getViewedByMe(load: true)
        return true
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
        viewedListTV.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
    
    //MARK: API METHODS
    
    func getViewedByMe(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getDeactivatedUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users = val
                            self.viewedListTV.reloadData()
                            self.hidePKHUD()
                        } else {
                            self.hidePKHUD()
                        }
                    case .error(let error):
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.viewedListTV.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
}
//MARK: TableView Extention
extension ViewedByMeVC : UITableViewDelegate, UITableViewDataSource {
    
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
                cell.headerLbl.text = "Deactivated Users"
                cell.searchView.isHidden = false
                cell.headerView.isHidden = false
                
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
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
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

                if users.isEmpty {
                    cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
                }
                
                if let visiblityCell = cell as? VisibilityOffTVCell {
                    
                    visiblityCell.visibiltyView.isHidden = true
                    visiblityCell.updateBtn.isHidden = true
                    visiblityCell.textLbl.text = "At this time, there are no profiles viewed by you."
                
                    
                } else if let feedCell = cell as? FeedItemsTVCell {
                    
                    let user = users[indexPath.row - 1]
                    
                    feedCell.nameLbl.text = user.firstName + " " + (user.lastName ?? "")
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
                    
                    let isStarred = localStarredStatus[user.userId] ?? user.isStarred
                    
                    let imageName = isStarred ?? false ? "star.fill" : "star"
                    feedCell.starBtn.setImage(UIImage(systemName: imageName), for: .normal)
                    
                    feedCell.starBtn.tag = indexPath.row
                    feedCell.starBtn.addTarget(self, action: #selector(starTapFunction(sender:)), for: .touchUpInside)

                }
                
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 && AppFunctions.isProfileVisble() {
            //if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= 15 {
                //AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if AppFunctions.getRole() == "Admin" {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let pram : [String : Any] = ["userId": users[indexPath.row - 1].userId ?? "",
                                         "reason" : "",
                                         "isActive": true]

            ApiService.markUserActiveOrDeactive(param: pram)
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
        return "Reactive" // Replace "Your Custom Text" with the desired button text
    }
}

