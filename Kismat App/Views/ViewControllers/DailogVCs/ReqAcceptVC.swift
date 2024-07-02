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
    
    @IBAction func accpetBtnPressed(_ sender: Any) {
        
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
        if !contact.isEmpty {
            msgTextView.text = contact.first?.value
        }
        
        if userModel.profilePicture != "" && userModel.profilePicture != nil {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicIV?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: img) { (image, error, imageCacheType, url) in }
        } else {
            profilePicIV.setImage(img, for: .normal)
        }
    }
    
}
