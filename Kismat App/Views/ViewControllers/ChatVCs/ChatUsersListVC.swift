//
//  ChatUsersListVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 27/09/2024.
//

import UIKit

class ChatUsersListVC: MainViewController {

    
    @IBOutlet weak var usersTV: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        
        if searchString != "" {
            searchString = ""
            self.getContUsers()
            return
        }
        self.getContUsers()
        
    }
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var users = [UserModel]()
    var searchString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        getContUsers()
        searchTF.delegate = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }
    
    func registerCells() {
        
        usersTV.tableFooterView = UIView()
        usersTV.separatorStyle = .none
        usersTV.delegate = self
        usersTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        usersTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        usersTV.register(UINib(nibName: "ChatListUserTVCell", bundle: nil), forCellReuseIdentifier: "ChatListUserTVCell")
        
    }

    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        searchString = !textField.text!.isTFBlank ? textField.text! : ""
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.returnKeyType = .search
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.getContUsers()
        return true
    }
   
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil) // For modal presentation
    }
    
    func getContUsers() {
        
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
                            self.usersTV.reloadData()
                            self.hidePKHUD()
                        } else {
                            self.hidePKHUD()
                            self.users.removeAll()
                            self.usersTV.reloadData()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.users.removeAll()
                        self.usersTV.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
    }
}

//MARK: TableView Extention
extension ChatUsersListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ChatListUserTVCell = tableView.dequeueReusableCell(withIdentifier: "ChatListUserTVCell", for: indexPath) as! ChatListUserTVCell
        
        
        cell.nameLbl.text = users[indexPath.row].userName
        cell.proffLbl.text = users[indexPath.row].workTitle
        
        if users[indexPath.row].profilePicture != "" && users[indexPath.row].profilePicture != nil {
            let imageUrl = URL(string: users[indexPath.row].profilePicture)
            cell.profileIcon?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
        } else {
            cell.profileIcon.image = UIImage(named: "placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.presentVC(id: "ChatViewController", presentFullType: "over" ) { (vc:ChatViewController) in
            let user = users[indexPath.row]

            vc.userId = user.userId
            //vc.chatId = user.chatId
            //vc.isOnline = user.isOnline
            vc.userName = user.userName
            vc.workTitle = user.workTitle
            vc.userProfilePic = user.profilePicture
            vc.isPresented = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

