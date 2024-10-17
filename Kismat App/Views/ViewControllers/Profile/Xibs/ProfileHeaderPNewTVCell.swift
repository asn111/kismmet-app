//
//  ProfileHeaderPNewTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 16/10/2024.
//

import UIKit

class ProfileHeaderPNewTVCell: UITableViewCell {

    
    @IBOutlet weak var backBtn: RoundCornerButton!
    @IBOutlet weak var profilePicBtn: RoundCornerButton!
    @IBOutlet weak var statusView: RoundCornerView!
    @IBOutlet weak var statusLbl: fullyCustomLbl!
    @IBOutlet weak var clockIV: UIImageView!
    
    @IBOutlet weak var notifbtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var workLbl: fullyCustomLbl!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
