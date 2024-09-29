//
//  GeneralTextviewTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class GeneralTextviewTVCell: UITableViewCell {

    @IBOutlet weak var countLbl: fullyCustomLbl!
    
    @IBOutlet weak var bubbleIV: UIImageView!
    @IBOutlet weak var generalTV: FormTextView!
    
    @IBOutlet weak var leadConstTV: NSLayoutConstraint!
    @IBOutlet weak var trailConstTV: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
