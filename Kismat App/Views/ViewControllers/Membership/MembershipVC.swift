//
//  MembershipVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit

class MembershipVC: MainViewController {
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upgradeBtnPressed(_ sender: Any) {
        
        if AppFunctions.isPremiumUser() {
            AppFunctions.setIsPremiumUser(value: false)
            freePlan()
            IAPManager.shared.showManageSubscriptions()
        } else {
            IAPManager.shared.fetchProducts()
        }
        
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    
    @IBOutlet weak var currentPlanView: RoundCornerView!
    @IBOutlet weak var planNameLbl: fullyCustomLbl!
    @IBOutlet weak var featureLbl1: fullyCustomLbl!
    @IBOutlet weak var featureLbl2: fullyCustomLbl!
    
    @IBOutlet weak var premiumPlanView: RoundCornerView!
    @IBOutlet weak var tryLbl: fullyCustomLbl!
    @IBOutlet weak var upgradeBtn: RoundCornerButton!
    
    @IBOutlet weak var currentPlanHeightConst: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if AppFunctions.isPremiumUser() {
            premiumPlan()
        } else {
            freePlan()
        }
        _ = productPublisher.subscribe(onNext: { val in
            
            if !val.isEmpty {
                Logs.show(message: "Products \(val)")
                IAPManager.shared.purchase(productID: val.keys.first!)
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        _ = generalPublisher.subscribe(onNext: { [weak self] val in
            
            if val == "purchased" {
                self?.premiumPlan()
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        // Do any additional setup after loading the view.
    }
    
    func premiumPlan() {
        let duration = 0.3
        let newHeight: CGFloat = 100
        
        // Update the frame of the view with the new size
        self.currentPlanHeightConst.constant = newHeight

        UIView.animate(withDuration: duration, animations: {
            self.planNameLbl.text = "KISMMET Premium"
            self.featureLbl1.text = "Discover Shadow Mode\nGo to Settings > Preferences > Shadow Mode"
            self.featureLbl2.text = ""
            
            self.upgradeBtn.setTitle("Cancel Subscription", for: .normal)
            
            self.featureLbl2.isHidden = false
            self.tryLbl.isHidden = true
            self.premiumPlanView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func freePlan() {
        let duration = 0.3
        let newHeight: CGFloat = 87
        
        // Update the frame of the view with the new size
        self.currentPlanHeightConst.constant = newHeight
        
        UIView.animate(withDuration: duration, animations: {
            self.planNameLbl.text = "Free Plan"
            self.featureLbl1.text = "Discover up to unlimited profiles per month"
            self.featureLbl2.text = ""
            
            self.upgradeBtn.setTitle("Upgrade Subscription", for: .normal)
            
            self.featureLbl2.isHidden = true
            self.tryLbl.isHidden = false
            self.premiumPlanView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
}
