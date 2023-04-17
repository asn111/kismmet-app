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
        IAPManager.shared.fetchProducts()
    }
    
    @IBAction func feedBtnPressed(_ sender: Any) {
        self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
            vc.selectedIndex = 2
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        _ = productPublisher.subscribe(onNext: {[weak self] val in
            
            if !val.isEmpty {
                Logs.show(message: "Products \(val)")
                IAPManager.shared.purchase(productID: val.keys.first!)
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        // Do any additional setup after loading the view.
    }
}
