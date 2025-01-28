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

class EditProfileSetup: MainViewController { //Birthday
    
    @IBOutlet weak var profileTV: UITableView!
    
    var placeholderArray = ["","First Name *","Last Name *","Birthday *"
                            ,"Public Email *","Where do you work / study? *","Title *","Bio.. *",""]
    var dataArray = [String]()
    var firstName = "", lastName = "", publicEmail = "", placeOfWork = "", workTitle = "" , dateOfBirth = "" , about = "", status = "", countryCode = "", phoneNum = "", countryName = "", profilePic = ""
    
    var isPicUpdateOnly = false

    var proximity = 0
    var isProfileVisible = false
    var disappearingStatus = false
    var limitExceed = false
    
    var updatedImagePicked : UIImage!

    var tags = [String]()
    var addedSocialArray = [String]()
    var profileDict = [String: Any]()

    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?

    var socialAccArray = [String]()
    
    var socialAccImgArray = [UIImage(named: ""),UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Instagram"),UIImage(named: "Snapchat"),UIImage(named: "Website")]
    
    var tempSocialAccImgArray = [String()]
    var socialAccounts = [SocialAccDBModel()]

    
    var userdbModel : Results<UserDBModel>!
    var socialAccModel = [SocialAccModel]()
    
    var isfromExtProf = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        tempSocialAccImgArray = socialAccounts.compactMap { $0.linkType }

        
        registerCells()
        //userSocialAcc()
        userProfile()
        if DBService.fetchloggedInUser().count > 0 {
            userdbModel = DBService.fetchloggedInUser()
            //DBUpdateUserdb()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "imageUpdate" {
                if self?.updatedImagePicked != nil {
                    self?.profileTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            } else if val == "tagsAdded" {
                Logs.show(message: val)
                if AppFunctions.getTagsArray().count > 0 {
                    self?.tags = AppFunctions.getTagsArray()
                    self?.profileTV.reloadRows(at: [IndexPath(row: (self?.placeholderArray.count)! + 1, section: 0)], with: .fade)
                }
                
            } else if val.contains("socialAdded") {
                Logs.show(message: val)
                
                self?.userProfile()

            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
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
    
    /*func DBUpdateUserdb() {
        
        Observable.changeset(from: userdbModel)
            .subscribe(onNext: { [weak self] _, changes in
                if let changes = changes {
                    Logs.show(message: "CHANGES: \(changes)")
                }
            })
            .disposed(by: dispose_Bag)
    }*/
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        profileTV.contentInset = contentInsets
        profileTV.scrollIndicatorInsets = contentInsets
        
        var activeView: UIView?
        if let activeTextField = activeTextField {
            activeView = activeTextField
        } else if let activeTextView = activeTextView {
            activeView = activeTextView
        }
        
        if let activeView = activeView {
            let rect = profileTV.convert(activeView.bounds, from: activeView)
            let offsetY = rect.maxY - (profileTV.bounds.height - keyboardSize.height)
            if offsetY > 0 {
                profileTV.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }
        }
    }


    
    @objc private func keyboardWillHide(notification: NSNotification) {
        profileTV.contentInset = .zero
    }
    
    @objc func updateDateField(sender: UIDatePicker) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
        
        cell.generalTF.text = formatDateForDisplay(date: sender.date)
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .long
        dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        !cell.generalTF.text!.isTFBlank ? dateOfBirth = dateformatter.string(from: sender.date) : print("Empty Date")
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" ///"yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter.string(from: date)
    }
    
    fileprivate func convertToDate(dateStr: String) -> Date {
        var theDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.date(from: dateStr) {
            theDate = date
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            if let date = dateFormatter.date(from: dateStr) {
                theDate = date
            } else {
                print("Error: Unable to convert date string.")
            }
        }
        return theDate
    }

    
    @objc func removeBtnPressed(sender:UIButton) {
        switch sender.tag {
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
        profileTV.reloadRows(at: [IndexPath(row: 8, section: 0),IndexPath(row: 9, section: 0)], with: .fade)
    }
    
    @objc func addBtnPressed(sender:UIButton) {
        //if sender.tag > 7 {
            let arr = AppFunctions.getTagsArray()
            if arr.count >= 5 {
                AppFunctions.showSnackBar(str: "Maximum tags added, remove to add new")
                return
            }
            self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                vc.accountType = "tags"
            }
        /*} else if sender.tag == 7 {
            self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
            }
        }*/
    }
    
    
    @objc func toolBtnPressed(sender: UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Add an optional email address to your profile for convenient connections.\nNote: it will be visible on your profile."
        } else if sender.tag == 002 {
            msg = "Please note that your date of birth is private and will not be visible to other users on the app."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
    }
    
    @objc func genBtnPressedForDone(sender:UIButton) {
        
        //Logs.show(message: "\(fullName), \(publicEmail), \(dateOfBirth), \(placeOfWork), \(workTitle), \(about), \(tags.joined(separator: ","))")
        
        if firstName != "" && lastName != "" && publicEmail != "" && dateOfBirth != "" && placeOfWork != "" && workTitle != "" && about != "" {
            if tags.joined(separator: ",").count != 0 {
                
                userProfileUpdate()
            } else {
                AppFunctions.showSnackBar(str: "Tags are important part of profile, please add at least one.")
            }
        } else {
            AppFunctions.showSnackBar(str: "Please fill out all the mandatory fields")
        }
        
        
    }
    @objc func genBtnPressedForProfile(sender:UIButton) {
        
            if tags.joined(separator: ",").count != 0 {
                
                self.pushVC(id: "ProfileVC") { (vc:ProfileVC) in
                    
                    profileDict["firstName"] = firstName
                    profileDict["lastName"] = lastName
                    profileDict["publicEmail"] = publicEmail
                    profileDict["profilePicture"] = profilePic
                    profileDict["workAdress"] = placeOfWork
                    profileDict["workTitle"] = workTitle
                    profileDict["about"] = about
                    profileDict["status"] = status
                    profileDict["disappearingStatus"] = disappearingStatus
                    profileDict["tags"] = tags.joined(separator: ",")
                    
                    let userModel = UserModel(fromDictionary: profileDict)
                    vc.userModel = userModel
                    vc.isOtherProfile = true
                }
            } else {
                AppFunctions.showSnackBar(str: "Tags are important part of profile, please add at least one.")
            }
        
    }
    @objc func backBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editBtnPressed(sender:UIButton) {
        let imagePickerClass = ImagePicker(viewController: self)
        imagePickerClass.handleTap()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if textView.text == "Bio" {
            // Clear the text view
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        about = !textView.text!.isTFBlank ? textView.text! : ""
        dataArray[6] = about
        activeTextView = nil
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if updatedText.count > 4000 {
            // Log message or take action when limit is exceeded
            limitExceed = true
            return false
        }
        
        limitExceed = false
        return true
    }

    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        
        activeTextField = textField

        if textField.tag == 1 {
            firstName = !textField.text!.isTFBlank ? textField.text! : ""
            dataArray[1] = firstName
        } else if textField.tag == 2 {
            lastName = !textField.text!.isTFBlank ? textField.text! : ""
            dataArray[2] = lastName
        } else if textField.tag == 4 {
            publicEmail = !textField.text!.isTFBlank ? textField.text! : ""
            dataArray[4] = publicEmail
        } else if textField.tag == 5 {
            placeOfWork = !textField.text!.isTFBlank ? textField.text! : ""
            dataArray[5] = placeOfWork
        } else if textField.tag == 6 {
            workTitle = !textField.text!.isTFBlank ? textField.text! : ""
            dataArray[6] = workTitle
        }
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    //MARK: UIPickerView Methods

    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 6 {
            textField.returnKeyType = .done
        } else {
            textField.returnKeyType = .next
        }
        if textField.tag == 3 {
            
            let indexPath = IndexPath(row: textField.tag, section: 0)
            let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
            cell.generalTF = textField as? FormTextField
            
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                if #available(iOS 14.0, *) {
                    picker.preferredDatePickerStyle = .inline
                } else {
                    // Fallback on earlier versions
                    picker.preferredDatePickerStyle = .wheels
                }
            } else {
                // Fallback on earlier versions
            }
            picker.minimumDate = Calendar.current.date(byAdding: .year, value: -100, to: Date())
            picker.maximumDate = Calendar.current.date(byAdding: .year, value: -17, to: Date())
            
            if dateOfBirth != "" {
                picker.date = convertToDate(dateStr: dateOfBirth)
            }
            picker.tag = textField.tag
            picker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
            
            //ToolBar
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
            
            let cancelButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapDone(sender:datePicker1:)));
            
            toolbar.setItems([cancelButton], animated: false)
            
            cell.generalTF.inputAccessoryView = toolbar
            
            textField.inputView = picker
            textField.text = formatDateForDisplay(date: picker.date)
            
            
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        let nextResponder = textField.superview?.superview?.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder?
        
        if nextResponder != nil {
            nextResponder?.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    @objc func tapDone(sender: Any, datePicker1: UIDatePicker) {
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
        print(datePicker1)
        if let datePicker = cell.generalTF.inputView as? UIDatePicker { // 2.1
            let dateformatter = DateFormatter() // 2.2
            dateformatter.dateStyle = .long // 2.3
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            !cell.generalTF.text!.isTFBlank ? dateOfBirth = dateformatter.string(from: datePicker.date) : print("Empty Date")
            dataArray[3] = formatDateForDisplay(date: datePicker.date)
            //profileTV.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)

        }
        cell.generalTF.resignFirstResponder() // 2.5
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
                            self.socialAccModel = val.socialAccounts
                            if DBService.fetchloggedInUser().count > 0 {
                                self.userdbModel = DBService.fetchloggedInUser()
                                let user = self.userdbModel.first
                                self.dataArray = ["",
                                                  user!.firstName.isEmpty ? "" : user!.firstName,
                                                  user!.lastName.isEmpty ? "" : user!.lastName,
                                                   self.formatDateForDisplay(date: self.convertToDate(dateStr: user?.dob ?? "Birthday")),
                                                  user!.publicEmail.isEmpty ? "Public Email" : user!.publicEmail,
                                                  user!.workAddress.isEmpty ? "Where do you work / study?" : user!.workAddress,
                                                  user!.workTitle.isEmpty ? "Title" : user!.workTitle,
                                                   ""]
                                self.firstName = user!.firstName.isEmpty ? "" : user!.firstName
                                self.lastName = user!.lastName.isEmpty ? "" : user!.lastName
                                self.profilePic = user!.profilePicture
                                self.dateOfBirth = user!.dob
                                self.publicEmail = user!.publicEmail
                                self.workTitle = user!.workTitle
                                self.placeOfWork = user!.workAddress
                                self.about = user!.about
                                self.status = user!.status
                                self.disappearingStatus = user!.disappearingStatus
                                self.countryCode = user!.countryCode
                                self.countryName = user!.countryName
                                self.phoneNum = user!.phone
                                self.proximity = user!.proximity
                                self.isProfileVisible = user!.isProfileVisible
                                
                                self.tags = (user?.tags.components(separatedBy: ","))!
                                AppFunctions.setTagsArray(value: self.tags)
                            }
                            self.profileTV.reloadData()
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

    func userProfileUpdate() {
        self.showPKHUD(WithMessage: "Signing up")
        
        if let image = updatedImagePicked {
            profilePic = AppFunctions.convertImageToBase64(image: image)
        } else if profilePic.isEmpty {
            AppFunctions.showSnackBar(str: "Profile Picture is mandatory")
            return
        }

        if limitExceed {
            AppFunctions.showSnackBar(str: "Maximum character limit exceeded for your bio!\nPlease keep it under 4000")
            return
        }
        // somewhere here add check for limit for bio
        profileDict["firstName"] = firstName
        profileDict["lastName"] = lastName
        profileDict["profilePicture"] = profilePic
        profileDict["publicEmail"] = publicEmail
        profileDict["countryCode"] = countryCode
        profileDict["phoneNumber"] = phoneNum
        profileDict["dob"] = dateOfBirth
        profileDict["countryName"] = dateOfBirth
        profileDict["workAdress"] = placeOfWork
        profileDict["workTitle"] = workTitle
        profileDict["about"] = about
        profileDict["proximity"] = proximity
        profileDict["isProfileVisible"] = isProfileVisible
        profileDict["tags"] = tags.joined(separator: ",")
        
        Logs.show(message: "SKILLS PRAM: \(profileDict)")
        
        APIService
            .singelton
            .userProfileUpdate(pram: profileDict)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            if isPicUpdateOnly {
                                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                    vc.selectedIndex = 2
                                }
                            }
                            self.hidePKHUD()
                            self.navigationController?.popViewController(animated: true)
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
        return placeholderArray.count + 5 //socialAccounts.count + 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTVCell", for: indexPath) as! ProfileHeaderTVCell
                if isPicUpdateOnly {
                    cell.backBtn.isHidden = true
                } else {
                    cell.backBtn.isHidden = false
                }
                cell.backBtn.addTarget(self, action: #selector(backBtnPressed(sender:)), for: .touchUpInside)
                
                if updatedImagePicked != nil {
                    cell.profileIV.image = updatedImagePicked
                    Logs.show(message: "Updated")
                } else {
                    if profilePic != "" {
                        let imageUrl = URL(string: profilePic)
                        cell.profileIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder_icon")) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.profileIV.image = UIImage(named: "placeholder_icon")
                    }
                }
                cell.editBtn.addTarget(self, action: #selector(editBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
                
            case placeholderArray.count - 2 : // About
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        cell.generalTV.text = user.about.isEmpty ? "Bio.." : user.about

                    }
                }
                cell.generalTV.delegate = self
                cell.generalTV.textColor = UIColor(named: "Text grey")

                
                return cell
                
            case placeholderArray.count - 1 : //socialAccounts.count + 1) - 1: // EmptyView
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case placeholderArray.count : //socialAccounts.count + 1: // Tags Heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                
                if let font = cell.headerLbl.font {
                    let text = "Tags (Please enter & save one tag at a time)"
                    let italicRange = (text as NSString).range(of: "(Please enter & save one tag at a time)")
                    
                    let attributedString = NSMutableAttributedString(string: text)
                    
                    // Apply the label's font to the entire text
                    attributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: text.count))
                    
                    // Apply the system italic font to the text within parentheses
                    let italicFont = UIFont.italicSystemFont(ofSize: font.pointSize)
                    attributedString.addAttribute(.font, value: italicFont, range: italicRange)
                    
                    cell.headerLbl.attributedText = attributedString
                }


                //cell.headerLbl.text = "Tags (Please enter & save one tag at a time)"
                
                cell.notifHeaderView.isHidden = true
                cell.toggleBtnView.isHidden = true
                cell.sliderView.isHidden = true
                
                cell.addBtn.isHidden = false
                cell.addBtn.tag = indexPath.row
                if tags.count == 5 {
                    cell.addBtn.isHidden = true
                } else {
                    cell.addBtn.isHidden = false
                }
                
                cell.addBtn.addTarget(self, action: #selector(addBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            case placeholderArray.count + 1 ://ocialAccounts.count + 2 : // Tags view Btn
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
                
            case placeholderArray.count + 2://socialAccounts.count + 3 : // Tags Count view
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.headerLblView.isHidden = true
                cell.toggleBtnView.isHidden = true
                cell.sliderView.isHidden = true
                cell.notifHeaderLbl.text = "Highlight your interests and personality with up to five tags."
                
                return cell
                
            case placeholderArray.count + 3://socialAccounts.count + 4: // Profile Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell

                cell.genBtnView.isHidden = true
                cell.newBtnView.isHidden = false
                cell.newBtn.tag = indexPath.row
                cell.newBtn.addTarget(self, action: #selector(genBtnPressedForProfile(sender:)), for: .touchUpInside)
                
                cell.newBtn.titleLabel?.font = UIFont(name: "Work Sans", size: 14)?.medium
                cell.newBtn.setTitle("Preview profile", for: .normal)
                cell.newBtn.backgroundColor = UIColor.clear
                cell.newBtn.tintColor = UIColor(named: "Secondary Grey")
                cell.newBtn.underline()
                cell.newBtn.isWork = true
                
                if isPicUpdateOnly {
                    cell.newBtn.isHidden = true
                }
                
                return cell
                
                
            case placeholderArray.count + 4://socialAccounts.count + 5: // Done Btn
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                
                cell.genBtnView.isHidden = false
                cell.newBtnView.isHidden = true
                cell.genBtn.tag = indexPath.row
                cell.genBtn.addTarget(self, action: #selector(genBtnPressedForDone(sender:)), for: .touchUpInside)
                
                cell.genBtn.setTitle("Update", for: .normal)
                
                cell.arrowView.isHidden = true
                
                return cell
                
            default:
                //if indexPath.row <= placeholderArray.count - 1 {
                    let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                    
                    cell.numberView.isHidden = true
                    cell.generalTFView.isHidden = false
                    cell.generalTF.delegate = self
                    
                    cell.generalTF.tag = indexPath.row
                    
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
                    if dataArray.count > 2 {
                        cell.generalTF.text = dataArray[indexPath.row]
                    }
                    if placeholderArray[indexPath.row] == "Public Email" {
                        cell.toolTipBtn.isHidden = false
                        cell.toolTipBtn.tag = 001
                    } else if placeholderArray[indexPath.row] == "Birthday" {
                        cell.toolTipBtn.isHidden = false
                        cell.toolTipBtn.tag = 002
                    } else {
                        cell.toolTipBtn.isHidden = true
                    }
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolBtnPressed(sender:)), for: .touchUpInside)
                    
                    
                    return cell
                    
                /*} else {
                    
                    let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                    
                    cell.socialLbl.isUserInteractionEnabled = false
                    
                    if socialAccounts[(indexPath.row - placeholderArray.count)].linkImage != "" {
                        let imageUrl = URL(string: socialAccounts[(indexPath.row - placeholderArray.count)].linkImage)
                        cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
                    }
                    if socialAccModel.filter({$0.linkType == socialAccounts[(indexPath.row - placeholderArray.count)].linkType }).count > 0 {
                        cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.medium
                    } else {
                        cell.socialLbl.font = UIFont(name: "Work Sans", size: 16)!.regular
                    }
                    cell.socialLbl.text = socialAccounts[(indexPath.row - placeholderArray.count)].linkType
                    
                    return cell
                }*/
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Logs.show(message: "INDEX: \(indexPath.row)")

        /*if indexPath.row > placeholderArray.count - 1 && indexPath.row < (placeholderArray.count + socialAccounts.count + 1) - 1{
            if socialAccModel.filter({$0.linkType == socialAccounts[(indexPath.row - placeholderArray.count)].linkType }).count > 0 {
                self.presentVC(id: "SocialLinks_VC",presentFullType: "not") { (vc:SocialLinks_VC) in
                    vc.socialAccModel = socialAccModel.filter {$0.linkType == socialAccounts[(indexPath.row - placeholderArray.count)].linkType }
                    vc.linkType = socialAccounts[(indexPath.row - placeholderArray.count)].linkType
                    vc.canEdit = true
                }
            } else {
                AppFunctions.showSnackBar(str: "Please add social account")
            }
        }*/
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == placeholderArray.count - 1 {//+ socialAccounts.count + 1) - 1 {
            return 5.0 // empty view below about
        } else if indexPath.row == placeholderArray.count + 2 {//+ socialAccounts.count + 3 {
            return 30.0 // empty view below tags
        } else if indexPath.row == placeholderArray.count + 3 {//socialAccounts.count + 4 {
            return 30.0 // profile btn
        } else {
            return UITableView.automaticDimension
        }
    }
}

