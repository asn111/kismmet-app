//
//  GeneralHeaderTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class GeneralHeaderTVCell: UITableViewCell {

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var educationLbl: fullyCustomLbl!
    @IBOutlet weak var professionLbl: fullyCustomLbl!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var ratingView: RoundCornerView!
    @IBOutlet weak var profilePicBtn: RoundCornerButton!
    
    @IBOutlet weak var headerLbl: fullyCustomLbl!
    @IBOutlet weak var headerLogo: UIImageView!
    @IBOutlet weak var notifBtn: UIButton!
    @IBOutlet weak var picBtn: RoundCornerButton!
    
    @IBOutlet weak var searchTFView: RoundCornerView!
    @IBOutlet weak var viewedprofLbl: fullyCustomLbl!
    @IBOutlet weak var viewCountsLbl: fullyCustomLbl!
    @IBOutlet weak var swipeTxtLbl: fullyCustomLbl!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var toolTipBtn: RoundCornerButton!
    @IBOutlet weak var searchView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
