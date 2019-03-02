//
//  PhotoCell.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    static let reusableIdentifier = "PhotoCell"

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        photo.image = UIImage(named: "placeholder")
        title.text = ""
    }

    private func createElements() {
        let imageView = UIImageView()
        photo = imageView
        self.addSubview(photo)
        
        let label = UILabel()
        title = label
        self.addSubview(title)
    }
}
