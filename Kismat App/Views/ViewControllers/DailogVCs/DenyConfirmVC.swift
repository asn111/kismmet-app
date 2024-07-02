//
//  DenyConfirmVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit

class DenyConfirmVC: MainViewController {

    
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func mainActionBtnPressed(_ sender: Any) {
        denyContact()
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    
    @IBOutlet weak var textLbl: fullyCustomLbl!
    
    var contactId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    func denyContact() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        let pram : [String : Any] = ["contactId": contactId, "status": 3]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .updateContactStatus(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
                            AppFunctions.showSnackBar(str: "Request denied successfully")
                            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                        } else {
                            self.hidePKHUD()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
    }
}
