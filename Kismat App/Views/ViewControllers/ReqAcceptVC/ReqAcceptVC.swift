//
//  ReqAcceptVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit

class ReqAcceptVC: MainViewController {

    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func contactBtnPressed(_ sender: Any) {
        
        if userModel.contactInformationsSharedByUser != nil {
            if userModel.contactInformationsSharedByUser.count > 0 {
                self.presentVC(id: "ContactListVC", presentFullType: "over" ) { (vc:ContactListVC) in
                    vc.userModel = userModel
                }
            } else {
                AppFunctions.showSnackBar(str: "This user has not shared any contact information yet.")
            }
        } else if let userContacts = userModel.userContacts {
            if userContacts.contactInformationsSharedByUser != nil {
                if userContacts.contactInformationsSharedByUser.count > 0 {
                    self.presentVC(id: "ContactListVC", presentFullType: "over" ) { (vc:ContactListVC) in
                        vc.userModel = userModel
                    }
                } else {
                    AppFunctions.showSnackBar(str: "This user has not shared any contact information yet.")
                }
            }
        } else {
            AppFunctions.showSnackBar(str: "This user has not shared any contact information yet.")
        }
        
    }
    
    @IBAction func viewProfileBtnPressed(_ sender: Any) {
        
        self.presentVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
            vc.userId = userModel.userId
            vc.isFromAccepDialog = true
            vc.isFromReq = true
        }
    }
    
    @IBAction func accpetBtnPressed(_ sender: Any) {
        updateContactStatus()
        /*if let contactId = userModel.contactId {
            self.presentVC(id: "ContactInformainVC", presentFullType: "over" ) { (vc:ContactInformainVC) in
                vc.contactId = userModel.contactId
            }
        } else if let userContact = userModel.userContacts {
            if let contactId = userContact.id {
                self.presentVC(id: "ContactInformainVC", presentFullType: "over" ) { (vc:ContactInformainVC) in
                    vc.contactId = contactId
                }
            }
        }*/
    }
    
    @IBAction func denyBtnPressed(_ sender: Any) {
        if let contactId = userModel.contactId {
            self.presentVC(id: "DenyConfirmVC", presentFullType: "over" ) { (vc:DenyConfirmVC) in
                vc.contactId = userModel.contactId
            }
        } else if let userContact = userModel.userContacts {
            if let contactId = userContact.id {
                self.presentVC(id: "DenyConfirmVC", presentFullType: "over" ) { (vc:DenyConfirmVC) in
                    vc.contactId = contactId
                }
            }
        }
    }
    
    @IBOutlet weak var profilePicIV: RoundCornerButton!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var workLocLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    @IBOutlet weak var viewProfileBtn: RoundCornerButton!
    @IBOutlet weak var msgTextView: FormTextView!
    
    
    var userModel = UserModel()
    var img = UIImage(named: "placeholder")

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = userModel.firstName + " " + (userModel.lastName ?? "")
        proffLbl.text = userModel.workTitle
        workLocLbl.text = userModel.workAddress
        
        //let contact = userModel.contactInformationsSharedByOther.filter{$0.contactTypeId == 6}
        if let msg = userModel.message, !userModel.message.isEmpty {
            msgTextView.text = msg //userModel.message ?? ""
        } else if let userContacts = userModel.userContacts {
            if let msg = userContacts.message {
                msgTextView.text = msg
            }
        } else {
            msgTextView.text = "See who's interested in connecting with you! Check out the shared contacts and start building new connections online."
        }
        
        if userModel.profilePicture != "" && userModel.profilePicture != nil {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicIV?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
        } else {
            profilePicIV.setImage(img, for: .normal)
        }
        
        if let read = userModel.isRead {
            viewProfileBtn.isHidden = false
            if !read {
                readThisProfile()
            }
        } else {
            viewProfileBtn.isHidden = true
            if let userContacts = userModel.userContacts {
                if let read = userContacts.isRead {
                    if !read {
                        readThisProfile()
                    }
                }
            }
        }
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "exitView" {
                self?.dismiss(animated: true)
            }
            
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        generalPublisher.onNext("roloadList")
    }
    
    func readThisProfile() {
        
        let pram = ["contactId": "\(userModel.contactId ?? 0)",
                    "isRead":"\(true)"
        ]
        
        SignalRManager.singelton.connection.invoke(method: "ReadContactRequest", pram) {  error in
            if let e = error {
                Logs.show(message: "Error: \(e)")
                AppFunctions.showSnackBar(str: "Error in updating values")
                return
            }
        }
    }
    
    func updateContactStatus() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        let pram : [String: Any] = ["contactId": userModel.contactId as Any,
                                    "status": 2 ]
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
                            AppFunctions.showSnackBar(str: "\(userModel.firstName ?? "User") has been moved to your contacts! 🎉🎉🎉")
                            self.dismiss(animated: true, completion: nil)
                            
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
