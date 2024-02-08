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
            //AppFunctions.setIsPremiumUser(value: false)
            //freePlan()
            if AppFunctions.getplatForm() == "iOS" {
                IAPManager.shared.showManageSubscriptions()
            } else {
                AppFunctions.showSnackBar(str: "This subscription is purchased on different platform other than Apple store and can not canceled in this app!")
            }
            
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
    
    @IBOutlet weak var freeViewHeightConstr: NSLayoutConstraint!
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
        let newHeight: CGFloat = 300
        
        // Update the frame of the view with the new size
        self.currentPlanHeightConst.constant = newHeight

        UIView.animate(withDuration: duration, animations: {
            
            let shadowModeText = "Discover Shadow Mode :\nGo to Settings > Preferences > Shadow Mode"
            let statusText = "Broadcast a status :\nKismmet members can see 50 characters on your profile card in the main feed and 100 characters in your full profile.\nGo to Settings > Preferences > Type up a status where it says “Add status here…”\nSet your status to disappear after 24hrs :\nUse this feature for urgent or timed statuses!\nGo to Settings > Preferences > Disappearing Status"
            
            // Create a NSMutableAttributedString for semi-bold and underline
            let shadowModeAttributedString = NSMutableAttributedString(string: shadowModeText)
            let statusAttributedString = NSMutableAttributedString(string: statusText)
            
            // Define attributes for semi-bold and underline text
            let semiBoldUnderlineAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            
            // Define attributes for italic text
            let italicAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 12).light
            ]
            
            // Define paragraph style for half-line spacing
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacingBefore = UIFont.systemFont(ofSize: 12).lineHeight * 0.5
            
            // Apply semi-bold and underline attributes to specific ranges
            shadowModeAttributedString.addAttributes(semiBoldUnderlineAttributes, range: (shadowModeText as NSString).range(of: "Discover Shadow Mode :"))
            statusAttributedString.addAttributes(semiBoldUnderlineAttributes, range: (statusText as NSString).range(of: "Broadcast a status :"))
            statusAttributedString.addAttributes(semiBoldUnderlineAttributes, range: (statusText as NSString).range(of: "Set your status to disappear after 24hrs :"))
            
            // Apply italic attributes to specific ranges
            shadowModeAttributedString.addAttributes(italicAttributes, range: (shadowModeText as NSString).range(of: "Go to Settings > Preferences > Shadow Mode"))
            statusAttributedString.addAttributes(italicAttributes, range: (statusText as NSString).range(of: "Go to Settings > Preferences > Type up a status where it says “Add status here…”"))
            statusAttributedString.addAttributes(italicAttributes, range: (statusText as NSString).range(of: "Go to Settings > Preferences > Disappearing Status"))
            
            // Apply paragraph style to the rest of the text
            let fullRange = NSRange(location: 0, length: shadowModeAttributedString.length)
            shadowModeAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            let fullStatusRange = NSRange(location: 0, length: statusAttributedString.length)
            statusAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullStatusRange)
            
            
            // Assign attributed strings to UILabels
            self.planNameLbl.text = "Welcome to Kismmet Premium!"
            self.featureLbl1.attributedText = shadowModeAttributedString
            self.featureLbl2.attributedText = statusAttributedString
            
            
            self.upgradeBtn.setTitle("Cancel Subscription", for: .normal)
            
            self.featureLbl2.isHidden = false
            self.tryLbl.isHidden = true
            self.premiumPlanView.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
    func freePlan() {
        let duration = 0.3
        let newHeight: CGFloat = 100
        
        // Update the frame of the view with the new size
        self.currentPlanHeightConst.constant = newHeight
        
        UIView.animate(withDuration: duration, animations: {
            self.planNameLbl.text = "Free Plan"
            self.featureLbl1.text = "Unlimited profile views per month"
            self.featureLbl2.text = ""
            
            self.upgradeBtn.setTitle("Upgrade Subscription", for: .normal)
            
            self.featureLbl2.isHidden = true
            self.tryLbl.isHidden = false
            self.premiumPlanView.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
}
