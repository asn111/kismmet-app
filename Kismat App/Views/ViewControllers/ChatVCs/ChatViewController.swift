//
//  ChatViewController.swift
//  GreenEntertainment
//
//  Created by Prateek Keshari on 13/06/20.
//  Copyright © 2020 Quytech. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SDWebImage


class ChatViewController: MainViewController {
    @IBOutlet weak var userNameLabel: fullyCustomLbl!

    @IBOutlet weak var userImageView: RoundedImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var onlineView: RoundCornerView!
    
    //var user = User()
    //var file: AttachmentInfo?
    var chats = [ChatModel]()
    
    //var chatModel = ChatModel()
    
    var userId = ""
    var userName = ""
    var userProfilePic = ""
    var isOnline = false
    var chatId =  0
    
    var offset =  0  // -10
    var user1 = [String:Any]()
    var isMoreData = true
    var isPresented = false
    var refreshControl: UIRefreshControl!
    
    //MARK: UIViewController LifeCycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        _ = generalPublisherChat.subscribe(onNext: {[weak self] val in
            
            self?.chats.append(val)
            self?.tableView.reloadData()
            self?.scrollToBottom()
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        initialMethod()
        getChats()
        //getMessageHistory()
        //messagesListner()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    
    
    //MARK: Helper Method
    func initialMethod() {
        pullToRefersh()
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
        //userImageView.layer.cornerRadius = userImageView.frame.height / 2
        //userImageView.clipsToBounds = true
        //userImageView.layer.borderWidth = 1.0
        //userImageView.layer.masksToBounds = true
        //userImageView.layer.borderColor = UIColor.darkGray.cgColor
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(openProfileScreen))
        self.userImageView.addGestureRecognizer(tapGesture)
        customSetup()
    }
    
    func customSetup(){
        
        userNameLabel.text = userName.capitalized
        
        onlineView.isHidden = !isOnline
        
        if let url = URL(string: userProfilePic) {
            userImageView.sd_setImage(with: url , placeholderImage: UIImage(named: "")) { (image, error, imageCacheType, url) in }
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
        if self.chats.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.chats.count - 1 , section: 0), at:.bottom, animated: false)
        }
    }
    
    //MARK: UIButton Action Method
    @IBAction func backButtonAction(_ sender: UIButton){
        if isPresented {
            self.dismiss(animated: true)
        }   else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sendButtonAction(_ sender: UIButton){
        self.view.endEditing(true)
        if chatTextView.text.isEmpty {
            AppFunctions.showSnackBar(str: "Please enter message.")
        }else {
            sendMessageToUser()
        }
    }

    
    @IBAction func donateButtonAction(_ sender: UIButton) {
        
        
    }
    
    //MARK: SignalR method

    func sendMessageToUser() {
        
        let pram = ["chatId": chatId > 0 ? "\(chatId)" : "",
                    "recipient":"\(userId)",
                    "chatMessage": "\(chatTextView.text ?? "")"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        SignalRService.connection.invoke(method: "SendMessage", pram) {  error in
            if let e = error {
                Logs.show(message: "Error: \(e)")
                AppFunctions.showSnackBar(str: "Error in sending message")
                return
            }
            self.chatTextView.text = ""
            self.view.endEditing(true)
            self.scrollToBottom()
        }
    }
    
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - UITableViewDelegateDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let obj = chats[indexPath.row]
        Logs.show(message:  "UserID: " + AppFunctions.getUserId())
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
        
        self.showPKHUD(WithMessage: "Fetching...")
        
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
