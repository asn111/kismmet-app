//
//  MainViewController.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Tuesday01/06/2021.
//

import UIKit
import RxSwift
import Alamofire

class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate {

    //MARK: LifeCycle Methods

    let internetView = UIView()
    let internetLbl = fullyCustomLbl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomView()
        
        if APIService.singelton.isCheckReachable() {
            internetView.isHidden = true
        } else {
            internetView.isHidden = false
        }
        
        _ = generalPublisher.subscribe(onNext: {[weak self] val in
            
            if val == "Internet" {
                self?.internetView.isHidden = true
            } else if val == "noInternet" {
                self?.internetView.isHidden = false
            }
        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
        
        // --Navigation--
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // --AppUIMode--(Dark Or Light)
        overrideUserInterfaceStyle = .light
        
        loading
            .bind(to: self.rx.isAnimating).disposed(by: dispose_Bag)
    }
    
    // --StatusBarMode--(Dark Or Light)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupCustomView() {
        internetView.frame = CGRect(x: 0, y: self.view.bounds.height - 38, width: self.view.bounds.width, height: 50.0)
        internetView.backgroundColor = UIColor(named: "Purple")
        
        internetView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(internetView)
        
        internetLbl.frame = CGRect(x: 0, y: 0, width: self.internetView.bounds.width, height: 20)
        internetLbl.text = "No Internet!☹️ Check your connection"
        internetLbl.txtColor = .white
        internetLbl.textAlignment = .center
        internetLbl.font = UIFont(name: "Avenir", size: 14)?.semibold
        
        internetView.addSubview(internetLbl)
        internetView.bringSubviewToFront(internetLbl)
    }
    
}
