//
//  URL+VideoThumbnail.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/18/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension URL {
  // e.g mediaURL.videoThumbnail() => UIImage
  public func videoThumbnail() throws -> UIImage  {
    // AVAsset
    let asset = AVAsset(url: self)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true // false
    
    // using Core Media to generated a timestamp
    let timestamp = CMTime(seconds: 1.0, preferredTimescale: 60)
    
    var image: UIImage
    
    do {
      // cg - Core Graphics
      let cgImage = try generator.copyCGImage(at: timestamp, actualTime: nil)
      // converting CGImage to UIImage
      image = UIImage(cgImage: cgImage)
    } catch {
      throw VideoError.thumbnailError
    }
    return image
  }
}
