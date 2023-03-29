//
//  FeedVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import Combine
import CoreLocation

class FeedVC: MainViewController {

    
    @IBOutlet weak var feedTV: UITableView!
    
    //MARK: PROPERTIES
    var locationManager = LocationManager()
    var cancellable: AnyCancellable? = nil
    var location = CLLocation()
    
    var users = [UserModel]()
    
    var nameArray = ["Zoya Grey","James Nio","Kris Burner","Nesa Node","Mark Denial"]
    var profArray = ["Professor","Bachelor, Student","Entrepreneur","Chemist","Professor"]
    var imageArray = [UIImage(named: "girl"),UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "teacher"),UIImage(named: "professor")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getProxUsers(load: true)
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getProxUsers(load: false)
        self.cancellable = self.locationManager.$currentLocation.sink(receiveValue: {[weak self] (CLLocation) in
            Logs.show(message: "LOC C: \(String(describing: CLLocation))")
            if let loc = CLLocation {
                self?.location = loc
                Logs.show(message: "LOC: \(String(describing: self?.location))")
            }
        })
    }
    
    func registerCells() {
        
        feedTV.tableFooterView = UIView()
        feedTV.separatorStyle = .none
        feedTV.delegate = self
        feedTV.dataSource = self
        feedTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        feedTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
    }


    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
    @objc func toolBtnPressed(sender: UIButton) {
        AppFunctions.showToolTip(str: "Search Users around you.", btn: sender)
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.pushVC(id: "ViewedByMeVC") { (vc:ViewedByMeVC) in }
    }
    
    @objc
    func starTapFunction(sender:UITapGestureRecognizer) {
        if let image = sender.view {
            if let cell = image.superview?.superview?.superview?.superview  as? FeedItemsTVCell {
                guard let indexPath = self.feedTV.indexPath(for: cell) else {return}
                print("index path =\(indexPath)")
                if cell.starLbl.image == UIImage(systemName: "star.fill") {
                    cell.starLbl.image = UIImage(systemName: "star")
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                    ApiService.markStarUser(val: users[indexPath.row].userId)
                }
                                
            }
        }
    }
    //MARK: API METHODS
    
    func getProxUsers(load: Bool) {
        
        if load {
            self.showPKHUD(WithMessage: "Fetching...")
        }

        let pram : [String : Any] = ["searchString": ""]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getproximityUsers(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.users = val
                            self.feedTV.reloadData()
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
extension FeedVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = false
                cell.viewCountsLbl.isHidden = false
                cell.searchView.isHidden = false
                cell.headerView.isHidden = false
                
                cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                cell.picBtn.setImage(UIImage(named: "placeholder_f"), for: .normal)
                cell.picBtn.isUserInteractionEnabled = false
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
                cell.viewCountsLbl.isUserInteractionEnabled = true
                cell.viewCountsLbl.addGestureRecognizer(tap)
                
                cell.viewCountsLbl.attributedText = NSAttributedString(string: "1 out of 15 profiles viewed", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                return cell
                
            default:
                let cell : FeedItemsTVCell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
                let user = users[indexPath.row - 1]
                cell.nameLbl.text = user.userName
                cell.professionLbl.text = user.workTitle
                cell.educationLbl.text = user.workAddress
                cell.profilePicIV.image = UIImage(named: "placeholder")
                cell.starLbl.image = user.isStarred ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(starTapFunction(sender:)))
                cell.starLbl.isUserInteractionEnabled = true
                cell.starLbl.addGestureRecognizer(tap)
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

