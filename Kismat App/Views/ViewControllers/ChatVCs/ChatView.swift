
import Foundation
import UIKit

enum MessageType {
    case recieved
    case sent
    
    func color() -> UIColor {
        switch self {
        case .recieved:
                return UIColor(named: "Secondary Grey")! //RGBA(246, g: 246, b: 246, a: 1)
        case .sent:
                return UIColor.white//RGBA(235, g: 36, b: 43, a: 1)
        }
    }
}


class ChatView: UIView {
    var messageType = MessageType.recieved // Either .recieved or .sent
    let cornerRadius: CGFloat = 8 // Standard corner radius for rounded corners
    let tailHeight: CGFloat = 60   // Height for the message bubble's tail
    
    override func draw(_ rect: CGRect) {
        drawBubbleShape(rect.size)
    }
    
    private func drawBubbleShape(_ size: CGSize) {
        let width = size.width
        let height = size.height
        
        let bezierPath = UIBezierPath()
        
        if messageType == .recieved {
            // Received bubble: Rounded corners + sharp tail on the top-left
            
            bezierPath.move(to: CGPoint(x: tailHeight, y: 0))  // Start at the tail
            bezierPath.addLine(to: CGPoint(x: -tailHeight, y: 0))
            
            bezierPath.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius), controlPoint: CGPoint(x: 0, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
            
            bezierPath.addQuadCurve(to: CGPoint(x: cornerRadius, y: height), controlPoint: CGPoint(x: 0, y: height))
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
            
            bezierPath.addQuadCurve(to: CGPoint(x: width, y: height - cornerRadius), controlPoint: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width, y: cornerRadius))
            bezierPath.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0), controlPoint: CGPoint(x: width, y: 0))
            
            // Sharp tail on top-left
            bezierPath.addLine(to: CGPoint(x: tailHeight, y: 0))
            bezierPath.addLine(to: CGPoint(x: 0, y: tailHeight))  // Sharp tip
            
        } else {
            // Start at the bottom-left corner with a slight inward curve
            bezierPath.move(to: CGPoint(x: cornerRadius, y: height))
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
            
            // Create the sharp tail at the bottom right
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height)) // Move to the start of the tail
            bezierPath.addLine(to: CGPoint(x: width, y: height + 15)) // Point of the tail
            bezierPath.addLine(to: CGPoint(x: width, y: height - cornerRadius)) // End of the tail
            
            // Right edge with top-right rounded corner
            bezierPath.addLine(to: CGPoint(x: width, y: cornerRadius))
            bezierPath.addQuadCurve(to: CGPoint(x: width - cornerRadius, y: 0), controlPoint: CGPoint(x: width, y: 0))
            
            // Top edge
            bezierPath.addLine(to: CGPoint(x: cornerRadius, y: 0))
            
            // Top-left rounded corner
            bezierPath.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius), controlPoint: CGPoint(x: 0, y: 0))
            
            // Left edge
            bezierPath.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
            
            // Bottom-left rounded corner to close the path
            bezierPath.addQuadCurve(to: CGPoint(x: cornerRadius, y: height), controlPoint: CGPoint(x: 0, y: height))
            

        }
        
        bezierPath.close()
        
        let fillColor = messageType.color()
        fillColor.setFill()
        bezierPath.fill()
    }
}
