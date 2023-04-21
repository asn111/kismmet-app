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
    var dataArray = [String]()
    
    var tags = [String]()
    var addedSocialArray = [String]()
    
    var socialAccArray = [String]()
    var tempSocialAccArray = ["Network via LinkedIn","Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
    
    
    var tempSocialAccImgArray = ["LinkedIn","Twitter","Insta","snapchat","Website"]

    var socialAccImgArray = [UIImage(named: ""),UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var userdbModel : Results<UserDBModel>!
    var socialAccdbModel = [SocialAccDBModel]()
    
    var isfromExtProf = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        userSocialAcc()
        userProfile()
        if DBService.fetchloggedInUser().count > 0 {
            userdbModel = DBService.fetchloggedInUser()
            DBUpdateUserdb()
        }
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "tagsAdded" {
                Logs.show(message: val)
                if AppFunctions.getTagsArray().count > 0 {
                    self?.tags = AppFunctions.getTagsArray()
                    self?.profileTV.reloadRows(at: [IndexPath(row: (self?.placeholderArray.count)! + (self?.socialAccImgArray.count)! + 1, section: 0)], with: .fade)
                }
                
            } else if val.contains("socialAdded") {
                Logs.show(message: val)
                
                if AppFunctions.getSocialArray().count > 0 {
                    switch AppFunctions.getSocialArray().count {
                        case 1:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
                        case 2:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Your Instagram handle","Snapchat","Link your Website"]
                        case 3:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Snapchat","Link your Website"]
                        case 4:
                            self?.socialAccArray = AppFunctions.getSocialArray() + ["Link your Website"]
                        case 5:
                            self?.socialAccArray = AppFunctions.getSocialArray()
                        default:
                            print("default")
                    }
                    var indexPaths: [IndexPath] = []
                    
                    for i in 8...12 {
                        let indexPath = IndexPath(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    self?.profileTV.reloadRows(at: indexPaths, with: .none)
                }
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppFunctions.removeFromDefaults(key: tagsArray)
        AppFunctions.removeFromDefaults(key: socialArray)
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
                        
                        self?.tags = (user?.tags.components(separatedBy: ","))!
                        AppFunctions.setTagsArray(value: self?.tags ?? [""])
                    }
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
            case 8:
                socialAccArray[0] = tempSocialAccArray[0]
                ApiService.deleteSocialLink(val: 0)
                profileTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 9:
                socialAccArray[1] = tempSocialAccArray[1]
                ApiService.deleteSocialLink(val: 0)
                profileTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 10:
                socialAccArray[2] = tempSocialAccArray[2]
                ApiService.deleteSocialLink(val: 0)
                profileTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 11:
                socialAccArray[3] = tempSocialAccArray[3]
                ApiService.deleteSocialLink(val: 0)
                profileTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 12:
                socialAccArray[4] = tempSocialAccArray[4]
                ApiService.deleteSocialLink(val: 0)
                profileTV.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .right)
            case 100:
                removeFromTagArray(index: sender.tag)
            case 200:
                removeFromTagArray(index: sender.tag)
            case 300:
                removeFromTagArray(index: sender.tag)
            case 400:
                removeFromTagArray(index: sender.tag)
            case 500:
                removeFromTagArray(index: sender.tag)
            default:
                print("default")
        }
    }
    
    func removeFromTagArray(index: Int) {
        Logs.show(message: "REMOVE PRESSED")
        var arr = AppFunctions.getTagsArray()
        arr.remove(at: (index/100 - 1))
        AppFunctions.setTagsArray(value: arr)
        self.tags.removeAll()
        self.tags = AppFunctions.getTagsArray()
        profileTV.reloadRows(at: [IndexPath(row: placeholderArray.count + socialAccImgArray.count + 1, section: 0)], with: .fade)
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        switch sender.tag {
            case 8:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "linkedIn"
                }
            case 9:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "twitter"
                }
            case 10:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "instagram"
                }
            case 11:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "snapchat"
                }
            case 12:
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "website"
                }
            default:
                let arr = AppFunctions.getTagsArray()
                if arr.count >= 5 {
                    AppFunctions.showSnackBar(str: "Maximum tags added, remove to add new")
                    return
                }
                self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                    vc.accountType = "tags"
                }
        }
        
    }
    
    
    @objc func toolBtnPressed(sender: UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Please note that this email is visible to other users on the app."
        } else if sender.tag == 002 {
            msg = "Please note that your date of birth is private and will not be visible to other users on the app."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
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
                        if val.userId != "" {
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
                            if DBService.fetchSocialAccList().count > 0 {
                                self.socialAccdbModel = Array(DBService.fetchSocialAccList())
                                

                                var imageIndices = [String: Int]()
                                for (index, imageName) in self.tempSocialAccImgArray.enumerated() {
                                    imageIndices[imageName.lowercased()] = index
                                }
                                
                                self.socialAccdbModel.sort { (model1, model2) -> Bool in
                                    if let imageName1 = model1.linkImage.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "").lowercased(),
                                       let imageName2 = model2.linkImage.components(separatedBy: "/").last?.replacingOccurrences(of: ".png", with: "").lowercased(),
                                       let index1 = imageIndices[imageName1],
                                       let index2 = imageIndices[imageName2] {
                                        return index1 < index2
                                    } else {
                                        // If there is any error in extracting the image name or index, keep the original order
                                        return false
                                    }
                                }
                                
                                self.socialAccArray = self.socialAccdbModel.compactMap({$0.linkTitle})
                                AppFunctions.setSocialArray(value: self.socialAccArray)
                               
                                if AppFunctions.getSocialArray().count > 0 {
                                    
                                    self.socialAccArray = self.socialAccdbModel.compactMap({$0.linkTitle})
                                    let linkTypes = self.socialAccdbModel.compactMap({$0.linkType})
                                    AppFunctions.setSocialArray(value: self.socialAccArray)
                                    
                                    var matchedIndex = [Int]()
                                    if self.tempSocialAccArray.count > 0 {

                                        for (_, linkType) in linkTypes.enumerated() {
                                            if let matchingIndex = self.tempSocialAccArray.firstIndex(where: { $0.range(of: linkType, options: .caseInsensitive) != nil }) {
                                                matchedIndex.append(matchingIndex)
                                            }
                                        }
                                        
                                        let nonMatchedIndex = self.tempSocialAccArray.indices.filter { !matchedIndex.contains($0) }
                                        for index in nonMatchedIndex {
                                            self.socialAccArray.insert(self.tempSocialAccArray[index], at: index)
                                        }
                                    }
                                    
                                    var indexPaths: [IndexPath] = []
                                    
                                    for i in 8...12 {
                                        let indexPath = IndexPath(item: i, section: 0)
                                        indexPaths.append(indexPath)
                                    }
                                    self.profileTV.reloadRows(at: indexPaths, with: .none)
                                    

                                }
                            }

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
        return placeholderArray.count + socialAccImgArray.count + 5
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
                
            case (placeholderArray.count + socialAccImgArray.count) - 1: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case placeholderArray.count + socialAccImgArray.count: // Tags Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                cell.addBtn.isHidden = false
                cell.addBtn.tag = indexPath.row
                if tags.count == 5 {
                    cell.addBtn.isHidden = true
                } else {
                    cell.addBtn.isHidden = false
                }
                
                cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            case placeholderArray.count + socialAccImgArray.count + 1 : // Tags view Btn
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                
                cell.isForEditing = true
                cell.removeBtn1.tag = 100
                cell.removeBtn2.tag = 200
                cell.removeBtn3.tag = 300
                cell.removeBtn4.tag = 400
                cell.removeBtn5.tag = 500
                
                cell.removeBtn1.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn2.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn3.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn4.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                cell.removeBtn5.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                
                cell.tagView1.isHidden = true
                cell.tagView2.isHidden = true
                cell.tagView3.isHidden = true
                cell.tagView4.isHidden = true
                cell.tagView5.isHidden = true
                
                if tags.count > 0 {
                    for i in 0...tags.count - 1 {
                        switch i {
                            case 0:
                                cell.tagLbl1.text = "\(tags[i])"
                                cell.tagView1.isHidden = false
                            case 1:
                                cell.tagLbl2.text = "\(tags[i])"
                                cell.tagView2.isHidden = false
                            case 2:
                                cell.tagLbl3.text = "\(tags[i])"
                                cell.tagView3.isHidden = false
                            case 3:
                                cell.tagLbl4.text = "\(tags[i])"
                                cell.tagView4.isHidden = false
                            case 4:
                                cell.tagLbl5.text = "\(tags[i])"
                                cell.tagView5.isHidden = false
                            default:
                                print("default")
                        }
                    }
                }
                
                
                return cell
                
            case placeholderArray.count + socialAccImgArray.count + 2 : // Tags Count view
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "You can maximum add five tags."
                
                return cell
                
            case placeholderArray.count + socialAccImgArray.count + 3: // Profile Btn
                
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
                
                
            case placeholderArray.count + socialAccImgArray.count + 4: // Done Btn
                
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
                        cell.toolTipBtn.tag = 001
                    } else if placeholderArray[indexPath.row] == "Date of Birth" {
                        cell.toolTipBtn.isHidden = false
                        cell.toolTipBtn.tag = 002
                    } else {
                        cell.toolTipBtn.isHidden = true
                    }
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                    
                    
                    return cell
                    
                } else {
                    
                    let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                    
                    cell.removeBtn.isHidden = false
                    cell.removeBtn.tag = indexPath.row
                    cell.socialLbl.isUserInteractionEnabled = false

                    cell.socialImgView.image = socialAccImgArray[(indexPath.row - placeholderArray.count) + 1]
                    if !socialAccArray.isEmpty {
                        cell.socialLbl.text = socialAccArray[(indexPath.row - placeholderArray.count)]
                        
                        if socialAccArray[(indexPath.row - placeholderArray.count)].isEqual(tempSocialAccArray[(indexPath.row - placeholderArray.count)]) {
                            cell.removeBtn.removeTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                            cell.removeBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                            cell.removeBtn.setImage(UIImage(systemName: "plus"), for: .normal)
                            cell.removeBtn.cornerRadius = 4
                        } else {
                            cell.removeBtn.removeTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                            cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
                            cell.removeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
                            cell.removeBtn.cornerRadius = 10
                        }
                    }
                    
                    return cell
                }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Logs.show(message: "INDEX: \(indexPath.row)")

        
        /*if indexPath.row > 4 {
            //AppFunctions.showSnackBar(str: "\(indexPath.row)")
            switch socialAccModel[indexPath.row - 5].linkType {
                case "LinkedIn":
                    AppFunctions.openLinkedIn(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Twitter":
                    AppFunctions.openTwitter(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Instagram":
                    AppFunctions.openInstagram(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Snapchat":
                    AppFunctions.openSnapchat(userName: socialAccModel[indexPath.row - 5].linkUrl)
                case "Website":
                    AppFunctions.openWebLink(link: socialAccModel[indexPath.row - 5].linkUrl)
                default:
                    print("default")
            }
        }*/
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == (placeholderArray.count + socialAccImgArray.count) - 1 {
            return 20.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccImgArray.count + 2 {
            return 30.0 // empty view
        } else if indexPath.row == placeholderArray.count + socialAccImgArray.count + 3 {
            return 30.0 // profile btn
        } else {
            return UITableView.automaticDimension
        }
    }
}

