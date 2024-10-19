//
//  SendReqVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 25/06/2024.
//

import UIKit

class SendReqVC: MainViewController {

    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        /*self.presentVC(id: "ContactInformainVC", presentFullType: "over" ) { (vc:ContactInformainVC) in
            //vc.contactId = userModel.contactId
            vc.isOwnInfo = true
            vc.sentMsg = sentMsg
            vc.userdId = userModel.userId
            vc.isStarred = userModel.isStarred
        }*/
        sendReq()
        /*self.presentVC(id: "ReqSentVC", presentFullType: "over" ) { (vc:ReqSentVC) in
            vc.userId = self.userModel.userId
        }*/
    }
    
    @IBOutlet weak var placeholderIV: UIImageView!
    @IBOutlet weak var profilePicIV: RoundCornerButton!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var workLocLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    @IBOutlet weak var msgTextView: FormTextView!
    
    var userModel = UserModel()
    var img = UIImage(named: "placeholder")
    
    var sentMsg = ""
    var limitExceed = false
    var isKeyBoardShown = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        nameLbl.text = userModel.userName
        proffLbl.text = userModel.workTitle
        workLocLbl.text = userModel.workAddress
        
        if userModel.profilePicture != "" && userModel.profilePicture != nil {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicIV?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
        } else {
            profilePicIV.setImage(img, for: .normal)
        }
        
        msgTextView.delegate = self
        msgTextView.textColor = UIColor(named: "Text grey")
        msgTextView.inputAccessoryView = createToolbar()

        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "exitView" {
                self?.dismiss(animated: true)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        generalPublisher.onNext("exitView")
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let frameInWindow = view.superview?.convert(msgTextView.frame, to: nil)
        let bottomOfTextField = frameInWindow?.maxY ??  0
        let topOfKeyboard = UIScreen.main.bounds.height/2 - keyboardSize.height
        
        if bottomOfTextField > topOfKeyboard && self.view.frame.origin.y >=  0 {
            self.view.frame.origin.y -= bottomOfTextField - topOfKeyboard
            placeholderIV.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyBoardShown = false
        if msgTextView.text == "" {
            placeholderIV.isHidden = false
        } else {
            placeholderIV.isHidden = true
        }
        self.view.frame.origin.y = 0
    }
    
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style:.done, target: self, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    @objc func doneButtonTapped() {
        if msgTextView.text == "" {
            placeholderIV.isHidden = false
        } else {
            placeholderIV.isHidden = true
        }
        msgTextView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "" {
            placeholderIV.isHidden = false
        } else {
            placeholderIV.isHidden = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeholderIV.isHidden = false
        } else {
            placeholderIV.isHidden = true
        }
        sentMsg = !textView.text!.isTFBlank ? textView.text! : ""
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
    
    //MARK: API METHODS
    
    func sendReq() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        var pram : [String: Any]
        
        pram = ["userId": self.userModel.userId as Any,
                "message": sentMsg]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .sendUserContactRequest(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
                            //AppFunctions.showSnackBar(str: "Your contact request is sent")
                            
                            self.presentVC(id: "ReqSentVC", presentFullType: "over" ) { (vc:ReqSentVC) in
                                vc.userId = self.userModel.userId
                                vc.isStarred = self.userModel.isStarred
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
