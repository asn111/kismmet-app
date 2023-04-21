//
//  ProfileSetupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class ProfileSetupVC: MainViewController  {

    @IBOutlet weak var profileTV: UITableView!
        
    var placeholderArray = ["","Full Name","Public Email","Phone","Date of Birth","Where do you work / study?","Work Title","Tell us about your self..",""]
    
    weak var activeTextField: UITextField?
    weak var activeTextView: UITextView?
    
    var updatedImagePicked : UIImage!
    var profileDict = [String: Any]()
    var fullName = "", publicEmail = "", placeOfWork = "", workTitle = "" , dateOfBirth = "", countryCode = "", phoneNum = "" , about = "", profilePic = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "imageUpdate" {
                if self?.updatedImagePicked != nil {
                    self?.profileTV.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            } else if val.contains("+") {
                self?.countryCode = val
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
        profileTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")
        profileTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
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
    
    @objc func updateDateField(sender: UIDatePicker) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
        
        cell.generalTF.text = formatDateForDisplay(date: sender.date)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        self.view.endEditing(true)
        

        Logs.show(message: "\(fullName), \(publicEmail), \(countryCode), \(dateOfBirth), \(phoneNum), \(placeOfWork), \(workTitle), \(about)")
        if fullName != "" && publicEmail != "" && countryCode != "" && phoneNum != "" && dateOfBirth != "" && placeOfWork != "" && workTitle != "" {
            
            if updatedImagePicked != nil {
                profilePic = AppFunctions.convertImageToBase64(image: updatedImagePicked)
            }
            
            profileDict["fullName"] = fullName
            profileDict["profilePicture"] = profilePic
            profileDict["publicEmail"] = publicEmail
            profileDict["countryCode"] = countryCode
            profileDict["phoneNumber"] = phoneNum
            profileDict["dob"] = dateOfBirth
            profileDict["workAdress"] = placeOfWork
            profileDict["workTitle"] = workTitle
            profileDict["about"] = about
            
            self.pushVC(id: "ProfileSetupExtend") { (vc:ProfileSetupExtend) in
                vc.profileDict = self.profileDict
            }

        } else {
            AppFunctions.showSnackBar(str: "Please add all fields.")
        }
    }
    
    @objc func backBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func editBtnPressed(sender:UIButton) {
        let imagePickerClass = ImagePicker(viewController: self)
        imagePickerClass.handleTap()
    }
    
    @objc func toolTipBtnPressed(sender:UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Please note that this email is visible to other users on the app."
        } else if sender.tag == 002 {
            msg = "The lock icon next to your phone number indicates that this number cannot be changed. Please ensure that you have entered the correct phone number during the registration process."
        } else if sender.tag == 003 {
            msg = "Please note that your date of birth is private and will not be visible to other users on the app."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender)
    }

    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        
        activeTextField = textField
        
        if textField.tag == 1 {
            fullName = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 2 {
            publicEmail = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 3 {
            phoneNum = textField.text!.isValidPhoneNumber ? textField.text! : ""
        } else if textField.tag == 5 {
            placeOfWork = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField.tag == 6 {
            workTitle = !textField.text!.isTFBlank ? textField.text! : ""
        }
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
        if textView.text == "Tell us about your self.." {
            // Clear the text view
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        about = !textView.text!.isTFBlank ? textView.text! : ""
        activeTextView = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 6 {
            textField.returnKeyType = .done
        } else {
        }
        if textField.tag == 4 {
            
            let indexPath = IndexPath(row: textField.tag, section: 0)
            let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTVCell
            cell.generalTF = textField as? FormTextField
            
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                picker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            picker.minimumDate = Calendar.current.date(byAdding: .year, value: -70, to: Date())
            picker.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
            
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    fileprivate func formatDateForDisplay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
    
    @objc func tapDone(sender: Any, datePicker1: UIDatePicker) {
        let indexPath = IndexPath(row: 4, section: 0)
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
                cell.generalTV.text = "Tell us about your self.."
                return cell
                
            default:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                if placeholderArray[indexPath.row] == "Phone" {
                    cell.numberView.isHidden = false
                    cell.numberTF.tag = indexPath.row
                    cell.numberTF.delegate = self
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode()
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
                if placeholderArray[indexPath.row] == "Public Email" {
                    cell.toolTipBtn.isHidden = false
                    cell.toolTipBtn.tag = 001
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                    cell.generalTF.keyboardType = .emailAddress
                } else if placeholderArray[indexPath.row] == "Date of Birth" {
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

