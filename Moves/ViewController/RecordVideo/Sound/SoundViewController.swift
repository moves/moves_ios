//
//  SoundViewController.swift
// //
//
//  Created by Wasiq Tayyab on 08/07/2024.
//

import UIKit
import SDWebImage
import AVFAudio

class SoundViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Outlets
    var audioPlayer : AVAudioPlayer?
    var isPlaying = false
    var isSoundLoading: Bool = false
    let spinner = UIActivityIndicatorView(style: .white)
    var isControllerpush = false
    private var startPoint = 0
    var isNextPageLoad = false
    var isSelectedfavourite = false   // CHECK EITHER USER CHECK SOUND OR FAVOURTE
    var currentPlayingCell: SoundsTableViewCell?
    var currentPlayingIndex: Int? = nil
    private var viewModel = AllSoundViewModel()
    fileprivate var menuTitles = [["menu":"Sound","isSelected":"true"],
                                  ["menu":"Favorite","isSelected":"false"]]
    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    var objSound = [Sound]()
    var selectedIndex = 0
    var selectedSection = 0
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration()
    }
    
    //MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       
    }
    //MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent

    }
    //MARK: Button actions
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        if self.isControllerpush{
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true)
        }
       
    }
    
}

extension SoundViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhoneSiginCollectionViewCell", for: indexPath)as! PhoneSiginCollectionViewCell
        cell.lblMenu.text = menuTitles[indexPath.row]["menu"] ?? ""
        if menuTitles[indexPath.row]["isSelected"] == "true" {
            cell.lineView.isHidden = false
            cell.lblMenu.textColor = UIColor.appColor(.theme)
        }else {
            cell.lineView.isHidden = true
            cell.lblMenu.textColor = UIColor.appColor(.darkGrey)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2.0, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for i in 0..<self.menuTitles.count {
            var obj  = self.menuTitles[i]
            obj.updateValue("false", forKey: "isSelected")
            self.menuTitles.remove(at: i)
            self.menuTitles.insert(obj, at: i)
        }
        
        var obj  =  self.menuTitles[indexPath.row]
        obj.updateValue("true", forKey: "isSelected")
        self.menuTitles.remove(at: indexPath.row)
        self.menuTitles.insert(obj, at: indexPath.row)
        collectionView.reloadData()
        self.startPoint = 0
        self.configuration(selectedIndex:indexPath.row)
    }
}

extension SoundViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSelectedfavourite ? 1 :  viewModel.allSound?.msg?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  isSelectedfavourite ? viewModel.allfavouriteSound?.msg?.count ?? 0  : viewModel.allSound?.msg?[section].sound.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SoundsTableViewCell", for: indexPath)as! SoundsTableViewCell
        let sound =  isSelectedfavourite ?  viewModel.allfavouriteSound?.msg?[indexPath.row].sound : viewModel.allSound?.msg?[indexPath.section].sound[indexPath.row]
        cell.soundImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.soundImage.sd_setImage(with: URL(string:(sound?.thum ?? "")), placeholderImage: UIImage(named: "videoPlaceholder"))
        cell.lblSoundName.text = sound?.name
        cell.lblName.text = sound?.description
        cell.lblInformation.text = sound?.duration
        cell.btnPlay.isHidden = false
        
        cell.btnPlay.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.superview?.tag = indexPath.section
        
        cell.btnVideo.addTarget(self, action: #selector(videoButtonPressed), for: .touchUpInside)
        cell.btnVideo.tag = indexPath.row
        cell.btnVideo.superview?.tag = indexPath.section
        cell.btnVideo.isHidden = true
        
        cell.btnHashtag.isHidden = false
        cell.btnHashtag.addTarget(self, action: #selector(hashtagButtonPressed), for: .touchUpInside)
        cell.btnHashtag.tag = indexPath.row
        cell.btnHashtag.superview?.tag = indexPath.section
        
        isSelectedfavourite ? cell.btnHashtag.setImage(UIImage(named: "btnFavFilled"), for: .normal)  : cell.btnHashtag.setImage(UIImage(named: "btnFavEmpty"), for: .normal)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func hashtagButtonPressed(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at:buttonPosition)
        let cell = self.tableView.cellForRow(at: indexPath!) as! SoundsTableViewCell
        
        let btnFavImg = cell.btnHashtag.currentImage
        if btnFavImg == UIImage(named: "btnFavEmpty"){
            cell.btnHashtag.setImage(UIImage(named: "btnFavFilled"), for: .normal)
        }else{
            cell.btnHashtag.setImage(UIImage(named: "btnFavEmpty"), for: .normal)
        }
        let sound =  isSelectedfavourite ?  viewModel.allfavouriteSound?.msg?[sender.tag].sound : viewModel.allSound?.msg?[sender.superview!.tag].sound[sender.tag]
        let request = addFvrtSoundsRequest(userId:  UserDefaultsManager.shared.user_id, sound_id: "\(sound?.id ?? 0)")
        viewModel.AddFavouriteSounds(parameters: request)
    }
    
    
    @objc func playButtonPressed(_ sender: UIButton) {
        print("selectedIndex", selectedIndex)
        print("selectedSection", selectedSection)
        
        print("selectedSection", sender.tag)
        print("selectedSection", sender.superview?.tag ?? 0)
        
        if self.selectedIndex != sender.tag || selectedSection != sender.superview?.tag ?? 0 {
            self.resetAudioPlayerAndButtons()
        }

        let index = IndexPath(row: sender.tag, section: sender.superview?.tag ?? 0)
        selectedIndex = sender.tag
        selectedSection = sender.superview?.tag ?? 0
        
        let sound = isSelectedfavourite ? viewModel.allfavouriteSound?.msg?[sender.tag].sound : viewModel.allSound?.msg?[sender.superview!.tag].sound[sender.tag]
        let cell = self.tableView.cellForRow(at: index) as! SoundsTableViewCell
        cell.btnVideo.isHidden = false

        if cell.btnPlay.currentImage == UIImage(systemName: "play.fill") {
            let urlString = sound?.audio ?? ""
            guard let audioUrl = URL(string: urlString) else {
                print("Invalid audio URL")
                DispatchQueue.main.async {
                    Utility.showMessage(message: "Invalid audio URL", on: self.view)
                }
                return
            }
            cell.btnVideo.isHidden = false
            
            // Ensure UI updates are on the main thread
            DispatchQueue.main.async {
                cell.btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }

            let task = URLSession.shared.dataTask(with: audioUrl) { [weak self] data, response, error in
                if let error = error {
                    print("Error loading audio: \(error)")
                    DispatchQueue.main.async {
                        Utility.showMessage(message: error.localizedDescription ?? "", on: self?.view ?? UIView())
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Failed to load audio with a valid HTTP response.")
                    DispatchQueue.main.async {
                        Utility.showMessage(message: "Failed to load audio.", on: self?.view ?? UIView())
                    }
                    return
                }
                
                // Ensure the data is not nil
                guard let data = data else {
                    print("No audio data found.")
                    DispatchQueue.main.async {
                        Utility.showMessage(message: "No audio data found.", on: self?.view ?? UIView())
                    }
                    return
                }
                
                print("Audio data", data)
                
                // Use AVPlayer to play the audio (UI updates on main thread)
                DispatchQueue.main.async {
                    do {
                        self?.audioPlayer = try AVAudioPlayer(data: data)
                        self?.audioPlayer?.prepareToPlay()
                        self?.audioPlayer?.play()
                        self?.audioPlayer?.delegate = self
                        self?.audioPlayer?.rate = 1.0
                    } catch let error {
                        DispatchQueue.main.async {
                            cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
                            Utility.showMessage(message: "Unable to play audio", on: self?.view ?? UIView())
                        }
                        print("Error loading audio file:", error.localizedDescription)
                    }
                }
            }
            task.resume()
        } else {
            audioPlayer?.stop()
            DispatchQueue.main.async {
                cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            let index = IndexPath(row: selectedIndex, section: selectedSection)
            let cell = self.tableView.cellForRow(at:index) as! SoundsTableViewCell
            cell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.audioPlayer?.stop()
            print("Audio playback finished successfully")
        } else {
            // Playback finished with an error
            print("Audio playback finished with an error")
        }
    }
    
    func resetAudioPlayerAndButtons() {
        self.audioPlayer?.stop()
        for cell in tableView.visibleCells {
            if let customCell = cell as? SoundsTableViewCell {
                customCell.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
                customCell.btnVideo.isHidden =  true
            }
        }
    }
    
    @objc func videoButtonPressed(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point),
              let sound = viewModel.allSound?.msg?[indexPath.section].sound[indexPath.item] else {
            return
        }
        
        UserDefaultsManager.shared.sound_id = sound.id?.toString() ?? ""
        UserDefaultsManager.shared.sound_name = sound.name ?? ""
        UserDefaultsManager.shared.sound_url = sound.audio ?? ""
        UserDefaultsManager.shared.sound_second = sound.duration ?? ""
        
        guard let audioURLString = sound.audio,
              let audioUrl = URL(string: audioURLString) else {
            return
        }
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            NotificationCenter.default.post(name: NSNotification.Name("loadAudio"), object: nil)
            if self.isControllerpush{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.dismiss(animated: true)
            }
        } else {
            URLSession.shared.downloadTask(with: audioUrl) { (location, response, error) in
                guard let location = location, error == nil else {
                    print("Failed to download file:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                do {
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    
                    // Ensuring the UI updates are performed on the main thread
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("loadAudio"), object: nil)
                        if self.isControllerpush {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    }
                } catch {
                    print("Failed to move downloaded file:", error.localizedDescription)
                }
            }.resume()
        }
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let label = UILabel()
        label.text = viewModel.allSound?.msg?[section].soundSection.name
        label.font = AppFont.font(type: .Semibold, size: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = AppFont.font(type: .Regular, size: 12.0)
        button.setTitleColor(UIColor.appColor(.darkGrey), for: .normal)
        button.addTarget(self, action: #selector(seeAllButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 13),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -13),
            button.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    @objc func seeAllButtonPressed(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
        // Handle "See All" button action
        print("See All button pressed in section: \(indexPath.section)")
    }
}

extension SoundViewController{
    
    func configuration(selectedIndex:Int = 0) {
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.register(UINib(nibName: "PhoneSiginCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhoneSiginCollectionViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SoundsTableViewCell", bundle: nil), forCellReuseIdentifier: "SoundsTableViewCell")
        initViewModel(startingPoint: startPoint,selectedIndex: selectedIndex)
    }
    
    func initViewModel(startingPoint:Int, selectedIndex:Int = 0) {
        self.lblNoData.isHidden =  true
        let allSound = ShowSoundsRequest(userId: UserDefaultsManager.shared.user_id, startingPoint: startingPoint)
        print("request",allSound)
        selectedIndex == 0 ? viewModel.showSounds(parameters: allSound) :viewModel.showFavouriteSounds(parameters: allSound)
        isSelectedfavourite = selectedIndex == 0 ? false : true
        observeEvent()
    }
    
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self else { return }
            
            switch event {
            case .error(let error):
                print("error",error ?? "")
                DispatchQueue.main.async {
                    if let dataError = error as? Moves.DataError {
                       switch dataError {
                       case .invalidResponse:
                           Utility.showMessage(message: "Unstable Network. Please try again", on: self.view)
                       default:
                           Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                       }
                   } else {
                       Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                   }
                }
           
            case .newShowSoundsAgainstSection(showSoundsAgainstSection: let showSoundsAgainstSection):
                if showSoundsAgainstSection.code == 200 {
                    if startPoint == 0 {
                        viewModel.allSound?.msg?.removeAll()
                        viewModel.allSound = showSoundsAgainstSection
                        print("response")
                    }else {
                        if let newMessages = showSoundsAgainstSection.msg {
                            viewModel.allSound?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.viewModel.allSound?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.isNextPageLoad = false
                        }
                        self.tableView.reloadData()
                    }
                }else {
                    if startPoint == 0 {
                        viewModel.allSound?.msg?.removeAll()
                        DispatchQueue.main.async {
                            self.lblNoData.isHidden = false
                            self.lblNoData.text = "There is no sound yet."
                        }
                        
                        
                    }else {
                        self.isNextPageLoad = false
                    }
                }
            case .ShowFavouriteSoundsAgainstUserID(showSoundsAgainstSection: let showSoundsfavouriteSound):
                if showSoundsfavouriteSound.code == 200 {
                    if startPoint == 0 {
                        viewModel.allfavouriteSound?.msg?.removeAll()
                        viewModel.allfavouriteSound = showSoundsfavouriteSound
                        print("showSoundsfavouriteSound response")
                    }else {
                        if let newMessages = showSoundsfavouriteSound.msg {
                            viewModel.allfavouriteSound?.msg?.append(contentsOf: newMessages)
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if (self.viewModel.allfavouriteSound?.msg?.count ?? 0) >= 10 {
                            self.isNextPageLoad = true
                        }else {
                            self.isNextPageLoad = false
                        }
                        if self.viewModel.allfavouriteSound?.msg?.count == 0{
                            DispatchQueue.main.async {
                                self.lblNoData.isHidden = false
                                self.lblNoData.text = "There is no sound yet."
                            }
                        }
                        self.tableView.reloadData()
                    }
                }else {
                    if startPoint == 0 {
                        viewModel.allfavouriteSound?.msg?.removeAll()
                        DispatchQueue.main.async {
                            self.lblNoData.isHidden = false
                            self.lblNoData.text = "There is no sound yet."
                        }


                    }else {
                        self.isNextPageLoad = false
                    }
                }
            case .TagSoundsAgainstUserID(showSoundsAgainstSection: let TagSoundsfavouriteSound):
                if TagSoundsfavouriteSound.code == 200 {
                    print("Tag fvrt response")
                }else{
                    print("Error fvrt response")
                }
            }
        }
    }
}
//MARK: PAGINATION
extension SoundViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDragging")
        if isNextPageLoad == true {
            self.spinner.stopAnimating()
            isSoundLoading = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.spinner.stopAnimating()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        if scrollView == self.tableView{
            if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
            {
                if isNextPageLoad == true {
                    if !isSoundLoading{
                        isSoundLoading = true
                        spinner.startAnimating()
                        startPoint += 1
                        initViewModel(startingPoint: startPoint)
                    }
                }
            }
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height {
            if isNextPageLoad == true {
                self.spinner.hidesWhenStopped = true
                self.spinner.stopAnimating()
            }
        }
    }
}
