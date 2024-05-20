//
//  SocialAccVC.swift
//  Kismmet
//
//  Created by Ahsan Iqbal on 14/05/2024.
//

import UIKit

class SocialAccVC: MainViewController {

    @IBOutlet weak var socialCV: UICollectionView!
    
    var socialAccounts = [SocialAccDBModel()]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        socialAccounts = Array(DBService.fetchSocialAccList())

        socialCV.dataSource = self
        socialCV.delegate = self
        socialCV.register(SocialLinkCell.self, forCellWithReuseIdentifier: "SocialLinkCell")
        
        if let layout = socialCV.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 10 // Horizontal spacing between items
            layout.minimumLineSpacing = 10 // Vertical spacing between lines
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Spacing around the entire collection view
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        self.view.addGestureRecognizer(tap)
        
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.socialCV.addGestureRecognizer(tap2)
        self.socialCV.isUserInteractionEnabled = true
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
    }

    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.socialCV?.indexPathForItem(at: sender.location(in: self.socialCV)) {
            
            let socialLink = socialAccounts[indexPath.item]
            self.presentVC(id: "AddLinksVC", presentFullType: "over" ) { (vc:AddLinksVC) in
                vc.socialLink = socialLink
            }
            
        }
    }
    @objc func respondToSwipeGesture(gesture: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil) // For modal presentation
    }
}

extension SocialAccVC : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialAccounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocialLinkCell", for: indexPath) as! SocialLinkCell
        let socialLink = socialAccounts[indexPath.item]
        cell.configure(with: socialLink.linkImage, text: socialLink.linkType)
        return cell
    }
    
}

extension SocialAccVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let linkTypeWidth = socialAccounts[indexPath.item].linkType.size(withAttributes: [NSAttributedString.Key.font : UIFont(name: "Roboto", size: 14)?.regular as Any]).width + 25
        let totalAvailableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let maxNumColumns = 3
        let availableWidthPerItem = totalAvailableWidth / CGFloat(maxNumColumns) - 10 * 2 // Subtract horizontal spacing
        let width = min(linkTypeWidth, availableWidthPerItem)
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
