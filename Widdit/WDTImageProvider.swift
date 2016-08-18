//
//  WDTImageProvider.swift
//  Widdit
//
//  Created by Игорь Кузнецов on 24.06.16.
//  Copyright © 2016 John McCants. All rights reserved.
//

import UIKit
import ImageViewer

var configuration: ImageViewerConfiguration!
let imageProvider = WDTImageProvider()

let buttonAssets = CloseButtonAssets(normal: UIImage(named:"DeletePhotoButton")!, highlighted: UIImage(named: "DeletePhotoButton"))

class WDTImageProvider: ImageProvider {
    
    var image: UIImage = UIImage()
    
    func provideImage(completion: UIImage? -> Void) {
        completion(image)
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        completion(image)
    }
}