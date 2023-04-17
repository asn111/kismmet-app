//
//  MainViewController.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Tuesday01/06/2021.
//

import UIKit
import RxSwift
import Combine
import Alamofire
import SwiftSignalRClient
import CoreLocation


class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, HubConnectionDelegate, UIPopoverPresentationControllerDelegate {

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
        
        // --Signal R Init--
        
        if AppFunctions.getToken() != "" && !connectionStarted {
            SignalRService.chatHubConnectionDelegate = self
            SignalRService.initializeSignalR()
        }

        
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
        return .darkContent
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
    
    //MARK: SignalR Delegate Methods
    func connectionDidOpen(hubConnection: HubConnection) {
        Logs.show(message: "Con ID: \(String(describing: hubConnection.connectionId))")
        
    }
    
    func connectionDidFailToOpen(error: Error) {
        Logs.show(message: "\(String(describing: error))")
        
    }
    
    func connectionDidClose(error: Error?) {
        Logs.show(message: "\(String(describing: error))")
        _ = SignalRManager.init()
        
    }
    
    func connectionWillReconnect(error: Error) {
        Logs.show(message: "\(String(describing: error))")
    }
    
    func connectionDidReconnect() {
        Logs.show(message: "Reconnecting.../.")
    }
    
}
