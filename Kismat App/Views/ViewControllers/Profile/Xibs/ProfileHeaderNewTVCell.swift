//
//  ProfileHeaderNewTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 06/10/2024.
//

import UIKit

class ProfileHeaderNewTVCell: UITableViewCell {

    
    @IBOutlet weak var backBtn: RoundCornerButton!
    @IBOutlet weak var starBtn: UIButton!
    @IBOutlet weak var profilePicBtn: RoundCornerButton!
    @IBOutlet weak var statusView: RoundCornerView!
    @IBOutlet weak var statusLbl: fullyCustomLbl!
    @IBOutlet weak var clockIV: UIImageView!
    
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var workLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var requestBtn2: UIButton!
    @IBOutlet weak var btnsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
