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

    
    @IBOutlet weak var saveBtn: RoundCornerButton!
    @IBOutlet weak var cancelBtn: RoundCornerButton!
    @IBOutlet weak var selectedlink: UIView!
    @IBOutlet weak var mainViewHightConst: NSLayoutConstraint!
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto", size: 16)?.medium
        label.textAlignment = .left
        label.textColor = UIColor(named: "Text grey")
        label.numberOfLines = 0
        return label
    }()
    
    
    
    @IBAction func nameToolTip(_ sender: Any) {
        var msg = ""
        if accountType == "tags" {
            msg = "Please enter and save one interest-tag at a time.\nNo # hashtag is required before the word/words.\nMax 30 characters per tag."
        } else {
            msg = "Choose a name for your link that will be shown next to the icon on your profile. Use your username or something that helps others recognize you easily."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender as! UIButton)

    }
    @IBAction func toolTipLink(_ sender: Any) {
        let msg = "Enter the appropriate link based on the type you've chosen. For social media accounts like Twitter, Instagram, and Snapchat, enter your username without the '@' symbol. For LinkedIn, Facebook, and Reddit, use the username found at the end of the URL link. For websites, enter the full URL."
        AppFunctions.showToolTip(str: msg, btn: sender as! UIButton)
    }
    
    @IBAction func linkToolTip(_ sender: Any) {
        AppFunctions.openWebLink(link: "https://www.kismmet.com/howtolink", vc: self)
    }
    
    @IBAction func dropDownBtnPressed(_ sender: Any) {
            dropDown.show()
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        if accountType == "tags" {
            self.dismiss(animated: true)
        } else {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
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
    @IBOutlet weak var cancelBottomConst: NSLayoutConstraint!
    @IBOutlet weak var saveBottomConst: NSLayoutConstraint!
    @IBOutlet weak var headingTopConst: NSLayoutConstraint!
    @IBOutlet weak var headingLblHeightConst: NSLayoutConstraint!
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
    var socialLink = SocialAccDBModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        socialAccName = socialAccounts.compactMap { $0.linkType }
        
        //setupDropDown()
        
        
        self.view.addBlurEffect(style: .extraLight, cornerRadius: 0, alpha: 0.5)
        
        self.view.bringSubviewToFront(mainView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tap)
        
       
        
        addAccName.delegate = self
        addAccLink.delegate = self
        addAccName.addDoneButtonOnKeyboard()
        addAccLink.addDoneButtonOnKeyboard()
        
        selectedlink.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        let imageUrl = URL(string: socialLink.linkImage)
        imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage()) { (image, error, imageCacheType, url) in
            if let image = image {
                self.imageView.image = image
            }
        }
        
        label.text = socialLink.linkType
        linkId = socialLink.linkTypeId
        
        configureConstraints()

        
        if socialLink.linkType == "Website" {
            self.addAccName.placeholder = "Name your website link"
            self.addAccLink.placeholder = "Enter your website’s full URL"
        } else {
            self.addAccName.placeholder = "Name it"
            self.addAccLink.placeholder = "Link it"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if accountType == "tags" {
            
            addAccName.delegate = self
            createNonDisappearingPlaceholder(for: addAccName, placeholderText: "#", font: UIFont.systemFont(ofSize: 16), color: UIColor(named: "Secondary Grey")!)

            headingLbl.text = "Find people with similar interests by searching tags in the feed. Choose 5 tags that represent you, your hobbies, and your passions."
            headingLbl.numberOfLines = 0
            addAccName.placeholder = "Enter tag here"
            accountTypeView.isHidden = true
            adAccLink.isHidden = true
            saveBottomConst.constant = 50
            cancelBottomConst.constant = 50
            headingLblHeightConst.constant = 52
            headingTopConst.constant = 12

            selectedlink.isHidden = true
            
                        
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

    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.topAnchor.constraint(equalTo: selectedlink.topAnchor, constant: 5), // Padding
            containerView.bottomAnchor.constraint(equalTo: selectedlink.bottomAnchor, constant: -5), // Padding
            
            // Image View Constraints
            imageView.leadingAnchor.constraint(equalTo: selectedlink.leadingAnchor, constant: 10), // Padding
            imageView.centerYAnchor.constraint(equalTo: selectedlink.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: selectedlink.heightAnchor, multiplier: 0.7),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0), // Assuming a square image, adjust the multiplier as needed
            
            // Label Constraints
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8), // Adjust constant for spacing
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: selectedlink.trailingAnchor, constant: -10), // Adjust for padding
            label.heightAnchor.constraint(equalTo: selectedlink.heightAnchor, multiplier: 0.7) // Adjust multiplier as needed
        ])
        
        // Set the width of selectedlink based on the intrinsic content size of the label plus the width of the imageView and padding
        let labelWidth = socialLink.linkType.size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "Roboto", size: 14)?.regular as Any]).width
        let totalWidth = labelWidth + imageView.frame.size.width + 60 + 10
        selectedlink.widthAnchor.constraint(equalToConstant: totalWidth).isActive = true
        
        // Apply rounded corners and border to the contentView
        selectedlink.layer.cornerRadius = 14 // Adjust for desired roundness
        selectedlink.layer.borderWidth = 1.2
        selectedlink.addShadow()
        selectedlink.layer.borderColor = UIColor(named: "Secondary Grey")?.cgColor
        selectedlink.clipsToBounds = true
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if accountType != "tags" {
            return true
        }
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return updatedText.count <= 30
        /*let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return !updatedText.contains(" ")*/
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
            } else {
                self?.addAccName.placeholder = "Name it"
                self?.addAccLink.placeholder = "Link it"
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

/*extension AddLinksVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialAccounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialLinkCell", for: indexPath) as! SocialLinkCell
        let socialLink = socialAccounts[indexPath.item]
        cell.configure(with: socialLink.linkImage, text: socialLink.linkType)
        return cell
    }
    
}

extension SocialLinkVC: UICollectionViewDelegateFlowLayout {
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 return CGSize(width: socialAccounts[indexPath.item].linkType.size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "Roboto", size: 14)?.regular as Any]).width + 25, height: 30)
 }
 
 }*/
