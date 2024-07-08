//
//  DenyConfirmVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit

class DenyConfirmVC: MainViewController {
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        AppFunctions.removeFromDefaults(key: selectedCheck)
        orignalSelectedCheckArray.forEach { id in
            AppFunctions.setSelectedCheckValue(value: id)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func mainActionBtnPressed(_ sender: Any) {
        if contactId > 0 {
            denyContact()
        } else {
            addContacts()
            
        }
    }
    
    @IBAction func skipBtnPressed(_ sender: Any) {
        AppFunctions.removeFromDefaults(key: selectedCheck)

        orignalSelectedCheckArray.forEach { id in
            AppFunctions.setSelectedCheckValue(value: id)
        }
        
        self.dismiss(animated: true)
    }
    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    
    @IBOutlet weak var mainActionBtn: RoundCornerButton!
    
    @IBOutlet weak var skipBtn: RoundCornerButton!
    @IBOutlet weak var textLbl: fullyCustomLbl!
    
    var contactId = 0
    
    var contactAccounts = [ContactTypesModel]()
    var orignalSelectedCheckArray: [Int] = []

    
    var linkedInContactValue = ""
    var whatsAppContactValue = ""
    var wechatContactValue = ""
    var directContactValue = ""
    var instagramContactValue = ""
    var kismmetMsgContactValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if contactId > 0 {
            mainActionBtn.setTitle("Deny", for: .normal)
            mainActionBtn.backgroundColor = UIColor(named: "warning")
            headingLbl.text = "Deny!"
            textLbl.text = "Are you sure you’d like to decline?\n\nNo worries if yes, the other person will not be notified."
        } else {
            mainActionBtn.setTitle("Yes", for: .normal)
            mainActionBtn.backgroundColor = UIColor(named: "Success")
            skipBtn.isHidden = false
            headingLbl.text = "Save Contact Info"
            textLbl.text = "Do you want to save this information for the future connections?"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        generalPublisher.onNext("roloadList")
    }

    func createContactEntry(for contactType: String, contactValue: String, includeIsShared: Bool) -> [String: Any] {
        let contactTypeId = contactAccounts.filter { $0.contactType == contactType }.first?.contactTypeId ?? 0
        
        var result: [String: Any] = [
            "contactTypeId": contactTypeId,
            "value": contactValue
        ]
        
        if includeIsShared {
            let isShared = AppFunctions.getSelectedCheckArray().contains(contactTypeId) ? true : false
            result["isShared"] = isShared
        }
        
        return result
    }
    
    func addContacts() {
        
        self.showPKHUD(WithMessage: "Fetching...")
        
        let contacts: [[String: Any]] = [
            createContactEntry(for: "LinkedIn", contactValue: linkedInContactValue, includeIsShared: true),
            createContactEntry(for: "WhatsApp", contactValue: whatsAppContactValue, includeIsShared: true),
            createContactEntry(for: "WeChat", contactValue: wechatContactValue, includeIsShared: true),
            createContactEntry(for: "Text/Call", contactValue: directContactValue, includeIsShared: true),
            createContactEntry(for: "Instagram", contactValue: instagramContactValue, includeIsShared: true),
            createContactEntry(for: "Other", contactValue: kismmetMsgContactValue, includeIsShared: true)
        ]
        
        
        let pram : [String: Any] = ["ContactInfoList": contacts]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .addContact(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
                            AppFunctions.showSnackBar(str: "Information saved successfully")
                            self.dismiss(animated: true)
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
