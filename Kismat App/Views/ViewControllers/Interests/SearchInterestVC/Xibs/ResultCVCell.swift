//
//  ResultCVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 05/03/2025.
//

import Foundation
import UIKit

class ResultCVCell: UICollectionViewCell {
    
    // Programmatically created title label.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .black
        return label
    }()
    
    // Programmatically created image view.
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    // Reference to the gradient layer (if added).
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        // Configure the cell's content view appearance.
        contentView.backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        // Add subviews to the content view.
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        // Set the default image (plus).
        iconImageView.image = UIImage(systemName: "plus")
        
        // Setup Auto Layout constraints.
        NSLayoutConstraint.activate([
            // Constraints for the image view.
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Constraints for the label.
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    
    /// Configure the cell with the given title and selection state.
    func configure(with title: String, selected: Bool) {
        titleLabel.text = title
        // This will trigger the didSet observer for isSelected to handle animation.
        self.isSelected = selected
    }
    
    // MARK: - Selection Animation
    
    override var isSelected: Bool {
        didSet {
            animateSelection(isSelected)
        }
    }
    
    private func animateSelection(_ selected: Bool) {
        if selected {
            // Create and add a gradient background.
            let gradient = CAGradientLayer()
            gradient.frame = contentView.bounds
            gradient.colors = [UIColor.systemRed.cgColor, UIColor.systemBlue.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            contentView.layer.insertSublayer(gradient, at: 0)
            self.gradientLayer = gradient
            
            // Animate the image transition from plus to checkmark.
            UIView.transition(with: iconImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.iconImageView.image = UIImage(systemName: "checkmark")
            }, completion: nil)
        } else {
            // Remove the gradient layer and revert to the plain white background.
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
            
            UIView.transition(with: iconImageView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.iconImageView.image = UIImage(systemName: "plus")
            }, completion: nil)
        }
    }
    
    // Ensure the gradient layer always fills the cell’s bounds.
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = contentView.bounds
    }
}
