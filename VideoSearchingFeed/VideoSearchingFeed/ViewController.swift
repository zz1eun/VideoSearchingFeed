//
//  ViewController.swift
//  VideoSearchingFeed
//
//  Created by baejji on 2018. 4. 12..
//  Copyright © 2018년 baejji. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var allVideos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchAllVideos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func fetchAllVideos() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            print("available")
            let allVideosOptions = PHFetchOptions()
            allVideosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            allVideosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            self.allVideos = PHAsset.fetchAssets(with: allVideosOptions)
            
        case PHAuthorizationStatus.notDetermined:
            PHPhotoLibrary.requestAuthorization({(authorizationStatus: PHAuthorizationStatus) in
                if authorizationStatus == .authorized {
                    
                }
            })
        default:
            print("not available")
        }
        collectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        
        let video: PHAsset = self.allVideos[indexPath.row]
        
        self.imageManager.startCachingImages(for: [video], targetSize: cell.frame.size, contentMode: .aspectFit, options: nil)
        self.imageManager.requestImageData(for: video, options: nil) { (data, string, orientation, info) in
            cell.imageView.image = UIImage(data: data!)
            
            let ciImage = CIImage(cgImage: cell.imageView.image!.cgImage!)
            
            let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)!
            
            let faces: [CIFeature] = faceDetector.features(in: ciImage)
            
            if faces.count >= 2 {
                cell.imageView.layer.borderWidth = 5.0
                cell.imageView.layer.borderColor = UIColor.yellow.cgColor
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size: CGSize = CGSize(width: self.collectionView.frame.width*0.5-0.5, height: self.collectionView.frame.width*0.5-0.5)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
}

