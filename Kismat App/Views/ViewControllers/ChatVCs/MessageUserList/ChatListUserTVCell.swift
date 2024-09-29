//
//  ChatListUserTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 27/09/2024.
//

import UIKit

class ChatListUserTVCell: UITableViewCell {

    @IBOutlet weak var profileIcon: RoundedImageView!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    
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
