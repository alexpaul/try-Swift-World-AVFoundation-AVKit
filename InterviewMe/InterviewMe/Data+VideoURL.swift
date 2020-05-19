//
//  Data+VideoURL.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/18/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

extension Data {
  // convert Data to a temporary URL
  // AVPlayer requires playback for a URL
  public func videoURL() throws -> URL {
    let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
    // write the data to disk
    do {
      try self.write(to: tempFileURL, options: .atomic)
    } catch {
      throw VideoError.failedToWriteToDisk
    }
    return tempFileURL
  }
}
