//
//  ReqSentVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 25/06/2024.
//

import UIKit

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
    
    @IBOutlet weak var starBtn: UIButton!
    var userId = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
