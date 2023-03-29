//
//  EditProfileSetup.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 22/02/2023.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class EditProfileSetup: MainViewController {
    
    @IBOutlet weak var profileTV: UITableView!
    
    var placeholderArray = ["","Full Name","Date of Birth"
                            ,"Public Email","Where do you work / study?","Title","Tell us about your self..",""]
    //var dataArray = ["","Tamara Pensiero ","Feb 25, 1993","tamar@kismet.org.com","Rice University, Houston TX","Professor","Chemistry professor, having a decade of experience in teaching chemistry. Completed PHD from Rich University, Houston TX. Nobel prize winner in....",""]
    var dataArray = [String]()
    
    var socialAccArray = [String]()
    var socialAccImgArray = [UIImage(named: ""),UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var userdbModel : Results<UserDBModel>!
    var socialAccdbModel : Results<SocialAccDBModel>!
    
    var isfromExtProf = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        userProfile()
        userSocialAcc()
        if DBService.fetchloggedInUser().count > 0 {
            userdbModel = DBService.fetchloggedInUser()
            DBUpdateUserdb()
        }
        if DBService.fetchSocialAccList().count > 0 {
            socialAccdbModel = DBService.fetchSocialAccList()
            DBUpdateSocialAcc()
        }
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "ProfileHeaderTVCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        
        profileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        
        profileTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")
        profileTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    func DBUpdateUserdb() {
        
        Observable.changeset(from: userdbModel)
            .subscribe(onNext: { [weak self] _, changes in
                if let changes = changes {
                    Logs.show(message: "CHANGES: \(changes)")
                    if DBService.fetchloggedInUser().count > 0 {
                        self?.userdbModel = DBService.fetchloggedInUser()
                        let user = self?.userdbModel.first
                        self?.dataArray = ["",
                                           user!.userName,
                                           self!.formatDateForDisplay(date: Date(user!.dob) ?? Date()),
                                           user!.publicEmail,
                                           user!.workAddress,
                                           user!.workTitle,
                                           ""]
                    }
                    self?.profileTV.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
    func DBUpdateSocialAcc() {
        
        Observable.changeset(from: socialAccdbModel)
            .subscribe(onNext: { [weak self] _, changes in
                if let changes = changes {
                    Logs.show(message: "CHANGES: \(changes)")
                    if DBService.fetchSocialAccList().count > 0 {
                        self?.socialAccdbModel = DBService.fetchSocialAccList()
                        self?.socialAccArray = self!.socialAccdbModel.compactMap { $0.linkTitle }
                        if self?.socialAccArray.count != self?.socialAccImgArray.count {
                            switch self?.socialAccArray.count {
                                case 1:
                                    self?.socialAccArray = self!.socialAccArray + ["Add your Twitter account","your Instagram handle","Snapchat","Link your Website"]
                                case 2:
                                    self?.socialAccArray = self!.socialAccArray + ["Share your Instagram handle","Snapchat","Link your Website"]
                                case 3:
                                    self?.socialAccArray = self!.socialAccArray + ["Snapchat","Link your Website"]
                                case 4:
                                    self?.socialAccArray = self!.socialAccArray + ["Link your Website"]
                                case 5:
                                    print("5")
                                default:
                                    print("default")
                            }
                        }
                    }
                    self?.socialAccArray.insert("", at: 0)
                    self?.profileTV.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" ///"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter.string(from: date)
    }
    
    @objc func removeBtnPressed(sender:UIButton) {
        switch sender.tag {
            case placeholderArray.count:
                print("1")
            case placeholderArray.count + 1:
                print("2")
            case placeholderArray.count + 2:
                print("3")
            case placeholderArray.count + 3:
                print("4")
            case placeholderArray.count + 4:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in }
            default:
                print("Default")
        }
        
    }
    
    @objc func genBtnPressedForDone(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @objc func genBtnPressedForProfile(sender:UIButton) {
        self.pushVC(id: "ProfileVC") { (vc:ProfileVC) in
            vc.isOtherProfile = true
        }
    }
    @objc func backBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
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
                        if val {
                            Logs.show(message: "PROFILE: 👉🏻 \(String(describing: self.userdbModel))")
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
    
    func userSocialAcc() {
        
        APIService
            .singelton
            .getUserSocialAccounts()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            Logs.show(message: "SOCIAL ACC: 👉🏻 \(String(describing: self.socialAccdbModel))")
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
extension EditProfileSetup : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count + socialAccArray.count + 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTVCell", for: indexPath) as! ProfileHeaderTVCell
                if isfromExtProf {
                    cell.backBtn.isHidden = false
                    cell.backBtn.addTarget(self, action: #selector(backBtnPressed(sender:)), for: .touchUpInside)
                }
                return cell
                
            case placeholderArray.count - 2 :
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.generalTV.text = user.about
                    }
                }
                cell.generalTV.textColor = UIColor(named: "Text grey")
                
                return cell
                
            case placeholderArray.count - 1 :
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.addBtn.isHidden = true
                cell.headerLbl.text = "Link your social accounts"
                
                return cell
                
            case (placeholderArray.count + socialAccArray.count) - 1: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case placeholderArray.count + socialAccArray.count : // Tags Heading
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                cell.addBtn.isHidden = false
                
                return cell
                
            case placeholderArray.count + socialAccArray.count + 1 : // Tags view Btn
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                cell.isForEditing = true
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        if user.tags != "" {
                            if !user.tags.contains(",") {
                                cell.tagLbl1.text = user.tags
                                cell.tagView1.isHidden = false
                            } else {
                                let split = user.tags.split(separator: ",")
                                for i in 0...split.count - 1 {
                                    switch i {
                                        case 0:
                                            cell.tagLbl1.text = "\(split[i])"
                                            cell.tagView1.isHidden = false
                                        case 1:
                                            cell.tagLbl2.text = "\(split[i])"
                                            cell.tagView2.isHidden = false
                                        case 2:
                                            cell.tagLbl3.text = "\(split[i])"
                                            cell.tagView3.isHidden = false
                                        case 3:
                                            cell.tagLbl4.text = "\(split[i])"
                                            cell.tagView4.isHidden = false
                                        case 4:
                                            cell.tagLbl5.text = "\(split[i])"
                                            cell.tagView5.isHidden = false
                                        default:
                                            print("default")
                                    }
                                }
                            }
                        }
                    }
                }
                return cell
                
            case placeholderArray.count + socialAccArray.count + 2 : // Tags Count view
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "You can maximum add five tags."
                
                return cell
                
            case placeholderArray.count + socialAccArray.count + 3: // Profile Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                
                
                cell.arrowView.isHidden = true
                cell.genBtn.titleLabel?.font = UIFont(name: "Work Sans", size: 14)?.medium
                cell.genBtn.setTitle("Preview profile", for: .normal)
                cell.genBtn.backgroundColor = UIColor.clear
                cell.genBtn.tintColor = UIColor(named: "Secondary Grey")
                cell.genBtn.underline()
                cell.genBtn.isWork = true
                cell.genBtn.addTarget(self, action: #selector(genBtnPressedForProfile(sender:)), for: .touchUpInside)
                
                
                return cell
                
                
            case placeholderArray.count + socialAccArray.count + 4: // Done Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                cell.genBtn.setTitle("Done", for: .normal)
                cell.arrowView.isHidden = true
                
                
                cell.genBtn.addTarget(self, action: #selector(genBtnPressedForDone(sender:)), for: .touchUpInside)
                return cell
                
            default:
                if indexPath.row <= placeholderArray.count - 1 {
                    let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                    
                    cell.numberView.isHidden = true
                    cell.generalTFView.isHidden = false
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
                    if dataArray.count > 2 {
                        cell.generalTF.text = dataArray[indexPath.row]
                    }
                    if placeholderArray[indexPath.row] == "Public Email" {
                        cell.toolTipBtn.isHidden = false
                    } else if placeholderArray[indexPath.row] == "Date of Birth" {
                        cell.toolTipBtn.isHidden = false
                    } else {
                        cell.toolTipBtn.isHidden = true
                    }
                    
                    return cell
                    
                } else {
                    let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                    
                    cell.removeBtn.isHidden = false
                    cell.removeBtn.tag = indexPath.row

                    switch socialAccArray[(indexPath.row - placeholderArray.count) + 1] {
                        case let str where str.contains("LinkedIn"):
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        case let str where str.contains("Twitter"):
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        case let str where str.contains("Instagram"):
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        case let str where str.contains("Snapchat"):
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        case let str where str.contains("Website"):
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        default:
                            print("default")
                    }
                    
                    cell.socialImgView.image = socialAccImgArray[(indexPath.row - placeholderArray.count) + 1]
                    cell.socialLbl.text = socialAccArray[(indexPath.row - placeholderArray.count) + 1].capitalized
                    
                    cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                    
                    return cell
                }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == (placeholderArray.count + socialAccArray.count) - 1 {
            return 20.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccArray.count + 2 {
            return 30.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccArray.count + 3 {
            return 30.0 // profile btn
        } else {
            return UITableView.automaticDimension
        }
    }
}

