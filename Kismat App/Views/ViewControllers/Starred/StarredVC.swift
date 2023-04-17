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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getStarUsers(load: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStarUsers(load: false)

    }
    
    func registerCells() {
        
        starredTV.tableFooterView = UIView()
        starredTV.separatorStyle = .none
        starredTV.delegate = self
        starredTV.dataSource = self
        starredTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        starredTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Search Users that you marked starred.", btn: sender)
    }
    
    @objc
    func starTapFunction(sender:UITapGestureRecognizer) {
        if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.starredTV.indexPath(for: cell) else {return}
                users.remove(at: indexPath.row - 1)
                starredTV.reloadData()
                /*print("index path =\(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    ApiService.markStarUser(val: users[indexPath.row].userId)
                }*/
            }
        }
    }
    
    //MARK: API METHODS
    
    func getStarUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": ""]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getStarredUsers()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users = val
                            self.starredTV.reloadData()
                            self.hidePKHUD()
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
extension StarredVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
                

                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)

                cell.picBtn.borderWidth = 0

                
                return cell
                
            default:
                let cell : FeedItemsTVCell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
                let user = users[indexPath.row - 1]
                cell.nameLbl.text = user.userName
                cell.professionLbl.text = user.workTitle
                cell.educationLbl.text = user.workAddress
                cell.profilePicIV.image = UIImage(named: "placeholder")
                cell.starLbl.image = UIImage(systemName: "star.fill")
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                vc.userModel = users[indexPath.row - 1]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            starredTV.beginUpdates()
            ApiService.markStarUser(val: users[indexPath.row - 1].userId)
            users.remove(at: indexPath.row - 1)
            starredTV.deleteRows(at: [indexPath], with: .automatic)
            starredTV.endUpdates()
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

