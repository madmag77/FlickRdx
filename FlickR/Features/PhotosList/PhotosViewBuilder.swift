//
//  PhotosViewBuilder.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit

struct PhotosViewBuilder {
    func build() -> UIViewController {
        
        let viewModel = PhotoViewModel(store: photosStore)
        let view = PhotosViewController()
        view.viewModel = viewModel
        
        return view
    }
}
