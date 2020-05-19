# try! Swift World
# UIImagePickerController, AVFoundation and AVKit

Looking to integrate video into your application? In this workshop you will get an introduction to AVFoundation and AVKit for video playback. We will also be using UIImagePickerController to capture video from the user’s device. The capture video will also be persisted to the user’s device for future playback.

## In-workshop final app

![screenshot](https://user-images.githubusercontent.com/1819208/82311309-8642fa00-9993-11ea-98b3-391f25cca54f.PNG)

## Convert URL to UIImage - Creates Thumbnail Image for Video Content 

```swift 
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
```

## Convert Data to URL - for video playback 

```swift 
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
````

## Play video on a CALayer 

```swift 
private func playPinVideo(in headerView: HeaderView) {
    if let videoFileName = UserDefaults.standard.object(forKey: "PinVideoKey") as? String {
      // make sure videoId exist, else play random video
      guard let interview = (interviews.filter { $0.videoFileName == videoFileName }.first) else {
        return
      }
      guard let url = try? interview.videoData.videoURL() else {
        return
      }
      let player = AVPlayer(url: url)
      let playerLayer = AVPlayerLayer(player: player)
      headerView.configureHeaderView(for: interview)
      playerLayer.frame = headerView.videoView.bounds
      playerLayer.videoGravity = .resizeAspect
      headerView.videoView.layer.sublayers?.removeAll()
      headerView.videoView.layer.addSublayer(playerLayer)
      player.play()
    } else {
      // no video to play
      // TODO: exercise: play random video
    }
}
 ```
 
 ## Play video using the AVPlayerViewController 
 
 ```swift 
 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  let interview = interviews[indexPath.row]
  // AVPlayerViewController is part of AVKit
  let playerController = AVPlayerViewController()

  // convert a Data (videoData) object to a URL
  guard let videoURL = try? interview.videoData.videoURL() else {
    return
  }
  let player = AVPlayer(url: videoURL)
  playerController.player = player
  present(playerController, animated: true) {
    // automatically start video
    player.play()
  }
}
 ```
 
 
