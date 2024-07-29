//
//  ContactInfoTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 02/07/2024.
//

import UIKit
import iOSDropDown

class ContactInfoTVCell: UITableViewCell {

    
    @IBOutlet weak var tfView: RoundCornerView!
    @IBOutlet weak var textLbl: fullyCustomLbl!
    @IBOutlet weak var chkBtn: UIButton!
    @IBOutlet weak var toolTipBtn: RoundCornerButton!
    @IBOutlet weak var socialPicIV: UIImageView!
   
    @IBOutlet weak var contactTF: FormTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
