//
//  ViewController.swift
//  CustomCollectionViewLayout
//
//  Created by Fernando Cardenas on 05.09.18.
//  Copyright © 2018 Fernando Cardenas. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource{

    var collectionView: UICollectionView!
    var flowLayout: OCTGalleryLayout_v1!

    var images: [UIImage] = [UIImage]()

    var imageModelController: ImageModelController = ImageModelController()

    let activityIndicator = UIActivityIndicatorView(style: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        flowLayout = OCTGalleryLayout_v1(numberOfColumns: 3)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)

        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)

        //If we need to add the safeAreaLayoutGuide
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: String(describing: ColorCell.self))

        collectionView.dataSource = self

        collectionView.backgroundColor = .white

        view.addSubview(activityIndicator)

        activityIndicator.frame = view.bounds

        activityIndicator.startAnimating()

        downloadImages(limit: 56)

    }

    func downloadImages(limit: Int) {
        var count = 0
        for index in 0..<limit {
            let string = "https://picsum.photos/3000/3000/?image=\(index)"
            guard let url = URL(string: string) else { assert(false) }

            imageModelController.loadData(fromURL: url) { [weak self] (outcome) in
                count += 1
                switch outcome {
                case .success(let data):
                    //When we implement getting a response with multiple images consider to use serialqueue.async to avoid overloading the CPUs.
                    self?.images.append(ImageProcessor.downsampleImage(fromData: data as CFData))
                    print("Index \(index)")
                case .error(let error):
                    print("|ERROR: \(error)")
                }
                if count == limit {
                    print("Finished")
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ColorCell.self), for: indexPath) as! ColorCell
        cell.thumbnailImageView.image = images[indexPath.item]
        return cell
    }

}

class ColorCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    lazy var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .yellow
        return iv
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        backgroundColor = .gray
        addSubview(thumbnailImageView)
        thumbnailImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        thumbnailImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
    }
}

