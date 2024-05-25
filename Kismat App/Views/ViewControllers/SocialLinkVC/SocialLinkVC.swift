//
//  SocialLinkVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 12/05/2024.
//

import UIKit

class SocialLinkVC: MainViewController {
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    @IBOutlet weak var socialAccTV: UITableView!
    //@IBOutlet weak var socialCV: UICollectionView!
    
    var socialAccounts = [SocialAccDBModel()]
    var socialAccModel = [SocialAccModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        socialAccounts = Array(DBService.fetchSocialAccList())
        userProfile()

        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val.contains("socialAdded") || val.contains("socialDeleted") {
                Logs.show(message: val)
                
                self?.userProfile()
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
    }
    
    
    func registerCells() {
        
        socialAccTV.tableFooterView = UIView()
        socialAccTV.separatorStyle = .none
        socialAccTV.delegate = self
        socialAccTV.dataSource = self
        socialAccTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        socialAccTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        self.presentVC(id: "SocialAccVC", presentFullType: "over" ) { (vc:SocialAccVC) in
        }
        
    }
    
    //MARK: API METHODS
    
    func userProfile() {
        
        APIService
            .singelton
            .getUserById(userId: "")
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            self.socialAccModel = val.socialAccounts
                            
                            let linkTypesInSocialAccModel = Set(socialAccModel.map { $0.linkType })

                            socialAccounts.sort { (account1, account2) -> Bool in
                                // Check if either account has a linkType present in socialAccModel
                                let isAccount1Matched = linkTypesInSocialAccModel.contains(account1.linkType)
                                let isAccount2Matched = linkTypesInSocialAccModel.contains(account2.linkType)
                                
                                // Move matched accounts to the front
                                if isAccount1Matched && !isAccount2Matched {
                                    return true
                                } else if !isAccount1Matched && isAccount2Matched {
                                    return false
                                } else {
                                    // Keep original order for unmatched or both matched/unmatched pairs
                                    return false
                                }
                            }
                            
                            self.socialAccTV.reloadData()
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
extension SocialLinkVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return socialAccounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
            cell.headerLblView.isHidden = false
            cell.addBtn.isHidden = true
            cell.headerLbl.text = "Link your social accounts"
            cell.addBtn.isHidden = false
            cell.addBtn.tag = indexPath.row
            
            cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
            
            return cell
        } else {
            
            let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
            
            cell.socialLbl.isUserInteractionEnabled = false
            
            if socialAccounts[(indexPath.row - 1)].linkImage != "" {
                let imageUrl = URL(string: socialAccounts[(indexPath.row - 1)].linkImage)
                cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
            }
            if socialAccModel.filter({$0.linkType == socialAccounts[(indexPath.row - 1)].linkType }).count > 0 {
                cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
            } else {
                cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
            }
            cell.socialLbl.text = socialAccounts[(indexPath.row - 1)].linkType
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Logs.show(message: "INDEX: \(indexPath.row)")
        
        if indexPath.row > 0 {
            if socialAccModel.filter({$0.linkType == socialAccounts[(indexPath.row - 1)].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.socialAccModel = socialAccModel.filter {$0.linkType == socialAccounts[(indexPath.row - 1)].linkType }
                    vc.linkType = socialAccounts[(indexPath.row - 1)].linkType
                    vc.canEdit = true
                }
            } else {
                AppFunctions.showSnackBar(str: "Please add social account")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

