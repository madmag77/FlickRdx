//
//  PhotoCell.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit
import SnapKit

final class PhotoCell: UICollectionViewCell {
    static let reusableIdentifier = "PhotoCell"

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createElements()
        createConstraints()
        setDefaultValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        setDefaultValues()
    }

    private func createElements() {
        let imageView = UIImageView()
        photo = imageView
        photo.contentMode = .scaleAspectFit
        contentView.addSubview(photo)
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        title = label
        contentView.addSubview(title)
    }
    
    private func createConstraints() {
        title.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(3)
            make.right.equalTo(contentView).offset(-3)
            make.bottom.equalTo(contentView).offset(-3)
            make.height.equalTo(20)
        }
        
        photo.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(contentView).offset(3)
            make.right.equalTo(contentView).offset(-3)
            make.top.equalTo(contentView).offset(3)
            make.bottom.equalTo(title.snp.top).offset(-3)
        }
    }
    
    private func setDefaultValues() {
        photo.image = UIImage(named: "placeholder")
        title.text = ""
    }
}

extension PhotoCell: ConfigurablePhotoCell {
    func configure(title: String, photo: UIImage?) {
        self.title.text = title
        
        if let image = photo {
            self.photo.image = image
        }
    }
}
