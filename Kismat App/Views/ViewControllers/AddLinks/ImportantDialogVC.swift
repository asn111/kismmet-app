//
//  ImportanDialogVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 19/02/2023.
//

import UIKit

class ImportantDialogVC: MainViewController {

    @IBOutlet weak var importantLbl: fullyCustomLbl!
    
    
    @IBAction func yesBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
