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
    
    
    @IBAction func viewProfileBtnPressed(_ sender: Any) {
        self.presentVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
            vc.userId = userModel.userId
            vc.isFromReq = true
        }
    }
    
    @IBAction func accpetBtnPressed(_ sender: Any) {
        self.presentVC(id: "ContactInformainVC", presentFullType: "over" ) { (vc:ContactInformainVC) in
            vc.contactId = userModel.contactId
        }
    }
    
    @IBAction func denyBtnPressed(_ sender: Any) {
        self.presentVC(id: "DenyConfirmVC", presentFullType: "over" ) { (vc:DenyConfirmVC) in
            vc.contactId = userModel.contactId
        }
        
    }
    
    @IBOutlet weak var profilePicIV: RoundCornerButton!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var workLocLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    @IBOutlet weak var msgTextView: FormTextView!
    
    
    var userModel = UserModel()
    var img = UIImage(named: "placeholder")

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = userModel.userName
        proffLbl.text = userModel.workTitle
        workLocLbl.text = userModel.workAddress
        
        let contact = userModel.contactInformationsShared.filter{$0.contactTypeId == 6}
        if let msg = userModel.message, !userModel.message.isEmpty {
            msgTextView.text = msg //userModel.message ?? ""
        } else {
            msgTextView.text = "Default introductory message will display here."
        }
        
        if userModel.profilePicture != "" && userModel.profilePicture != nil {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicIV?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
        } else {
            profilePicIV.setImage(img, for: .normal)
        }
        
        if !userModel.isRead {
            readThisProfile()
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
        
        SignalRService.connection.invoke(method: "ReadContactRequest", pram) {  error in
            if let e = error {
                Logs.show(message: "Error: \(e)")
                AppFunctions.showSnackBar(str: "Error in updating values")
                return
            }
        }
    }
}
