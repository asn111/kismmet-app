//
//  EnlargedIV VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 27/04/2023.
//

import UIKit

class EnlargedIV_VC: MainViewController {

    @IBOutlet weak var ProfileIV: RoundedImageView!
    
    @IBAction func crossBtnPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    var profileImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ProfileIV.image = profileImage
        
        // Do any additional setup after loading the view.
    }
    
}
