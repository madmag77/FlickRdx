//
//  PhotosSection.swift
//  FlickR
//
//  Created by Artem Goncharov on 2/3/19.
//  Copyright © 2019 madmag77. All rights reserved.
//

import Foundation
import RxDataSources

extension PhotosState: SectionModelType {
    typealias Item = Photo
    
    init(original: PhotosState, items: [Photo]) {
        self = original
        self.items = items
    }
}

