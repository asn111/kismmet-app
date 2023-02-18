//
//  AddLinksVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit

class AddLinksVC: MainViewController {

    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        AppFunctions.showSnackBar(str: "Link Added")
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tap)
        
    }
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
}
