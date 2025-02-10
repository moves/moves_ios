//
//  VideoCollectionViewCell.swift
// //
//
//  Created by Mac on 18/04/2024.
//

import UIKit
class VideoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imgReceipe: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func handleFetchVideoFromCachingManagerUsing(urlString: String, completion: @escaping (URL?) -> ()) {
          CacheManager.shared.getFileWith(stringUrl: urlString) { result in
              
              switch result {
              case .succeeded(let url):
                  // do some magic with path to saved video
                  completion(url)
                  break;
              case .failed(let error):
                  // handle errror
                  completion(nil)
                  print(error, "failed to find value of key\(urlString) in cache and also synchroniously failed to fetch video from our remote server, most likely a network issue like lack of connectivity or database failure")
                  break;
              }
          }
      }
}
