//
//  SocialLinks VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 03/05/2023.
//

import UIKit
import UIMultiPicker

class SocialLinks_VC: MainViewController {

    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var socialLinksTV: UITableView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    @IBOutlet weak var pickerView: UIView!
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
    }
    
    
    var socialAccModel = [SocialAccModel]()
    var linkType = ""
    var canEdit = false
    var isFromOther = false
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getReasons()
        
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

    func setupMultiPickerView() {
        
        pickerView.isHidden = false
        multiPickerView.options = reasonsListName
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .darkGray
        multiPickerView.tintColor = .black
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedReasonsAray = sender.selectedIndexes
        Logs.show(message: "Selected REASONS: \(selectedReasonsAray)")
        
    }
    
    @objc func removeBtnPressed(sender:UIButton) {
        let index = sender.tag
        if canEdit {
            ApiService.deleteSocialLink(val: socialAccModel[index].socialAccountId)
            socialAccModel.remove(at: index)
            socialLinksTV.reloadData()
        } else {
            setupMultiPickerView()
        }
        
    }
   
    //MARK: API METHODS

    func getReasons() {
        
        
        APIService
            .singelton
            .getReportReasons()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        AppFunctions.setIsNotifCheck(value: false)
                        if val.count > 0 {
                            self.reasonsList = val
                            self.reasonsListName = self.reasonsList.map({$0.reason})
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
//MARK: TableView Extention
extension SocialLinks_VC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return socialAccModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : SocialAccTVCell = tableView.dequeueReusableCell(withIdentifier: "SocialAccTVCell", for: indexPath) as! SocialAccTVCell
        
        cell.socialLbl.text = socialAccModel[indexPath.row].linkTitle.capitalized
        
        if socialAccModel[indexPath.row].linkImage != "" {
            let imageUrl = URL(string: socialAccModel[indexPath.row].linkImage)
            cell.socialImgView.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
        }
        cell.socialLbl.isUserInteractionEnabled = false
        
        if isFromOther {
            cell.removeBtn.isHidden = false
        }
        cell.removeBtn.tintColor = UIColor(named: "warning")
        cell.removeBtn.backgroundColor = UIColor.clear
        cell.removeBtn.setImage(UIImage(systemName: "exclamationmark.shield.fill"), for: .normal)
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.addTarget(self, action: #selector(removeBtnPressed(sender:)), for: .touchUpInside)
        
        if canEdit {
            cell.removeBtn.isHidden = false
            cell.removeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
            cell.removeBtn.cornerRadius = 10
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

