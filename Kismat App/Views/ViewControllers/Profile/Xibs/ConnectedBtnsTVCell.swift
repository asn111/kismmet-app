//
//  ConnectedBtnsTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 06/11/2024.
//

import UIKit

class ConnectedBtnsTVCell: UITableViewCell {

    @IBOutlet weak var viewProfileBtn: UIButton!
    
    @IBOutlet weak var msgBtn: UIButton!
    
    @IBOutlet weak var blockBtn: UIButton!
    
    @IBOutlet weak var deleteContactBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
