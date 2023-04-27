//
//  AccountStatusVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 19/02/2023.
//

import UIKit

class AccountStatusVC: MainViewController {

    
    
    @IBOutlet weak var deactivateView: RoundCornerView!
    @IBOutlet weak var deacTxtLbl: fullyCustomLbl!
    @IBOutlet weak var deleteView: RoundCornerView!
    @IBOutlet weak var delTxtLbl: fullyCustomLbl!
    
    @IBOutlet weak var profilePicBtn: RoundCornerButton!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var educationLbl: fullyCustomLbl!
    @IBOutlet weak var professionLbl: fullyCustomLbl!
    
    
    @IBOutlet weak var genBtn: RoundCornerButton!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func genBtnPressed(_ sender: Any) {
        self.presentVC(id: "ImportantDialogVC", presentFullType: "over" ) { (vc:ImportantDialogVC) in
            vc.dialogType = tappedType
        }
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    var tappedType = "Deactivate"
    var userModel = UserDBModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBService.fetchloggedInUser().count > 0 {
            self.userModel = DBService.fetchloggedInUser().first!
        }
        
        nameLbl.text = userModel.userName
        professionLbl.text = userModel.workTitle
        educationLbl.text = userModel.workAddress
        
        if userModel.profilePicture != "" {
            let imageUrl = URL(string: userModel.profilePicture)
            profilePicBtn?.sd_setImage(with: imageUrl, for: .normal , placeholderImage: UIImage(named: "placeholder")) { (image, error, imageCacheType, url) in }
        } else {
            profilePicBtn.setImage(UIImage(named: "placeholder"), for: .normal)
        }
        
        let deactTap = UITapGestureRecognizer(target: self, action: #selector(deactTapFunction))
        let deactTap2 = UITapGestureRecognizer(target: self, action: #selector(deactTapFunction))
        deactivateView.addGestureRecognizer(deactTap)
        deacTxtLbl.addGestureRecognizer(deactTap2)
        
        let delTap = UITapGestureRecognizer(target: self, action: #selector(delTapFunction))
        let delTap2 = UITapGestureRecognizer(target: self, action: #selector(delTapFunction))
        deleteView.addGestureRecognizer(delTap)
        delTxtLbl.addGestureRecognizer(delTap2)

    }
    
    @objc
    func deactTapFunction(sender:UITapGestureRecognizer) {
        deactivateView.borderColor = UIColor(named: "Primary Yellow")
        deleteView.borderColor = UIColor(named: "Secondary Grey")
        genBtn.backgroundColor = UIColor(named: "Primary Yellow")
        genBtn.setTitle("Deactivate", for: .normal)
        tappedType = "Deactivate"
    }
    
    @objc
    func delTapFunction(sender:UITapGestureRecognizer) {
        deleteView.borderColor = UIColor(named: "Danger")
        deactivateView.borderColor = UIColor(named: "Secondary Grey")
        genBtn.backgroundColor = UIColor(named: "Danger")
        genBtn.setTitle("Delete", for: .normal)
        tappedType = "Delete"
    }
}
