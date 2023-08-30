//
//  ReportDialogVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 30/08/2023.
//

import UIKit

class ReportDialogVC: MainViewController {

    @IBOutlet weak var reportTxt: fullyCustomLbl!
    
    @IBAction func yesBtnPressed(_ sender: Any) {
        userReport()
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func userReport() {
        self.showPKHUD(WithMessage: "")
        
        let pram : [String : Any] = [ "reportedUser": userId,
                                      "reportReasons": "1",
                                      "reportDetails": ""
        ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .reportUser(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            AppFunctions.showSnackBar(str: "Thanks for taking time to let us know.\nYour report is submitted")
                            self.hidePKHUD()
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
