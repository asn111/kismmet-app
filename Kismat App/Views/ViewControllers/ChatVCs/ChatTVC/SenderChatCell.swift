
import UIKit


class SenderChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shapeView: ChatView!
    @IBOutlet weak var seenImageView: UIImageView!
    
    
    var vc : UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shapeView.messageType = .sent
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction(sender:)))
        messageLabel.addGestureRecognizer(tap)
        
        shapeView.setNeedsDisplay()
    }

    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        //print("tap working")
//        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
//        
//        let vc : TabbarViewController = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//        vc.selectedIndex = 4
//        goneToVideo = true
//        self.vc.navigationController?.pushViewController(vc, animated: true)
    }
    
    func populateCell(obj: ChatModel) {
        messageLabel.text = obj.message
        
        
        messageLabel.text = obj.message
        messageLabel.isUserInteractionEnabled = false
        
        timeLabel.text = convertStringToFormattedString(obj.createdAt)

      //  seenImageView.image = UIImage.init(named: model.read_status == "1" ? "icn_double_check" : "icn_single_tick")
        seenImageView.image = UIImage.init(named: "icn_double_check")
        seenImageView.tintColor = .red//model.read_status == "1"  ? .red  : .lightGray

        shapeView.messageType = .sent
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
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.timeZone = TimeZone.current // Convert to the current timezone
        
        return dateFormatter.string(from: date)
    }
}
