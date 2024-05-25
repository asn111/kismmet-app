//
//  SocialLinkCVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 12/05/2024.
//

import Foundation
import UIKit
import SDWebImage

class SocialLinkCell: UICollectionViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Roboto", size: 14)?.regular
        label.textAlignment = .center
        label.textColor = UIColor(named: "Text grey")
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        configureConstraints()
        configureCellAppearance()
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10), // Padding
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10), // Padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5), // Padding
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5), // Padding
            
            // Image View Constraints
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1.0), // Assuming a square image, adjust the multiplier as needed
            
            // Label Constraints
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8), // Adjust constant for spacing
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7) // Adjust multiplier as needed
        ])
    }
    
    private func configureCellAppearance() {
        // Apply rounded corners and border to the contentView
        contentView.layer.cornerRadius = 14 // Adjust for desired roundness
        contentView.layer.borderWidth = 0.7
        contentView.backgroundColor = .white
        //contentView.backgroundColor = UIColor(named: "Secondary Grey")?.withAlphaComponent(0.3)
        contentView.layer.borderColor = UIColor(named: "Text grey")?.cgColor
        contentView.clipsToBounds = true
        contentView.isUserInteractionEnabled = false
    }
    
    func configure(with imageURLString: String?, text: String) {
        if let imageURLString = imageURLString, let imageUrl = URL(string: imageURLString) {
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage()) { (image, error, imageCacheType, url) in
                if let image = image {
                    self.imageView.image = image
                }
            }
        }
        label.text = text
    }
}
