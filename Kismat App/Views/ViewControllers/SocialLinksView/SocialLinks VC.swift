//
//  SocialLinks VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 03/05/2023.
//

import UIKit
import UIMultiPicker
import CDAlertView

class SocialLinks_VC: MainViewController {

    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var socialLinksTV: UITableView!
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    @IBOutlet weak var pickerView: UIView!
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        pickerView.isHidden = true
        AppFunctions.showSnackBar(str: "Thanks for taking time to let us know.\nYour report is submitted")
    }
    
    
    var socialAccModel = [SocialAccModel]()
    var linkType = ""
    var canEdit = false
    var isFromOther = false
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()

    var userId = ""
    
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
            //add alert here
            showAlert(index: index)
        } else {
            
            let alert = UIAlertController(title: "Select Option", message: "Please Select an Option", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Copy Link", style: .default , handler:{ (UIAlertAction)in
                UIPasteboard.general.string = "Selected for copy \(self.socialAccModel[index].linkUrl ?? "")"
                AppFunctions.showSnackBar(str: "Link copied.")
            }))
            
            alert.addAction(UIAlertAction(title: "Share Link", style: .default , handler:{ (UIAlertAction)in
                self.share(message: "Share the \(self.socialAccModel[index].linkType ?? "") link", link: self.socialAccModel[index].linkUrl, sender: sender)
            }))
            
            alert.addAction(UIAlertAction(title: "Report Link", style: .destructive , handler:{ (UIAlertAction)in
                self.presentVC(id: "ReportDialogVC", presentFullType: "no" ) { (vc:ReportDialogVC) in
                    vc.userId = self.userId
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
                print("User click Dismiss button")
            }))
            
            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true, completion: {
                print("completion block")
            })
            
            //setupMultiPickerView()
        }
        
    }
    
    func showAlert(index: Int){
        let message = "Alert!"
        let alert = CDAlertView(title: message, message: "Are you sure you want to remove link?", type: .warning)
        let action = CDAlertViewAction(title: "Remove",
                                       handler: {[weak self] action in
            let accountId = self?.socialAccModel[index].socialAccountId ?? -1 // Assuming -1 is an acceptable fallback
            ApiService.deleteSocialLink(val: accountId)
            self?.socialAccModel.remove(at: index)
            self?.socialLinksTV.reloadData()
            generalPublisher.onNext("socialDeleted")
            return true
        })
        let cancel = CDAlertViewAction(title: "Cancel",
                                       handler: { action in
            print("CANCEL PRESSED")
            return true
        })
        alert.isTextFieldHidden = true
        alert.add(action: action)
        alert.add(action: cancel)
        alert.hideAnimations = { (center, transform, alpha) in
            transform = .identity
            alpha = 0
        }
        alert.show() { (alert) in
            print("completed")
        }
    }
    
    func share(message: String, link: String, sender: UIButton) {
        let textToShare = message
                
        if let myWebsite = NSURL(string: link) {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        } else {
            AppFunctions.showSnackBar(str: "Provided link is invalid.")
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
        cell.removeBtn.tintColor = UIColor(named: "Text grey")
        cell.removeBtn.backgroundColor = UIColor.clear
        cell.removeBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        cell.removeBtn.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
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
        
        if let urlString = socialAccModel[indexPath.row].linkUrl,
           let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            // Opens the URL in browser
            UIApplication.shared.open(url)
        } else {
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
                case "TikTok":
                    AppFunctions.openTikTok(userName: socialAccModel[indexPath.row].linkUrl)
                case "YouTube":
                    AppFunctions.openYouTube(channelName: socialAccModel[indexPath.row].linkUrl)
                case "Twitch":
                    AppFunctions.openTwitch(userName: socialAccModel[indexPath.row].linkUrl)
                case "Kickstarter":
                    AppFunctions.openKickstarter(userName: socialAccModel[indexPath.row].linkUrl)
                case "Venmo":
                    AppFunctions.openVenmo(userName: socialAccModel[indexPath.row].linkUrl)
                case "Shopify":
                    AppFunctions.openShopify(storeName: socialAccModel[indexPath.row].linkUrl)
                case "Discord":
                    AppFunctions.openDiscord(userName: socialAccModel[indexPath.row].linkUrl)
                case "PayPal":
                    AppFunctions.openPaypal(userName: socialAccModel[indexPath.row].linkUrl)
                case "Tumblr":
                    AppFunctions.openTumblr(userName: socialAccModel[indexPath.row].linkUrl)
                case "SoundCloud":
                    AppFunctions.openSoundCloud(userName: socialAccModel[indexPath.row].linkUrl)
                case "Quora":
                    AppFunctions.openQuora(userName: socialAccModel[indexPath.row].linkUrl)
                case "Spotify":
                    AppFunctions.openSpotify(userName: socialAccModel[indexPath.row].linkUrl)
                case "Pinterest":
                    AppFunctions.openPinterest(userName: socialAccModel[indexPath.row].linkUrl)
                case "WeChat":
                    AppFunctions.openWeChat(userName: socialAccModel[indexPath.row].linkUrl)
                case "Cash App":
                    AppFunctions.openCashApp(userName: socialAccModel[indexPath.row].linkUrl)
                case "Patreon":
                    AppFunctions.openPatreon(userName: socialAccModel[indexPath.row].linkUrl)
                case "Website":
                    AppFunctions.openWebLink(link: socialAccModel[indexPath.row].linkUrl, vc: self)
                default:
                    print("default")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

