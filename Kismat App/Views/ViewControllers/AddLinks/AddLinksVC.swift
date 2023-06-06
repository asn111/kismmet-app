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
            
            addAccName.delegate = self
            createNonDisappearingPlaceholder(for: addAccName, placeholderText: "#", font: UIFont.systemFont(ofSize: 16), color: UIColor(named: "Secondary Grey")!)

            adAccLink.isHidden = true
            headingLbl.text = "Find people with similar interests by searching tags in the feed. Choose 5 tags that represent you, your hobbies, and your passions."
            addAccName.placeholder = "Enter tag here"
            accountTypeView.isHidden = true
            saveBtnTopConst.constant = 120
            cancelBtnTopConst.constant = 120
            view.setNeedsLayout()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        if accountType == "tags" {
            if !isUpdatedOnServer { return }
            var arr = AppFunctions.getTagsArray()
            if arr.count >= 5 { return }
            arr.append(accountName)
            AppFunctions.setTagsArray(value: arr)
            generalPublisher.onNext("tagsAdded")
        } else {
            generalPublisher.onNext("socialAdded")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if accountType != "tags" {
            return true
        }
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return !updatedText.contains(" ")
    }
    
    func createNonDisappearingPlaceholder(for textField: UITextField, placeholderText: String, font: UIFont, color: UIColor) {
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        let placeholderLabel = UILabel()
        placeholderLabel.attributedText = attributedPlaceholder
        placeholderLabel.sizeToFit()
        
        textField.leftView = placeholderLabel
        textField.leftViewMode = .always
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
            
            if item == "Website" {
                self?.addAccName.placeholder = "Name your website link"
                self?.addAccLink.placeholder = "Enter your website’s full URL"
            }
            
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
