//
//  StatusTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 20/12/2023.
//

import UIKit

class StatusTVCell: UITableViewCell {

    
    @IBOutlet weak var statusLbl: fullyCustomLbl!
    
    @IBOutlet weak var clockIV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
