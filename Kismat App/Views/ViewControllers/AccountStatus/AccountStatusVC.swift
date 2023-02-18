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
    
    @IBOutlet weak var genBtn: RoundCornerButton!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func genBtnPressed(_ sender: Any) {
        self.presentVC(id: "ImportantDialogVC", presentFullType: "over" ) { (vc:ImportantDialogVC) in }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
    
    @objc
    func delTapFunction(sender:UITapGestureRecognizer) {
        deleteView.borderColor = UIColor(named: "Danger")
        deactivateView.borderColor = UIColor(named: "Secondary Grey")
        genBtn.backgroundColor = UIColor(named: "Danger")
    }
}
