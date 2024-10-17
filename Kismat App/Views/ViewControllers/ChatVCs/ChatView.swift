//
//  ChatView.swift
//  AthleteApp
//
//  Created by Abhishek Tyagi on 14/11/18.
//  Copyright © 2018 Uninterrupted. All rights reserved.
//


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
            // Sent bubble: Rounded corners + sharp tail on the top-right
            bezierPath.move(to: CGPoint(x: cornerRadius, y: height))
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: height))
            
            //bezierPath.addQuadCurve(to: CGPoint(x: width, y: height - cornerRadius), controlPoint: CGPoint(x: width, y: height))
            bezierPath.addLine(to: CGPoint(x: width, y: height))  // Top-right curve, before tail
            
            // Sharp tail on top-right
            bezierPath.addLine(to: CGPoint(x: width, y: 0))  // Sharp tip
            bezierPath.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            
            // Continue to round top-left corner and other sides
            bezierPath.addLine(to: CGPoint(x: 0, y: 0))
            bezierPath.addQuadCurve(to: CGPoint(x: 0, y: cornerRadius), controlPoint: CGPoint(x: 0, y: 0))
            
            bezierPath.addLine(to: CGPoint(x: 0, y: height - cornerRadius))
            bezierPath.addQuadCurve(to: CGPoint(x: cornerRadius, y: height), controlPoint: CGPoint(x: 0, y: height))
        }
        
        bezierPath.close()
        
        let fillColor = messageType.color()
        fillColor.setFill()
        bezierPath.fill()
    }
}
