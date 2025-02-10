//
//  SearchTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import UIKit
import SDWebImage
import SkeletonView
import ZoomingTransition
class SearchTableViewCell: UITableViewCell, SkeletonCollectionViewDataSource,SkeletonCollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    var lastSelectedIndexPath: IndexPath? = nil
    var index = 0
    var hashTagIndexPath: IndexPath?
    var videoObj = [HomeResponseMsg]()
    
    var hashtagVideo: DiscoverResponse?
    
    var hashtagClickHandler: ((IndexPath, String) -> Void)?
    var videoClickHandler: ((IndexPath, [HomeResponseMsg]) -> Void)?
    
    @IBOutlet weak var discoverCollectionView: UICollectionView!
    
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var hashName : UILabel!
    @IBOutlet weak var hashNameSub : UILabel!
    @IBOutlet weak var lblVideoCount: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        discoverCollectionView.delegate = self
        discoverCollectionView.dataSource = self
        discoverCollectionView.register(UINib(nibName: "newDiscoverCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "newDiscoverCollectionViewCell")
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    //MARK: - CollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(5, videoObj.count)
    }
    
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "newDiscoverCollectionViewCell"
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier:"newDiscoverCollectionViewCell" , for: indexPath) as! newDiscoverCollectionViewCell
        
        let vidObj = videoObj[indexPath.row].video
        cell.lbl.isHidden = true
        cell.img.isHidden = false
        let thumURL : String = (Utility.shared.detectURL(ipString: vidObj?.thum ?? ""))
//        cell.img.sd_setImage(with: URL(string:(thumURL)), placeholderImage: UIImage(named:""))
//        
        cell.img.sd_setImage(with: URL(string: thumURL), placeholderImage: UIImage(named: ""), options: .continueInBackground, completed: { [weak cell] image, _, _, _ in
            guard let cell = cell, let image = image else { return }
            UIView.transition(with: cell.img, duration: 0.3, options: .transitionCrossDissolve, animations: {
                cell.img.image = image
            }, completion: nil)
        })
        
        if indexPath.row > 3 {
            
            cell.lbl.isHidden = false
            cell.img.isHidden = true
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let video = videoObj[indexPath.row].video
            if let thum = video?.thum, let url = URL(string: thum) {
                SDWebImagePrefetcher.shared.prefetchURLs([url])
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.discoverCollectionView.frame.size.width/4, height: 130)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            self.hashtagClickHandler?(indexPath, videoObj[indexPath.row].hashtag?.name ?? "")

        }else {
            print("indexpath",videoObj[indexPath.row].video?.id)
            self.videoClickHandler?(indexPath,videoObj)
        }
    }
}
