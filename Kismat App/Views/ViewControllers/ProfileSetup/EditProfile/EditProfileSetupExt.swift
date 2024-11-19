//
//  EditProfileSetupExt.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 22/02/2023.
//

import Foundation
import UIKit
import MapKit
import MultiSlider
import RealmSwift
import GoogleMaps
import Combine

class EditProfileSetupExt: MainViewController {
    
    @IBOutlet weak var profileExtTV: UITableView!
    
    //var placeholderArray = ["hed","pxlbl","sldr","map","stts","t1","t2","t3","emp","Public Email","Phone","bt"]
    var placeholderArray = ["hed","pxlbl","sldr","maph","map","sttsh","stts","t1","t2","t3","emp","Public Email","Phone","bt"]

    
    var isFromSetting = true
    var isProfileVisible = false
    var isStatusDelete = false
    var isShadowMode = false
    var proximity = 5000
    var email = ""
    var countName = ""
    var phoneNum = ""
    var name = ""
    var status = ""

    weak var activeTextView: UITextView?

    var overlayView: UIView?

    var circle : GMSCircle?
    
    var userdbModel = UserDBModel()
    var location = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DBService.fetchloggedInUser().count > 0 {
            self.userdbModel = DBService.fetchloggedInUser().first!
        }
        
        if userdbModel.userName != "" {
            let nameStr = userdbModel.userName.components(separatedBy: " ")
            name = nameStr.first ?? ""
        }
        
        proximity = userdbModel.proximity
        isProfileVisible = userdbModel.isProfileVisible
        isStatusDelete = userdbModel.isProfileVisible
        status = userdbModel.status
        isStatusDelete = userdbModel.disappearingStatus
        isShadowMode = userdbModel.shadowMode
        email = userdbModel.email
        countName = userdbModel.countryName
        phoneNum = userdbModel.phone
        
        registerCells()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func registerCells() {
        
        profileExtTV.tableFooterView = UIView()
        profileExtTV.separatorStyle = .none
        profileExtTV.delegate = self
        profileExtTV.dataSource = self
        
        profileExtTV.register(UINib(nibName: "GeneralHeaderTVCell", bundle: nil), forCellReuseIdentifier: "GeneralHeaderTVCell")
        profileExtTV.register(UINib(nibName: "AboutTVCell", bundle: nil), forCellReuseIdentifier: "AboutTVCell")
        
        profileExtTV.register(UINib(nibName: "MixHeaderTVCell", bundle: nil), forCellReuseIdentifier: "MixHeaderTVCell")
        profileExtTV.register(UINib(nibName: "ProfileTVCell", bundle: nil), forCellReuseIdentifier: "ProfileTVCell")

        profileExtTV.register(UINib(nibName: "SocialAccTVCell", bundle: nil), forCellReuseIdentifier: "SocialAccTVCell")
        profileExtTV.register(UINib(nibName: "GeneralButtonTVCell", bundle: nil), forCellReuseIdentifier: "GeneralButtonTVCell")
        
        profileExtTV.register(UINib(nibName: "RideMapViewTVCell", bundle: nil), forCellReuseIdentifier: "RideMapViewTVCell")

        profileExtTV.register(UINib(nibName: "GeneralTextviewTVCell", bundle: nil), forCellReuseIdentifier: "GeneralTextviewTVCell")

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = generalPublisherLoc.subscribe(onNext: {[weak self] loc in
            
            
            self?.location = loc
            self?.profileExtTV.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)

        }, onError: {print($0.localizedDescription)}, onCompleted: {print("Completed")}, onDisposed: {print("disposed")})
        
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        profileExtTV.contentInset = contentInsets
        profileExtTV.scrollIndicatorInsets = contentInsets
        
        var activeView: UIView?
        if let activeTextView = activeTextView {
            activeView = activeTextView
        }
        
        if let activeView = activeView {
            let rect = profileExtTV.convert(activeView.bounds, from: activeView)
            let offsetY = rect.maxY - (profileExtTV.bounds.height - keyboardSize.height)
            if offsetY > 0 {
                profileExtTV.setContentOffset(CGPoint(x: 0, y: offsetY), animated: true)
            }
        }
    }
    
    
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        profileExtTV.contentInset = .zero
    }
    
    
    @objc func picBtnPressed(sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func genBtnPressed(sender:UIButton) {
        updateConfig()
    }
    
    func updateConfig() {
        let pram = ["proximity": "\(proximity)",
                    "shadowMode":"\(isShadowMode)",
                    "status":"\(status)",
                    "disappearingStatus":"\(isStatusDelete)",
                    "isProfileVisible":"\(isProfileVisible)"
        ]
        
        Logs.show(message: "PRAM: \(pram)")
        
        APIService
            .singelton
            .updatePreff(pram: pram)
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        Logs.show(message: "MARKED: 👉🏻 \(val)")
                        if val {
                            self.hidePKHUD()
                            self.navigationController?.popViewController(animated: true)
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
        
        /*SignalRManager.singelton.connection.invoke(method: "UpdateUserConfigurations", pram) {  error in            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                AppFunctions.showSnackBar(str: "Error in updating values")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }*/
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        activeTextView = textView
        if textView.text == "" {
            // Clear the text view
            textView.text = ""

        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        status = !textView.text!.isTFBlank ? textView.text! : ""
        activeTextView = nil
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let remainingCharacters = textLimit(existingText: textView.text, newText: text, limit: 100)
        
        return remainingCharacters
    }

    func textViewDidChange(_ textView: UITextView) {
        let cell = profileExtTV.cellForRow(at: IndexPath(row: 6, section: 0)) as! GeneralTextviewTVCell
        
        if textView.text.count == 0 {
            cell.countLbl.text = "100 / 100 remaining"
            
            // Show the placeholder label when the text is empty
            if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = false
                if let iconIV = textView.viewWithTag(101) as? UIImageView {
                    iconIV.isHidden = false
                }
            }
        } else {
            cell.countLbl.text = "\(100 - textView.text.count) / 100 remaining"
            
            // Hide the placeholder label when the text is not empty
            if let placeholderLabel = textView.viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = true
                if let iconIV = textView.viewWithTag(101) as? UIImageView {
                    iconIV.isHidden = true
                }
            }
        }
    }



    private func textLimit(existingText: String?, newText: String, limit: Int) -> Bool {
        let text = existingText ?? ""
        let isAtLimit = text.count + newText.count <= limit

        return isAtLimit
    }

    
    @objc func toolTipBtnPressed(sender:UIButton) {
        var msg = ""
        
        if sender.tag == 001 {
            msg = "Activate Disappearing Status to automatically remove your status after 24hrs.\nKeep toggle off, and your status will stay until you choose to delete or update it."
        } else if sender.tag == 010 {
            msg = "Upgrade to premium to broadcast a status."
        } else if sender.tag == 002 {
            msg = "Toggle off to go completely offline.\nOthers won't see you, and you won't see them.Toggle on to rejoin the community."
        } else if sender.tag == 003 {
            msg = "Stay incognito with Shadow Mode!\nAllowing you to discreetly browse and star profiles without leaving a trace on the other member’s “Viewed By” and “Notifications” page.\nExclusive to premium members!"
            
        } else if sender.tag == 004 {
            msg = "Please note that the email and phone number fields on this page are kept private and will not be visible to other users.\nThese fields serve solely for account verification purposes and will not be shared on your profile.\nTo enhance your networking experience, you can add a separate email address on your Edit Profile page."
        } else if sender.tag == 005 {
            msg = "The lock icon next to your phone number means that the number cannot be changed.\nYour phone number is not visible to others."
        }
        
        if sender.tag == 004 {
            AppFunctions.showToolTip(str: msg, btn: sender, arrowPos: "right")
        } else {
            AppFunctions.showToolTip(str: msg, btn: sender)
        }
    }

    
    @objc func toggleButtonPressed(_ sender: UISwitch) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = profileExtTV.cellForRow(at: indexPath) as? MixHeaderTVCell {
            
            if cell.toggleBtn.tag == 7 {
                isStatusDelete = cell.toggleBtn.isOn
                //AppFunctions.setIsProfileVisble(value: cell.toggleBtn.isOn)
            } else if cell.toggleBtn.tag == 8 {
                isProfileVisible = cell.toggleBtn.isOn
                //AppFunctions.setIsProfileVisble(value: cell.toggleBtn.isOn)
            } else {
                isShadowMode = cell.toggleBtn.isOn
                //AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
            }
        }
    }
    
    fileprivate func convertToDate(dateStr: String) -> Date {
        var theDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: dateStr) {
            theDate = date
        } else {
            print("Error: Unable to convert date string.")
        }
        
        return theDate
    }
    
    @objc func sliderChanged(slider: MultiSlider) {
        print("thumb \(slider.draggedThumbIndex) moved")
        print("now thumbs are at \(slider.value)")
        
        if slider.draggedThumbIndex == 1 {
            let cell : MixHeaderTVCell = profileExtTV.cellForRow(at: IndexPath(row: 1, section: 0)) as! MixHeaderTVCell
            cell.proximeterLbl.text = "\(Int(round(slider.value[1]))) Meters"
            profileExtTV.rectForRow(at: IndexPath(row: 1, section: 0))
            proximity = Int(round(slider.value[1]))
            
            let mapCell : RideMapViewTVCell = profileExtTV.cellForRow(at: IndexPath(row: 4, section: 0)) as! RideMapViewTVCell
            updateMapView(mapView: mapCell.mapView, radius: Double(proximity))
        }
    }
    
    func updateMapView(mapView: GMSMapView, radius: Double) {
        let pLat = location.coordinate.latitude
        let pLong = location.coordinate.longitude
        let myLoc = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        
        let bounds = getBounds(center: myLoc, radius: radius/2)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: update)
        
        /// Remove old circle
        circle?.map = nil
        
        /// Create a circle
        circle = GMSCircle()
        circle!.position = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        circle!.radius = radius
        circle!.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circle!.strokeColor = .blue.withAlphaComponent(0.5)
        circle!.strokeWidth = 1
        circle!.map = mapView
    }

    
    func makeMapView(mapView: GMSMapView, radius: Double) {
        
        if location.coordinate.latitude == 0.00 {
            Logs.show(message: "No Location found")
            return
        }
        
        let pLat = location.coordinate.latitude
        let pLong = location.coordinate.longitude
        
        let markerMyLoc : GMSMarker = GMSMarker()
        let myLoc = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        let markerImage = UIImage(named: "pickup_icon")!.withRenderingMode(.alwaysOriginal)
        let markerView = UIImageView(image: markerImage)
        markerMyLoc.iconView = markerView
        markerMyLoc.position = myLoc
        /// uncomment this line below to show marker
        
        let bounds = getBounds(center: myLoc, radius: radius/2)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        mapView.animate(with: update)
        
        /// Remove old circle
        circle?.map = nil
        
        /// Create a circle
        circle = GMSCircle()
        circle!.position = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        circle!.radius = radius
        circle!.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circle!.strokeColor = .blue.withAlphaComponent(0.5)
        circle!.strokeWidth = 1
        circle!.map = mapView
        
        mapView.isMyLocationEnabled = true
        mapView.isTrafficEnabled = false
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = false
        mapView.settings.setAllGesturesEnabled(false)
        mapView.mapType = .normal
        mapView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5)
        
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                NSLog("Found style.json")
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }

    func getBounds(center: CLLocationCoordinate2D, radius: Double) -> GMSCoordinateBounds {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: radius * 2, longitudinalMeters: radius * 2)
        let northEast = CLLocationCoordinate2D(latitude: region.center.latitude + (region.span.latitudeDelta / 2), longitude: region.center.longitude + (region.span.longitudeDelta / 2))
        let southWest = CLLocationCoordinate2D(latitude: region.center.latitude - (region.span.latitudeDelta / 2), longitude: region.center.longitude - (region.span.longitudeDelta / 2))
        return GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
    }

    func getCellForView(_ view: UIView) -> RideMapViewTVCell? {
        var superView = view.superview
        while superView != nil {
            if let cell = superView as? RideMapViewTVCell {
                return cell
            }
            superView = superView?.superview
        }
        return nil
    }

    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let mapView = sender.view as? GMSMapView,
              let cell = getCellForView(mapView),
              let _ = profileExtTV.indexPath(for: cell) else { return }
        
        let cellFrameInSuperview = profileExtTV.convert(cell.frame, to: profileExtTV.superview)
        
        // Create an overlay view that covers the entire screen
        overlayView = UIView(frame: self.view.bounds)
        overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        let newView = UIView()
        newView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: 450)
        newView.center = overlayView!.center
        newView.clipsToBounds = true
        newView.layer.cornerRadius = 5
        overlayView?.addSubview(newView)
        
        let newMapView = GMSMapView(frame: newView.bounds)
        newMapView.camera = mapView.camera
        
        if location.coordinate.latitude == 0.00 {
            Logs.show(message: "No Location found")
            return
        }
        
        let pLat = location.coordinate.latitude
        let pLong = location.coordinate.longitude
        
        let markerMyLoc : GMSMarker = GMSMarker()
        let myLoc = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        let markerImage = UIImage(named: "pickup_icon")!.withRenderingMode(.alwaysOriginal)
        let markerView = UIImageView(image: markerImage)
        markerMyLoc.iconView = markerView
        markerMyLoc.position = myLoc
        /// uncomment this line below to show marker
        /// markerMyLoc.map = mapView
        
        let bounds = getBounds(center: myLoc, radius: Double(proximity)/2)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
        newMapView.animate(with: update)
        
        // Remove old circle
        circle?.map = nil
        
        // Create a circle
        circle = GMSCircle()
        circle!.position = CLLocationCoordinate2D(latitude: pLat, longitude: pLong)
        circle!.radius = Double(proximity)
        circle!.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circle!.strokeColor = .blue.withAlphaComponent(0.5)
        circle!.strokeWidth = 1
        circle!.map = newMapView
        
        newMapView.isMyLocationEnabled = true
        newMapView.isTrafficEnabled = false
        newMapView.settings.compassButton = true
        newMapView.settings.myLocationButton = true
        newMapView.settings.setAllGesturesEnabled(true)
        newMapView.mapType = .normal
        newMapView.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 5)
        
        do {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                newMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                NSLog("Found style.json")
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        
        newView.addSubview(newMapView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap(_:)))
        overlayView?.addGestureRecognizer(tapGestureRecognizer)
        
        view.addSubview(overlayView!)
        
        // Animate the map view to expand from the cell's frame to the center of the screen
        overlayView?.alpha = 0
        newMapView.frame = cellFrameInSuperview
        UIView.animate(withDuration: 0.3) {
            self.overlayView?.alpha = 1
            newMapView.frame = newView.bounds
        }
    }

    
    @objc func handleOverlayTap(_ sender: UITapGestureRecognizer) {
        guard let overlayView = overlayView else { return }
        
        // Animate the overlay view to fade out, then remove it
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 0
        }) { _ in
            overlayView.removeFromSuperview()
            self.profileExtTV.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
            self.overlayView = nil
        }
    }

    
}
//MARK: TableView Extention
extension EditProfileSetupExt : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeholderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
            case 0: // Header
                let cell : GeneralHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralHeaderTVCell", for: indexPath) as! GeneralHeaderTVCell
                cell.headerLbl.isHidden = false
                cell.headerLbl.text = "Hi, \(name)"
                cell.headerLbl.textAlignment = .left
                cell.searchView.isHidden = true
                cell.swipeTxtLbl.isHidden = true
                cell.headerView.isHidden = false
                cell.notifBtn.isHidden = true
                cell.chatBtn.isHidden = true
                cell.picBtn.addTarget(self, action: #selector(picBtnPressed(sender:)), for: .touchUpInside)
                cell.picBtn.setImage(UIImage(systemName: "arrow.left"), for: .normal)

                return cell
            case 1: // Proximity Lbl View
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.proximeterLbl.isHidden = false
                cell.headerLbl.text = "Set Proximity"
                cell.proximeterLbl.text = "\(proximity) Meters"
                
                return cell
            case 2: // Slider
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.sliderView.isHidden = false
                cell.sliderValue = proximity
                cell.slider.addTarget(self, action: #selector(sliderChanged(slider:)), for: .valueChanged) /// continuous changes
                return cell
            case 3: // map heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.addBtn.isHidden = true
                cell.headerLbl.text = "Tap map to visualize your radius"
                
                return cell
            case 4: // Map
                let cell : RideMapViewTVCell = tableView.dequeueReusableCell(withIdentifier: "RideMapViewTVCell", for: indexPath) as! RideMapViewTVCell
                if location.coordinate.latitude != 0.00 {
                    makeMapView(mapView: cell.mapView, radius: Double(proximity))
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                    cell.mapView.addGestureRecognizer(tap)

                }
                
                return cell
            case 5: // Status heading
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.headerLblView.isHidden = false
                cell.addBtn.isHidden = true
                cell.headerLbl.text = "What's on your mind? Broadcast a status:"
                
                return cell
            case 6 : // Status
                
                let cell : GeneralTextviewTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralTextviewTVCell", for: indexPath) as! GeneralTextviewTVCell
                
                cell.generalTV.isEditable = AppFunctions.isPremiumUser()

                cell.leadConstTV.constant = 40
                cell.trailConstTV.constant = 50
                
                cell.bubbleIV.isHidden = false
                cell.generalTV.backgroundColor = .clear
                cell.generalTV.text = status//.isEmpty ? "" : status
                if !status.isEmpty {
                    cell.countLbl.text = "\(100 - status.count) / 100 remaining"
                } else {
                    cell.generalTV.addPlaceholder("Add status here...", size: 14, iconImage: UIImage(systemName: "megaphone.fill"))

                    cell.countLbl.text = "100 / 100 remaining"
                }

                cell.countLbl.isHidden = false
                cell.generalTV.delegate = self
                cell.generalTV.textColor = UIColor(named: "Text grey")
                
                return cell
            case 7: // status toggle
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Disappearing status"
                cell.toggleBtn.isOn = isStatusDelete
                cell.toggleBtn.isEnabled = AppFunctions.isPremiumUser()
                cell.toggleBtn.tag = indexPath.row
                if AppFunctions.isPremiumUser() {
                    cell.toggleTooltipBtn.tag = 001
                } else {
                    cell.toggleTooltipBtn.tag = 010
                }
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                return cell
            case 8: // Visibilty 1
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Online Presence"
                cell.toggleBtn.isOn = isProfileVisible
                cell.toggleBtn.tag = indexPath.row
                cell.toggleTooltipBtn.tag = 002
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                
                
                return cell
            case 9: // Visibility 2
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell
                cell.toggleBtnView.isHidden = false
                cell.toggleLbl.text = "Shadow Mode"
                cell.toggleBtn.isOn = isShadowMode
                cell.toggleBtn.isEnabled = AppFunctions.isPremiumUser()
                cell.toggleBtn.tag = indexPath.row
                AppFunctions.setIsShadowMode(value: cell.toggleBtn.isOn)
                cell.toggleTooltipBtn.tag = 003
                
                cell.toggleTooltipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                cell.toggleBtn.addTarget(self, action: #selector(toggleButtonPressed(_:)), for: .valueChanged)
                return cell
            case placeholderArray.count - 4: // Empty View
                let cell : MixHeaderTVCell = tableView.dequeueReusableCell(withIdentifier: "MixHeaderTVCell", for: indexPath) as! MixHeaderTVCell

                return cell
            case placeholderArray.count - 1: // Done Btn
                let cell : GeneralButtonTVCell = tableView.dequeueReusableCell(withIdentifier: "GeneralButtonTVCell", for: indexPath) as! GeneralButtonTVCell
                cell.genBtn.tag = indexPath.row
                cell.arrowView.isHidden = true
                if isFromSetting {
                    cell.genBtn.setTitle("Update", for: .normal)
                } else {
                    cell.genBtn.setTitle("Save and Continue", for: .normal)
                }
                cell.genBtn.addTarget(self, action: #selector(genBtnPressed(sender:)), for: .touchUpInside)
                return cell
                
            default:
                
                let cell : ProfileTVCell = tableView.dequeueReusableCell(withIdentifier: "ProfileTVCell", for: indexPath) as! ProfileTVCell
                if placeholderArray[indexPath.row] == "Phone" {
                    cell.numberView.isHidden = false
                    cell.numberTF.isUserInteractionEnabled = false
                    cell.countryPickerView.isUserInteractionEnabled = false
                    cell.generalTFView.isHidden = true
                    cell.setupCountryCode(name: countName)
                    cell.numberTF.text = phoneNum
                    cell.numberTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.numberTF, s: placeholderArray[indexPath.row])
                    cell.lockTipBtn.tag = 004
                    
                    cell.lockTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                } else {
                    cell.numberView.isHidden = true
                    cell.generalTF.isUserInteractionEnabled = false
                    cell.generalTFView.isHidden = false
                    cell.toolTipBtn.isHidden = false
                    cell.generalTF.text = email
                    cell.generalTF.placeholder = placeholderArray[indexPath.row]
                    AppFunctions.colorPlaceholder(tf: cell.generalTF, s: placeholderArray[indexPath.row])
                    
                    cell.toolTipBtn.tag = 005
                    
                    cell.toolTipBtn.addTarget(self, action: #selector(toolTipBtnPressed(sender:)), for: .touchUpInside)
                    
                }
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 6 && !AppFunctions.isPremiumUser() {
            AppFunctions.showSnackBar(str: "Upgrade to premium to broadcast a status.")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80.0
        } else if indexPath.row == placeholderArray.count - 4 {
            return 30.0
        } else {
            return UITableView.automaticDimension
        }
    }
}

/* if messageType == .recieved {
    // Received bubble: Rounded corners + tail on the top-left
    bezierPath.move(to: CGPoint(x: tailWidth + cornerRadius, y: height))
    bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
    bezierPath.addQuadCurve(to: CGPoint(x: width, y: height - cornerRadius), controlPoint: CGPoint(x: width, y: height))
    bezierPath.addLine(to: CGPoint(x: width, y: cornerRadius))
    bezierPath.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0), controlPoint: CGPoint(x: width, y: 0))
    bezierPath.addLine(to: CGPoint(x: tailWidth + cornerRadius, y: 0))
    bezierPath.addQuadCurve(to: CGPoint(x: tailWidth, y: cornerRadius), controlPoint: CGPoint(x: tailWidth, y: 0))
    
    // Sharp tail on the top-left
    bezierPath.addLine(to: CGPoint(x: 0, y: tailHeight / 2))
    bezierPath.addLine(to: CGPoint(x: tailWidth, y: tailHeight))
    
    // Finish the bubble shape
    bezierPath.addLine(to: CGPoint(x: tailWidth, y: height - cornerRadius))
    bezierPath.addQuadCurve(to: CGPoint(x: tailWidth + cornerRadius, y: height), controlPoint: CGPoint(x: tailWidth, y: height))
    
    } */
