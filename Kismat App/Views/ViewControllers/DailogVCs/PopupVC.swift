//
//  PopupVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 22/08/2023.
//

import UIKit

class PopupVC: MainViewController {

    
    @IBAction func okayBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var textLbl: fullyCustomLbl!
    
    @IBOutlet weak var importantLbl: fullyCustomLbl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
