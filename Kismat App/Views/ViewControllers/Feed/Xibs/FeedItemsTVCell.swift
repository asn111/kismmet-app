//
//  FeedItemsTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 12/02/2023.
//

import UIKit
import SDWebImage

class FeedItemsTVCell: UITableViewCell {

    @IBOutlet weak var statusView: RoundCornerView!
    
    @IBOutlet weak var mainViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var statusLbl: fullyCustomLbl!
    @IBOutlet weak var clockIV: UIImageView!
    @IBOutlet weak var blurView: RoundCornerView!
    @IBOutlet weak var nonBlurView: RoundCornerView!
    @IBOutlet weak var profilePicIV: RoundedImageView!
    @IBOutlet weak var nameLbl: fullyCustomLbl!
    @IBOutlet weak var educationLbl: fullyCustomLbl!
    @IBOutlet weak var starLbl: UIImageView!
    @IBOutlet weak var tagsView: UIView!
    @IBOutlet weak var tagLbl: fullyCustomLbl!
    @IBOutlet weak var tagMoreView: RoundCornerView!
    @IBOutlet weak var tagMoreLbl: fullyCustomLbl!
    @IBOutlet weak var professionLbl: fullyCustomLbl!
    
    var isViewBHidden = false {
        didSet {
            statusView.isHidden = isViewBHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        sd_cancelCurrentImageLoad()
        profilePicIV.image = UIImage()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
