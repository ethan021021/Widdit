//
//  WDTAddPostViewController.swift
//  Widdit
//
//  Created by JH Lee on 09/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit
import Parse
import ALCameraViewController
import UITextView_Placeholder
import DKImagePickerController
import Kingfisher


class WDTAddPostViewController: UIViewController, UITextViewDelegate {

    var m_strPlaceholder: String?
    var m_hashtag: String?
    var m_objPost: PFObject?
    
    @IBOutlet weak var m_btnPost: UIBarButtonItem!
    @IBOutlet weak var m_txtDescription: UITextView!
    @IBOutlet weak var m_lblLength: UILabel!
    @IBOutlet weak var m_imagesCollectionView: UICollectionView!
    @IBOutlet weak var m_imagesLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var m_lblSliderValue: UILabel!
    @IBOutlet weak var m_viewSliderContainer: UIView!
    
    let slider = WDTCircleSlider()
    
    var geoPoint: PFGeoPoint?
    var photos: [UIImage] = []
    
    var isLoadPhotos = false {
        didSet {
            self.m_imagesCollectionView.isUserInteractionEnabled = !isLoadPhotos
            if isLoadPhotos {
                self.m_imagesLoadingIndicator.startAnimating()
                self.m_imagesLoadingIndicator.isHidden = false
            } else {
                self.m_imagesLoadingIndicator.stopAnimating()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLoadPhotos = false

        // Do any additional setup after loading the view.
        if let strPlaceholder = m_strPlaceholder {
            m_txtDescription.placeholder = strPlaceholder
        }
        
        if let objPost = m_objPost {
            m_txtDescription.text = objPost["postText"] as? String ?? ""
            
            let photoURLs = (objPost["photoURLs"] as? [String] ?? [])
            if photoURLs.count > 0 {
                isLoadPhotos = true
                var photosLoaded = 0
                photoURLs.forEach { path in
                    guard let url = URL(string: path) else { return }
                    
                    KingfisherManager.shared.retrieveImage(with: url,
                                                           options: nil,
                                                           progressBlock: nil,
                                                           completionHandler:
                    { [weak self] (image, error, _, _) in
                        if let image = image {
                            objc_sync_enter(self)
                            self?.photos.append(image)
                            self?.m_imagesCollectionView.reloadData()
                            objc_sync_exit(self)
                        }
                        
                        photosLoaded += 1
                        if photosLoaded >= photoURLs.count {
                            self?.isLoadPhotos = false
                        }
                    })
                }
            }
        } else if let hashtag = m_hashtag {
            m_txtDescription.text = hashtag + " "
        }
        
        m_lblLength.text = "\(m_txtDescription.text.characters.count) / \(Constants.Integer.MAX_POST_LENGTH)"
        
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error == nil {
                self.geoPoint = geoPoint
            }
        }
        
        //Initialize CircleSlider
        m_viewSliderContainer.addSubview(slider)
        slider.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        slider.addTarget(self, action: #selector(valueChanged(sender:)), for: .valueChanged)
        
        postGuard()
    }

    func valueChanged(sender: WDTCircleSlider) {
        slider.roundControll()
        
        var s = ""
        if Int(sender.value) == 1 {
            s = ""
        } else {
            s = "s"
        }
        
        if slider.circle == .Hours {
            m_lblSliderValue.text = "Lasts for \(Int(sender.value)) hour" + s
        } else {
            m_lblSliderValue.text = "Lasts for \(Int(sender.value)) day" + s
        }
        
        postGuard()
    }
    
    func postGuard() {
        m_btnPost.isEnabled = m_txtDescription.text.characters.count > 0 && slider.value > 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBtnCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onClickBtnPost(_ sender: Any) {
        view.endEditing(true)
        
        showHud()
        
        var tasksCount = 1
        
        func removeTask() {
            tasksCount -= 1
            if tasksCount <= 0 {
                self.hideHud()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        if m_objPost == nil {
            m_objPost = PFObject(className: "posts")
        }
        
        m_objPost?["postText"] = m_txtDescription.text
        m_objPost?["user"] = PFUser.current()
        
        if let geoPoint = self.geoPoint {
            tasksCount += 1
            
            m_objPost?["geoPoint"] = geoPoint
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks.last
                        
                        if let fullLocation = placemark?.asString {
                            self.m_objPost?["fullLocation"] = fullLocation
                        }
                        
                        if let city = placemark?.locality {
                            self.m_objPost?["city"] = city
                        }
                        
                        if let country = placemark?.isoCountryCode {
                            self.m_objPost?["country"] = country
                        }
                        
                        self.m_objPost?.saveInBackground(block: { (success, error) in
                            removeTask()
                        })
                    } else {
                        removeTask()
                    }
                } else {
                    removeTask()
                }
            })
        }
        
        if slider.circle == .Days {
            m_objPost?["hoursexpired"] = Date().addHours(Double(slider.value) * 24)
        } else {
            m_objPost?["hoursexpired"] = Date().addHours(Double(slider.value))
        }
        
        if photos.count > 0 {
            tasksCount += 1
            
            var photoTasksCount = 0
            
            var photosToSave: [String] = []
            
            func removePhotoTask() {
                photoTasksCount -= 1
                
                if photoTasksCount <= 0 {
                    self.m_objPost?["photoURLs"] = photosToSave
                    self.m_objPost?.saveInBackground(block: { (success, error) in
                        removeTask()
                    })
                }
            }
            
            photos.forEach { photo in
                if let photoData = UIImageJPEGRepresentation(photo, 0.5) {
                    if let photoFile = PFFile(name: "postPhoto.jpg", data: photoData) {
                        photoTasksCount += 1
                        
                        photoFile.saveInBackground(block: { (success, error) in
                            if let url = photoFile.url {
                                photosToSave.append(url)
                            }
                            
                            removePhotoTask()
                        })
                    }
                }
            }
        } else {
            m_objPost?["photoURLs"] = [String]()
        }
        
        var tags = [String]()
        let nsstring = m_txtDescription.text as NSString
        let matches = WDTTextParser.getElements(from: m_txtDescription.text, with: WDTTextParser.hashtagPattern)
        for match in matches where match.range.length > 2 {
            let tag = nsstring.substring(with: match.range)
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
            
            tags.append(tag.substring(from: 1))
        }
        
        m_objPost?["hashtags"] = tags

        m_objPost?.saveInBackground(block: { (success, error) in
            if error == nil {
                self.addNewCategories() {
                    removeTask()
                }
            } else {
                removeTask()
            }
        })
    }
    
    func addNewCategories(completion: @escaping () -> Void) {
        let categories = m_objPost?["hashtags"] as! [String]
        
        var tasksCount = categories.count
        
        func removeTask() {
            tasksCount -= 1
            if tasksCount <= 0 {
                completion()
            }
        }
        
        if categories.count == 0 {
            removeTask()
        }
        
        for category in categories {
            let categoriesQuery = PFQuery(className: "categories")
            categoriesQuery.whereKey("title", equalTo: category)
            categoriesQuery.getFirstObjectInBackground(block: { (objCategory, error) in
                if objCategory == nil {
                    let newCategory = PFObject(className: "categories")
                    newCategory["title"] = category
                    newCategory.saveInBackground(block: { (success, error) in
                        removeTask()
                    })
                } else {
                    removeTask()
                }
            })
        }
    }
    
    
    fileprivate func showPhotoPicker() {
        let pickerController = DKImagePickerController()
        pickerController.maxSelectableCount = 6 - photos.count
        pickerController.assetType = .allPhotos
        
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            var pendingAssets = assets.count
            
            func removePendingAsset() {
                pendingAssets -= 1
                
                if pendingAssets <= 0 {
                    self.m_imagesCollectionView.reloadData()
                }
            }
            
            assets.forEach {
                $0.fetchOriginalImageWithCompleteBlock({ [weak self] (image, _) in
                    if let image = image {
                        objc_sync_enter(self)
                        self?.photos.append(image)
                        objc_sync_exit(self)
                    }
                    
                    removePendingAsset()
                })
            }
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        postGuard()
        
        if newLength > Constants.Integer.MAX_POST_LENGTH {
            return false
        } else {
            m_lblLength.text = "\(newLength) / \(Constants.Integer.MAX_POST_LENGTH)"
            return true
        }
    }
    
}


extension WDTAddPostViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count >= 6 ? photos.count : photos.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! WDTPhotoCell
        
        if photos.count >= 6 {
            cell.imageView.image = photos[indexPath.item]
            cell.isPlaceholder = false
        } else if indexPath.item == photos.count {
            cell.imageView.image = UIImage(named: "post_image_placeholder")
            cell.isPlaceholder = true
        } else {
            cell.imageView.image = photos[indexPath.item]
            cell.isPlaceholder = false
        }
        
        cell.onDelete = {
            collectionView.performBatchUpdates({
                let needToInsert = self.photos.count >= 6
                
                self.photos.remove(at: indexPath.item)
                collectionView.deleteItems(at: [indexPath])
                
                if needToInsert {
                    collectionView.insertItems(at: [indexPath])
                }
            }, completion: { [weak collectionView] _ in
                collectionView?.reloadData()
            })
        }
        
        return cell
    }
    
}

extension WDTAddPostViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photos.count < 6 {
            if indexPath.item == photos.count {
                showPhotoPicker()
            }
        }
    }
    
}


extension CLPlacemark {

    var asString: String? {
        var entries: [String] = []
        
        if let city = self.locality {
            entries.append(city)
        }
//        if let state = self.administrativeArea {
//            entries.append(state)
//        }
        if let street = self.thoroughfare {
            entries.append(street)
        }
        if let number = self.subThoroughfare {
            entries.append(number)
        }
        if let name = self.name {
            entries.append(name)
        }
        
        guard entries.count > 0 else { return nil }
        
        return entries.joined(separator: ", ")
    }

}
