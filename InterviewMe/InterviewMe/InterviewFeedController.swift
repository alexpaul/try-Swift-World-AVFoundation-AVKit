//
//  ViewController.swift
//  InterviewMe
//
//  Created by Alex Paul on 5/16/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class InterviewFeedController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var promptButton: FloatingButton!
  
  private var interviews = [Interview]()
  private var alertController = UIAlertController()
  private var currentPrompt = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
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
      self.addInterviewToCollection()
    }
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let recordAction = UIAlertAction(title: "Record Interview", style: .default) { action in
        self.addInterviewToCollection()
      }
      alertController.addAction(recordAction)
    }
    alertController.addAction(photoLibrary)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
  
  private func addInterviewToCollection() {
    // TODO: generate videoData and imageData
    let interview = Interview(prompt: currentPrompt, videoData: Data(), videoFileName: "someName", imageData: Data())
    interviews.insert(interview, at: 0)
    let indexPath = IndexPath(item: 0, section: 0)
    collectionView.insertItems(at: [indexPath])
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
    // TODO: check of video id in UserDeaults, if nil play random video if available
    return headerView
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
}

extension InterviewFeedController: VideoCellDelegate {
  func didSelectInterview(_ cell: VideoCell, interview: Interview) {
    print("selected: \(interview.prompt)")
    alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let pinVideoAction = UIAlertAction(title: "Pin Video", style: .default) { action in
      // TODO: add video id to UserDefaults
    }
    // TODO: delete video
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(pinVideoAction)
    alertController.addAction(cancelAction)
    present(alertController, animated: true)
  }
}


