//
//  PhotosViewController.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit
import SnapKit

class PhotosViewController: UIViewController {
    private let loadingLabelHeight: CGFloat = 21

    @IBOutlet weak var photoCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createElements()
       
        title = localize("PHOTOSVIEW_TITLE")
    }
    
    override func updateViewConstraints() {
        photoCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).offset(1)
        }
        
        super.updateViewConstraints()
    }
    
    private func createElements() {
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: UICollectionViewFlowLayout())
        photoCollectionView = collectionView
        photoCollectionView.backgroundColor = UIColor.white
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reusableIdentifier)
        view.addSubview(photoCollectionView)
     }

}

