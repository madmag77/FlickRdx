//
//  PhotoDetailsBuilder.swift
//  FlickR
//
//  Created by Artem Goncharov on 3/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import UIKit

struct PhotoDetailsBuilder {
    func build() -> UIViewController {
        let viewModel = PhotoDetailsViewModel(store: photosStore)
        let view = PhotoDetailsViewController()
        view.viewModel = viewModel
        
        return view
    }
}
