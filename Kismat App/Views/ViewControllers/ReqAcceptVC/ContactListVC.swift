//
//  ContactListVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 16/07/2024.
//

import UIKit

class ContactListVC: MainViewController {

    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var contactTV: UITableView!
    
    @IBOutlet weak var profilePicIV: RoundCornerButton!
    
    @IBOutlet weak var workLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    
    var userModel = UserModel()
    var img = UIImage(named: "placeholder")
    var socialAccModel = [ContactInformations]()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        
        if userModel.profilePicture != "" && userModel.profilePicture != nil {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicIV?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
        } else {
            profilePicIV.setImage(img, for: .normal)
        }
        
        nameLbl.text = userModel.userName
        proffLbl.text = userModel.workTitle
        workLbl.text = userModel.workAddress
        
        
        if userModel.contactInformationsSharedByUser != nil {
            socialAccModel = userModel.contactInformationsSharedByUser
            if let lastContact = socialAccModel.last, lastContact.contactTypeId == 6 {
                socialAccModel.removeLast()
            }
        }
        
    }
    
    func registerCells() {
        
        contactTV.tableFooterView = UIView()
        contactTV.separatorStyle = .none
        contactTV.delegate = self
        contactTV.dataSource = self
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        contactTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
      
        contactTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        contactTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
    }
    

}

//MARK: TableView Extention
extension ContactListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialAccModel.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
                           
            case 0: // social heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                if !socialAccModel.isEmpty {
                    cell.headerLblView.isHidden = false
                    cell.headerLbl.text = "Contact info shared"
                } else {
                    cell.headerLblView.isHidden = true
                }
                return cell
                
            
            default:
                
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                    
                    switch socialAccModel[indexPath.row - 1].contactTypeId {
                        case 1:
                            cell.socialImgView.image = UIImage(named: "LinkedIn")
                        case 4:
                            cell.socialImgView.image = UIImage(named: "whatsapp")
                        case 3:
                            cell.socialImgView.image = UIImage(named: "WeChat")
                        case 5:
                            cell.socialImgView.image = UIImage(named: "phone")
                        case 2:
                            cell.socialImgView.image = UIImage(named: "Instagram")
                            //case 6:
                            //cell.socialImgView.image = UIImage(named: "message")
                        default:
                            print("default")
                    }
                    
                    cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                    
                    /*if socialAccModel.filter({$0.contactType == socialAccounts[indexPath.row - 6].contactType }).count > 0 {
                     cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                     } else {
                     cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
                     }*/
                    
                    cell.socialLbl.text = socialAccModel[indexPath.row - 1].contactType.capitalized
                    cell.socialLbl.isUserInteractionEnabled = false
                    return cell
            }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            AppFunctions.showSnackBar(str: "You can view contact information once accepted")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

