//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Khlood on 7/30/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var myCollectionView: UICollectionView!
    @IBOutlet var newCollectionButton: UIButton!

    var dataController:DataController!
    var pin: Pin!
    var lat: Double = 0.0
    var lon: Double = 0.0
    var page = 0
    var images: [Image] = []
    var photosArray: [Photo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        images = fetch()
        if images.count > 0 {
            for image in images {
                images.append(image)
                myCollectionView.reloadData()
            }
        } else {
            getImages()
        }
    }
    
    func fetch() -> [Image] {
        let fetchRequest:NSFetchRequest<Image> = Image.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin) 
        fetchRequest.predicate = predicate
        do {
            let result = try dataController.viewContext.fetch(fetchRequest)
            images = result
        } catch {
            print("error")
        }
        return images 
    }
    
    func getImages() {
        FlickrAPI.searchPhotos(lon, lat, page) { (photos, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.showAlert(title: "error", message: "There was an error performing your request")
                    return
                }
                guard let photos = photos else {
                    self.showAlert(title: "error", message: "There was an error")
                    return
                }
                if photos.pages == 0 {
                    let myNoImagesLabel: UILabel = UILabel()
                    myNoImagesLabel.frame = CGRect(x: self.view.frame.width / 2, y: self.view.frame.height / 2, width: 100, height: 50)
                    myNoImagesLabel.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    myNoImagesLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
                    myNoImagesLabel.textAlignment = NSTextAlignment.center
                    myNoImagesLabel.text = "No Images"
                    self.view.addSubview(myNoImagesLabel)
                    self.newCollectionButton.isEnabled = false
                    self.newCollectionButton.setTitleColor(.gray, for: .normal)
                } else {
                    self.photosArray = photos.photo
                    let randomPageValue = Int.random(in: 1...photos.pages)
                    self.page = randomPageValue
                    for photo in self.photosArray {
                        let image = Image(context: self.dataController.viewContext)
                        image.imageURL = photo.url 
                        image.pin = self.pin
                        self.images.append(image)
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            print("error")
                        }
                    }
                }
                self.myCollectionView.reloadData()
            }
        }
    }
 
    @IBAction func newCollectionButtonClicked(_ sender: Any) {
        for image in images {
            dataController.viewContext.delete(image)
            do {
                try self.dataController.viewContext.save()
            } catch {
                print("error")
            }
        }
        photosArray = []
        images = []
        getImages()
        myCollectionView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PhotoAlbumViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let cellPhoto = images[indexPath.row]
        
        if cellPhoto.imageData != nil {
            cell.imageCell.image = UIImage(data: cellPhoto.imageData!)
        } else {
            cell.imageCell.image = UIImage(named: "Placeholder")
            if cellPhoto.imageURL != nil {
                let url = URL(string: cellPhoto.imageURL ?? "")
                FlickrAPI.downloadImage(url!) { (data, error) in
                    DispatchQueue.main.async {
                        guard error == nil else {
                            self.showAlert(title: "error", message: "There was an error performing your request")
                            return
                        }
                        cellPhoto.imageData = data
                        cellPhoto.pin = self.pin
                        do {
                            try self.dataController.viewContext.save()
                        } catch {
                            print("error")
                        }
                        cell.imageCell?.image = UIImage(data: data!)
                    }
                }
            } 
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        dataController.viewContext.delete(image)
        images.remove(at: indexPath.row)
        try? dataController.viewContext.save()
        myCollectionView.reloadData()
    }
}
