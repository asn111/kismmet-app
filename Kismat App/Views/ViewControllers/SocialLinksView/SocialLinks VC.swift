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
    var canEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headingLbl.text = "Social Links Connected"
        registerCells()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        generalPublisher.onNext("socialAdded")
    }
    
    func registerCells() {
        
        socialLinksTV.tableFooterView = UIView()
        socialLinksTV.separatorStyle = .none
        socialLinksTV.delegate = self
        socialLinksTV.dataSource = self
        socialLinksTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")

    }

    
    @objc func removeBtnPressed(sender:UIButton) {
        let index = sender.tag
        ApiService.deleteSocialLink(val: socialAccModel[index].socialAccountId)
        socialAccModel.remove(at: index)
        socialLinksTV.reloadData()
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
        //cell.socialImgView.image = UIImage(named: linkType)
        if socialAccModel[indexPath.row].linkImage != "" {
            let imageUrl = URL(string: socialAccModel[indexPath.row].linkImage)
            cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
        }
        cell.socialLbl.isUserInteractionEnabled = false
        
        if canEdit {
            cell.removeBtn.isHidden = false
            cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
            cell.removeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
            cell.removeBtn.cornerRadius = 10
            cell.removeBtn.tag = indexPath.row
        }
        
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
            case "Facebook":
                AppFunctions.openFacebook(userName: socialAccModel[indexPath.row].linkUrl)
            case "Reddit":
                AppFunctions.openRedditProfile(userName: socialAccModel[indexPath.row].linkUrl)
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

