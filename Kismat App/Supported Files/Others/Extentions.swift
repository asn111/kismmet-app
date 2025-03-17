//
//  Extentions.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday15/08/2020.
//  Copyright © 2020 SelfIt. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import PKHUD
//import RxRealm
import RxSwift
import RxCocoa
import FLAnimatedImage


//MARK: Public Extention, NSObject
public extension NSObject {
    var theClassName: String {
        return NSStringFromClass(type(of: self))
    }
}

//MARK: UIApplication
extension UIApplication {
    static func topViewController() -> UIViewController? {
        guard var top = shared.keyWindow?.rootViewController else {
            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }
}


//MARK: CALayer

extension CALayer {
    
  func roundCorners(corners: UIRectCorner, radius: CGFloat, viewBounds: CGRect) {

      let maskPath = UIBezierPath(roundedRect: viewBounds,
                                  byRoundingCorners: corners,
                                  cornerRadii: CGSize(width: radius, height: radius))

      let shape = CAShapeLayer()
      shape.path = maskPath.cgPath
      mask = shape
  }
}

//MARK: UIView

extension UIView {
    
    func addBlurEffect(style: UIBlurEffect.Style, cornerRadius: CGFloat, alpha: CGFloat = 0.9) {
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.bounds
        self.addSubview(blurView)
        
        let maskView = UIView(frame: blurView.bounds)
        maskView.backgroundColor = .white
        maskView.layer.cornerRadius = cornerRadius
        maskView.layer.masksToBounds = true
        blurView.mask = maskView
        
        blurView.alpha = alpha
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func showAnim(){
        UIView.animate(withDuration: 0.7, delay: 0, options: [.transitionCrossDissolve],
                       animations: {
            //self.center.y -= self.bounds.height
            self.alpha = 1
            //self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
            //self.frame = CGRect(x: self.frame.minX, y: self.frame.minY - self.bounds.height, width: self.bounds.width, height: self.bounds.height)

            self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    
    func hideAnim(){
        UIView.animate(withDuration: 0.7, delay: 0, options: [.transitionCrossDissolve],
                       animations: {
            //self.center.y += self.bounds.height
            self.alpha = 0
            self.layoutIfNeeded()
            
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
    
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(duration: TimeInterval = 2.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
                // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? any CAAnimationDelegate
            }
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
                // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromRightTransition")
    }
    func popFromMid(duration: TimeInterval = 2.0, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? any CAAnimationDelegate
        }
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.reveal
        slideInFromLeftTransition.subtype = CATransitionSubtype.fromBottom
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromBottomTransition")
    }
    
    func addShadow() {
        self.layer.shadowColor = UIColor(named: "Secondary Grey")?.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1
    }
}


//MARK: UIColor

extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        let scanner = Scanner(string: hexFromString)
        scanner.scanLocation = 0
        
        var rgbColorValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbColorValue)
        
        let r = (rgbColorValue & 0xff0000) >> 16
        let g = (rgbColorValue & 0xff00) >> 8
        let b = rgbColorValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff,
            alpha: alpha
        )
    }
}

//MARK: Color

extension Color {
    init(hexFromString:String) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: Double(CGFloat((rgbValue & 0xFF0000) >> 16)) / 255.0,
            green: Double(CGFloat((rgbValue & 0x00FF00) >> 8)) / 255.0,
            blue: Double(CGFloat(rgbValue & 0x0000FF) / 255.0)
        )
    }
}


//MARK: Lable

extension UILabel {
    func addCharacterSpacing(kernValue: Double) {
        guard let attributedString: NSMutableAttributedString = {
            if let text = self.text, !text.isEmpty {
                return NSMutableAttributedString(string: text)
            } else if let attributedText = self.attributedText {
                return NSMutableAttributedString(attributedString: attributedText)
            }
            return nil
            }() else { return}
        
        attributedString.addAttribute(
            NSAttributedString.Key.kern,
            value: kernValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        self.attributedText = attributedString
    }
    public func zeroLineSpace(){
        let s = NSMutableAttributedString(string: self.text!)
        let style = NSMutableParagraphStyle()
        let lineHeight = self.font.pointSize - self.font.ascender + self.font.capHeight
        let offset = self.font.capHeight - self.font.ascender
        let range = NSMakeRange(0, self.text!.count)
        style.maximumLineHeight = lineHeight + 17
        style.minimumLineHeight = lineHeight + 17
        style.alignment = self.textAlignment
        s.addAttribute(.paragraphStyle, value: style, range: range)
        s.addAttribute(.baselineOffset, value: offset, range: range)
        self.attributedText = s
    }
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

//MARK: Texfields

extension UITextField.BorderStyle {
    func insets() -> UIEdgeInsets {
        switch self {
            case .none:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            case .line, .bezel:
                return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            case .roundedRect:
                return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            @unknown default:
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension UITextField {
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
    
    
    class func connectFields(fields:[UITextField]) -> Void {
        guard let last = fields.last else {
            return
        }
        for i in 0 ..< fields.count - 1 {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .next
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
    
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry){
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        }else{
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            
        }
    }
    
    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.tintColor = UIColor(named: "Secondary Grey")
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
    
}

//MARK: TableView

extension UITableView {
    
    func addTopBounceAreaView(color: UIColor) {
        var frame = UIScreen.main.bounds
        frame.origin.y = -frame.size.height
        
        let view = UIView(frame: frame)
        view.backgroundColor = color
        
        self.addSubview(view)
    }
}

//MARK: TextView

extension UITextView : UITextViewDelegate
{
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    func addPlaceholder(_ placeholderText: String, size: CGFloat, iconImage: UIImage?) {
        // Remove existing placeholder if it exists
        if let existingPlaceholder = self.viewWithTag(100) as? UILabel {
            existingPlaceholder.removeFromSuperview()
        }
        if let existingIcon = self.viewWithTag(101) as? UIImageView {
            existingIcon.removeFromSuperview()
        }
        
        // Create placeholder label
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.font = UIFont(name: "Roboto", size: size)
        placeholderLabel.textColor = UIColor(named: "Text grey")
        placeholderLabel.tag = 100
        placeholderLabel.numberOfLines = 0
        placeholderLabel.lineBreakMode = .byWordWrapping
        placeholderLabel.isHidden = !self.text.isEmpty
        
        // Create image view for the icon
        let iconImageView = UIImageView()
        iconImageView.image = iconImage
        iconImageView.tag = 101
        iconImageView.tintColor = UIColor(named: "warning")
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        iconImageView.isHidden = placeholderLabel.isHidden
        
        // Configure the placeholder label frame
        placeholderLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 5, height: self.frame.size.height - 16)
        
        // Add both label and image view to the text view
        self.addSubview(placeholderLabel)
        self.addSubview(iconImageView)
        
        // Call resizePlaceholder to set their positions correctly
        self.resizePlaceholderWI()
    }
    
    // Resize placeholder and icon positions
    func resizePlaceholderWI() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel,
            let iconImageView = self.viewWithTag(101) as? UIImageView {
            
            // Calculate the label's frame
            let labelX = self.textContainerInset.left + 5
            let labelY = self.textContainerInset.top
            let labelWidth = placeholderLabel.sizeThatFits(CGSize(width: self.frame.width - (self.textContainerInset.left + self.textContainerInset.right + 10) - 22, height: CGFloat.greatestFiniteMagnitude)).width
            let labelHeight = placeholderLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            
            // Set the icon position right after the label
            iconImageView.frame = CGRect(x: labelX + labelWidth, y: labelY, width: 17, height: 17)
            
            // Sync the visibility of the icon with the placeholder label
            let isHidden = !self.text.isEmpty
            placeholderLabel.isHidden = isHidden
            iconImageView.isHidden = isHidden
        }
    }
    
    func addPlaceholder(_ placeholderText: String, size: CGFloat) {
        // Remove existing placeholder if it exists
        if let existingPlaceholder = self.viewWithTag(100) as? UILabel {
            existingPlaceholder.removeFromSuperview()
        }
        
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.font = UIFont(name: "Roboto", size: size)
        placeholderLabel.textColor = UIColor(named: "Text grey")
        placeholderLabel.tag = 100
        placeholderLabel.numberOfLines = 0
        placeholderLabel.lineBreakMode = .byWordWrapping
        
        // Configure placeholder label frame
        placeholderLabel.frame = CGRect(x: 5, y: 0, width: self.frame.size.width - 10, height: self.frame.size.height - 16)
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder() // Assuming this method adjusts the layout based on the placeholder
    }
    
    // Implement resizePlaceholder if needed
    func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            let labelX = self.textContainerInset.left + 5
            let labelY = self.textContainerInset.top
            let labelWidth = self.frame.width - (self.textContainerInset.left + self.textContainerInset.right + 10)
            let labelHeight = placeholderLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)).height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    func numberOfLines() -> Int {
        guard let font = self.font else { return 0 }
        
        // Ensure the text is not nil or empty
        guard let text = self.text, !text.isEmpty else { return 0 }
        
        let textContainer = self.textContainer
        let layoutManager = self.layoutManager
        
        // Calculate the range of the visible glyphs
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        var lineCount = 0
        var index = glyphRange.location
        
        // Iterate through the glyphs to count lines
        while index < NSMaxRange(glyphRange) {
            var lineRange = NSRange()
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            lineCount += 1
            index = NSMaxRange(lineRange)
        }
        
        return lineCount
    }
    
    func trimToThreeLines() {
        guard let font = self.font, let text = self.text, !text.isEmpty else { return }
        
        let textContainer = self.textContainer
        let layoutManager = self.layoutManager
        
        // Calculate the range of the visible glyphs
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        
        var lineCount = 0
        var index = glyphRange.location
        var lineEndIndex: Int = 0
        
        // Iterate to find the end of the third line
        while index < NSMaxRange(glyphRange) {
            var lineRange = NSRange()
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            lineCount += 1
            
            if lineCount == 3 {
                lineEndIndex = NSMaxRange(lineRange)
                break
            }
            
            index = NSMaxRange(lineRange)
        }
        
        // If more than 3 lines, trim the text
        if lineCount > 3 {
            let visibleText = (text as NSString).substring(to: lineEndIndex)
            var words = visibleText.split(separator: " ")
            
            // Ensure there are enough words to trim
            if words.count > 3 {
                words.removeLast(3) // Remove last 3 words
            }
            
            // Update the text with ellipsis
            self.text = words.joined(separator: " ") + "..."
        }
    }

}

//MARK: String

extension String {

    var isTFBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }
    var isValidUserName: Bool {
       let regEx = "\\A\\w{3,15}\\z"
        let val = NSPredicate(format:"SELF MATCHES %@", regEx)
       return val.evaluate(with: self)
    }
    var isValidEmail: Bool {
       let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let val = NSPredicate(format:"SELF MATCHES %@", regEx)
       return val.evaluate(with: self)
    }
    var isValidPassword: Bool {
       let regEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d$@$!%*#?&]{8,}$" //Minimum 8 characters at least 1 Alphabet, 1 Number and 1 Special Character
        let val = NSPredicate(format:"SELF MATCHES %@", regEx)
       return val.evaluate(with: self)
    }
    var isValidPhoneNumber: Bool {
       let regEx = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let val = NSPredicate(format:"SELF MATCHES %@", regEx)
       return val.evaluate(with: self)
    }
    
}
//MARK: String Protocol

extension StringProtocol {
    subscript(offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }
    subscript(_ range: Range<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        return prefix(range.lowerBound + range.count)
            .suffix(range.count)
    }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence {
        return prefix(range.upperBound.advanced(by: 1))
    }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence {
        return prefix(range.upperBound)
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence {
        return suffix(Swift.max(0, count - range.lowerBound))
    }
}

extension LosslessStringConvertible {
    var string: String { return .init(self) }
}

extension BidirectionalCollection {
    subscript(safe offset: Int) -> Element? {
        guard !isEmpty, let i = index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex)) else { return nil }
        return self[i]
    }
}

//MARK: Int

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

//MARK: Fonts

extension UIFont {
    var bold: UIFont { return withWeight(.bold) }
    var semibold: UIFont { return withWeight(.semibold) }
    var heavy: UIFont { return withWeight(.heavy) }
    var medium: UIFont { return withWeight(.medium) }
    var regular: UIFont { return withWeight(.regular) }
    var light: UIFont { return withWeight(.light) }
    var black: UIFont { return withWeight(.black) }

    
    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]
        
        traits[.weight] = weight
        
        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName
        
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        
        // create a new font descriptor with the given traits
        guard let fd = fontDescriptor.withSymbolicTraits(traits) else {
            // the given traits couldn't be applied, return self
            return self
        }
        
        // return a new font with the created font descriptor
        return UIFont(descriptor: fd, size: pointSize)
    }
    
    func italics() -> UIFont {
        return withTraits(.traitItalic)
    }
    
    func boldItalics() -> UIFont {
        return withTraits([ .traitBold, .traitItalic ])
    }
}

//MARK: ViewController

extension UIViewController {
    
    
    func showPKHUD(WithMessage message: String) {
        
        loading.onNext(true)
           /*PKHUD.sharedHUD.contentView = PKHUDTextView(text: message)
           PKHUD.sharedHUD.dimsBackground = true
           PKHUD.sharedHUD.show()*/
       }
       func hideOnTap() {
           PKHUD.sharedHUD.dimsBackground = true
       }
       func showPKHUD() {
           
           self.showPKHUD(WithMessage: "")
       }
       
       func hidePKHUD() {
        loading.onNext(false)
           //PKHUD.sharedHUD.hide()
       }
    
    public func add(asChildViewController viewController: UIViewController,to parentView:UIView) {
        // Add Child View Controller
        addChild(viewController)
        
        // Add Child View as Subview
        parentView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = parentView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    public func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParent()
    }
    
    func navigateVC<T:UIViewController> (id: String,  sb: String = "Main", setup: (_ vc: T) -> ()) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: id) as? T {
            setup(vc)
            let transition = CATransition()
                transition.duration = 0.3
                transition.type = CATransitionType.push
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                let nav = UINavigationController(rootViewController:vc)
                appDelegate.window!.rootViewController = nav
                nav.navigationController?.view.layer.add(transition, forKey: nil)
                nav.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func pushVC<T:UIViewController> (id: String,  sb: String = "Main", setup: (_ vc: T) -> ()) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: id) as? T {
            setup(vc)
            let transition = CATransition()
            transition.duration = 0.5
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            transition.type = CATransitionType.fade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func pushVC(vc: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .default)
        transition.type = .fade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(vc, animated: false)
    }

    
    func presentVC<T:UIViewController> (id: String, sb: String = "Main", presentFullType: String = "full" , setup: (_ vc: T) -> ()) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: id) as? T {
            setup(vc)
            if presentFullType == "full" { vc.modalPresentationStyle = .fullScreen }
            else if presentFullType == "over" { vc.modalPresentationStyle = .overCurrentContext }
            self.present(vc, animated: true)
        }
    }
    
    func presentVCWithTransition<T:UIViewController> (id: String, sb: String = "Main", setup: (_ vc: T) -> ()) {
        let storyboard = UIStoryboard(name: sb, bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: id) as? T {
            setup(vc)
            appDelegate.window!.rootViewController = vc
            let transition = CATransition()
            transition.duration = 1
            transition.type = CATransitionType.push
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            vc.view.window?.layer.add(transition, forKey: kCATransition)
            self.present(vc, animated: true)
        }
    }
}

//MARK: UIApplication

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

//MARK: Navigation View

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
    
    func popViewControllers(viewsToPop: Int, animated: Bool = true) {
        if viewControllers.count > viewsToPop {
            let vc = viewControllers[viewControllers.count - viewsToPop - 1]
            popToViewController(vc, animated: animated)
        }
    }
    var previousViewController: UIViewController? {
        viewControllers.count > 1 ? viewControllers[viewControllers.count - 2] : nil
    }
}

//MARK: Image

extension UIImage {
    
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func fixOrientation() -> UIImage? {
        
        if (imageOrientation == .up) { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0.0, y: size.height)
            transform = transform.rotated(by: -.pi / 2.0)
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        default:
            break
        }
        
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        default:
            break
        }
        
        guard let cgImg = cgImage else { return nil }
         
        if let context = CGContext(data: nil,
                                   width: Int(size.width), height: Int(size.height),
                                   bitsPerComponent: cgImg.bitsPerComponent,
                                   bytesPerRow: 0, space: cgImg.colorSpace!,
                                   bitmapInfo: cgImg.bitmapInfo.rawValue) {
            
            context.concatenate(transform)
            
            if imageOrientation == .left || imageOrientation == .leftMirrored ||
                imageOrientation == .right || imageOrientation == .rightMirrored {
                context.draw(cgImg, in: CGRect(x: 0.0, y: 0.0, width: size.height, height: size.width))
            } else {
                context.draw(cgImg, in: CGRect(x: 0.0 , y: 0.0, width: size.width, height: size.height))
            }
            
            if let contextImage = context.makeImage() {
                return UIImage(cgImage: contextImage)
            }
            
        }
        
        return nil
    }
    
}

//MARK: UIImageView

extension UIImageView {
    
}

//MARK: UITableView

extension UITableView {
    /*func applyChangeset(_ changes: RealmChangeset , operation: Int) {
        beginUpdates()
        
        if operation == 1 {
            deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        } else if operation == 2 {
            insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        } else if operation == 3 {
            reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        }
        
        endUpdates()
    }*/
}

//MARK: Button

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        //NSAttributedStringKey.foregroundColor : UIColor.blue
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: self.titleColor(for: .normal)!, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
   
    func showGifAnimation(imageName: String, duration: TimeInterval = 5.0) {
        guard let imageData = gifImageToData(imageName: imageName) else {
            print("Could not load GIF data")
            return
        }
        
        let gifImageView = FLAnimatedImageView()
        let gifImage = FLAnimatedImage(animatedGIFData: imageData)
        gifImageView.animatedImage = gifImage
        
        // Calculate the new frame
        let extraSize: CGFloat = 35 // Adjust this value to increase/decrease the extra size
        let newWidth = self.bounds.width + extraSize
        let newHeight = self.bounds.height + extraSize
        let newX = self.bounds.midX - newWidth / 2
        let newY = self.bounds.midY - newHeight / 2
        gifImageView.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        
        
        gifImageView.contentMode = .scaleAspectFit
        gifImageView.backgroundColor = .clear
        
        self.addSubview(gifImageView)

        // Add bouncing animation to the button
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.2, 0.8, 1.1, 0.9, 1.0]
        bounceAnimation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        bounceAnimation.duration = 0.6
        bounceAnimation.repeatCount = Float(duration / bounceAnimation.duration)
        self.layer.add(bounceAnimation, forKey: "bounce")
        
        // Remove gifImageView after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            gifImageView.removeFromSuperview()
            self.layer.removeAnimation(forKey: "bounce")
        }
    }
    
    private func gifImageToData(imageName: String, ofType type: String = "gif") -> Data? {
        guard let imagePath = Bundle.main.path(forResource: imageName, ofType: type),
              let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) else {
            print("GIF file not found or could not be loaded")
            return nil
        }
        
        return imageData
    }
    
}


//MARK: UIProgressView

extension UIProgressView{
    
    @IBInspectable var barHeight : CGFloat {
        get {
            return transform.d * 2.0
        }
        set {
            // 2.0 Refers to the default height of 2
            let heightScale = newValue / 2.0
            let c = center
            transform = CGAffineTransform(scaleX: 1.0, y: heightScale)
            center = c
        }
    }
    
    private struct Holder {
        static var _progressFull:Bool = false
        static var _completeLoading:Bool = false;
    }
    
    var progressFull:Bool {
        get {
            return Holder._progressFull
        }
        set(newValue) {
            Holder._progressFull = newValue
        }
    }
    
    var completeLoading:Bool {
        get {
            return Holder._completeLoading
        }
        set(newValue) {
            Holder._completeLoading = newValue
        }
    }
    
    func animateProgress(){
        if(completeLoading){
            return
        }
        UIView.animate(withDuration: 1, animations: {
            self.setProgress(self.progressFull ? 1.0 : 0.0, animated: true)
        })
        
        progressFull = !progressFull;
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.animateProgress();
        }
    }
    
    func startIndefinateProgress(){
        isHidden = false
        completeLoading = false
        animateProgress()
    }
    
    func stopIndefinateProgress(){
        completeLoading = true
        isHidden = true
    }
}


//MARK: Bundle

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        
        #if DEBUG
        return "\(infoDictionary?["CFBundleVersion"] ?? "") Debug"
        #else
        return infoDictionary?["CFBundleVersion"] as? String
        #endif
        
    }
}

//MARK: Devices

public extension UIDevice {
    
    
    var iPhoneX: Bool { UIScreen.main.nativeBounds.height == 2436 }
    var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }
    var iPad: Bool { UIDevice().userInterfaceIdiom == .pad }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_6Plus_6sPlus_7Plus_8Plus_Simulators = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus Simulators"
        case iPhones_X_XS_12MiniSimulator = "iPhone X or iPhone XS or iPhone 12 Mini Simulator"
        case iPhone_XR_11 = "iPhone XR or iPhone 11"
        case iPhone_XSMax_ProMax = "iPhone XS Max or iPhone Pro Max"
        case iPhone_11Pro = "iPhone 11 Pro"
        case iPhone_12Mini = "iPhone 12 Mini"
        case iPhone_12_12Pro = "iPhone 12 or iPhone 12 Pro"
        case iPhone_12ProMax = "iPhone 12 Pro Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
            case 1136: return .iPhones_5_5s_5c_SE
            case 1334: return .iPhones_6_6s_7_8
            case 1792: return .iPhone_XR_11
            case 1920: return .iPhones_6Plus_6sPlus_7Plus_8Plus
            case 2208: return .iPhones_6Plus_6sPlus_7Plus_8Plus_Simulators
            case 2340: return .iPhone_12Mini
            case 2426: return .iPhone_11Pro
            case 2436: return .iPhones_X_XS_12MiniSimulator
            case 2532: return .iPhone_12_12Pro
            case 2688: return .iPhone_XSMax_ProMax
            case 2778: return .iPhone_12ProMax
            default: return .unknown
        }
    }
    

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
                case "iPod5,1":                                 return "iPod touch (5th generation)"
                case "iPod7,1":                                 return "iPod touch (6th generation)"
                case "iPod9,1":                                 return "iPod touch (7th generation)"
                case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
                case "iPhone4,1":                               return "iPhone 4s"
                case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
                case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
                case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
                case "iPhone7,2":                               return "iPhone 6"
                case "iPhone7,1":                               return "iPhone 6 Plus"
                case "iPhone8,1":                               return "iPhone 6s"
                case "iPhone8,2":                               return "iPhone 6s Plus"
                case "iPhone8,4":                               return "iPhone SE"
                case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
                case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
                case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
                case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
                case "iPhone10,3", "iPhone10,6":                return "iPhone X"
                case "iPhone11,2":                              return "iPhone XS"
                case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
                case "iPhone11,8":                              return "iPhone XR"
                case "iPhone12,1":                              return "iPhone 11"
                case "iPhone12,3":                              return "iPhone 11 Pro"
                case "iPhone12,5":                              return "iPhone 11 Pro Max"
                case "iPhone12,8":                              return "iPhone SE (2nd generation)"
                case "iPhone13,1":                              return "iPhone 12 mini"
                case "iPhone13,2":                              return "iPhone 12"
                case "iPhone13,3":                              return "iPhone 12 Pro"
                case "iPhone13,4":                              return "iPhone 12 Pro Max"
                case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
                case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
                case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
                case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
                case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
                case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
                case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
                case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
                case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
                case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
                case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
                case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
                case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
                case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
                case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
                case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
                case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
                case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
                case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
                case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
                case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
                case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
                case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
                case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
                case "AppleTV5,3":                              return "Apple TV"
                case "AppleTV6,2":                              return "Apple TV 4K"
                case "AudioAccessory1,1":                       return "HomePod"
                case "AudioAccessory5,1":                       return "HomePod mini"
                case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
                default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}

