//
//  PreviewViewController.swift
// //
//
//  Created by Wasiq Tayyab on 06/07/2024.
//

import UIKit
import GSPlayer
import AVFoundation
import SVProgressHUD
class PreviewViewController: UIViewController, AVAudioPlayerDelegate {
 
    fileprivate var playerItem: AVPlayerItem!
    fileprivate var video: AVURLAsset?
    fileprivate var originalImage: UIImage?
    var url:URL?
    internal var image: UIImage?
    var audioPlayer : AVAudioPlayer?
    @IBOutlet weak var lblSoundName: UILabel!
    @IBOutlet weak var videoView: VideoPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let thumbnailImage = getThumbnailImage(forUrl: url!) {
            image = thumbnailImage
        }
        //SVProgressHUD.show()
        self.playerSetup()
       
    }
    override func viewWillAppear(_ animated: Bool) {
        self.loadAudio()
        self.lblSoundName.text = UserDefaultsManager.shared.sound_name.isEmpty ? "Select Sound" : UserDefaultsManager.shared.sound_name
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoView.pause(reason: .hidden)
        audioPlayer?.stop()
    }
    
    func loadAudio() {
        let urlString = UserDefaultsManager.shared.sound_url
        
        guard let audioUrl = URL(string: urlString) else {
            print("Invalid audio URL")
            return
        }
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        
        do {
           
            audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            audioPlayer?.delegate = self
            audioPlayer?.rate = 1.0
            print("Loaded audio file successfully")
            print("Audio duration: ", audioPlayer?.duration ?? "Unknown")
            
        } catch let error {
            // Handle any errors during audio player initialization
            print("Error loading audio file:", error.localizedDescription)
        }
    }
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // Playback finished successfully
            print("Audio playback finished successfully")
            audioPlayer?.currentTime = 0
            audioPlayer?.play()
        } else {
            // Playback finished with an error
            print("Audio playback finished with an error")
        }
    }
    
 
    //MARK: - ViewDidDisappear
    
    override func viewDidDisappear(_ animated: Bool) {
        videoView.pause(reason: .hidden)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        videoView.pause(reason: .hidden)
        
        let myViewController = PostVideoViewController(nibName: "PostVideoViewController", bundle: nil)
        myViewController.videoUrl = url
        myViewController.thumbnailImage = image
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    
    @IBAction func btnSelectSounAction(_ sender: Any) {
        self.audioPlayer?.pause()
        let myViewController = SoundViewController(nibName: "SoundViewController", bundle: nil)
        myViewController.isControllerpush  = true
        self.navigationController?.pushViewController(myViewController, animated: true)
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
   
    func playerSetup() {
        self.videoView.contentMode = .scaleAspectFill
        self.videoView.play(for: self.url!)
        self.videoView.player?.volume = (UserDefaultsManager.shared.sound_url != nil &&  UserDefaultsManager.shared.sound_url != "") ? 0.0 : 1.0
        self.videoView.stateDidChanged = { [self] state in
            switch state {
            case .none:
                print("none")
            case .error(let error):
                Utility.showMessage(message: error.localizedDescription, on: self.view)
                print("error - \(error.localizedDescription)")
            case .loading:
                print("loading")
            case .paused(let playing, let buffering):
                print("paused - progress \(Int(playing * 100))% buffering \(Int(buffering * 100))%")
            case .playing:
                audioPlayer?.play()
                SVProgressHUD.dismiss()
            }
        }
    }
    
}
