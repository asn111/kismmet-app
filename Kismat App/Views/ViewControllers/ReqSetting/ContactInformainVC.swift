//
//  ContactInformainVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit
import RealmSwift

class ContactInformainVC: MainViewController {

    
    @IBOutlet weak var contactTV: UITableView!
    
    var isSetting = false
    var userdbModel : Results<UserDBModel>!
    var img = UIImage(named: "placeholder")
    
    var ConnectedAccount = [ContactTypesModel]()
    var socialAccounts = [SocialAccModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getConnectAcc()
        userProfile()
        
        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser()
        }
        registerCells()
    }

    func registerCells() {
        
        contactTV.tableFooterView = UIView()
        contactTV.separatorStyle = .none
        contactTV.delegate = self
        contactTV.dataSource = self
        
        let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
        let bottomSpace: CGFloat = 5  // Adjust the value as needed
        contactTV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight + bottomSpace, right: 0)
        
        contactTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        contactTV.register(UINib(nibName: "ContactInfoTVCell", bundle: nil), forCellReuseIdentifier: "ContactInfoTVCell")
        contactTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        contactTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
        
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        if isSetting {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    @objc func checkBtnPressed(sender: UIButton) {
        //let indexPath = IndexPath(row: sender.tag, section: 0)
        //let cell = contactTV.cellForRow(at: indexPath) as! ContactInfoTVCell
        
        
        if sender.tintColor == UIColor(named: "Success") {
            sender.tintColor = UIColor.systemGray2
        } else {
            sender.tintColor = UIColor(named: "Success")
        }
        
        contactTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)

    }
    
    @objc func genBtnPressed(sender:UIButton) {
        self.view.endEditing(true)
        
        if isSetting {
            AppFunctions.showSnackBar(str: "Information saved")
            self.navigationController?.popViewController(animated: true)
        } else {
            self.presentVC(id: "DenyConfirmVC", presentFullType: "over" ) { (vc:DenyConfirmVC) in
            }
            
            //dismissViewControllers() // when no new change made to contact info // add check
            AppFunctions.showSnackBar(str: "Request accepted")
            //self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func getConnectAcc() {
        
        
        APIService
            .singelton
            .getConnectAccTypes()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.ConnectedAccount = val
                            
                            self.contactTV.reloadData()
                            
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
                            self.socialAccounts = val.socialAccounts
                            
                            self.contactTV.reloadData()
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
extension ContactInformainVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConnectedAccount.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                
                cell.headerLbl.isHidden = false
                if isSetting {
                    cell.headerLbl.text = "CONTACT SETTING"
                } else {
                    cell.headerLbl.text = "MY INFO"
                }
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.rattingBtn.isHidden = true
                cell.headerView.isHidden = false
                
                cell.picBtn.borderWidth = 0
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.nameLbl.text = user.userName
                        cell.educationLbl.text = user.email
                        cell.professionLbl.text = "\(user.countryCode)\(user.phone)"
                        
                        if user.profilePicture != "" {
                            let imageUrl = URL(string: user.profilePicture)
                            cell.profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
                        } else {
                            cell.profilePicBtn.setImage(img, for: .normal)
                        }
                        
                    }
                    
                }
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.isHidden = true
                
                
                return cell
            case 1:
                let cell : ContactInfoTVCell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoTVCell", for: indexPath) as! ContactInfoTVCell
                
                cell.textLbl.isHidden = false
                cell.tfView.isHidden = true
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        
                        let text = "Please choose one or more ways for \(user.userName.trimmingCharacters(in: CharacterSet.whitespaces)) to reach out!"
                        let attributedText = NSMutableAttributedString(string: text)
                        
                        // Apply global styling
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .left
                        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
                        
                        // Styling for "Terms & Conditions"
                        let termsRange = (text as NSString).range(of: "\(user.userName.trimmingCharacters(in: CharacterSet.whitespaces))")
                        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.bold, range: termsRange)
                        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81"), range: termsRange)
                        
                        cell.textLbl.attributedText = attributedText
                        
                        //cell.textLbl.text = "Please choose one or more ways for \(user.userName) to reach out!"
                    }
                }

                return cell
            case ConnectedAccount.count + 2:
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case ConnectedAccount.count + 3:
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                
                if isSetting {
                    cell.genBtn.setTitle("Save", for: .normal)
                } else {
                    cell.genBtn.setTitle("Accept", for: .normal)
                }
                cell.genBtn.backgroundColor = UIColor(named: "Success")
                
                cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                return cell
            default:
                
                let cell : ContactInfoTVCell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoTVCell", for: indexPath) as! ContactInfoTVCell

                cell.textLbl.isHidden = true
                cell.tfView.isHidden = false
                cell.chkBtn.tag = indexPath.row
                
                
                cell.contactTF.checkMarkEnabled = false
                cell.contactTF.semanticContentAttribute = .forceLeftToRight
                //cell.contactTF.textAlignment = .left
                cell.contactTF.updatePadding(top: 0, left: 10, bottom: 0, right: 10)
                cell.contactTF.textColor = UIColor(named: "Text grey")
                cell.contactTF.arrowColor = .clear
                cell.contactTF.font = UIFont(name: "Roboto", size: 14)?.medium
                
                cell.contactTF.didSelect { selectedText, index, id in
                    //cell.contactTF.text = "Selected String: \(selectedText) \n index: \(index) \n Id: \(id)"
                }
                
                var socialObjArr = [SocialAccModel]()
                
                switch ConnectedAccount[indexPath.row - 2].contactTypeId {
                    case 1:
                        cell.socialPicIV.image = UIImage(named: "LinkedIn")
                        cell.contactTF.keyboardType = .default
                        
                        socialObjArr = socialAccounts.filter {$0.linkType == "LinkedIn"}
                        cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                        cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                        
                        if socialObjArr.count <= 1 {
                            cell.contactTF.text = socialObjArr.first?.linkTitle
                        }
                    case 2:
                        cell.socialPicIV.image = UIImage(named: "whatsapp")
                        cell.contactTF.keyboardType = .numberPad
                    case 3:
                        cell.socialPicIV.image = UIImage(named: "WeChat")
                        cell.contactTF.keyboardType = .numberPad
                        
                        socialObjArr = socialAccounts.filter {$0.linkType == "WeChat"}
                        cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                        cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                        
                        if socialObjArr.count <= 1 {
                            cell.contactTF.text = socialObjArr.first?.linkTitle
                        }
                    case 4:
                        cell.socialPicIV.image = UIImage(named: "phone")
                        cell.contactTF.keyboardType = .numberPad
                    case 5:
                        cell.socialPicIV.image = UIImage(named: "Instagram")
                        cell.contactTF.keyboardType = .default
                        
                        socialObjArr = socialAccounts.filter {$0.linkType == "Instagram"}
                        cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                        cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                        if socialObjArr.count <= 1 {
                            cell.contactTF.text = socialObjArr.first?.linkTitle
                        }
                    case 6:
                        cell.socialPicIV.image = UIImage(named: "message")
                        cell.contactTF.keyboardType = .numberPad
                    default:
                        print("default")
                }
                
                cell.chkBtn.addTarget(self, action: #selector(checkBtnPressed(sender:)), for: .touchUpInside)

                cell.contactTF.placeholder = ConnectedAccount[indexPath.row - 2].contactType
                AppFunctions.colorPlaceholder(tf: cell.contactTF, s: ConnectedAccount[indexPath.row - 2].contactType)
                return cell
                
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension

    }
}