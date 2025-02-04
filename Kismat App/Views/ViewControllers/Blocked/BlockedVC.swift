//
//  BlockedVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/04/2023.
//

import Foundation

import UIKit

class BlockedVC: MainViewController {
    
    @IBOutlet weak var blockedTV: UITableView!
    
    var users = [UserModel]()
    
    var localStarredStatus: [String: Bool] = [:] // Key: userId, Value: isStarred

    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getBlockedUsers(load: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func registerCells() {
        
        blockedTV.tableFooterView = UIView()
        blockedTV.separatorStyle = .none
        blockedTV.delegate = self
        blockedTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        blockedTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        blockedTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        blockedTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        blockedTV.register(UINib(nibName: "FeedItem2TVCell", bundle: nil), forCellReuseIdentifier: "FeedItem2TVCell")
        blockedTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

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
        AppFunctions.showToolTip(str: "Browse your blocked users.", btn: sender)
    }
    
    @objc func searchBtnPressed(sender: UIButton) {
        if searchString != "" {
            searchString = ""
            getBlockedUsers(load: true)
            return
        }
        getBlockedUsers(load: true)
    }
    
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .done
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        getBlockedUsers(load: true)
        return true
    }
    
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
        blockedTV.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
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
    
    func getBlockedUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getBlockUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users.removeAll()
                            self.users = val
                            self.blockedTV.reloadData()
                            self.hidePKHUD()
                        } else {
                            self.users.removeAll()
                            self.hidePKHUD()
                            self.blockedTV.reloadData()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.blockedTV.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    
}
//MARK: TableView Extention
extension BlockedVC : UITableViewDelegate, UITableViewDataSource {
    
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
                cell.headerLbl.text = "BLOCKED"
                cell.searchView.isHidden = false
                cell.swipeTxtLbl.isHidden = false
                cell.headerView.isHidden = false
                cell.swipeTxtLbl.text = "Please swipe left to remove from block list."

                cell.searchTF.delegate = self
                cell.searchTF.placeholder = "Search through your blocked list.."
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
                cell.notifBtn.setImage(UIImage(named: "wifi man grey 2"), for: .normal)

                
                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.chatBtn.addTarget(self, action: #selector(chatBtnPressed(sender:)), for: .touchUpInside)
                
                cell.picBtn.borderWidth = 0
                
                
                return cell
                
            default:
                
                
                var cell = UITableViewCell()
                
                if users.isEmpty {
                    cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "FeedItem2TVCell", for: indexPath) as! FeedItem2TVCell
                }
                
                if let visiblityCell = cell as? VisibilityOffTVCell {
                    
                    visiblityCell.visibiltyView.isHidden = true
                    visiblityCell.updateBtn.isHidden = true
                    visiblityCell.textLbl.text = "You currently have no blocked users."
                    
                    
                } else if let feedCell = cell as? FeedItem2TVCell {
                    
                    let user = users[indexPath.row - 1]
                    feedCell.nameLbl.text = user.firstName + " " + (user.lastName ?? "")
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
                    
//                    let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
//                    feedCell.starLbl.isUserInteractionEnabled = true
//                    feedCell.starLbl.addGestureRecognizer(tap)
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
            //if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= AppFunctions.getMaxProfViewedCount() {
                //AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
            if !users.isEmpty {
                self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                    vc.userId = users[indexPath.row - 1].userId
                    vc.isFromBlock = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            ApiService.markBlockUser(val: users[indexPath.row - 1].userId)
            if users[indexPath.row - 1].userId == users.last?.userId {
                self.navigationController?.popViewController(animated: true)
                return
            }
            users.remove(at: indexPath.row - 1)
            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }, completion: nil)
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Unblock" // Replace "Your Custom Text" with the desired button text
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

