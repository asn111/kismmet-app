//
//  AddLinksVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 18/02/2023.
//

import UIKit
import SDWebImage
import DropDown
import Firebase
import FirebaseAuth
import FacebookLogin
import TwitterKit
import OAuthSwift
import SCSDKLoginKit
import TikTokOpenAuthSDK
import FBSDKCoreKit
import FBSDKLoginKit



class AddLinksVC: MainViewController {

    @IBAction func linkItBtnPressed(_ sender: Any) {
        /*if linkId == 0 {
            AppFunctions.showSnackBar(str: "Select social platform before linking")
        } else {
            switch linkId {
                case 1:
                    print("linkedin")
                case 2:
                    loginWithTwitter()
                    // Usage example:
                    
                case 3:
                    print("Insta")
                case 4:
                    print("Snap")
                case 5:
                    print("website")
                case 6:
                    loginWithFacebook()
                case 7:
                    print("reddit")
                case 8:
                    print("tiktok")
                default:
                    print("default")
            }
        }*/
    }
    
    @IBAction func nameToolTip(_ sender: Any) {
        var msg = ""
        if accountType == "tags" {
            msg = "Please enter and save one interest-tag at a time.\nNo # hashtag is required before the word/words.\nMax 30 characters per tag."
        } else {
            msg = "Choose a name for your link that will be shown next to the icon on your profile. Use your username or something that helps others recognize you easily."
        }
        
        AppFunctions.showToolTip(str: msg, btn: sender as! UIButton)

    }
    @IBAction func toolTipLink(_ sender: Any) {
        let msg = "Enter the appropriate link based on the type you've chosen. For social media accounts like Twitter, Instagram, and Snapchat, enter your username without the '@' symbol. For LinkedIn, Facebook, and Reddit, use the username found at the end of the URL link. For websites, enter the full URL."
        AppFunctions.showToolTip(str: msg, btn: sender as! UIButton)
    }
    
    @IBAction func linkToolTip(_ sender: Any) {
        AppFunctions.openWebLink(link: "https://www.kismmet.com/howtolink", vc: self)
    }
    
    @IBAction func dropDownBtnPressed(_ sender: Any) {
            dropDown.show()
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        if accountType == "tags" {
            if accountName != "" {
                isUpdatedOnServer = true
                self.dismiss(animated: true)
                return
            } else {
                AppFunctions.showSnackBar(str: "All fields are required")
            }
        } else {
            //if accountName != "" && accountLink != "" && linkId != 0 {
            if accountName != "" && linkId != 0 {
                //userSocialAdd()
                // load auth func
                //AppFunctions.showSnackBar(str: "Acc Linked")
                if linkId == 0 {
                    AppFunctions.showSnackBar(str: "Select social platform before linking")
                } else {
                    switch linkId {
                        case 1:
                            loginWithLinkedIn()
                        case 2:
                            loginWithTwitter()
                        case 3:
                            loginWithInta()
                        case 4:
                            loginWithSnapchat()
                        case 5:
                            print("website")
                        case 6:
                            loginWithFacebook()
                        case 7:
                            loginWithReddit()
                        case 8:
                            loginWithTiktok()
                        default:
                            print("default")
                    }
                }
            } else {
                AppFunctions.showSnackBar(str: "All fields are required")
            }
        }
        
    }
    
    @IBOutlet weak var linkItBtn: RoundCornerButton!
    @IBOutlet weak var mainView: RoundCornerView!
    @IBOutlet weak var saveBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var cancelBtnTopConst: NSLayoutConstraint!
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    @IBOutlet weak var addAccView: RoundCornerView!
    @IBOutlet weak var accountTypeView: RoundCornerView!
    @IBOutlet weak var addAccName: FormTextField!
    @IBOutlet weak var adAccLink: RoundCornerView!
    @IBOutlet weak var addAccLink: FormTextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    var isKeyBoardShown = false
    var isUpdatedOnServer = false
    var accountType = ""
    var accountName = ""
    var accountLink = ""
    var linkId = 0
    let dropDown = DropDown()
    var oauthswift: OAuthSwift?
    
    var socialAccName = [String()] //["LinkedIn","Twitter","Instagram","Snapchat","Website"]
    var socialAccounts = [SocialAccDBModel()]
    var selectedSocialAccount = SocialAccDBModel()

    let provider = OAuthProvider(providerID: "twitter.com")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socialAccounts = Array(DBService.fetchSocialAccList())
        let tiktokobj = SocialAccDBModel()
        tiktokobj.linkTypeId = 8
        tiktokobj.linkType = "Tiktok"
        tiktokobj.linkImage = ""
        socialAccounts.append(tiktokobj)
        socialAccName = socialAccounts.compactMap { $0.linkType }
        
        setupDropDown()
        self.view.addBlurEffect(style: .extraLight, cornerRadius: 0, alpha: 0.5)
        
        self.view.bringSubviewToFront(mainView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tap)
        
        addAccName.delegate = self
        addAccLink.delegate = self
        addAccName.addDoneButtonOnKeyboard()
        addAccLink.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if accountType == "tags" {
            
            addAccName.delegate = self
            createNonDisappearingPlaceholder(for: addAccName, placeholderText: "#", font: UIFont.systemFont(ofSize: 16), color: UIColor(named: "Secondary Grey")!)

            adAccLink.isHidden = true
            headingLbl.text = "Find people with similar interests by searching tags in the feed. Choose 5 tags that represent you, your hobbies, and your passions."
            addAccName.placeholder = "Enter tag here"
            accountTypeView.isHidden = true
            saveBtnTopConst.constant = 120
            cancelBtnTopConst.constant = 120
            view.setNeedsLayout()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                
        if accountType == "tags" {
            if !isUpdatedOnServer { return }
            var arr = AppFunctions.getTagsArray()
            if arr.count >= 5 { return }
            arr.append(accountName)
            AppFunctions.setTagsArray(value: arr)
            generalPublisher.onNext("tagsAdded")
        } else {
            generalPublisher.onNext("socialAdded")
        }
    }


    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if accountType != "tags" {
            return true
        }
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return updatedText.count <= 30
        /*let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return !updatedText.contains(" ")*/
    }
    
    func createNonDisappearingPlaceholder(for textField: UITextField, placeholderText: String, font: UIFont, color: UIColor) {
        let attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        let placeholderLabel = UILabel()
        placeholderLabel.attributedText = attributedPlaceholder
        placeholderLabel.sizeToFit()
        
        textField.leftView = placeholderLabel
        textField.leftViewMode = .always
    }
    
    func setupDropDown() {
        
        dropDown.hide()
        dropDown.anchorView = dropDownBtn // UIView or UIBarButtonItem
        dropDown.dataSource = socialAccName
        dropDown.direction = .bottom
        
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 50
        appearance.backgroundColor = UIColor(named: "BG Base White")
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.separatorColor = UIColor(named: "Secondary Grey")!
        appearance.cornerRadius = 10
        //appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        //appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 15
        appearance.animationduration = 0.25
        appearance.textColor = UIColor(named: "Text grey")!
        appearance.textFont = UIFont(name: "Work Sans", size: 20)!
        appearance.setupMaskedCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            let account = self?.socialAccounts[index]

            self?.dropDownBtn.setTitle("  \(item)", for: .normal)
            
            if item == "Website" {
                self?.addAccName.placeholder = "Name your website link"
                self?.addAccLink.placeholder = "Enter your website’s full URL"
            } else {
                self?.addAccName.placeholder = "Name it"
                self?.addAccLink.placeholder = "Link it"
                self?.linkItBtn.setTitle("Link \(account?.linkType ?? "") here", for: .normal)

            }
            
            self?.linkId = account?.linkTypeId ?? 0
            if account?.linkImage != "" {
                let imageUrl = URL(string: account?.linkImage ?? "")
                
                // Create the transformer with the desired size and scale mode
                let transformer = SDImageResizingTransformer(size: CGSize(width: 20, height: 20), scaleMode: .aspectFit)

                self?.dropDownBtn.sd_setImage(with: imageUrl, for: .normal, placeholderImage: UIImage(named: "Website")?.resized(to: CGSize(width: 20, height: 20)), context: [.imageTransformer: transformer]) { (image, error, imageCacheType) in
                    // Perform any additional actions after the image is set
                }
            } else {
                self?.dropDownBtn.setImage(UIImage(named: "Website")?.resized(to: CGSize(width: 20, height: 20)), for: .normal)
            }
                        
        }
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == addAccName {
            accountName = !textField.text!.isTFBlank ? textField.text! : ""
        } else if textField == addAccLink {
            accountLink = !textField.text!.isTFBlank ? textField.text! : ""
        }
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if !isKeyBoardShown {
                isKeyBoardShown = true
                self.view.frame.origin.y -= keyboardSize.height - 50
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyBoardShown = false
        self.view.frame.origin.y = 0
    }
    
    func userSocialAdd() {
        self.showPKHUD(WithMessage: "Signing up")
        
        let pram : [String : Any] = [ "linkTitle": accountName,
                                      "linkURL": accountLink,
                                      "linkTypeId": linkId
        ]
        
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userSocialAdd(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.isUpdatedOnServer = true
                            self.dismiss(animated: true)
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

//MARK: Auth Functions

extension AddLinksVC {
    
    func loginWithReddit() {
        
        let oauthswift = OAuth2Swift(
            consumerKey:    "LUcUGE1Wbg2RyGQh8tk2_A",//serviceParameters["consumerKey"]!,
            consumerSecret: "LUcUGE1Wbg2RyGQh8tk2_A",//serviceParameters["consumerSecret"]!,
            authorizeUrl:   "https://www.reddit.com/api/v1/authorize.compact",
            accessTokenUrl: "https://www.reddit.com/api/v1/access_token",
            responseType:   "code",
            contentType:    "application/json"
        )
        self.oauthswift = oauthswift
        oauthswift.accessTokenBasicAuthentification = true
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "kismmet://reddit")!, scope: "identity", state: state) { result in
                switch result {
                    case .success(let (credential, _, _)):
                        print("\(credential)")
                        //self.showTokenAlert(name: serviceParameters["name"], credential: credential)
                    case .failure(let error):
                        Logs.show(message: "Reddet Failure error: \n\(error.localizedDescription)")
                        print(error.description)
                }
            }
        
    }
    
    func loginWithTiktok() {

        
        let authRequest = TikTokAuthRequest(scopes: ["user.info.basic"],
                                            redirectURI: "https://www.kismmet.com/tiktok/callback")
        /* Step 2 */
        authRequest.send { response in
            /* Step 3 */
            if let authResponse = response as? TikTokAuthResponse {
                if authResponse.errorCode == .noError {
                    print("Auth code: \(String(describing: authResponse.authCode))")
                } else {
                    print("Authorization Failed! Error: \(authResponse.error ?? "") Error Description: \(authResponse.errorDescription ?? "")")
                }
            }//else { return }
            
            }
    }
    
    
    //MARK:- Snapchat
    
    func loginWithSnapchat() {
        SCSDKLoginClient.login(from: self) { (success, error) in
            if let error = error {
                // Handle login error
                Logs.show(message: "Snap login Error: \(error)")

            } else if success {
                // Login successful!
                // Access user information (username, display name)
                //let username = user.dictionary

                Logs.show(message: "Snap User success: \(success)")
                
                let builder = SCSDKUserDataQueryBuilder()
                    .withDisplayName()
                    .withIdToken()
                    .withExternalId()
                    .withProfileLink()
                    .withBitmojiAvatarID()
                    .withBitmojiTwoDAvatarUrl()
                SCSDKLoginClient.fetchUserData(
                    with: builder.build(),
                    success:  { (userData, errors) in
                        let displayName = userData?.displayName ?? ""
                        let avatar = userData?.bitmojiTwoDAvatarUrl ?? ""
                        
                        dump(userData.value)
                    },
                    failure: { (error: Error?, isUserLoggedOut: Bool) in
                        if let error = error {
                            print(String.init(format: "Failed to fetch user data. Details: %@", error.localizedDescription))
                        }
                    })
                
                // Proceed to your app's functionality

            }
        }
    }
    
    //MARK:- Twitter
    
    func loginWithTwitter() {
                
        //TWTRTwitter.sharedInstance().start(withConsumerKey: "1779847385755095040-IeLBAhAhgukWr8UbDEKlxrRjynSQ3W", consumerSecret: "LdUB9ukAMYKFdYlWDve2V7gHQaIQaxuCibFpXFR24Zhog") // Dev@kismmet

        TWTRTwitter.sharedInstance().logIn { (session, error) in
            
            if (session != nil) {
                
                Logs.show(message: "X USer signed in as \(session!.userName)");
                let client = TWTRAPIClient.withCurrentUser()
                
                let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/account/verify_credentials.json", parameters: ["include_entities": "false", "include_email": "true", "skip_status": "true"], error: nil)
                
                client.sendTwitterRequest(request) { response, data, connectionError in
                    
                    if connectionError != nil {
                        Logs.show(message: "X USer Error: \(String(describing: connectionError))")
                        
                    }else{
                        do {
                            let twitterJson = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:AnyObject]
                            
                            let name = twitterJson["name"]
                            //let id = twitterJson["id"]
                            //let email = twitterJson["email"]
                            //let image = twitterJson["profile_image_url_https"]
                            
                            Logs.show(message: "X USer: \(name!)")
                                                        
                        } catch let jsonError as NSError {
                            Logs.show(message: "X USer json error: \(jsonError.localizedDescription)")
                            
                        }
                    }
                    
                }
                
            } else {
                Logs.show(message: "X USer error: \(error!.localizedDescription)");
            }
        }
        
        /*TWTRTwitter.sharedInstance().logIn { session, error in
            if session != nil {
                // User logged in successfully
                print("Logged in as @\(session!.userName)")
                
                // Get username and potentially other user details (explained later)
            } else if let error = error {
                print("Twitter login error: \(error.localizedDescription)")
            }
        }*/
        
        /*provider.getCredentialWith(nil) { credential, error in
            if error != nil {
                // Handle error.
                print("Twitter credential error: \(error!.localizedDescription)")
                
                return
            }
            if credential != nil {
                Auth.auth().signIn(with: credential!) { authResult, error in
                    if error != nil {
                        print("Twitter login error: \(error!.localizedDescription)")
                        
                        return
                        // Handle error.
                    }
                    guard let user = authResult?.user else { return }
                    // User successfully signed in
                    Logs.show(message: "X USer: \(String(describing: user.displayName))")
                    
                    if let credential = authResult?.credential as? OAuthCredential {
                        // Proceed with token revocation (see next point)
                        Logs.show(message: "X USer credential: \(credential)")

                    } else {
                        // Handle non-OAuth login methods (if applicable)
                    }

                    let auth = Auth.auth()
                    
                    try! auth.signOut()
                    
                    
                    // User is signed in.
                    // IdP data available in authResult.additionalUserInfo.profile.
                    // Twitter OAuth access token can also be retrieved by:
                    // (authResult.credential as? OAuthCredential)?.accessToken
                    // Twitter OAuth ID token can be retrieved by calling:
                    // (authResult.credential as? OAuthCredential)?.idToken
                    // Twitter OAuth secret can be retrieved by calling:
                    // (authResult.credential as? OAuthCredential)?.secret
                }
            }
        }*/
        
        /*let provider = TwitterAuthProvider.credential(withToken: "1779847385755095040-IeLBAhAhgukWr8UbDEKlxrRjynSQ3W", secret: "LdUB9ukAMYKFdYlWDve2V7gHQaIQaxuCibFpXFR24Zhog")
        
        Auth.auth().signIn(with: provider) { (result, error) in
            if let error = error {
                // Login failed
                print("Twitter login error: \(error.localizedDescription)")
                
                // Handle the error appropriately, e.g., display an error message to the user
                return
            }
            
            guard let user = result?.user else { return }
            // User successfully signed in
            print("User signed in with Twitter: \(user.uid)")
            Logs.show(message: "X USer: \(user)")
            dump(user)

            // Optionally, access user information from the result
            let username = user.displayName
            let email = user.email // Note: Twitter login typically doesn't provide email
            
            // Store user information or perform actions based on successful login
        }*/
    }
    
    func fetchUserProfile() {
        let graphRequest : GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, name"])
        
        //let params = ["key": "value"] // Replace with your actual parameters
        //let graphRequest = GraphRequest(graphPath: "link", parameters: params, httpMethod: HTTPMethod(rawValue: "GET") )

        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if let error = error {
                print("Error took place: \(error)")
            } else {
                print("Print entire fetched result: \(String(describing: result))")
                
                if let res = result as? [String:String] {
                    
                    if let id = res["id"] {
                        print("User ID is: \(id)")
                        
                        /*let params = ["fields":"id, name, link"] // Replace with your actual parameters
                        let request = GraphRequest(graphPath: "/\(id)", parameters: params, httpMethod: HTTPMethod(rawValue: "GET") )
                        request.start(completionHandler: { (connection, result, error) in
                            if let error = error {
                                print("Error: \(error)")
                            } else if let result = result as? [String: Any] {
                                // Handle the result
                                print(result)
                            }
                        })*/
                    }
                                        
                    

                }
                
                
                //if let userName = result.value(forKey: "name") as? String {
                    //print("User Name is: \(userName)")
                //}
                
                // Additional code to handle profile picture if needed
            }
        })
    }

    func loginWithFacebook() {
        let loginManager = LoginManager()
        
        loginManager.logOut()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                // Login failed
                print("Facebook login error FB: \(error.localizedDescription)")
                
                // Handle the error appropriately, e.g., display an error message to the user
                return
            }
            
            //guard let accessToken = AccessToken.current else {
                //print("Failed to obtain Facebook access token")
                //return
            //}
            
            guard let accessToken = AccessToken.current?.tokenString else {
                print("Failed to obtain Facebook access token")
                return
            }
            

            Logs.show(message: "FB TOKEN: \(accessToken)")
            self.fetchUserProfile()
            


            
            /*let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { (result, error) in
                if let error = error {
                    // Login failed
                    print("Firebase login error fb: \(error.localizedDescription)")
                    
                    // Handle the error appropriately, e.g., display an error message to the user
                    return
                }
                
                guard let user = result?.user else { return }
                // User successfully signed in
                //print("User signed in with Facebook: \(user.uid)")
                
                Logs.show(message: "FB USer: \(user)")
                
                // Optionally, access user information from the result
                //let username = user.displayName
                //let email = user.email
                
                // Store user information or perform actions based on successful login
            }*/
        }
    }

    // MARK: Instagram
    func loginWithInta(){
        let oauthswift = OAuth2Swift(
            consumerKey:    "316301091337244",
            consumerSecret: "52ae2f817b0c07e25f0fb8cc159daf5b",
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "code"
            // or
            // accessTokenUrl: "https://api.instagram.com/oauth/access_token",
            // responseType:   "code"
        )
        
        let state = generateState(withLength: 20)
        self.oauthswift = oauthswift
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.kismmet.com/src/assets/apple-app-site-association")!, scope: "user_profile", state:state) { result in
                switch result {
                    case .success(let (credential, _, _)):
                        //self.testInstagram(oauthswift)
                        print(credential)
                    case .failure(let error):
                        print(error.description)
                }
            }
    }
    
    func testInstagram(_ oauthswift: OAuth2Swift) {
        let url :String = "https://api.instagram.com/v1/users/1574083/?access_token=\(oauthswift.client.credential.oauthToken)"
        let parameters :Dictionary = Dictionary<String, AnyObject>()
        let _ = oauthswift.client.get(url, parameters: parameters) { result in
            switch result {
                case .success(let response):
                    let jsonDict = try? response.jsonObject()
                    print(jsonDict as Any)
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    
    /*func loginWithInta() {
        
        //let urlString = "https://api.instagram.com/oauth/access_token?client_id=316301091337244&client_secret=52ae2f817b0c07e25f0fb8cc159daf5b&code=code&grant_type=authorization_code&redirect_uri=https://www.kismmet.com/insta/callback"
        
        let urlString = "https://api.instagram.com/oauth/authorize?client_id=316301091337244&redirect_uri=https://www.kismmet.com/insta/callback&scope=user_profile,user_media&response_type=token"
        
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let err = error {
                print("Insta Error: \(err)")
                return
            }
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                
                print("\nInsta res: \(response)")

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if json?["access_token"] is String {
                        // Use the Instagram access token to fetch user details
                        //self.fetchInstagramUserDetails(accessToken: accessToken)
                    } else {
                        // Handle error: access token not found
                    }
                } catch {
                    // Handle JSON parsing error
                }
            } else {
                // Handle network error
            }
        }.resume()

        
    }*/
    
    
    
    func loginWithLinkedIn() {
        // create an instance and retain it
        let oauthswift = OAuth2Swift(
            consumerKey:    "78r0k84piwtids",
            consumerSecret: "XcxDuZcNFzsskX1P",
            authorizeUrl:   "https://www.linkedin.com/uas/oauth2/authorization",
            accessTokenUrl: "https://www.linkedin.com/uas/oauth2/accessToken",
            responseType:   "code"
        )
        
        // authorize
        self.oauthswift = oauthswift
        let state = generateState(withLength: 20)
        _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://www.kismmet.com/auth/linkedin/callback"), scope: "profile", state: state) { result in
                switch result {
                    case .success(let (credential, _, parameters)):
                        print(credential.oauthToken)
                        print(credential.oauthTokenSecret)
                        print(parameters["user_id"] ?? "")
                        // Do your request
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
    }
 
    
    public func generateState(withLength len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.count)
        
        var randomString = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
            let letter = letters[idx]
            randomString += String(letter)
        }
        return randomString
    }
}
