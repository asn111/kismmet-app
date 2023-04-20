//
//  VisibilityOffTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 17/04/2023.
//

import UIKit

class VisibilityOffTVCell: UITableViewCell {

    @IBOutlet weak var toolTipBtn: RoundCornerButton!
    
    @IBOutlet weak var toggleBtn: CustomToggleButton!
    
    @IBOutlet weak var textLbl: fullyCustomLbl!
    
    @IBOutlet weak var updateBtn: RoundCornerButton!
    
    @IBOutlet weak var visibiltyView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
