//
//  PhotosViewController.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class PhotosViewController: UIViewController {
    private let loadingLabelHeight: CGFloat = 21
    private let disposeBag = DisposeBag()

    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var viewModel: PhotoViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = localize("PHOTOSVIEW_TITLE")
        view.backgroundColor = .white
        
        createElements()
        createConstraints()
        
        photoCollectionView.backgroundColor = .white
        
        // Bind collection view to viewModels dataSource
        viewModel.photos
            .bind(to: photoCollectionView.rx.items(dataSource: viewModel.getDataSource(photoCellDequeClosure: { [weak self] ip in
                return self?.photoCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reusableIdentifier, for: ip)
            })))
            .disposed(by: disposeBag)
     }
    
    override func updateViewConstraints() {
        photoCollectionView.snp.updateConstraints { (make) -> Void in
            make.edges.equalTo(self.view).offset(1)
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        guard let layout = photoCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.itemSize = CollectionViewUISetup.cellSize(collectionViewWidth: photoCollectionView.frame.size.width)
        layout.sectionInset = CollectionViewUISetup.sectionInsets
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
    }

    private func createElements() {
        let collectionView = UICollectionView(frame: CGRect.null, collectionViewLayout: UICollectionViewFlowLayout())
        photoCollectionView = collectionView
        photoCollectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reusableIdentifier)
        view.addSubview(photoCollectionView)
     }

    private func createConstraints() {
        photoCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view).offset(1)
        }
    }
}

fileprivate struct CollectionViewUISetup {
    static let sectionInsets = UIEdgeInsets(top: 1, left: 0, bottom: 1, right: 0)
    static let itemsPerRow: Int = 3
    static let heightToWidthProportion: CGFloat = 1.2
    
    static func cellSize(collectionViewWidth: CGFloat) -> CGSize {
        let widthPerItem = (collectionViewWidth - 5) / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: widthPerItem * heightToWidthProportion)
    }
    
}
