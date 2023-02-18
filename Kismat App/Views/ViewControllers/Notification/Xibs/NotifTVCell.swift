//
//  NotifTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 15/02/2023.
//

import UIKit

class NotifTVCell: UITableViewCell {

    
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var notifView: RoundCornerView!
    @IBOutlet weak var notifLbl: fullyCustomLbl!
    @IBOutlet weak var timeLbl: fullyCustomLbl!
    @IBOutlet weak var profilePicIV: RoundedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
