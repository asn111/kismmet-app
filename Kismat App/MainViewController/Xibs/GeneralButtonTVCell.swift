//
//  GeneralButtonTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit

class GeneralButtonTVCell: UITableViewCell {

    @IBOutlet weak var arrowView: RoundCornerView!
    @IBOutlet weak var genBtn: RoundCornerButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
