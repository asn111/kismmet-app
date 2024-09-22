//
//  ReceiverChatCell.swift
//  HP
//
//  Created by apple on 05/11/19.
//  Copyright © 2019 Quytech. All rights reserved.
//

import UIKit

class ReceiverChatCell: UITableViewCell {

   @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shapeView: ChatView!
    @IBOutlet weak var userNameLbl: fullyCustomLbl!
    @IBOutlet weak var userProfilePic: RoundedImageView!
    
    var vc : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shapeView.messageType = .recieved
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        messageLabel.addGestureRecognizer(tap)
        
        shapeView.setNeedsDisplay()
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        //print("tap working")
//        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
//        
//        let tabVc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//        tabVc.selectedIndex = 4
//        goneToVideo = true
//        self.vc.navigationController?.pushViewController(tabVc, animated: true)
    }

    func populateCell(obj: ChatModel) {
        messageLabel.text = obj.message
        

        
        messageLabel.text = obj.message
        userNameLbl.text = obj.senderUserName
        messageLabel.isUserInteractionEnabled = false
        
        if obj.senderProfilePicture != "" && obj.senderProfilePicture != nil {
            let imageUrl = URL(string: obj.senderProfilePicture)
            userProfilePic?.sd_setImage(with: imageUrl , placeholderImage: UIImage()) { (image, error, imageCacheType, url) in }
        } else {
            userProfilePic.image = UIImage()
        }

        timeLabel.text = convertStringToFormattedString(obj.createdAt)
        
        shapeView.messageType = .recieved
        shapeView.setNeedsDisplay()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func convertStringToFormattedString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        
        // Input format (should match the input date string)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Treat the input as GMT/UTC
        
        // Attempt to parse the date string
        guard let date = dateFormatter.date(from: dateString) else {
            print("Failed to parse date: \(dateString)")
            return nil
        }
        
        // Output format (desired output)
        dateFormatter.dateFormat = "dd MMM, hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone.current // Convert to the current timezone
        
        return dateFormatter.string(from: date)
    }

}
