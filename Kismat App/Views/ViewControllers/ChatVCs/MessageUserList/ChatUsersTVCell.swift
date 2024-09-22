//
//  ChatUsersTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 07/09/2024.
//

import UIKit

class ChatUsersTVCell: UITableViewCell {

    
    @IBOutlet weak var profileIcon: RoundedImageView!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var msgLbl: fullyCustomLbl!
    
    @IBOutlet weak var onlineView: RoundCornerView!
    @IBOutlet weak var proffLbl: fullyCustomLbl!
    
    @IBOutlet weak var lastMsgTimeLbl: fullyCustomLbl!
    
    @IBOutlet weak var countView: RoundCornerView!
    @IBOutlet weak var countLbl: fullyCustomLbl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
