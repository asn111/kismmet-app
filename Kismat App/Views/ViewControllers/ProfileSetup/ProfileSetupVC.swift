//
//  ProfileSetupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import CDAlertView

class ProfileSetupVC: MainViewController  { //Birthday

    @IBOutlet weak var profileTV: UITableView!
        
    var placeholderArray = ["","First Name *","Last Name *","Public Email *","Phone *","Birthday *","Where do you work / study? *","Work Title *","Bio.. *",""]
    
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?
    
    var limitExceed = false
    
    var updatedImagePicked : UIImage!
    var profileDict = [String: Any]()
    var firstName = "", lastName = "", publicEmail = "", placeOfWork = "", workTitle = "" , dateOfBirth = "", countryCode = "", countryName = "", phoneNum = "" , about = "", profilePic = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        getSocialAccounts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "imageUpdate" {
                if self?.updatedImagePicked != nil {
                    self?.profileTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        _ = generalPublisherCountry.subscribe(onNext: {[weak self] val in
            
            self?.countryCode = val.phoneCode
            self?.countryName = val.name
            
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "ProfileHeaderTVCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        profileTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")
        profileTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
    func showAlert(){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to exit the setup?", type: .warning)
        let action = CDAlertViewAction(title: "Yes",
                                       handler: {[weak self] action in
            AppFunctions.resetDefaults2()
            DBService.removeCompletedDB()
            self?.navigateVC(id: "SplashVC") { (vc:SplashVC) in }
            return true
        })
        let cancel = CDAlertViewAction(title: "Cancel",
                                       handler: { action in
            print("CANCEL PRESSED")
            return true
        })
        alert.isTextFieldHidden = true
        alert.add(action: action)
        alert.add(action: cancel)
        alert.hideAnimations = { (center, transform, alpha) in
            transform = .identity
            alpha = 0
        }
        alert.show() { (alert) in
            print("completed")
        }
    }
    
    //MARK: OBJC Methods

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
    
    @objc func genBtnPressed(sender:UIButton) {
        self.view.endEditing(true)
        
        if limitExceed {
            AppFunctions.showSnackBar(str: "Maximum character limit exceeded for your bio!\nPlease keep it under 4000")
            return
        }
        Logs.show(message: "\(firstName), \(lastName), \(publicEmail), \(countryCode), \(phoneNum), \(dateOfBirth), \(placeOfWork), \(workTitle), \(about)")
        if firstName != "" && lastName != "" && publicEmail != "" && countryCode != "" && phoneNum != "" && dateOfBirth != "" && placeOfWork != "" && workTitle != "" {
            
            if updatedImagePicked != nil {
                profilePic = AppFunctions.convertImageToBase64(image: updatedImagePicked)
            } else {
                AppFunctions.showSnackBar(str: "Profile Picture is mandatory")
                return
            }
            
            profileDict["firstName"] = firstName
            profileDict["lastName"] = lastName
            profileDict["profilePicture"] = profilePic
            profileDict["publicEmail"] = publicEmail
            profileDict["countryCode"] = countryCode
            profileDict["countryName"] = countryName
            profileDict["phoneNumber"] = phoneNum
            profileDict["dob"] = dateOfBirth
            profileDict["workAdress"] = placeOfWork
            profileDict["workTitle"] = workTitle
            profileDict["about"] = about
            
            self.pushVC(id: "ProfileSetupExtend") { (vc:ProfileSetupExtend) in
                vc.profileDict = self.profileDict
            }

        } else {
            AppFunctions.showSnackBar(str: "Please fill out all the mandatory fields")
        }
    }
    
    @objc func backBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func powerBtnPressed(sender:UIButton) {
        showAlert()
    }
    
    
    @objc func editBtnPressed(sender:UIButton) {
        let imagePickerClass = ImagePicker(viewController: self)
        imagePickerClass.handleTap()
    }
    
    @objc func toolTipBtnPressed(sender:UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Add an optional email address to your profile for convenient connections.\nMuch like you would on a business card.\nNote: It will be visible on your profile."
        } else if sender.tag == 002 {
            msg = "The lock icon next to your phone number means that the number cannot be changed.\nYour phone number is not visible to others."
        } else if sender.tag == 003 {
            msg = "Please note that your date of birth is private and will not be visible to other users on the app."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
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
        } else if textField.tag == 2 {
            lastName = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 3 {
            publicEmail = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 4 {
            phoneNum = textField.text!.isValidPhoneNumber ? textField.text! : ""
        } else if textField.tag == 6 {
            placeOfWork = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 7 {
            workTitle = !textField.text!.isTFBlank ? textField.text! : ""
        }
        
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if textView.text == "Bio.. *" {
            // Clear the text view
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        about = !textView.text!.isTFBlank ? textView.text! : ""
        activeTextView = nil
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
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 7 {
            textField.returnKeyType = .done
        } else {
        }
        if textField.tag == 5 {
            
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
    
    
    //MARK: UIPickerView Methods
    
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    @objc func tapDone(sender: Any, datePicker1: UIDatePicker) {
        let indexPath = IndexPath(row:5, section: 0)
        let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
        print(datePicker1)
        if let datePicker = cell.generalTF.inputView as? UIDatePicker { // 2.1
            let dateformatter = DateFormatter() // 2.2
            dateformatter.dateStyle = .long // 2.3
            dateformatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            !cell.generalTF.text!.isTFBlank ? dateOfBirth = dateformatter.string(from: datePicker.date) : print("Empty Date")
        }
        cell.generalTF.resignFirstResponder() // 2.5
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
    
    
    //MARK: API Method
    
    func getSocialAccounts() {
        
        APIService
            .singelton
            .getSocialAccounts()
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
    
}
//MARK: TableView Extention
extension ProfileSetupVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTVCell", for: indexPath) as! ProfileHeaderTVCell

                if updatedImagePicked != nil {
                    cell.profileIV.image = updatedImagePicked
                    Logs.show(message: "Updated")
                } else {
                    cell.profileIV.image = UIImage(named: "placeholder_icon")
                }
                cell.powerBtn.isHidden = false
                
                cell.powerBtn.addTarget(self, action: #selector(powerBtnPressed(sender:)), for: .touchUpInside)
                
                cell.editBtn.addTarget(self, action: #selector(editBtnPressed(sender:)), for: .touchUpInside)
                return cell
            case placeholderArray.count - 1 :
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell

                    cell.genBtn.setTitle("Continue", for: .normal)
                
                cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                return cell
            case placeholderArray.count - 2 :
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                cell.generalTV.delegate = self
                cell.generalTV.tag = indexPath.row
                cell.generalTV.text = "Bio.."
                return cell
                
            default:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                if placeholderArray[indexPath.row] == "Phone *" {
                    cell.numberView.isHidden = false
                    cell.numberTF.tag = indexPath.row
                    cell.numberTF.delegate = self
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode(name: "United States")
                    cell.numberTF.keyboardType = .phonePad
                    cell.numberTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])
                    cell.lockTipBtn.tag = 002
                    
                    cell.lockTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)

                } else {
                    cell.numberView.isHidden = true
                    cell.generalTFView.isHidden = false
                    cell.generalTF.tag = indexPath.row
                    cell.generalTF.delegate = self
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])

                }
                if placeholderArray[indexPath.row] == "Public Email *" {
                    cell.toolTipBtn.isHidden = false
                    cell.toolTipBtn.tag = 001
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                    cell.generalTF.keyboardType = .emailAddress
                } else if placeholderArray[indexPath.row] == "Birthday *" {
                    cell.toolTipBtn.isHidden = false
                    cell.toolTipBtn.tag = 003
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                } else {
                    cell.toolTipBtn.isHidden = true
                }
                
                return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

