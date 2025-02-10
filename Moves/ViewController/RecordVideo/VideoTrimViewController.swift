//
//  CropVideoThumnailViewController.swift
// //
//
//  Created by Macbook Pro on 26/09/2024.
//

import UIKit
import AVFoundation
import PryntTrimmerView

protocol customThumbnailImage:class{
    func customThumbnail(img:UIImage?)
}

class VideoTrimViewController: UIViewController {  // USED FOR CUSTOM COVER PHOTOS

    
    //MARK: Outlets
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var frameContainerView: UIView!
    @IBOutlet weak var imageFrameView: TrimmerView!
    @IBOutlet weak var thumnailImage: UIImageView!
    var delegate:customThumbnailImage?
    var player: AVPlayer?
    var img:UIImage?
    var url:URL! = nil
    var asset: AVAsset!

    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        asset = AVAsset(url: url)
        self.thumnailImage.image = img
        imageFrameView.asset = asset
        imageFrameView.delegate = self
        self.createImageFrames()
    }

    //MARK: Button actions
    @IBAction func btnDoneAction(_ sender: Any) {
        delegate?.customThumbnail(img: thumnailImage.image)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    //MARK: generateThumbnail
    func generateThumbnail(at time: CMTime) -> UIImage? {
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        var thumbnail: UIImage?
        let timeInSeconds = CMTimeGetSeconds(time)
        let thumbnailTime = CMTimeMakeWithSeconds(timeInSeconds, preferredTimescale: 600)
        
        do {
            let imgRef = try assetImgGenerate.copyCGImage(at: thumbnailTime, actualTime: nil)
            thumbnail = UIImage(cgImage: imgRef)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        
        return thumbnail
    }
    
    func createImageFrames() {
        // Create an AVAssetImageGenerator for the asset
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero

        let assetDuration = asset.duration
        let durationSeconds = CMTimeGetSeconds(assetDuration)
        
        // Determine the number of thumbnails (6 in this case)
        let numberOfThumbnails = 15
        let thumbInterval = durationSeconds / Double(numberOfThumbnails)

        var startTime: Float64 = 0
        var startXPosition: CGFloat = 0.0
        let buttonWidth = frameContainerView.frame.width / CGFloat(numberOfThumbnails)
        let buttonHeight = frameContainerView.frame.height

        // Loop to create 6 thumbnails
        for i in 0..<numberOfThumbnails {
            let imageButton = UIButton()
            imageButton.frame = CGRect(x: startXPosition, y: 0, width: buttonWidth, height: buttonHeight)
            
            let time = CMTimeMakeWithSeconds(startTime, preferredTimescale: assetDuration.timescale)

            do {
                // Generate image at the current time
                let cgImage = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                
                // Set the generated image to the button
                imageButton.setImage(thumbnail, for: .normal)
            } catch {
                print("Error generating image: \(error)")
            }

            // Adjust x position and time for the next button
            startXPosition += buttonWidth
            startTime += thumbInterval

            // Disable user interaction for these image buttons (as per your original code)
            imageButton.isUserInteractionEnabled = false
            
            // Add the button to the imageFrameView
            frameContainerView.addSubview(imageButton)
        }
    }


}

// MARK: - TrimmerViewDelegate
extension VideoTrimViewController: TrimmerViewDelegate {
    func didChangePositionBar(_ playerTime: CMTime) {
        print("Current time of the trimmer bar: \(CMTimeGetSeconds(playerTime))")
    }
    
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        print("Position bar stopped at: \(CMTimeGetSeconds(playerTime))")
        if let startTime = imageFrameView.startTime {
            let thumbnailImage = generateThumbnail(at: startTime)
            self.thumnailImage.image = thumbnailImage
        }
    }
}
