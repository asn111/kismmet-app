//
//  RoundedTabBarController.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import TransitionableTab

enum Type: String {
case move
    static var all: Type = .move
}

class RoundedTabBarController: UITabBarController {

    var type: Type = .move
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
                
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 30, y: tabBar.bounds.minY - 10, width: tabBar.bounds.width - 60, height: tabBar.bounds.height + 10), cornerRadius: (tabBar.frame.width/2)).cgPath
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.shadowRadius = 25.0
        layer.shadowOpacity = 0.3
        layer.borderWidth = 1.0
        layer.opacity = 1.0
        layer.isHidden = false
        layer.masksToBounds = false
        layer.fillColor = UIColor(named: "Secondary Grey")?.cgColor
        
        tabBar.layer.insertSublayer(layer, at: 0)
        
        if let items = tabBar.items {
            for (index, item) in items.enumerated() {
                
                if index == 1 { //|| index == 2 {
                    item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
 
                }
                
            }
        }
        
        tabBar.itemWidth = 30.0
        tabBar.unselectedItemTintColor = .white
        tabBar.itemPositioning = .centered
        
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.backgroundColor = UIColor.clear
    }

}
extension RoundedTabBarController: TransitionableTab {
    
    func transitionDuration() -> CFTimeInterval {
        return 0.4
    }
    
    func transitionTimingFunction() -> CAMediaTimingFunction {
        return .easeInOut
    }
    
    func fromTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        switch type {
            case .move: return DefineAnimation.move(.from, direction: direction)
        }
    }
    
    func toTransitionAnimation(layer: CALayer?, direction: Direction) -> CAAnimation {
        switch type {
            case .move: return DefineAnimation.move(.to, direction: direction)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
}
