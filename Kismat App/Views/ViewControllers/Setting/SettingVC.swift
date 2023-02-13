//
//  SettingVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit

class SettingVC: MainViewController {

    
    @IBOutlet weak var settingTV: UITableView!
    
    var lblTxt = ["","","Edit Profile","Notifications","Change Password","Membership","Privacy Policy","About Kismmet","Account Status","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        settingTV.tableFooterView = UIView()
        settingTV.separatorStyle = .none
        settingTV.delegate = self
        settingTV.dataSource = self
        settingTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        settingTV.register(UINib(nibName: "SettingTVCell", bundle: nil), forCellReuseIdentifier: "SettingTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.dismiss(animated: true)
    }
}
//MARK: TableView Extention
extension SettingVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lblTxt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "SETTINGS"
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.ratingView.isHidden = true
                
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                
                cell.nameLbl.text = "Tamara"
                cell.educationLbl.text = "tamara@gmail.com"
                cell.professionLbl.text = "+123456789"
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                
                return cell
                
            default:
                let cell : SettingTVCell = tableView.dequeueReusableCell(withIdentifier: "SettingTVCell", for: indexPath) as! SettingTVCell
                cell.txtLbl.text = lblTxt[indexPath.row]
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

