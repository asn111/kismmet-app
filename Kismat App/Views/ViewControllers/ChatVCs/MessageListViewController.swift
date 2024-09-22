//
//  MessageListViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit

class MessageListViewController: MainViewController {

    @IBOutlet weak var tableView: UITableView!

    var chatsUsers = [ChatUsersModel]()
    
    var searchString = ""

    //MARK:- UIViewController Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
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
                        } else {
                            self.hidePKHUD()
                            self.chatsUsers.removeAll()
                            self.tableView.reloadData()
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
        return chatsUsers.count + 1
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
            cell.searchTF.placeholder = "Search through your chat users.."
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
            
            
            return cell
            
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUsersTVCell", for: indexPath) as! ChatUsersTVCell
            
            let user = chatsUsers[indexPath.row - 1]
            
            cell.nameLbl.text = user.userName.capitalized
            cell.proffLbl.text = user.userWorkTitle.capitalized
            
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
                cell.msgLbl.text = "You: " + user.lastMessage.chatMessage.capitalized
            } else {
                cell.msgLbl.text = user.lastMessage.chatMessage.capitalized
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            // delete the item here
            // completionHandler(true)
            //self.deleteMessage(obj: self.chats[indexPath.row])
        }
        deleteAction.image = UIImage(systemName: "x.circle")
        deleteAction.image?.withTintColor(UIColor.white)
        //deleteAction.backgroundColor = UIColor(named: "Text Grey")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}
