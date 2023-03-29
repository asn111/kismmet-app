//
//  TagsTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 15/02/2023.
//

import UIKit

class TagsTVCell: UITableViewCell {
    
    
    @IBOutlet weak var removeBtn1: RoundCornerButton!
    @IBOutlet weak var removeBtn2: RoundCornerButton!
    @IBOutlet weak var removeBtn3: RoundCornerButton!
    @IBOutlet weak var removeBtn4: RoundCornerButton!
    @IBOutlet weak var removeBtn5: RoundCornerButton!
    
    @IBOutlet weak var tagLbl1: fullyCustomLbl!
    @IBOutlet weak var tagLbl2: fullyCustomLbl!
    @IBOutlet weak var tagLbl3: fullyCustomLbl!
    @IBOutlet weak var tagLbl4: fullyCustomLbl!
    @IBOutlet weak var tagLbl5: fullyCustomLbl!
    
    @IBOutlet weak var tagView1: RoundCornerView!
    @IBOutlet weak var tagView2: RoundCornerView!
    @IBOutlet weak var tagView3: RoundCornerView!
    @IBOutlet weak var tagView4: RoundCornerView!
    @IBOutlet weak var tagView5: RoundCornerView!
    
    
    var isForEditing: Bool = false {
        didSet {
            bindViewModel()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func bindViewModel() {
        if isForEditing {
            removeBtn1.isHidden = false
            removeBtn2.isHidden = false
            removeBtn3.isHidden = false
            removeBtn4.isHidden = false
            removeBtn5.isHidden = false
        }
    }

    
}
