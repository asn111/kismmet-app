//
//  SocialAccTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit

class SocialAccTVCell: UITableViewCell {

    @IBOutlet weak var removeBtn: RoundCornerButton!
    
    @IBOutlet weak var socialLbl: FormTextField!
    @IBOutlet weak var socialImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
