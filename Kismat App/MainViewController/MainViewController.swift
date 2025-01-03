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
import SDWebImage


class MainViewController: UIViewController, UIViewControllerTransitioningDelegate, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate, HubConnectionDelegate, UIPopoverPresentationControllerDelegate {

    //MARK: LifeCycle Methods

    let internetView = UIView()
    let internetLbl = fullyCustomLbl()
    var locationManager = LocationManager()
    var cancellable: AnyCancellable? = nil
    var lastLocation : CLLocation?
    var floatingActionButton: UIButton?

    var fabTapAction: (() -> Void)?

    private var timer: Timer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomView()
        setupFloatingActionButton()

        // Clear memory cache
        SDImageCache.shared.clearMemory()
        
        /// this will clear cache and downloads every time
        /// Clear disk cache
        //SDImageCache.shared.clearDisk(onCompletion: nil)
        
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
            SignalRManager.singelton.chatHubConnectionDelegate = self
            SignalRManager.singelton.initializeSignalR()
            
            
            _ = generalPublisherLoc.subscribe(onNext: {[weak self] loc in
                
                
                self?.lastLocation = loc
                self?.sendLocation()
            }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
            
            /*self.cancellable = self.locationManager.$currentLocation.sink(receiveValue: {[weak self] (CLLocation) in
                Logs.show(message: "LOC C: \(String(describing: CLLocation))")
                if let loc = CLLocation {
                    self?.lastLocation = loc
                    self?.sendLocation()
                }
            })
            
            self.cancellable = self.locationManager.$lastLocation.sink(receiveValue: {[weak self] (CLLocation) in
                Logs.show(message: "LOC L: \(String(describing: CLLocation))")
                if let loc = CLLocation {
                    self?.lastLocation = loc
                    self?.sendLocation()
                }
            })*/
        }

        
        loading
            .bind(to: self.rx.isAnimating).disposed(by: dispose_Bag)
        
        //timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(sendLocation), userInfo: nil, repeats: true)

    }
    
    func sendLocation() {
        let lat = self.lastLocation?.coordinate.latitude ?? 0.0
        let long = self.lastLocation?.coordinate.longitude ?? 0.0
        
        let pram = ["lat": "\(lat)",
                    "long":"\(long)"
        ]
        SignalRManager.singelton.connection.invoke(method: "UpdateUserLocation", pram) {  error in
            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // --Navigation--
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        // --AppUIMode--(Dark Or Light)
        overrideUserInterfaceStyle = .light
        
        floatingActionButton?.isHidden = !shouldShowFloatingActionButton()

    }

    // --StatusBarMode--(Dark Or Light)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setupFloatingActionButton() {
        floatingActionButton = UIButton()
        
        //let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .heavy, scale: .medium)
        let systemImage = UIImage(named: "Subtract")
        
        floatingActionButton?.setImage(systemImage, for: .normal)
        floatingActionButton?.backgroundColor = UIColor(named: "Success")
        floatingActionButton?.tintColor = .white
        floatingActionButton?.layer.cornerRadius = 8
        floatingActionButton?.contentMode = .scaleAspectFill
        
        floatingActionButton?.addTarget(self, action: #selector(fabTapped), for: .touchUpInside)
        
        if let fab = floatingActionButton {
            view.addSubview(fab)
            fab.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                fab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                fab.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                fab.widthAnchor.constraint(equalToConstant: 50),
                fab.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
    }
    
    
    
    func shouldShowFloatingActionButton() -> Bool {
        return false
    }
    
    func showHideFabBtn(shouldShow: Bool) {
        floatingActionButton?.isHidden = !shouldShow
    }
    
    func setupCustomView() {
        internetView.frame = CGRect(x: 0, y: self.view.bounds.height - 38, width: self.view.bounds.width, height: 50.0)
        internetView.backgroundColor = UIColor(named: "Purple")
        
        internetView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(internetView)
        
        internetLbl.frame = CGRect(x: 0, y: 0, width: self.internetView.bounds.width, height: 20)
        internetLbl.text = "No Internet!☹️ Check your connection"
        internetLbl.txtColor = .red
        internetLbl.textAlignment = .center
        internetLbl.font = UIFont(name: "Avenir", size: 14)?.semibold
        
        internetView.addSubview(internetLbl)
        internetView.bringSubviewToFront(internetLbl)
    }
    
    @objc func fabTapped() {
        fabTapAction!()
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
