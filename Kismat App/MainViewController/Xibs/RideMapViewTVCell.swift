//
//  RideMapViewTVCell.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Tuesday23/11/2021.
//

import UIKit
import GoogleMaps

class RideMapViewTVCell: UITableViewCell {

    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var heightConst: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
