//
//  TabsHeaderTVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 23/06/2024.
//

import UIKit

class TabsHeaderTVCell: UITableViewCell {

    
    @IBOutlet weak var notifbtn: UIButton!
    @IBOutlet weak var wifiManBtn: RoundCornerButton!
    @IBOutlet weak var reqBtn: UIButton!
    @IBOutlet weak var conBtn: UIButton!
    
    @IBOutlet weak var settingsLbl: fullyCustomLbl!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchView: RoundCornerView!
    @IBOutlet weak var headerLbl: fullyCustomLbl!
    @IBOutlet weak var btnsImg: UIImageView!
    
    @IBAction func reqBtnPressed(_ sender: Any) {
        onReqBtnTap?()
    }
    
    @IBAction func conBtnPressed(_ sender: Any) {
        onConBtnTap?()
    }
    
    var onReqBtnTap: (() -> Void)?
    var onConBtnTap: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
