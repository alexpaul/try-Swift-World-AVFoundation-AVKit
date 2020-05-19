//
//  ViewController.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation // allows playback on a CALayer
import AVKit // allows playback with the built-in AVPlayerViewController
import DataPersistence

enum VideoError: Error {
  case noContentsAtURL
  case thumbnailError
  case failedToWriteToDisk
}

class InterviewFeedController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var promptButton: FloatingButton!
  
  private var interviews = [Interview]()
  private var alertController = UIAlertController()
  private var currentPrompt = ""
  
  private var imagePickerController: UIImagePickerController!
  
  private var dataPersistence =  DataPersistence<Interview>(filename: "interviews") //.plist
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configureImagePickerController()
    loadInterviews()
  }
  
  private func loadInterviews() {
    do {
      interviews = try dataPersistence.loadItems()
    } catch {
      print("could not load interviews: \(error)")
    }
  }
  
  private func configureImagePickerController() {
    imagePickerController = UIImagePickerController()
    // we need to retrieve the mediaTypes available on the device
    if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
      imagePickerController.mediaTypes = mediaTypes // public.movie, public.image
    }
    imagePickerController.delegate = self
  }
  
  private func configureCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
  }
  
  @IBAction func promptButtonPressed(_ button: FloatingButton
  ) {
    showPrompt()
  }
  
  private func showPrompt() {
    currentPrompt = Interview.getPrompt()
    alertController = UIAlertController(title: "Interview Prompt", message: currentPrompt, preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    let photoLibrary = UIAlertAction(title: "Interview from Library", style: .default) { action in
      self.imagePickerController.sourceType = .photoLibrary
      self.present(self.imagePickerController, animated: true)
    }
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let recordAction = UIAlertAction(title: "Record Interview", style: .default) { action in
        // check if camera is available on the device
        self.imagePickerController.sourceType = .camera
        // video, photo (default)
        self.imagePickerController.cameraCaptureMode = .video
        self.present(self.imagePickerController, animated: true)
      }
      alertController.addAction(recordAction)
    }
    alertController.addAction(photoLibrary)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  private func addInterviewToCollection(_ mediaURL: URL) throws {
    // TODO: generate videoData and imageData
    
    // this data property will be persisted
    var videoData: Data
    
    do {
      videoData = try Data(contentsOf: mediaURL)
    } catch {
      throw VideoError.noContentsAtURL
    }
    
    // TODO: convert URL to Image => Data
    
    let image = try? mediaURL.videoThumbnail()
    
    // convert image to data
    guard let imageData = image?.jpegData(compressionQuality: 1.0) else {
      return
    }
    
    // videoFileName: trim.8AF97EB4-3FFD-42C7-AD8C-639ABE153876.MOV
    let videoFileName = mediaURL.lastPathComponent
    
    let interview = Interview(prompt: currentPrompt, videoData: videoData, videoFileName: videoFileName, imageData: imageData)
    interviews.insert(interview, at: 0)
    let indexPath = IndexPath(item: 0, section: 0)
    collectionView.insertItems(at: [indexPath])
    
    // persist (save) interview to documents directory
    do {
      try dataPersistence.createItem(interview)
    } catch {
      print("could not save interview \(error)")
    }
  }
}

extension InterviewFeedController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return interviews.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as? VideoCell else {
      fatalError("could not dequeue a VideoCell")
    }
    let interview = interviews[indexPath.row]
    cell.configureCell(for: interview)
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
      fatalError("could not dequeue HeaderView")
    }
    headerView.layoutIfNeeded()
    playPinVideo(in: headerView)
    
    return headerView
  }
  
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
}

extension InterviewFeedController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemWidth: CGFloat = collectionView.bounds.size.width
    let itemHeight: CGFloat = collectionView.bounds.size.height * 0.40
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.size.width, height: 300)
  }
  
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
}

extension InterviewFeedController: VideoCellDelegate {
  func pinVideo(_ interview: Interview) {
    // add the videoId to UserDefaults
    // reload the collection view
    UserDefaults.standard.set(interview.videoFileName, forKey: "PinVideoKey") // refactor to a constant
    collectionView.reloadData() // this will reload the HeaderView
  }
  
  func didSelectInterview(_ cell: VideoCell, interview: Interview) {
    print("selected: \(interview.prompt)")
    alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let pinVideoAction = UIAlertAction(title: "Pin Video", style: .default) { action in
      self.pinVideo(interview)
    }
    // TODO: delete video
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(pinVideoAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
}

extension InterviewFeedController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Two keys we are interested in from the info dicitonary
    // mediaURL - URL
    // mediaType - String
    picker.dismiss(animated: true)
    guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String,
      mediaType == "public.movie",
      let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
      print("not working this type")
      return
    }
    try? addInterviewToCollection(mediaURL)
    print("mediaType: \(mediaType), mediaURL: \(mediaURL)")
  }
}


