//
//  ReqSentVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 25/06/2024.
//

import UIKit
import FLAnimatedImage

class ReqSentVC: MainViewController {

    @IBAction func closeBtnPressed(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func starBtnPressed(_ sender: Any) {

        if starBtn.currentImage == UIImage(systemName: "star") {
            markUserStar(userId: userId)
            //ApiService.markStarUser(val: userId)
            //AppFunctions.showSnackBar(str: "User has been starred")
            starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            markUserStar(userId: userId)
            //ApiService.markStarUser(val: userId)
            //AppFunctions.showSnackBar(str: "User has been unstarred")
            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        
    }
    
    func markUserStar(userId: String) {
        TimeTracker.shared.startTracking(for: "markUserStar")
        
        let pram = ["userId": "\(userId)"]
        Logs.show(message: "PRAM: \(pram)")
        SignalRService.connection.invoke(method: "StarUser", pram) {  error in
            Logs.show(message: "\(pram)")
            if let e = error {
                Logs.show(message: "Error: \(e)")
                return
            }
            TimeTracker.shared.stopTracking(for: "markUserStar")
        }
    }
    
    @IBOutlet weak var gifIV: FLAnimatedImageView!
    
    @IBOutlet weak var starBtn: UIButton!
    
    var userId = ""
    var isStarred = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if isStarred {
            starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        if let imageData = gifImageToData(imageName: "rocketLaunch") {
            let gifImage = FLAnimatedImage(animatedGIFData: imageData)
            gifIV.animatedImage = gifImage
            gifIV.layer.cornerRadius = 10
            
            print("Image data loaded successfully")
        }
        
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //generalPublisher.onNext("exitView")
    }

    
    func gifImageToData(imageName: String, ofType type: String = "gif") -> Data? {
        guard let imagePath = Bundle.main.path(forResource: imageName, ofType: type),
              let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) else {
            print("GIF file not found or could not be loaded")
            return nil
        }
        
        return imageData
    }

}
