//
//  ContactInformainVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit
import RealmSwift
import Alamofire
import iOSDropDown

class ContactInformainVC: MainViewController {

    
    @IBOutlet weak var contactTV: UITableView!
    
    var isSetting = false
    var userdbModel : Results<UserDBModel>!
    var img = UIImage(named: "placeholder")
    
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?

    var contactAccounts = [ContactTypesModel]()
    var connectedContactAccount = [ContactsModel]()
    var socialAccounts = [SocialAccModel]()
    
    var contactId = 0
    
    var linkedInContactValue = ""
    var whatsAppContactValue = ""
    var wechatContactValue = ""
    var directContactValue = ""
    var instagramContactValue = ""
    var kismmetMsgContactValue = ""
    var selectedContactValue = ""

    private var baselineLinkedINContactValue = ""
    private var baselineWhatsAppContactValue = ""
    private var baselineWechatContactValue = ""
    private var baselineDirectContactValue = ""
    private var baselineInstagramContactValue = ""
    private var baselinekismmetMsgContactValue = ""
    
    private var baselineSelectedCheckArray: [Int] = []
    
    private var orignalSelectedCheckArray: [Int] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        userProfile()
        getConnectAcc()

        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser()
        }
        registerCells()
        
        baselineSelectedCheckArray = AppFunctions.getSelectedCheckArray()
        orignalSelectedCheckArray = AppFunctions.getSelectedCheckArray()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        generalPublisher.onNext("exitView")
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
        contactTV.register(UINib(nibName: "ContactTextViewTVcell", bundle: nil), forCellReuseIdentifier: "ContactTextViewTVcell")
        contactTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
        
    }
    
    func extractValue(forID id: Int, from objects: [ContactsModel]) -> String? {
        return objects.first(where: { $0.contactTypeId == id })?.value
    }
    
    //MARK: OBJC Methods
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        contactTV.contentInset = contentInsets
        contactTV.scrollIndicatorInsets = contentInsets
        
        var activeView: UIView?
        if let activeTextField = activeTextField {
//            if let ddTf = activeTextField as? DropDownTF {
//                ddTf.touchAction()
//            }
            activeView = activeTextField
        } else if let activeTextView = activeTextView {
            activeView = activeTextView
        }
        
        
        
        if let activeView = activeView {
            let rect = contactTV.convert(activeView.bounds, from: activeView)
            let offsetY = rect.maxY - (contactTV.bounds.height - keyboardSize.height)
            if offsetY > 0 {
                contactTV.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }
        }
    }
    
    
    @objc private func keyboardWillHide(notification: NSNotification) {

        
        contactTV.contentInset = .zero
    }

    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        
        activeTextField = textField
        
        Logs.show(message: "TFmsg: \(textField.text ?? "")")
        if textField.tag == 1 {
            linkedInContactValue = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 2 {
            instagramContactValue = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 3 {
            wechatContactValue = textField.text!.isValidPhoneNumber ? textField.text! : ""
        } else if textField.tag == 4 {
            whatsAppContactValue = textField.text!.isValidPhoneNumber ? textField.text! : ""
        } else if textField.tag == 5 {
            directContactValue = !textField.text!.isTFBlank ? textField.text! : ""
        } /*else if textField.tag == 6 {
            kismmetMsgContactValue = !textField.text!.isTFBlank ? textField.text! : ""
        }*/
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //let isTextFieldBlank = textField.text?.isTFBlank ?? true
        //textField.backgroundColor = isTextFieldBlank ? UIColor.red : UIColor.clear
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView

        if textView.text == "" {
            // Clear the text view
            textView.text = ""
            
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil

        kismmetMsgContactValue = !textView.text!.isTFBlank ? textView.text! : ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let remainingCharacters = textLimit(existingText: textView.text, newText: text, limit: 100)
        
        return remainingCharacters
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let cell = contactTV.cellForRow(at: IndexPath(row: textView.tag + 1, section: 0)) as! ContactTextViewTVcell
        
        if textView.text.count == 0 {
            cell.countLbl.text = "100 / 100 remaining"
            
            // Show the placeholder label when the text is empty
            if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = false
            }
        } else {
            cell.countLbl.text = "\(100 - textView.text.count) / 100 remaining"
            
            // Hide the placeholder label when the text is not empty
            if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = true
            }
        }
    }
    
    
    
    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit
        
        return isAtLimit
    }
    
    func createContactEntries(for contactTypes: [String], contactValues: [String], includeIsShared: Bool) -> [[String: Any]] {
        var entries: [[String: Any]] = []
        
        for (index, contactType) in contactTypes.enumerated() {
            guard !contactValues[index].isEmpty else {
                continue // Skip this iteration if contactValue is empty
            }
            
            let contactTypeId = contactAccounts.filter { $0.contactType == contactType }.first?.contactTypeId ?? 0
            
            var entry: [String: Any] = [
                "contactTypeId": contactTypeId,
                "value": contactValues[index]
            ]
            
            if includeIsShared {
                let isShared = AppFunctions.getSelectedCheckArray().contains(contactTypeId) ? true : false
                entry["isShared"] = isShared
            }
            
            entries.append(entry)
        }
        
        return entries
    }


    func checkForChanges() -> Bool {
        if linkedInContactValue != baselineLinkedINContactValue ||
            whatsAppContactValue != baselineWhatsAppContactValue ||
            wechatContactValue != baselineWechatContactValue ||
            directContactValue != baselineDirectContactValue ||
            instagramContactValue != baselineInstagramContactValue ||
            kismmetMsgContactValue != baselinekismmetMsgContactValue ||
            !ArraysAreEqual(baselineSelectedCheckArray, AppFunctions.getSelectedCheckArray()) {
            
            return true
        }
        return false
    }
    
    private func ArraysAreEqual(_ array1: [Int], _ array2: [Int]) -> Bool {
        if array1.count != array2.count {
            return false
        }
        for index in 0..<array1.count {
            if array1[index] != array2[index] {
                return false
            }
        }
        return true
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
        
        switch sender.tag {
            case 1:
                if linkedInContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            case 2:
                if instagramContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            case 3:
                if wechatContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            case 4:
                if whatsAppContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            case 5:
                if directContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            case 6:
                if kismmetMsgContactValue.isEmpty {
                    return
                }
                AppFunctions.setSelectedCheckValue(value: sender.tag)
                contactTV.reloadRows(at: [IndexPath(row: sender.tag + 1, section: 0)], with: .none)
            default:
                print("")
        }
        
       

    }
    
    @objc func genBtnPressed(sender:UIButton) {
        self.view.endEditing(true)
        
        Logs.show(message: "\nlinkedIn: \(linkedInContactValue)\n whatsapp: \(whatsAppContactValue)\n wechat: \(wechatContactValue)\n direct: \(directContactValue)\n insta: \(instagramContactValue)\n kismmetMsg: \(kismmetMsgContactValue)")
        if isSetting {
           addContacts()
        } else {
            if AppFunctions.getSelectedCheckArray().isEmpty {
                AppFunctions.showSnackBar(str: "Please select at least one contact to reach you back.")
                return
            }
            updateContactStatus()
                        
        }
        
    }
    
    //MARK: API METHODS

    func getConnectAcc() {
        
        
        APIService
            .singelton
            .getConnectAccTypes()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.contactAccounts = val
                            
                            self.getMyContacts()

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
    
    func getMyContacts() {
        
        
        APIService
            .singelton
            .getConnectedContactsAccTypes()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.connectedContactAccount = val
                            if !self.connectedContactAccount.isEmpty {

                                /*connectedContactAccount.forEach { contact in
                                    if contact.isShared {
                                        AppFunctions.setSelectedCheckValue(value: contact.contactTypeId)
                                    }
                                }
                                
                                baselineSelectedCheckArray = AppFunctions.getSelectedCheckArray()*/
                                
                                if let linkedin = extractValue(forID: 1, from: self.connectedContactAccount) {
                                    let socialAcc = SocialAccModel()
                                    
                                    let filteredSocialAccounts = socialAccounts.compactMap { $0.socialAccountId }
                                    if let maxId = filteredSocialAccounts.max() {
                                        socialAcc.socialAccountId = maxId + 1
                                    }
                                    socialAcc.linkTitle = linkedin
                                    socialAcc.linkUrl = linkedin
                                    socialAcc.linkType = "LinkedIn"
                                    socialAccounts.append(socialAcc)
                                    linkedInContactValue = linkedin
                                    
                                }
                                if let whatsapp = extractValue(forID: 4, from: self.connectedContactAccount) {
                                    whatsAppContactValue = whatsapp
                                }
                                if let wechat = extractValue(forID: 3, from: self.connectedContactAccount) {
                                    let socialAcc = SocialAccModel()
                                    
                                    let filteredSocialAccounts = socialAccounts.compactMap { $0.socialAccountId }
                                    if let maxId = filteredSocialAccounts.max() {
                                        socialAcc.socialAccountId = maxId + 1
                                    }
                                    socialAcc.linkTitle = wechat
                                    socialAcc.linkUrl = wechat
                                    socialAcc.linkType = "WeChat"
                                    socialAccounts.append(socialAcc)
                                    wechatContactValue = wechat
                                }
                                if let direct = extractValue(forID: 5, from: self.connectedContactAccount) {
                                    directContactValue = direct
                                }
                                if let insta = extractValue(forID: 2, from: self.connectedContactAccount) {
                                    let socialAcc = SocialAccModel()
                                    
                                    let filteredSocialAccounts = socialAccounts.compactMap { $0.socialAccountId }
                                    if let maxId = filteredSocialAccounts.max() {
                                        socialAcc.socialAccountId = maxId + 1
                                    }
                                    socialAcc.linkTitle = insta
                                    socialAcc.linkUrl = insta
                                    socialAcc.linkType = "Instagram"
                                    socialAccounts.append(socialAcc)
                                    instagramContactValue = insta
                                }
                                if let msg = extractValue(forID: 6, from: self.connectedContactAccount) {
                                    kismmetMsgContactValue = msg
                                }
                            }
                            
                            baselineLinkedINContactValue = linkedInContactValue
                            baselineWhatsAppContactValue = whatsAppContactValue
                            baselineWechatContactValue = wechatContactValue
                            baselineDirectContactValue = directContactValue
                            baselineInstagramContactValue = instagramContactValue
                            baselinekismmetMsgContactValue = kismmetMsgContactValue

                            
                            
                            self.contactTV.reloadData()
                            self.contactTV.reloadRows(at: [IndexPath(row: 8, section: 0)], with: .none)

                            
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
    
    
    func addContacts() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        let contactTypes = ["LinkedIn", "WhatsApp", "WeChat", "Text/Call", "Instagram", "Other"]
        let contactValues = [linkedInContactValue, whatsAppContactValue, wechatContactValue, directContactValue, instagramContactValue, kismmetMsgContactValue]
        
        let filteredContacts = createContactEntries(for: contactTypes, contactValues: contactValues, includeIsShared: true)
        

        let pram : [String: Any] = ["contactInfoList": filteredContacts]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .addContact(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
                            AppFunctions.showSnackBar(str: "Information saved")
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
    
    
    func updateContactStatus() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        let contactTypes = ["LinkedIn", "WhatsApp", "WeChat", "Text/Call", "Instagram", "Other"]
        let contactValues = [linkedInContactValue, whatsAppContactValue, wechatContactValue, directContactValue, instagramContactValue, kismmetMsgContactValue]
        
        let filteredContacts = createContactEntries(for: contactTypes, contactValues: contactValues, includeIsShared: false)
        
        let pram : [String: Any] = ["contactInformations": filteredContacts,
                                    "contactId":contactId,
                                    "status":2]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .updateContactStatus(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
                            AppFunctions.showSnackBar(str: "Request accepted")
                            
                            if checkForChanges() {
                                self.presentVC(id: "DenyConfirmVC", presentFullType: "over" ) { (vc:DenyConfirmVC) in
                                    vc.contactAccounts = self.contactAccounts
                                    vc.linkedInContactValue = self.linkedInContactValue
                                    vc.whatsAppContactValue = self.whatsAppContactValue
                                    vc.wechatContactValue = self.wechatContactValue
                                    vc.directContactValue = self.directContactValue
                                    vc.instagramContactValue = self.instagramContactValue
                                    vc.kismmetMsgContactValue = self.kismmetMsgContactValue
                                    
                                    vc.orignalSelectedCheckArray = self.orignalSelectedCheckArray
                                }
                            } else {
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
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
extension ContactInformainVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactAccounts.count + 4
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
                cell.toolTipBtn.isHidden = false
                cell.tfView.isHidden = true
                if let userDb = userdbModel {
                    if let user = userDb.first {
                        
                        if isSetting {
                            
                            cell.textLbl.attributedText = NSAttributedString(string: "Contact Info you want to share", attributes:
                                                                                    [.font: UIFont(name: "Roboto", size: 14)!.bold, .foregroundColor: UIColor(hexFromString: "4E6E81")])
                            
                        } else {
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
                        }
                        
                    }
                }

                return cell
            case contactAccounts.count + 2:
                
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = true
                return cell
                
            case contactAccounts.count + 3:
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
                
                if contactAccounts[indexPath.row - 2].contactTypeId == 6 {
                    
                    let cell : ContactTextViewTVcell = tableView.dequeueReusableCell(withIdentifier: "ContactTextViewTVcell", for: indexPath) as! ContactTextViewTVcell
                                        
                    if !kismmetMsgContactValue.isEmpty {
                        cell.countLbl.text = "\(100 - kismmetMsgContactValue.count) / 100 remaining"
                        cell.generalTV.text = kismmetMsgContactValue//.isEmpty ? "" : status
                    } else {
                        cell.generalTV.addPlaceholder(contactAccounts[indexPath.row - 2].contactType, size: 14)
                        cell.countLbl.text = "100 / 100 remaining"
                    }
                    
                    //cell.socialPicIV.image = UIImage(named: "message")
                    cell.generalTV.tag = contactAccounts[indexPath.row - 2].contactTypeId
                    cell.countLbl.isHidden = false
                    cell.generalTV.delegate = self
                    cell.generalTV.textColor = UIColor(named: "Text grey")
                    cell.chkBtn.tag = contactAccounts[indexPath.row - 2].contactTypeId

                    if !AppFunctions.getSelectedCheckArray().isEmpty {
                        let selectedIds = AppFunctions.getSelectedCheckArray()
                        let currentContactTypeId = contactAccounts[indexPath.row - 2].contactTypeId
                        
                        if selectedIds.contains(currentContactTypeId!) {
                            cell.chkBtn.tintColor = UIColor(named: "Success")
                        } else {
                            cell.chkBtn.tintColor = UIColor.systemGray2
                        }
                    } else {
                        cell.chkBtn.tintColor = UIColor.systemGray2
                    }
                    
                    cell.chkBtn.addTarget(self, action: #selector(checkBtnPressed(sender:)), for: .touchUpInside)

                    if contactAccounts[indexPath.row - 2].icon != nil && contactAccounts[indexPath.row - 2].icon != "" {
                        let imageUrl = URL(string: contactAccounts[indexPath.row - 2].icon)
                        cell.socialPicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.socialPicIV.image = UIImage(named: "placeholder")
                    }
                    
                    return cell
                    
                } else {
                    let cell : ContactInfoTVCell = tableView.dequeueReusableCell(withIdentifier: "ContactInfoTVCell", for: indexPath) as! ContactInfoTVCell

                    cell.textLbl.isHidden = true
                    cell.toolTipBtn.isHidden = true
                    cell.tfView.isHidden = false
                    cell.chkBtn.tag = contactAccounts[indexPath.row - 2].contactTypeId
                    
                    cell.contactTF.selectedRowColor = UIColor(named: "warning")!
                    
                    cell.contactTF.handleKeyboard = true
                    cell.contactTF.isSearchEnable = true
                    
                    cell.contactTF.delegate = self
                    cell.contactTF.checkMarkEnabled = true
                    cell.contactTF.semanticContentAttribute = .forceLeftToRight
                    cell.contactTF.updatePadding(top: 0, left: 10, bottom: 0, right: 10)
                    cell.contactTF.textColor = UIColor(named: "Text grey")
                    
                    cell.contactTF.arrowSize = 8

                    cell.contactTF.font = UIFont(name: "Roboto", size: 14)?.bold
                    cell.contactTF.tag = contactAccounts[indexPath.row - 2].contactTypeId
                    
                    
                    //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                    //cell.contactTF.addGestureRecognizer(tapGesture)
                    
                    cell.contactTF.didSelect { [self] selectedText, index, id in
                        //cell.contactTF.text = "Selected String: \(selectedText) \n index: \(index) \n Id: \(id)"
                        Logs.show(message: "Selected String: \(selectedText) \n index: \(index) \n Id: \(id) \n tag: \(cell.contactTF.tag)")
                        //selectedContactValue =
                        
                        if cell.contactTF.tag == 1 {
                            linkedInContactValue = socialAccounts.filter {$0.socialAccountId == id}.first?.linkUrl ?? ""
                        } else if cell.contactTF.tag == 2 {
                            instagramContactValue = socialAccounts.filter {$0.socialAccountId == id}.first?.linkUrl ?? ""
                        } else if cell.contactTF.tag == 3 {
                            wechatContactValue = socialAccounts.filter {$0.socialAccountId == id}.first?.linkUrl ?? ""
                        }
                    }
                    
                    
                    if !AppFunctions.getSelectedCheckArray().isEmpty {
                        let selectedIds = AppFunctions.getSelectedCheckArray()
                        let currentContactTypeId = contactAccounts[indexPath.row - 2].contactTypeId
                        
                        if selectedIds.contains(currentContactTypeId!) {
                            cell.chkBtn.tintColor = UIColor(named: "Success")
                        } else {
                            cell.chkBtn.tintColor = UIColor.systemGray2
                        }
                    } else {
                        cell.chkBtn.tintColor = UIColor.systemGray2
                    }
                    
                    var socialObjArr = [SocialAccModel]()
                    
                    switch contactAccounts[indexPath.row - 2].contactTypeId {
                        case 1:
                            //cell.socialPicIV.image = UIImage(named: "LinkedIn")
                            cell.contactTF.keyboardType = .default
                            
                            socialObjArr = socialAccounts.filter {$0.linkType == "LinkedIn"}
                            cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                            cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                            
                            cell.contactTF.arrowColor = UIColor(named: "Text grey")!
                            cell.contactTF.arrowSize = 8
                            
                            if linkedInContactValue.isEmpty {
                                if socialObjArr.count <= 1 {
                                    cell.contactTF.text = socialObjArr.first?.linkUrl
                                    linkedInContactValue = socialObjArr.first?.linkUrl ?? ""
                                }
                            } else {
                                cell.contactTF.text = linkedInContactValue
                            }
                            
                        case 2:
                            
                            cell.contactTF.keyboardType = .default
                            
                            socialObjArr = socialAccounts.filter {$0.linkType == "Instagram"}
                            cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                            cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                            
                            cell.contactTF.arrowColor = UIColor(named: "Text grey")!
                            
                            if instagramContactValue.isEmpty {
                                if socialObjArr.count <= 1 {
                                    cell.contactTF.text = socialObjArr.first?.linkUrl
                                    instagramContactValue = socialObjArr.first?.linkUrl ?? ""
                                }
                            } else {
                                cell.contactTF.text = instagramContactValue
                            }
                            
                        case 3:
                            //cell.socialPicIV.image = UIImage(named: "WeChat")
                            cell.contactTF.keyboardType = .phonePad
                            
                            socialObjArr = socialAccounts.filter {$0.linkType == "WeChat"}
                            cell.contactTF.optionArray = socialObjArr.compactMap {$0.linkTitle}
                            cell.contactTF.optionIds = socialObjArr.compactMap {$0.socialAccountId}
                            
                            cell.contactTF.arrowColor = UIColor(named: "Text grey")!
                            
                            if wechatContactValue.isEmpty {
                                if socialObjArr.count <= 1 {
                                    cell.contactTF.text = socialObjArr.first?.linkUrl
                                    wechatContactValue = socialObjArr.first?.linkUrl ?? ""
                                }
                            } else {
                                cell.contactTF.text = wechatContactValue
                            }
                        case 4:
                            
                            //cell.socialPicIV.image = UIImage(named: "whatsapp")
                            cell.contactTF.keyboardType = .phonePad
                            
                            cell.contactTF.arrowColor = .clear
                            
                            if !whatsAppContactValue.isEmpty {
                                cell.contactTF.text = whatsAppContactValue
                            } else {
                                cell.contactTF.text = ""
                            }
                           
                        case 5:
                            //cell.socialPicIV.image = UIImage(named: "Instagram")
                            //cell.socialPicIV.image = UIImage(named: "phone")
                            cell.contactTF.keyboardType = .phonePad
                            
                            cell.contactTF.arrowColor = .clear
                            
                            if !directContactValue.isEmpty {
                                cell.contactTF.text = directContactValue
                            } else {
                                cell.contactTF.text = ""
                            }

                        default:
                            print("default")
                    }
                    
                    cell.chkBtn.addTarget(self, action: #selector(checkBtnPressed(sender:)), for: .touchUpInside)

                    if contactAccounts[indexPath.row - 2].icon != nil && contactAccounts[indexPath.row - 2].icon != "" {
                        let imageUrl = URL(string: contactAccounts[indexPath.row - 2].icon)
                        cell.socialPicIV?.sd_setImage(with: imageUrl , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
                    } else {
                        cell.socialPicIV.image = UIImage(named: "placeholder")
                    }
                    
                    cell.contactTF.placeholder = contactAccounts[indexPath.row - 2].contactType
                    AppFunctions.colorPlaceholder(tf: cell.contactTF, s: contactAccounts[indexPath.row - 2].contactType)
                    return cell
                }
                
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == contactAccounts.count + 2 {
            return 20
        } else {
            return UITableView.automaticDimension
        }

    }
}
