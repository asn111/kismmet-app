//
//  ProfileSetupVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class ProfileSetupVC: MainViewController {

    @IBOutlet weak var profileTV: UITableView!
        
    var placeholderArray = ["","Full Name","Public Email","Phone","Date of Birth","Where do you work / study?","Title","Tell us about your self..",""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
        
    }

    func registerCells() {
        
        profileTV.tableFooterView = UIView()
        profileTV.separatorStyle = .none
        profileTV.delegate = self
        profileTV.dataSource = self
        profileTV.register(UINib(nibName: "ProfileHeaderTVCell", bundle: nil), forCellReuseIdentifier: "ProfileHeaderTVCell")
        profileTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")
        profileTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")
        profileTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
    }
    
}
//MARK: TableView Extention
extension ProfileSetupVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0:
                let cell : ProfileHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTVCell", for: indexPath) as! ProfileHeaderTVCell
                
                return cell
            case placeholderArray.count - 1 :
                
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                
                return cell
            case placeholderArray.count - 2 :
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                //cell.generalTV.newPlaceholder =
                cell.generalTV.addPlaceholder(" Tell us about your self..")
                return cell
                
            default:
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                if placeholderArray[indexPath.row] == "Phone" {
                    cell.numberView.isHidden = false
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode()
                    cell.numberTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])

                } else {
                    cell.numberView.isHidden = true
                    cell.generalTFView.isHidden = false
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])

                }
                if placeholderArray[indexPath.row] == "Public Email" {
                    cell.imageIconIV.isHidden = false
                } else if placeholderArray[indexPath.row] == "Date of Birth" {
                    cell.imageIconIV.isHidden = false
                } else {
                    cell.imageIconIV.isHidden = true
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

