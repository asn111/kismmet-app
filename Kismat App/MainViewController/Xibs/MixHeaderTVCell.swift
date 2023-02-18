//
//  MixHeaderTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 14/02/2023.
//

import UIKit
import MultiSlider

class MixHeaderTVCell: UITableViewCell {


    @IBOutlet weak var toggleBtnView: UIView!
    @IBOutlet weak var toggleLbl: fullyCustomLbl!
    @IBOutlet weak var toggleTooltipBtn: RoundCornerButton!
    @IBOutlet weak var toggleBtn: CustomToggleButton!
    
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var proximeterLbl: fullyCustomLbl!
    @IBOutlet weak var headerLblView: UIView!
    @IBOutlet weak var headerLbl: fullyCustomLbl!
    @IBOutlet weak var notifHeaderView: UIView!
    @IBOutlet weak var notifHeaderLbl: fullyCustomLbl!
    @IBOutlet weak var addBtn: RoundCornerButton!
    
    var minValue = 1
    var maxValue = 500
    let slider = MultiSlider()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSlider()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupSlider() {
        
        slider.orientation = .horizontal
        slider.snapStepSize = 50
        slider.isHapticSnap = true
        slider.trackWidth = 8
        slider.disabledThumbIndices = [0]
        slider.thumbImage = UIImage(named: "thumbView")
        slider.minimumValue = CGFloat(minValue)
        slider.maximumValue = CGFloat(maxValue)
        slider.outerTrackColor = .lightGray
        slider.tintColor = UIColor(named: "Secondary Grey")
        
        slider.value = [CGFloat(minValue),CGFloat(maxValue/2)]
        
        
        sliderView.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint(item: slider, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sliderView, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: slider, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sliderView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: slider, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.sliderView.bounds.width - 20)
        let heightConstraint = NSLayoutConstraint(item: slider, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 30)
        
        sliderView.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
}
