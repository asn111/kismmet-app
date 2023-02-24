//
//  FeedVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class FeedVC: MainViewController {

    
    @IBOutlet weak var feedTV: UITableView!
    
    
    var nameArray = ["Zoya Grey","James Nio","Kris Burner","Nesa Node","Mark Denial"]
    var profArray = ["Professor","Bachelor, Student","Entrepreneur","Chemist","Professor"]
    var imageArray = [UIImage(named: "girl"),UIImage(named: "guy"),UIImage(named: "office"),UIImage(named: "teacher"),UIImage(named: "professor")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
    }
    
    func registerCells() {
        
        feedTV.tableFooterView = UIView()
        feedTV.separatorStyle = .none
        feedTV.delegate = self
        feedTV.dataSource = self
        feedTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        feedTV.register(UINib(nibName: "FeedItemsTVCell", bundle: nil), forCellReuseIdentifier: "FeedItemsTVCell")
    }


    @objc func notifBtnPressed(sender: UIButton) {
        self.pushVC(id: "NotificationVC") { (vc:NotificationVC) in }
    }
    
}
//MARK: TableView Extention
extension FeedVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLogo.isHidden = false
                cell.viewCountsLbl.isHidden = false
                cell.searchView.isHidden = false
                cell.headerView.isHidden = false
                
                cell.notifBtn.addTarget(self, action: #selector(notifBtnPressed(sender:)), for: .touchUpInside)
                
                cell.viewCountsLbl.attributedText = NSAttributedString(string: "14 out of 15 profiles viewed", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
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
        return UITableView.automaticDimension
    }
}

