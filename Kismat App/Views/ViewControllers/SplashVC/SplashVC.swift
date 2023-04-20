//
//  SplashVC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 10/02/2023.
//

import UIKit

class SplashVC: MainViewController {

    @IBAction func continueBtnPressed(_ sender: Any) {
        self.navigateVC(id: "SignInVC") { (vc:SignInVC) in }
    }

    @IBOutlet weak var heightConst: NSLayoutConstraint!
    @IBOutlet weak var animateThisView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    var timer : Timer!
    var heightSet = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppFunctions.isLoggedIn() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.userProfile()
            }
            animateThisView.isHidden = false
            
            timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(timerMethod), userInfo: nil, repeats: true)

        } else {
            btnView.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer.invalidate()
    }
    
    @objc func timerMethod() {
        heightChnage()
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
                            self.navigateVC(id: "RoundedTabBarController") { (vc:RoundedTabBarController) in
                                vc.selectedIndex = 2
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

    func heightChnage() {

        let oldHeight: CGFloat = 85
        var newHeight: CGFloat = 0
        
        if heightSet == 0 {
            newHeight = oldHeight
            heightSet = 1
        } else if heightSet == 1 {
            newHeight = oldHeight - 27
            heightSet = 2
        } else if heightSet == 2 {
            newHeight = oldHeight - 56
            heightSet = 3
        } else if heightSet == 3 {
            newHeight = 4
            heightSet = 4
        } else if heightSet == 4 {
            newHeight = 0
            heightSet = 0
        }
        
        // Update the frame of the view with the new size
        self.heightConst.constant = newHeight
        
        self.view.layoutIfNeeded()

    }
    
}
