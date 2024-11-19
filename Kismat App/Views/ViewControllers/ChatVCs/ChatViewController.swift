

import UIKit
import IQKeyboardManagerSwift
import SDWebImage
import DropDown
import RxSwift

class ChatViewController: MainViewController {
    @IBOutlet weak var userNameLabel: fullyCustomLbl!

    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var workLbl: fullyCustomLbl!
    
    @IBOutlet weak var userNameLabelM: fullyCustomLbl!
    
    @IBOutlet weak var userImageViewM: RoundedImageView!
    @IBOutlet weak var workLblM: fullyCustomLbl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var onlineView: RoundCornerView!
    
    @IBOutlet var moreView: UIView!
    @IBOutlet weak var profileView: RoundCornerView!
    @IBOutlet weak var profileViewS: UIView!
    @IBOutlet weak var clearChatView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        
        if isPresented {
            self.dismiss(animated: true)
        }   else {
            navigationController?.popViewController(animated: true)
        }
    }
    //var user = User()
    //var file: AttachmentInfo?
    var chats = [ChatModelArray]()
    
    let dropDown = DropDown()
    var ddOptions = ["View Profile","Clear Chat","Delete Chat"]

    //var chatModel = ChatModel()
    
    var userId = ""
    var userName = ""
    var workTitle = ""
    var userProfilePic = ""
    var isOnline = false
    var chatId =  0
    
    var offset =  0  // -10
    var user1 = [String:Any]()
    var isMoreData = true
    var isPresented = false
    var refreshControl: UIRefreshControl!
    
    private var disposeBag = DisposeBag() // DisposeBag specific to this view

    
    //MARK: UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reset the disposeBag to ensure a new subscription setup each time the view appears
        disposeBag = DisposeBag()
        
        // Subscribe to the publisher when the view is visible
        generalPublisherChat.subscribe(onNext: {[weak self] val in
            guard let self = self else { return }
            
            if self.chats.isEmpty {
                let chat = ChatModelArray()
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                let dateString = dateFormatter.string(from: date)
                
                chat.dayHeader = dateString
                chat.messages.append(val)
                self.chats.append(chat)
                self.tableView.reloadData()
                self.scrollToBottom()
                self.markMsgRead()
            } else {
                self.chats.last?.messages.append(val)
                self.tableView.reloadData()
                self.scrollToBottom()
                self.markMsgRead()
            }
            
        }, onError: { print($0.localizedDescription) }, onCompleted: { print("Completed") }, onDisposed: { print("disposed") })
        .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Dispose of the current subscription when the view goes off-screen
        disposeBag = DisposeBag() // This will cancel the current subscription
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        initialMethod()
        getChats()
        //getMessageHistory()
        //messagesListner()
    }

    
    
    //MARK: Helper Method
    func initialMethod() {
        pullToRefersh()
        tableView.register(UINib(nibName: "EmptyChatView", bundle: nil), forCellReuseIdentifier: "EmptyChatView")
        tableView.register(UINib(nibName: "SenderChatCell", bundle: nil), forCellReuseIdentifier: "SenderChatCell")
        tableView.register(UINib(nibName: "ReceiverChatCell", bundle: nil), forCellReuseIdentifier: "ReceiverChatCell")
        
        tableView.register(UINib(nibName: "SenderImageTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderImageTableViewCell")
        tableView.register(UINib(nibName: "ReceiverImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverImageTableViewCell")
        tableView.register(UINib(nibName: "SenderShareTableViewCell", bundle: nil), forCellReuseIdentifier: "SenderShareTableViewCell")
        tableView.register(UINib(nibName: "ReceiverShareTableViewCell", bundle: nil), forCellReuseIdentifier: "ReceiverShareTableViewCell")
        
        
        chatTextView.delegate = self
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openProfileScreen))
        self.profileView.addGestureRecognizer(tapGesture)
        
        let tapGestureProfile = UITapGestureRecognizer.init(target: self, action: #selector(openProfileScreen))
        self.profileViewS.addGestureRecognizer(tapGestureProfile)
        
        let tapGestureDelChat = UITapGestureRecognizer.init(target: self, action: #selector(openDialogVC))
        self.deleteView.addGestureRecognizer(tapGestureDelChat)
        
        let tapGestureMore = UITapGestureRecognizer.init(target: self, action: #selector(dismissMoreView))
        self.tableView.addGestureRecognizer(tapGestureMore)
        
        customSetup()
    }
    
    func customSetup(){
        
        userNameLabel.text = userName
        userNameLabelM.text = userName
        workLbl.text = workTitle
        workLblM.text = workTitle
        
        onlineView.isHidden = !isOnline
        
        moreView.layer.cornerRadius = 16
        moreView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
        if let url = URL(string: userProfilePic) {
            userImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
            
            userImageViewM.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
        }
    }
    
    func moreBtnPressed(sender: UIButton) {
        dropDown.show()
        dropDown.anchorView = sender // UIView or UIBarButtonItem
        dropDown.dataSource = ddOptions
        dropDown.direction = .any
        
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 30
        appearance.backgroundColor = UIColor.white
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 4
        //appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        //appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 15
        appearance.animationduration = 0.25
        appearance.textColor = UIColor(named: "Text grey") ?? .darkGray
        appearance.textFont = UIFont(name: "Roboto", size: 12)!
        appearance.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        // Action triggered on selection
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            if index == 0 {
                self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                    vc.userId = self.userId
                    //vc.markView = true
                }
            }
        }
    }
    
    func pullToRefersh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        // refresh tableView
        self.offset = self.offset + 10
        //self.getMessageHistory()
        refreshControl.endRefreshing()
    }

    @objc func openProfileScreen(){
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.3) {
            self.moreView.alpha = self.moreView.isHidden ? 1 : 0
            self.moreView.isHidden.toggle()
        }
        
        if isPresented {
            self.presentVC(id: "OtherUserProfile", presentFullType: "over" ) { (vc:OtherUserProfile) in
                vc.userId = userId
                vc.isFromMessage = true
                vc.isPresented = true
            }
        } else {
            
            self.pushVC(id: "OtherUserProfile") { (vc:OtherUserProfile) in
                vc.userId = userId
                vc.isFromMessage = true
            }
        }
    }
    
    @objc func dismissMoreView(){
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.3) {
            self.moreView.alpha = self.moreView.isHidden ? 1 : 0
            self.moreView.isHidden.toggle()
        }
    }
    
    @objc func openDialogVC(){
        
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.3) {
            self.moreView.alpha = self.moreView.isHidden ? 1 : 0
            self.moreView.isHidden.toggle()
        }
        if chatId == 0 { return }
        self.presentVC(id: "ImportantDialogVC", presentFullType: "over" ) { (vc:ImportantDialogVC) in
            vc.dialogType = "DeleteChat"
            vc.chatId = chatId
        }
    }
    
    
    //MARK: Keyboard Methods
    @objc func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            if let keyboardHeight = keyboardHeight {
                viewBottomConstraint.constant = -keyboardHeight
                UIView.animate(withDuration: duration, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.perform(#selector(self.scrollToBottom), with: nil, afterDelay: 0.0)
                })
            }
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        viewBottomConstraint.constant = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded()
        })
        self.perform(#selector(scrollToBottom), with: nil, afterDelay: 0.2)
    }
    
    //MARK: Target Method
    @objc func scrollToBottom() {
        if let lastChat = self.chats.last, lastChat.messages.count > 0 {
            let lastRowIndex = lastChat.messages.count - 1
            let lastSectionIndex = self.tableView.numberOfSections - 1
            
            // Add extra bottom inset if the last cell is being cut off
            let bottomInset: CGFloat = 5 // Adjust as needed
            self.tableView.contentInset.bottom = bottomInset
            
            // Ensure the section and row are within bounds
            if lastSectionIndex >= 0, lastRowIndex < self.tableView.numberOfRows(inSection: lastSectionIndex) {
                let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                
                // Step 1: Scroll to the last message
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                
                // Step 2: Scroll further to account for the bottom inset
                DispatchQueue.main.async {
                    // Calculate the content offset to scroll to the bottom inset
                    let contentHeight = self.tableView.contentSize.height
                    let tableViewHeight = self.tableView.bounds.height
                    let offset = CGPoint(x: 0, y: contentHeight - tableViewHeight + self.tableView.contentInset.bottom)
                    
                    // Ensure we don't scroll past the content height
                    if contentHeight > tableViewHeight {
                        self.tableView.setContentOffset(offset, animated: true)
                    }
                }
            }
        }
    }

    
    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        
        //moreBtnPressed(sender: sender)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.3) {
            self.moreView.alpha = self.moreView.isHidden ? 1 : 0
            self.moreView.isHidden.toggle()
        }
       
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton){
        //self.view.endEditing(true)
        if chatTextView.text.isEmpty {
            AppFunctions.showSnackBar(str: "Please enter message.")
        }else {
            sendMessageToUser()
        }
    }

    
    @IBAction func donateButtonAction(_ sender: UIButton) {
        
        
    }
    
    
    func convertStringToFormattedString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // Input format (should match the input date string)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.locale = Locale(identifier: "en_US") // Ensure locale is set to English
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Treat the input as GMT/UTC
        
        // Attempt to parse the date string
        guard let date = dateFormatter.date(from: dateString) else {
            print("Failed to parse date: \(dateString)")
            return nil
        }
        
        // Check if the date is today, yesterday, or earlier
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            // Output format (desired output for dates older than yesterday)
            dateFormatter.dateFormat = "EEEE, dd MMM"
            dateFormatter.timeZone = TimeZone.current // Convert to the current timezone
            return dateFormatter.string(from: date)
        }
    }

    
    //MARK: SignalR method

    func sendMessageToUser() {
        
        let pram = ["chatId": chatId > 0 ? "\(chatId)" : "",
                    "recipient":"\(userId)",
                    "chatMessage": "\(chatTextView.text ?? "")"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        SignalRManager.singelton.connection.invoke(method: "SendMessage", pram) {  error in
            if let e = error {
                Logs.show(message: "Error in sending message: \(e)")
                AppFunctions.showSnackBar(str: "Error in sending message")
                return
            }
            self.chatTextView.text = ""
            self.scrollToBottom()
        }
    }
    
    func markMsgRead() {
        
        if let lastChat = self.chats.last, lastChat.messages.count > 0 {
            
            let pram = ["messageId": "\(lastChat.messages.last?.messageId ?? 0)"]
            
            Logs.show(message: "PRAM: \(pram)")
            
            SignalRManager.singelton.connection.invoke(method: "UpdateMessageStatusToRead", pram) {  error in
                if let e = error {
                    Logs.show(message: "Error in mark message read: \(e)")
                    //AppFunctions.showSnackBar(str: "Error in mark message read")
                    return
                }
            }
        }
        
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - UITableViewDelegateDataSource Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return chats.count > 0 ? chats.count : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count > 0 ? chats[section].messages.count : 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if chats.isEmpty {
            
            let headerView = UIView()
            headerView.backgroundColor = .clear
            return headerView
        }
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        let headerLabel = fullyCustomLbl()
        headerLabel.font = UIFont(name: "Roboto", size: 12)?.light
        headerLabel.textColor = UIColor(named: "Text grey")
        headerLabel.text = (convertStringToFormattedString(chats[section].dayHeader) ?? "")
        headerLabel.textAlignment = .center
        
        // Add label to the header view
        headerView.addSubview(headerLabel)
        
        // Set the constraints for centering the label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Center horizontally in the header view
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            // Center vertically in the header view
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if chats.isEmpty {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyChatView", for: indexPath) as! EmptyChatView
            
            cell.emptyLbl.text = "No messages yet. Start the conversation now and keep the discussion respectful and courteous."
            cell.emptyViewBtn.isHidden = true
            return cell
        } else {
            // Get the array of messages for the current section
            let messages = chats[indexPath.section].messages
            
            // Get the message object for the current row
            let obj = messages[indexPath.row]
            
            if obj.senderId == AppFunctions.getUserId() {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderChatCell", for: indexPath) as! SenderChatCell
                cell.populateCell(obj: obj)
                cell.vc = self
                cell.shapeView.setNeedsDisplay()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverChatCell", for: indexPath) as! ReceiverChatCell
                cell.populateCell(obj: obj)
                cell.vc = self
                cell.shapeView.setNeedsDisplay()
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //pagination
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.frame.size.height + scrollView.contentOffset.y) >= scrollView.contentSize.height{
            //  self.offset = offset + 10
            if isMoreData {
                // getMessageHistory()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
    }
}

//MARK: - decription and encryption
extension String {
    
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self.replacingOccurrences(of: "\n", with: "")) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}

extension ChatViewController {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard var str = textView.text, let range = Range(range, in: str) else { return true }
        str = str.replacingCharacters(in: range, with: text)
        
        let numLines = Double(textView.contentSize.height) / Double(textView.font?.lineHeight ?? 16)
        textView.isScrollEnabled = numLines > 6
        self.view.layoutSubviews()
        DispatchQueue.main.async {
            self.scrollToBottom()
        }
        
        return true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
    }
    
}

extension ChatViewController {
    
    func getChats() {
        
        //self.showPKHUD(WithMessage: "Fetching...")
        
        let pram : [String : Any] = ["userId": userId]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .getChats(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.count > 0 {
                            self.chats.removeAll()
                            self.chats = val
                            self.tableView.reloadData()
                            self.scrollToBottom()
                            self.hidePKHUD()
                            self.markMsgRead()
                            if let allMsg = val.first?.messages {
                                if let id = allMsg.first?.chatId {
                                    self.chatId = id
                                }
                            }
                        } else {
                            self.hidePKHUD()
                            self.chats.removeAll()
                            self.tableView.reloadData()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                        self.chats.removeAll()
                        self.tableView.reloadData()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                        self.tableView.reloadData()
                }
            })
            .disposed(by: dispose_Bag)
    }
}
