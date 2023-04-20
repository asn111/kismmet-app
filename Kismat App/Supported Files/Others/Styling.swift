//
//  Styling.swift
//  Von Rides
//
//  Created by Ahsan Iqbal on Saturday15/08/2020.
//  Copyright © 2020 SelfIt. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialRipple

//MARK: Round Image View

@IBDesignable
class RoundedImageView : UIImageView {
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
}

//MARK: Round Corner View

@IBDesignable
class RoundCornerView : UIView {
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    // Will limit the given cornors with given radius
    @IBInspectable
    public var topLimitedCornerRadius: CGFloat = 0.0 {
        didSet {
            self.clipsToBounds = true
            self.layer.cornerRadius = topLimitedCornerRadius
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            //self.roundCorners(corners: [.topLeft,.topRight], radius: limitedCornerRadius)
        }
    }
    
    @IBInspectable
    public var botLimitedCornerRadius: CGFloat = 0.0 {
        didSet {
            self.clipsToBounds = true
            self.layer.cornerRadius = botLimitedCornerRadius
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    /// Use Dash Width for dash border not border width
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = borderColor?.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        
        if cornerRadius > 0.0 {
            
            dashBorder.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath

        } else if topLimitedCornerRadius > 0.0 {
            
            dashBorder.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize(width: topLimitedCornerRadius, height: topLimitedCornerRadius)).cgPath

        } else if botLimitedCornerRadius > 0.0 {
            
            dashBorder.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft,.bottomRight], cornerRadii: CGSize(width: botLimitedCornerRadius, height: botLimitedCornerRadius)).cgPath

        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }

}

//MARK: Vertical Button

@IBDesignable
class VerticalButton: UIButton {
    
    @IBInspectable public var padding: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        if let titleSize = titleLabel?.sizeThatFits(maxSize), let imageSize = imageView?.sizeThatFits(maxSize) {
            let width = ceil(max(imageSize.width, titleSize.width))
            let height = ceil(imageSize.height + titleSize.height + padding)
            
            return CGSize(width: width, height: height)
        }
        
        return super.intrinsicContentSize
    }
    
    override func layoutSubviews() {
        if let image = imageView?.image, let title = titleLabel?.attributedText {
            let imageSize = image.size
            let titleSize = title.size()
    
            if effectiveUserInterfaceLayoutDirection == .leftToRight {
                titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width - 5.5, bottom: -(imageSize.height + padding), right: 0.0)
                imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + padding), left: 0.0, bottom: 0.0, right: -titleSize.width)
            }
            else {
                titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -(imageSize.height + padding), right: -imageSize.width)
                imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + padding), left: -titleSize.width, bottom: 0.0, right: 0.0)
            }
        }
        
        super.layoutSubviews()
    }
    
}

//MARK: Custom UISwitch (Toggle)

@IBDesignable
class CustomToggleButton: UISwitch {
    
    @IBInspectable var scale : CGFloat = 1{
        didSet{
            setupView()
        }
    }
    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        
    }
    
    override func layoutSubviews() {
        setupView()
        super.layoutSubviews()
    }
    
    func setupView () {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}


//MARK: Round Corner Button

@IBDesignable
class RoundCornerButton : UIButton {
   
    let rippleTouchController = MDCRippleTouchController()
    var isWork = true
    
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0

    var dashBorder: CAShapeLayer?
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
            self.imageView?.layer.cornerRadius = self.cornerRadius
        }
    }

    
    @IBInspectable var isFontWork: Bool = true { didSet { isWork = isFontWork }}
    
    @IBInspectable var bgColor: UIColor = UIColor(hexFromString: "2B2A29") {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable
        var shadowRadius: CGFloat {
            get {
                return layer.shadowRadius
            }
            set {
                layer.masksToBounds = false
                layer.shadowRadius = newValue
            }
        }

        @IBInspectable
        var shadowOpacity: Float {
            get {
                return layer.shadowOpacity
            }
            set {
                layer.masksToBounds = false
                layer.shadowOpacity = newValue
            }
        }

        @IBInspectable
        var shadowOffset: CGSize {
            get {
                return layer.shadowOffset
            }
            set {
                layer.masksToBounds = false
                layer.shadowOffset = newValue
            }
        }

        @IBInspectable
        var shadowColor: UIColor? {
            get {
                if let color = layer.shadowColor {
                    return UIColor(cgColor: color)
                }
                return nil
            }
            set {
                if let color = newValue {
                    layer.shadowColor = color.cgColor
                } else {
                    layer.shadowColor = nil
                }
            }
        }


    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
        //self.tintColor = .white
    }
    
    func setupView () {
        rippleTouchController.addRipple(to: self)
        self.backgroundColor = bgColor
        self.adjustsImageWhenHighlighted = false
        self.layer.cornerRadius = cornerRadius
        self.imageView?.layer.cornerRadius = cornerRadius
        self.imageView?.contentMode = .scaleAspectFill

        if isWork {
            self.titleLabel?.font = UIFont(name: "Work Sans", size: 16)?.regular
        } else {
            self.titleLabel?.font = UIFont(name: "Roboto", size: 16)?.regular
        }
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.addCharacterSpacing(kernValue: isWork ? 2 : 0.8)
    }
}


//MARK: TextView Form

@IBDesignable
class FormTextView: UITextView {

   
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var txtColor: UIColor = UIColor(hexFromString: "A5A4A2") {
        didSet {
            self.textColor = txtColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    @IBInspectable var txtSize: CGFloat = 14.0 {
        didSet {
            self.font!.withSize(txtSize)
        }
    }
    @IBInspectable var txtStroke: String = "r"
    
    
    @IBInspectable var topInset: CGFloat = 0 {
        didSet {
            self.contentInset = UIEdgeInsets(top: topInset, left: self.contentInset.left, bottom: self.contentInset.bottom, right: self.contentInset.right)
        }
    }

    @IBInspectable var bottmInset: CGFloat = 0 {
        didSet {
            self.contentInset = UIEdgeInsets(top: self.contentInset.top, left: self.contentInset.left, bottom: bottmInset, right: self.contentInset.right)
        }
    }

    @IBInspectable var leftInset: CGFloat = 0 {
        didSet {
            self.contentInset = UIEdgeInsets(top: self.contentInset.top, left: leftInset, bottom: self.contentInset.bottom, right: self.contentInset.right)
        }
    }

    @IBInspectable var rightInset: CGFloat = 0 {
        didSet {
            self.contentInset = UIEdgeInsets(top: self.contentInset.top, left: self.contentInset.left, bottom: self.contentInset.bottom, right: rightInset)
        }
    }
    

    func setupView() {
        let baseFont = UIFont(name: "Roboto", size: txtSize)
        
        self.font = baseFont?.regular
        self.textColor = txtColor
        
        switch txtStroke {
            case "r":
                self.font = baseFont?.regular
            case "bl":
                self.font = baseFont?.black
            case "b":
                self.font = baseFont?.bold
            case "sb":
                self.font = baseFont?.semibold
            case "h":
                self.font = baseFont?.heavy
            case "m":
                self.font = baseFont?.medium
            case "l":
                self.font = baseFont?.light
            case "i":
                self.font = baseFont?.italics()
            case "bi":
                self.font = baseFont?.boldItalics()
            default:
                self.font = baseFont?.regular
        }
    }
    
}

//MARK: Textfeild

@IBDesignable
class FormTextField: UITextField {
    
    @IBInspectable var txtSize: CGFloat = 13.0 {
        didSet {
            self.font!.withSize(txtSize)
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var txtStroke: String = "r"

    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderRadious: CGFloat = 0 {
        didSet {
            layer.cornerRadius = borderRadious
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    func setupView() {
        let baseFont = UIFont(name: "Work Sans", size: txtSize)

        self.font = baseFont?.regular

        switch txtStroke {
            case "r":
                self.font = baseFont?.regular
            case "bl":
                self.font = baseFont?.black
            case "b":
                self.font = baseFont?.bold
            case "sb":
                self.font = baseFont?.semibold
            case "h":
                self.font = baseFont?.heavy
            case "m":
                self.font = baseFont?.medium
            case "l":
                self.font = baseFont?.light
            case "i":
                self.font = baseFont?.italics()
            case "bi":
                self.font = baseFont?.boldItalics()
            default:
                self.font = baseFont?.regular
        }
    }
}

//MARK: Custom Gradient

@IBDesignable
public class Gradient: UIView {
    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
    
    func updatePoints() {
        if horizontalMode {
            gradientLayer.startPoint = diagonalMode ? .init(x: 1, y: 0) : .init(x: 0, y: 0.5)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 0, y: 1) : .init(x: 1, y: 0.5)
        } else {
            gradientLayer.startPoint = diagonalMode ? .init(x: 0, y: 0) : .init(x: 0.5, y: 0)
            gradientLayer.endPoint   = diagonalMode ? .init(x: 1, y: 1) : .init(x: 0.5, y: 1)
        }
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}


//MARK: Custom TableView

@IBDesignable
class CustomeTableView : UITableView {
    
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    // Will limit the given cornors with given radius
    @IBInspectable
    public var limitedCornerRadius: CGFloat = 0.0 {
        didSet {
            self.roundCorners(corners: [.topLeft,.topRight], radius: limitedCornerRadius)
        }
    }
    @IBInspectable var firstColor: UIColor = UIColor.clear
    @IBInspectable var secondColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    
    @IBInspectable var startLocation: Double =   0.25 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.75 { didSet { updateLocations() }}
    
    @IBInspectable var vertical: Bool = true
    
    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        gradientLayer.startPoint = CGPoint.zero
        gradientLayer.endPoint = vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updatePoints()
        updateLocations()
        updateColors()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updatePoints()
        updateLocations()
        updateColors()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updatePoints()
        updateLocations()
        updateColors()
    }
    
}


//MARK: Full Custom Lbl

@IBDesignable
class fullyCustomLbl : UILabel {
    
    var isWork : Bool = false
    
    var isSuezOne : Bool = false
    
    @IBInspectable var txtColor: UIColor = UIColor(hexFromString: "A5A4A2") {
        didSet {
            self.textColor = txtColor
        }
    }
    @IBInspectable var txtSize: CGFloat = 13.0 {
        didSet {
            self.font.withSize(txtSize)
        }
    }
    
    @IBInspectable var isFontWork: Bool = false { didSet { isWork = isFontWork }}
    @IBInspectable var isFontSuezOne: Bool = false { didSet { isSuezOne = isFontSuezOne }}
    
    @IBInspectable var txtStroke: String = "r"
    
    @IBInspectable var txtSpacing: Double = 0.1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
                
        var baseFont = UIFont()
        if isWork {
            baseFont = UIFont(name: "Work Sans Bold", size: txtSize)!
        } else if isSuezOne {
            baseFont = UIFont(name: "SuezOne-Regular", size: txtSize)!
        } else {
            baseFont = UIFont(name: "Roboto", size: txtSize)!
        }
        self.textColor = txtColor
        self.adjustsFontSizeToFitWidth = false
        self.addCharacterSpacing(kernValue: txtSpacing)
        
        switch txtStroke {
        case "r":
            self.font = baseFont.regular
        case "bl":
            self.font = baseFont.black
        case "b":
            self.font = baseFont.bold
        case "sb":
            self.font = baseFont.semibold
        case "h":
            self.font = baseFont.heavy
        case "m":
            self.font = baseFont.medium
        case "l":
            self.font = baseFont.light
        default:
            self.font = baseFont.regular
        }
    }
}


//MARK: Bottom Bar
@IBDesignable class TabBarWithCorners: UITabBar {
    @IBInspectable var color: UIColor?
    @IBInspectable var radii: CGFloat = 15.0

    @IBInspectable var height: CGFloat = 0.0

       override open func sizeThatFits(_ size: CGSize) -> CGSize {
           guard let window = UIApplication.shared.keyWindow else {
               return super.sizeThatFits(size)
           }
           var sizeThatFits = super.sizeThatFits(size)
           if #available(iOS 11.0, *) {
               sizeThatFits.height = self.height + window.safeAreaInsets.bottom
           } else {
               sizeThatFits.height = self.height
           }
           return sizeThatFits
       }
    
    private var shapeLayer: CALayer?

    override func draw(_ rect: CGRect) {
        addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()
    
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.gray.withAlphaComponent(0.1).cgColor
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
        shapeLayer.lineWidth = 1
    
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
    
        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radii, height: 0.0))
    
        return path.cgPath
    }
}
