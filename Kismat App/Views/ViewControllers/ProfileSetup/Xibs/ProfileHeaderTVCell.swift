//
//  ProfileHeaderTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class ProfileHeaderTVCell: UITableViewCell {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var backBtn: RoundCornerButton!
    
    @IBOutlet weak var powerBtn: RoundCornerButton!
    @IBOutlet weak var profileIV: RoundedImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
