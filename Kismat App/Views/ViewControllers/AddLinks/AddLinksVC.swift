//
//  AddLinksVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit
import SDWebImage
import DropDown

class AddLinksVC: MainViewController {

    
    
    @IBAction func dropDownBtnPressed(_ sender: Any) {
            dropDown.show()
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        if accountType == "tags" {
            if accountName != "" {
                isUpdatedOnServer = true
                self.dismiss(animated: true)
                return
            } else {
                AppFunctions.showSnackBar(str: "All fields are required")
            }
        } else {
            if accountName != "" && accountLink != "" && linkId != 0 {
                userSocialAdd()
            } else {
                AppFunctions.showSnackBar(str: "All fields are required")
            }
        }
        
    }
    
    @IBOutlet weak var mainView: RoundCornerView!
    @IBOutlet weak var saveBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var addAccView: RoundCornerView!
    @IBOutlet weak var accountTypeView: RoundCornerView!
    @IBOutlet weak var addAccName: FormTextField!
    @IBOutlet weak var adAccLink: RoundCornerView!
    @IBOutlet weak var addAccLink: FormTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    var isKeyBoardShown = false
    var isUpdatedOnServer = false
    var accountType = ""
    var accountName = ""
    var accountLink = ""
    var linkId = 0
    let dropDown = DropDown()

    var socialAccName = [String()] //["LinkedIn","Twitter","Instagram","Snapchat","Website"]
    var socialAccounts = [SocialAccDBModel()]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        socialAccName = socialAccounts.compactMap { $0.linkType }
        
        setupDropDown()
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
        
        if accountType == "tags" {
            adAccLink.isHidden = true
            headingLbl.text = "Tags are what describe you in here"
            addAccName.placeholder = "Enter tag here"
            accountTypeView.isHidden = true
            saveBtnTopConst.constant = 120
            cancelBtnTopConst.constant = 120
            view.setNeedsLayout()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if accountName == "" { return }
        
        if accountType == "tags" {
            if !isUpdatedOnServer { return }
            var arr = AppFunctions.getTagsArray()
            if arr.count >= 5 { return }
            arr.append(accountName)
            AppFunctions.setTagsArray(value: arr)
            generalPublisher.onNext("tagsAdded")
        }
    }
    
    func addToArrays(index: Int) {
        
        if !isUpdatedOnServer { return }
        var arr = AppFunctions.getSocialArray()
        
        let placeholderValues = ["LinkedIn Profile","Twitter Username","Instagram Handle","Snapchat Username","Website URL"]
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
    
    func setupDropDown() {
        
        dropDown.hide()
        dropDown.anchorView = dropDownBtn // UIView or UIBarButtonItem
        dropDown.dataSource = socialAccName
        dropDown.direction = .bottom
        
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 50
        appearance.backgroundColor = UIColor(named: "BG Base White")
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.separatorColor = UIColor(named: "Secondary Grey")!
        appearance.cornerRadius = 10
        //appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        //appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 15
        appearance.animationduration = 0.25
        appearance.textColor = UIColor(named: "Text grey")!
        appearance.textFont = UIFont(name: "Work Sans", size: 20)!
        appearance.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            let account = self?.socialAccounts[index]

            self?.dropDownBtn.setTitle("  \(item)", for: .normal)
            self?.linkId = account?.linkTypeId ?? 0
            if account?.linkImage != "" {
                let imageUrl = URL(string: account?.linkImage ?? "")
                
                // Create the transformer with the desired size and scale mode
                let transformer = SDImageResizingTransformer(size: CGSize(width: 20, height: 20), scaleMode: .aspectFit)

                self?.dropDownBtn.sd_setImage(with: imageUrl, for: .normal, placeholderImage: UIImage(named: "Website")?.resized(to: CGSize(width: 20, height: 20)), context: [.imageTransformer: transformer]) { (image, error, imageCacheType) in
                    // Perform any additional actions after the image is set
                }
            } else {
                self?.dropDownBtn.setImage(UIImage(named: "Website")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
            }
                        
        }
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
    
    func userSocialAdd() {
        self.showPKHUD(WithMessage: "Signing up")
        
        let pram : [String : Any] = [ "linkTitle": accountName,
                                      "linkURL": accountLink,
                                      "linkTypeId": linkId
        ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userSocialAdd(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.isUpdatedOnServer = true
                            self.dismiss(animated: true)
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
