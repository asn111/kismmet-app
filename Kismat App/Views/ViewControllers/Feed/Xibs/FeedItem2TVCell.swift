//
//  FeedItem2TVCell.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 21/12/2023.
//

import UIKit

class FeedItem2TVCell: UITableViewCell {

    @IBAction func starBtnPressed(_ sender: Any) {
        
//        if let currentImage = starBtn.imageView?.image, currentImage.isEqual(UIImage(systemName: "star.fill")) {
//            starBtn.setImage(UIImage(systemName: "star"), for: .normal)
//        } else {
//            starBtn.setImage(UIImage(systemName: "star.fill"), for: .normal)
//        }
        
    }
    
    @IBOutlet weak var firstTagView: RoundCornerView!
    
    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var starBtn: UIButton!
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
    
    @IBOutlet weak var tagsWidthConst: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
