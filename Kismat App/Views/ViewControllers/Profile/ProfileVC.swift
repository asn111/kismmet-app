//
//  ProfileVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit

class ProfileVC: MainViewController {

    @IBOutlet weak var profileTV: UITableView!
    
    var socialAccArray = ["Tamara Pensiero","@tamaraapp","@tamara","@tamarasnap","My Website"]
    var socialAccImgArray = [UIImage(named: "LinkedIn"),UIImage(named: "Twitter"),UIImage(named: "Insta"),UIImage(named: "snapchat"),UIImage(named: "website")]
    
    var titleName = "TAMARA PENSIERO"
    var img = UIImage(named: "girl")
    var prof = "Professor"
    var isOtherProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        profileTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileTV.register(UINib(nibName: "TagsTVCell", bundle: nil), forCellReuseIdentifier: "TagsTVCell")
        profileTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
    }
    @objc func picBtnPressed(sender: UIButton) {
        if isOtherProfile {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.pushVC(id: "SettingVC") { (vc:SettingVC) in }
        }
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
}
//MARK: TableView Extention
extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socialAccImgArray.count + 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = false
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.profileView.isHidden = false
                cell.headerView.isHidden = false
                
                cell.profilePicBtn.setImage(img, for: .normal)
                cell.nameLbl.text = titleName
                cell.professionLbl.text = prof
                
                if isOtherProfile {
                    cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)
                } else {
                    cell.picBtn.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
                }
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)

                return cell
            case 1:
                let cell : AboutTVCell = tableView.dequeueReusableCell(withIdentifier: "AboutTVCell", for: indexPath) as! AboutTVCell
                return cell
            case 2:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Tags"
                return cell
            case 3:
                let cell : TagsTVCell = tableView.dequeueReusableCell(withIdentifier: "TagsTVCell", for: indexPath) as! TagsTVCell
                return cell
            case 4:
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.headerLbl.text = "Social accounts"
                return cell
                
            default:
                let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
                cell.socialImgView.image = socialAccImgArray[indexPath.row - 5]
                cell.socialLbl.text = socialAccArray[indexPath.row - 5]
                return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

