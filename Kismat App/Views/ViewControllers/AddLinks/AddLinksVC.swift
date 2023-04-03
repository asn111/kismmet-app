//
//  AddLinksVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit

class AddLinksVC: MainViewController {

    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        isUpdatedOnServer = true
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var mainView: RoundCornerView!
    @IBOutlet weak var saveBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var addAccView: RoundCornerView!
    @IBOutlet weak var addAccName: FormTextField!
    @IBOutlet weak var adAccLink: RoundCornerView!
    @IBOutlet weak var addAccLink: FormTextField!
    
    var isKeyBoardShown = false
    var isUpdatedOnServer = false
    var accountType = ""
    var accountName = ""
    var accountLink = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addBlurEffect(style: .extraLight, cornerRadius: 0, alpha: 0.5)
        
        self.view.bringSubviewToFront(mainView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tap)
        
        addAccName.delegate = self
        addAccLink.delegate = self
        addAccName.addDoneButtonOnKeyboard()
        addAccLink.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        switch accountType {
            case "linkedIn":
                headingLbl.text = "Increase your connection through LinkedIn"
                addAccName.placeholder = "Enter LinkedIn Username"
            case "twitter":
                headingLbl.text = "Share your Twitter account"
                addAccName.placeholder = "Enter Twitter Username"
            case "instagram":
                headingLbl.text = "Get followers through your Instagram handle"
                addAccName.placeholder = "Enter Instagram Username"
            case "snapchat":
                headingLbl.text = "Your Snapchat account"
                addAccName.placeholder = "Enter Snapchat Username"
            case "website":
                adAccLink.isHidden = true
                headingLbl.text = "Get reach on your Website"
                addAccName.placeholder = "Enter your Website link"
                saveBtnTopConst.constant = 80
                cancelBtnTopConst.constant = 80
                view.setNeedsLayout()
            case "tags":
                adAccLink.isHidden = true
                headingLbl.text = "Tags are what describe you in here"
                addAccName.placeholder = "Enter tag here"
                saveBtnTopConst.constant = 80
                cancelBtnTopConst.constant = 80
                view.setNeedsLayout()
            default :
                print("default")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if accountName == "" { return }
        
        switch accountType {
            case "linkedIn":
                addToArrays(index: 0)
            case "twitter":
                addToArrays(index: 1)
            case "instagram":
                addToArrays(index: 2)
            case "snapchat":
                addToArrays(index: 3)
            case "website":
                addToArrays(index: 4)
            case "tags":
                if !isUpdatedOnServer { return }
                var arr = AppFunctions.getTagsArray()
                if arr.count >= 5 { return }
                arr.append(accountName)
                AppFunctions.setTagsArray(value: arr)
                generalPublisher.onNext("tagsAdded")
            default :
                print("default")
        }
    }
    
    func addToArrays(index: Int) {
        
        if !isUpdatedOnServer { return }
        var arr = AppFunctions.getSocialArray()
        
        let placeholderValues = ["Network via LinkedIn","Your Twitter account","Your Instagram handle","Snapchat","Link your Website"]
        // Initialize the array with placeholder values if it's empty
        if arr.isEmpty {
            arr = placeholderValues
        }
        // If the index is out of bounds, pad the array with empty strings
        while index >= arr.count {
            arr.append("")
        }
        // Update the value at the specified index
        arr[index] = accountName
        
        AppFunctions.setSocialArray(value: arr)
        generalPublisher.onNext("socialAdded")
        
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == addAccName {
            accountName = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField == addAccLink {
            accountLink = !textField.text!.isTFBlank ? textField.text! : ""
        }
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyBoardShown {
                isKeyBoardShown = true
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyBoardShown = false
        self.view.frame.origin.y = 0
    }
}
