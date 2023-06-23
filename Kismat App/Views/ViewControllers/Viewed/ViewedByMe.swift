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
    
    func getViewedByMe(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }
        
        let pram : [String : Any] = ["searchString": searchString]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getViewedByMe(pram: pram)
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
                cell.headerLbl.text = "VIEWED BY ME"
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
                
                if AppFunctions.isNotifNotCheck() {
                    cell.notifBtn.tintColor = UIColor(named:"Danger")
                } else {
                    cell.notifBtn.tintColor = UIColor(named: "Text grey")
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

