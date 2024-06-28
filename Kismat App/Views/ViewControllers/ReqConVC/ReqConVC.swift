//
//  ReqConVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 18/06/2024.
//

import UIKit

class ReqConVC: MainViewController {

    
    @IBOutlet weak var reqTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        reqTV.tableFooterView = UIView()
        reqTV.separatorStyle = .none
        reqTV.delegate = self
        reqTV.dataSource = self
        reqTV.register(UINib(nibName: "TabsHeaderTVCell", bundle: nil), forCellReuseIdentifier: "TabsHeaderTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
}

//MARK: TableView Extention
extension ReqConVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : TabsHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "TabsHeaderTVCell", for: indexPath) as! TabsHeaderTVCell
        
        cell.notifbtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
        cell.wifiManBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
        
        cell.onReqBtnTap = {

            cell.headerLbl.text = "REQUESTS"
            UIView.transition(with: cell.btnsImg,
                              duration: 0.1, // Adjust the duration as needed
                              options:.transitionCrossDissolve,
                              animations: { cell.btnsImg.image = UIImage(named: "reqSelected") },
                              completion: nil)
        }
        
        cell.onConBtnTap = {
            cell.headerLbl.text = "CONTACTS"
            UIView.transition(with: cell.btnsImg,
                              duration: 0.1, // Adjust the duration as needed
                              options:.transitionCrossDissolve,
                              animations: { cell.btnsImg.image = UIImage(named: "conSelected") },
                              completion: nil)
        }

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

