//
//  SingleImageViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 25.02.2024.
//
import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Private Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else {
                return
            }
            imageView.image = image
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }    
}
