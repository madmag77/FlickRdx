//
//  PhotoDetailsViewController.swift
//  FlickR
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit
import RxSwift

final class PhotoDetailsViewController: UIViewController {
    private let commonInset: CGFloat = 3
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!

    var viewModel: PhotoDetailsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createElements()
        createConstraints()
        
        view.backgroundColor = .white
        
        viewModel.photo.map({ image in
            image == nil ? UIImage(named: "placeholder") : image
        }).bind(to: photo.rx.image).disposed(by: disposeBag)
        viewModel.photoTitle.bind(to: photoTitle.rx.text).disposed(by: disposeBag)
    }
    
    private func createElements() {
        let imageView = UIImageView()
        photo = imageView
        photo.contentMode = .scaleAspectFit
        view.addSubview(photo)
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.numberOfLines = -1
        photoTitle = label
        view.addSubview(photoTitle)
    }

    private func createConstraints() {
        photoTitle.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(commonInset)
            make.right.equalTo(view).offset(-commonInset)
            
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-commonInset)
            } else {
                make.bottom.equalTo(view).offset(-commonInset)
            }

            make.height.equalTo(50)
        }
        
        photo.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(view).offset(commonInset)
            make.right.equalTo(view).offset(-commonInset)
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(commonInset)
            } else {
                make.top.equalTo(view).offset(commonInset)
            }
            make.bottom.equalTo(photoTitle.snp.top).offset(-commonInset)
        }
    }
}
