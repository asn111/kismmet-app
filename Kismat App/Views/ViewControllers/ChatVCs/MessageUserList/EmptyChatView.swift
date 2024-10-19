//
//  EmptyChatView.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 17/10/2024.
//

import UIKit

class EmptyChatView: UITableViewCell {

    @IBOutlet weak var emptyViewBtn: RoundCornerButton!
    @IBOutlet weak var emptyLbl: fullyCustomLbl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
