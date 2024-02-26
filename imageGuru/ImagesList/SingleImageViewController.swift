//
//  SingleImageViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 25.02.2024.
//
import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Private Properties
    var image: UIImage? {
        didSet {
            guard isViewLoaded else {
                return
            }
            imageView.image = image
            if let image  {
                rescaleAndCenterImageInScrollView(image: image)
            }
        }
    }
    
    // MARK: - Override Properties
    override var preferredStatusBarStyle: UIStatusBarStyle { // меняем цвет StatusBar на белый
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 10.25
        if let image {
            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    // MARK: - IB Actions
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        if let image {
            let share = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            present(share, animated: true, completion: nil)
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
        //        print (visibleRectSize, imageSize, scale, newContentSize, x, y)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
