//
//  SignInVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import GoogleSignIn
import AuthenticationServices
import SafariServices


class SignInVC: MainViewController {

    @IBAction func SignInBtnPressed(_ sender: Any) {
        if email != "" && password != "" {
            isKeyBoardShown = false
            view.endEditing(true)
            userLogin()
        } else {
            AppFunctions.showSnackBar(str: "Invalid or Empty Feilds")
        }
    }
    
    @IBOutlet weak var googleLbl: fullyCustomLbl!
    @IBAction func googleSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            let emailAddress = user.profile?.email
            
            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName
            
            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            Logs.show(message: "\(String(describing: user.profile?.name))")
            Logs.show(message: "\(String(describing: user.idToken?.tokenString))")
            //self.socialLoginUser(providor: "Google", token: user.authentication.idToken)
            self.userSocialLogin(token: user.idToken?.tokenString ?? "", provider: "Google")


        }
    }
    
    @IBOutlet weak var tcNppLbl: fullyCustomLbl!
    @IBOutlet weak var appleLbl: fullyCustomLbl!
    @IBAction func appleSignInPressed(_ sender: Any) {
        handleAppleIdRequest()
    }
    
    @IBAction func forgotPassPressed(_ sender: Any) {
        self.presentVC(id: "CodeVerification_VC") { (vc:CodeVerification_VC) in }

    }
    
    @IBOutlet weak var emailTF: FormTextField!
    @IBOutlet weak var passwordTF: FormTextField!
    
    @IBOutlet weak var signUpLbl: fullyCustomLbl!
    
    var isKeyBoardShown = false
    var email = ""
    var password = ""
    weak var activeTextField: UITextField?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTF.delegate = self
        passwordTF.delegate = self
        emailTF.addDoneButtonOnKeyboard()
        passwordTF.addDoneButtonOnKeyboard()
        passwordTF.enablePasswordToggle()

        setupLbl()
        setupTCnPP()
        setupClickableLbls()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        // Do any additional setup after loading the view.
    }

    func setupLbl() {
        let text = "Don’t have an account? Sign up"
        let textRange = NSRange(location: 23, length: 7)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.medium , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81") , range: textRange)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: textRange)
        signUpLbl.attributedText = attributedText
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        signUpLbl.addGestureRecognizer(tapGesture)
        signUpLbl.isUserInteractionEnabled = true
    }
    
    func setupTCnPP() {
        let text = "By signing up, you agree to our Terms & Conditions and Privacy Policy"
        let attributedText = NSMutableAttributedString(string: text)
        
        // Apply global styling
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        // Styling for "Terms & Conditions"
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.medium, range: termsRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81"), range: termsRange)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: termsRange)
        
        // Styling for "Privacy Policy"
        let policyRange = (text as NSString).range(of: "Privacy Policy")
        attributedText.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Roboto", size: 14)!.medium, range: policyRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hexFromString: "4E6E81"), range: policyRange)
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.thick.rawValue, range: policyRange)
        
        tcNppLbl.attributedText = attributedText
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTCnPPTap))
        tcNppLbl.addGestureRecognizer(tapGesture)
        tcNppLbl.isUserInteractionEnabled = true
    }
    
    @objc func handleTCnPPTap(_ gesture: UITapGestureRecognizer) {
        guard let attributedText = tcNppLbl.attributedText else { return }
        let location = gesture.location(in: tcNppLbl)
        
        // Calculate the text container size based on the label's frame
        let textContainerSize = CGSize(width: tcNppLbl.frame.width, height: CGFloat.greatestFiniteMagnitude)
        let textContainer = NSTextContainer(size: textContainerSize)
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        // Create a text storage object and add the layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)
        
        // Calculate the character index at the tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Define ranges for "Terms & Conditions" and "Privacy Policy"
        let termsRange = (attributedText.string as NSString).range(of: "Terms & Conditions")
        let policyRange = (attributedText.string as NSString).range(of: "Privacy Policy")
        
        // Check if the tap occurred within these ranges
        if NSLocationInRange(characterIndex, termsRange) {
            if let tosUrl = URL(string: "https://www.kismmet.com/termsofservices") {
                let safariVC = SFSafariViewController(url: tosUrl)
                present(safariVC, animated: true)
            }
            // Handle Terms & Conditions tap
        } else if NSLocationInRange(characterIndex, policyRange) {
            print("Privacy Policy tapped")
            if let privacyPolicyURL = URL(string: "https://www.kismmet.com/privacypolicy") {
                let safariVC = SFSafariViewController(url: privacyPolicyURL)
                present(safariVC, animated: true)
            }
            // Handle Privacy Policy tap
        }
    }
    
    func setupClickableLbls() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(googleTapFunction(sender:)))
        googleLbl.isUserInteractionEnabled = true
        googleLbl.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(appleTapFunction(sender:)))
        //appleLbl.isUserInteractionEnabled = true
        //appleLbl.addGestureRecognizer(tap2)
    }
    
    //MARK: objc Functions

    @objc func handleTap() {
        self.presentVC(id: "SignupVC") { (vc:SignupVC) in }
    }
    
    @objc
    func googleTapFunction(sender:UITapGestureRecognizer) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            let emailAddress = user.profile?.email
            
            let fullName = user.profile?.name
            let givenName = user.profile?.givenName
            let familyName = user.profile?.familyName
            
            let profilePicUrl = user.profile?.imageURL(withDimension: 320)
            
            Logs.show(message: "\(String(describing: user.profile?.name))")
            Logs.show(message: "\(String(describing: user.idToken?.tokenString))")
            //self.socialLoginUser(providor: "Google", token: user.authentication.idToken)
            self.userSocialLogin(token: user.idToken?.tokenString ?? "", provider: "Google")
            
        }
    }
    
    @objc
    func appleTapFunction(sender:UITapGestureRecognizer) {
        handleAppleIdRequest()
    }
    
    @objc func textFieldDidChangeSelection(_ textField: UITextField) {
        Logs.show(message: "\(textField.text ?? "nil")")
        activeTextField = textField

        if textField == emailTF {
            email = textField.text!.isValidEmail ? textField.text! : ""
        } else if textField == passwordTF {
            password = !textField.text!.isTFBlank ? textField.text! : ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    @objc func action() {
        isKeyBoardShown = false
        view.endEditing(true)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var activeView: UIView?
        if let activeTextField = activeTextField {
            activeView = activeTextField
        }
        
        if let activeView = activeView {
            let frameInWindow = activeView.superview?.convert(activeView.frame, to: nil)
            let bottomOfTextField = frameInWindow?.maxY ??  0
            let topOfKeyboard = UIScreen.main.bounds.height - keyboardSize.height
            
            if bottomOfTextField > topOfKeyboard && self.view.frame.origin.y >=  0 {
                self.view.frame.origin.y -= bottomOfTextField - topOfKeyboard
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyBoardShown = false
        self.view.frame.origin.y = 0
    }
    
    @objc
    func handleAppleIdRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    //MARK: API Functions
    
    func sendLocationOnLogin() {
        let lat = initalLatitude
        let long = initalLongitude
        
        let pram = ["lat": "\(lat)",
                    "long":"\(long)"
        ]
        SignalRService.connection.invoke(method: "UpdateUserLocation", pram) {  error in
            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    
    func userLogin() {
        self.showPKHUD(WithMessage: "Logging In")
        
        let pram : [String : Any] = ["email": email,
                                     "password": password,
                                     "deviceId":UIDevice.current.identifierForVendor!.uuidString,
                                     "deviceName":UIDevice.modelName,
                                     "devicePlatform":"iOS"]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userLogin(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            
                            SignalRService.chatHubConnectionDelegate = self
                            SignalRService.initializeSignalR()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.sendLocationOnLogin()
                                self.startUpCall()
                                self.userProfile()
                                self.getSocialAccounts()
                            }
                            
                           
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
    
    func userSocialLogin(token: String, provider: String) {
        //self.showPKHUD(WithMessage: "Logging In")
        
        let pram : [String : Any] = ["provider": provider,
                                     "token": token,
                                     "deviceId":UIDevice.current.identifierForVendor!.uuidString,
                                     "deviceName":UIDevice.modelName,
                                     "devicePlatform":"iOS"]
        Logs.show(message: "SKILLS PRAM: \(pram)")
        
        APIService
            .singelton
            .userSocialLogin(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            if AppFunctions.IsProfileUpdated() {
                                
                                SignalRService.chatHubConnectionDelegate = self
                                SignalRService.initializeSignalR()
                                
                                sendLocationOnLogin()
                                
                                self.startUpCall()
                                self.userProfile()
                                self.getSocialAccounts()
                            } else {
                                self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
                            }
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
    
    
    func startUpCall() {
        
        APIService
            .singelton
            .startUpCall(vc: self)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.accountStatusId != 0 {
                            
                            if let subs = val.subscription {
                                if subs == "Premium Plan" {
                                    AppFunctions.setIsPremiumUser(value: true)
                                } else {
                                    AppFunctions.setIsPremiumUser(value: false)
                                }
                            }
                            
                            if let shadowMode = val.shadowMode {
                                AppFunctions.setIsShadowMode(value: shadowMode)
                                
                            }
                            
                            if let profVis = val.isProfileVisible {
                                AppFunctions.setIsProfileVisble(value: profVis)
                                
                            }
                            
                            if let profVis = val.isProfileVisible {
                                AppFunctions.setIsProfileVisble(value: profVis)
                                
                            }
                            
                            if let emailVerifed = val.isEmailVarified {
                                AppFunctions.setIsEmailVerified(value: emailVerifed)
                                
                            }
                            
                            if let profCount = val.profileCountForSubscription {
                                AppFunctions.saveMaxProfViewedCount(count: profCount)
                            }
                            
                            self.hidePKHUD()
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
    
    
    func userProfile() {
        
        APIService
            .singelton
            .getUserById(userId: "")
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val.userId != "" {
                            if AppFunctions.IsProfileUpdated(){
                                self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                    vc.selectedIndex = 2
                                }
                            } else {
                                self.navigateVC(id: "ProfileSetupVC") { (vc:ProfileSetupVC) in }
                            }
                            
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

    func getSocialAccounts() {
        
        APIService
            .singelton
            .getSocialAccounts()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        if val {
                            self.hidePKHUD()
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

//MARK: Apple Login Extentions
extension SignInVC: ASAuthorizationControllerDelegate {
    /// - Tag: did_complete_authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                
                if let identityTokenData = appleIDCredential.identityToken,
                   let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                    //print("Identity Token \(identityTokenString)")
                    let jwtValue = try! AppFunctions.decode(jwtToken: identityTokenString)
                    Logs.show(message: "\(jwtValue)")
                    //socialLoginUser(providor: "Apple", token: identityTokenString)
                    userSocialLogin(token: identityTokenString, provider: "Apple")
                    
                }
                // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
            case let passwordCredential as ASPasswordCredential:
                
                // Sign in using an existing iCloud Keychain credential.
                let username = passwordCredential.user
                let password = passwordCredential.password
                
                // For the purpose of this demo app, show the password credential as an alert.
                DispatchQueue.main.async {
                    self.showPasswordCredentialAlert(username: username, password: password)
                }
                
            default:
                break
        }
    }
    
    
    
    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        let alertController = UIAlertController(title: "Keychain Credential Received",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// - Tag: did_complete_error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension SignInVC: ASAuthorizationControllerPresentationContextProviding {
    /// - Tag: provide_presentation_anchor
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
