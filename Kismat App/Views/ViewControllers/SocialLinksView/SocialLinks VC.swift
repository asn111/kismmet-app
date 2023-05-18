//
//  SocialLinks VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 03/05/2023.
//

import UIKit

class SocialLinks_VC: MainViewController {

    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var socialLinksTV: UITableView!
    
    var socialAccModel = [SocialAccModel]()
    var linkType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
    }

    func registerCells() {
        
        socialLinksTV.tableFooterView = UIView()
        socialLinksTV.separatorStyle = .none
        socialLinksTV.delegate = self
        socialLinksTV.dataSource = self
        socialLinksTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")

    }
}
//MARK: TableView Extention
extension SocialLinks_VC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return socialAccModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
        
        cell.socialLbl.text = socialAccModel[indexPath.row].linkTitle.capitalized
        cell.socialImgView.image = UIImage(named: linkType)
        cell.socialLbl.isUserInteractionEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch linkType {
            case "LinkedIn":
                AppFunctions.openLinkedIn(userName: socialAccModel[indexPath.row].linkUrl)
            case "Twitter":
                AppFunctions.openTwitter(userName: socialAccModel[indexPath.row].linkUrl)
            case "Instagram":
                AppFunctions.openInstagram(userName: socialAccModel[indexPath.row].linkUrl)
            case "Snapchat":
                AppFunctions.openSnapchat(userName: socialAccModel[indexPath.row].linkUrl)
            case "Website":
                AppFunctions.openWebLink(link: socialAccModel[indexPath.row].linkUrl, vc: self)
            default:
                print("default")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

