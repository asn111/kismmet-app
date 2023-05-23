//
//  hashTagsTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 23/05/2023.
//

import UIKit

class hashTagsTVCell: UITableViewCell {

    @IBOutlet weak var tagsLbl: FormTextField!
    @IBOutlet weak var tagImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
