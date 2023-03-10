//
//  ViewedProfilesVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 12/02/2023.
//

import UIKit

class ViewedProfilesVC: MainViewController {

    @IBOutlet weak var viewedListTV: UITableView!
    
    var nameArray = ["James Nio","Kris Burner","Mark Denial"]
    var profArray = ["Bachelor, Student","Entrepreneur","Professor"]
    var imageArray = [UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "professor")]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
    }
    
    func registerCells() {
        
        viewedListTV.tableFooterView = UIView()
        viewedListTV.separatorStyle = .none
        viewedListTV.delegate = self
        viewedListTV.dataSource = self
        viewedListTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        viewedListTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
    }
    
    @objc func picBtnPressed(sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
    }
    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
}
//MARK: TableView Extention
extension ViewedProfilesVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "VIEWED BY"
                cell.toolTipBtn.isHidden = true
                cell.searchTFView.isHidden = true
                cell.headerView.isHidden = false
                
                
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)

                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.borderWidth = 0

                
                return cell
                
            default:
                let cell : FeedItemsTVCell = tableView.dequeueReusableCell(withIdentifier: "FeedItemsTVCell", for: indexPath) as! FeedItemsTVCell
                cell.nameLbl.text = nameArray[indexPath.row - 1]
                cell.professionLbl.text = profArray[indexPath.row - 1]
                cell.profilePicIV.image = imageArray[indexPath.row - 1]
                if indexPath.row / 3 == 0 {
                    cell.starLbl.image = UIImage(systemName: "star")
                } else {
                    cell.starLbl.image = UIImage(systemName: "star.fill")
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            self.pushVC(id: "ProfileVC") { (vc:ProfileVC) in
                vc.isOtherProfile = true
                vc.img = imageArray[indexPath.row - 1]
                vc.titleName = nameArray[indexPath.row - 1]
                vc.prof = profArray[indexPath.row - 1]
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100.0
        } else {
            return UITableView.automaticDimension
        }
    }
}

