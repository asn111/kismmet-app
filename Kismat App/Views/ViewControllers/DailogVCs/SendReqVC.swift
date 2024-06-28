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
        sendReq()
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
        
        let pram : [String : Any] = ["userId": userModel.userId ?? "", "text": sentMsg]
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
                            AppFunctions.showSnackBar(str: "Your contact request is sent")
                            
                            self.presentVC(id: "ReqSentVC", presentFullType: "over" ) { (vc:ReqSentVC) in
                                vc.userId = self.userModel.userId
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
