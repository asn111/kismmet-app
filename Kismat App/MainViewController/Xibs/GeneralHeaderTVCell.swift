//
//  GeneralHeaderTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class GeneralHeaderTVCell: UITableViewCell {

    
    
    @IBAction func rattingBtnPressed(_ sender: Any) {
        if let currentImage = rattingBtn.imageView?.image, currentImage.isEqual(UIImage(systemName: "star.fill")) {
            rattingBtn.setImage(UIImage(systemName: "star"), for: .normal)
        } else {
            rattingBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        
    }
    
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var rocketBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var educationLbl: fullyCustomLbl!
    @IBOutlet weak var professionLbl: fullyCustomLbl!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var ratingView: RoundCornerView!
    @IBOutlet weak var profilePicBtn: RoundCornerButton!
    @IBOutlet weak var welcomePicBtn: RoundCornerButton!
    @IBOutlet weak var welcomeHeaderLbl: fullyCustomLbl!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var welcomePowerBtn: RoundCornerButton!
    
    @IBOutlet weak var headerLbl: fullyCustomLbl!
    @IBOutlet weak var headerLogo: UIImageView!
    @IBOutlet weak var notifBtn: UIButton!
    @IBOutlet weak var picBtn: RoundCornerButton!
    
    @IBOutlet weak var rattingBtn: UIButton!
    
    @IBOutlet weak var searchTFView: RoundCornerView!
    @IBOutlet weak var viewedprofLbl: fullyCustomLbl!
    @IBOutlet weak var viewCountsLbl: fullyCustomLbl!
    @IBOutlet weak var swipeTxtLbl: fullyCustomLbl!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var toolTipBtn: RoundCornerButton!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var searchContraint: NSLayoutConstraint!
    
    @IBOutlet weak var shadowLbl: fullyCustomLbl!
    @IBOutlet weak var viewedToolTipBtn: RoundCornerButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
