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
            ApiService.markStarUser(val: userId)
            AppFunctions.showSnackBar(str: "User has been starred")
            starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            ApiService.markStarUser(val: userId)
            AppFunctions.showSnackBar(str: "User has been unstarred")
            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
        
        
    }
    
    @IBOutlet weak var gifIV: FLAnimatedImageView!
    
    @IBOutlet weak var starBtn: UIButton!
    
    var userId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageData = gifImageToData(imageName: "rocketLaunch") {
            let gifImage = FLAnimatedImage(animatedGIFData: imageData)
            gifIV.animatedImage = gifImage
            gifIV.layer.cornerRadius = 10
            
            print("Image data loaded successfully")
        }
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
