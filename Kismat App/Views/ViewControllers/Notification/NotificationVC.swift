//
//  NotificationVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 15/02/2023.
//

import UIKit

class NotificationVC: MainViewController {

    @IBOutlet weak var notifTV: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        notifTV.tableFooterView = UIView()
        notifTV.separatorStyle = .none
        notifTV.delegate = self
        notifTV.dataSource = self
        notifTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        notifTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        notifTV.register(UINib(nibName: "NotifTVCell", bundle: nil), forCellReuseIdentifier: "NotifTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
//MARK: TableView Extention
extension NotificationVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "NOTIFICATIONS"
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.headerView.isHidden = false
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
            case 1:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "New"
                return cell
            case 4:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.notifHeaderView.isHidden = false
                cell.notifHeaderLbl.text = "Earlier"
                return cell
            default:
                let cell : NotifTVCell = tableView.dequeueReusableCell(withIdentifier: "NotifTVCell", for: indexPath) as! NotifTVCell
                if indexPath.row / 4 == 0 {
                    cell.notifView.backgroundColor = UIColor(named: "Cell BG Base Grey")
                    cell.notifView.shadowColor = UIColor(named: "Cell BG Base Grey")
                } else {
                    cell.notifView.backgroundColor = UIColor(named: "Base White")
                    cell.notifView.shadowColor = UIColor.lightGray
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.0
        } else {
            return UITableView.automaticDimension
        }
    }
}

