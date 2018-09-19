//
//  ImageModelController.swift
//  CustomCollectionViewLayout
//
//  Created by Fernando Cardenas on 19.09.18.
//  Copyright © 2018 Fernando Cardenas. All rights reserved.
//

import UIKit

class ImageProcessor {
    static func downsampleImage(fromData data: CFData, to pointSize: CGSize = CGSize(width: 200, height: 200), scale: CGFloat = 1.0) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data, imageSourceOptions) else { assert(false) }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { assert(false) }
        return UIImage(cgImage: downsampledImage)
    }
}

class ImageModelController {

    let session: URLSession = URLSession()
    private var task: URLSessionDataTask?

    typealias Handler = (Outcome<Data, NSError>) -> Void

    func loadData(fromURL url: URL, completion: @escaping Handler) {
        task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("|ERROR: \(String(describing: error))")
                completion(.error(error as NSError))
            }
            guard let data = data else { return }
            completion(.success(data))
        }
        task?.resume()
    }
}

enum Outcome<Value, Error: Swift.Error> {
    case success(Value)
    case error(Error)
}

