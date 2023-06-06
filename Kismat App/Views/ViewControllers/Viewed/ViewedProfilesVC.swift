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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        getViewedByUsers(load: true)
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
        viewedListTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        viewedListTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
        viewedListTV.register(UINib(nibName: "VisibilityOffTVCell", bundle: nil), forCellReuseIdentifier: "VisibilityOffTVCell")

    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Unlock Kismmet: Find kindred spirits among your profile viewers and forge lasting friendships.", btn: sender)
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
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.viewedListTV.indexPath(for: cell) else {return}
                print("index path =\(indexPath)")
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
                        } else {
                            self.users.removeAll()
                            self.viewedListTV.reloadData()
                            self.hidePKHUD()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
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
                
                cell.searchTF.delegate = self
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
                
                
                return cell
                
                
                
            default:
                
                
                var cell = UITableViewCell()
                
                if !AppFunctions.isProfileVisble(){
                    cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                } else {
                    if users.isEmpty {
                        cell = tableView.dequeueReusableCell(withIdentifier: "VisibilityOffTVCell", for: indexPath) as! VisibilityOffTVCell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
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
                        visiblityCell.textLbl.text = "Your visibility is off, Please change your visibility to on to view people who have viewed profile."
                    }
                    
                    
                } else if let feedCell = cell as? FeedItemsTVCell {
                                        
                    let user = users[indexPath.row - 1]
                    feedCell.nameLbl.text = user.userName
                    feedCell.professionLbl.text = user.workTitle
                    feedCell.educationLbl.text = user.workAddress
                    feedCell.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                    
                    if user.tags != "" {
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
                    
                }
                
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 && AppFunctions.isProfileVisble() {
            if !AppFunctions.isPremiumUser() && AppFunctions.getviewedCount() >= 15 {
                AppFunctions.showSnackBar(str: "You have reached your profile views limit.")
            } else if !users.isEmpty {
                self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                    vc.userModel = users[indexPath.row - 1]
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
    }
}

