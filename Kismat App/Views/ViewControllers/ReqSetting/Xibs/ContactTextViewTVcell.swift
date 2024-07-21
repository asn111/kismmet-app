//
//  ContactTextViewTVcell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 06/07/2024.
//

import UIKit

class ContactTextViewTVcell: UITableViewCell {

    
    @IBOutlet weak var countLbl: fullyCustomLbl!
    
    @IBOutlet weak var generalTV: FormTextView!
    
    @IBOutlet weak var chkBtn: UIButton!
    
    @IBOutlet weak var socialPicIV: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
