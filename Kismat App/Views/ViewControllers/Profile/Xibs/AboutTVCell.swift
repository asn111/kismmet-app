//
//  AboutTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit

class AboutTVCell: UITableViewCell {

    @IBOutlet weak var seemoreBtn: UIButton!
    @IBOutlet weak var aboutTxtView: FormTextView!
    
    @IBOutlet weak var bioLbl: fullyCustomLbl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
