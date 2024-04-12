//
//  SingleImageViewController.swift
//  imageGuru
//
//  Created by Andrey Zhelev on 25.02.2024.
//
import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    // MARK: - Visual Components
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Public Properties
    var imageURL: URL?
    
    // MARK: - Private Properties
    private var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.05
        scrollView.maximumZoomScale = 1.25
        setImageWithKF()
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
    
    // MARK: - Private methods
    private func setImageWithKF() {
        imageView.kf.indicatorType = .activity
        guard let imageURL else {
            return
        }
        imageView.kf.setImage(with: imageURL) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard let image = self?.imageView.image else { return }
                    self?.image =  image
                    self?.imageView.frame.size = image.size
                    self?.rescaleImageInScrollView(image: image)
                case .failure(let error):
                    print("CONSOLE func setImageWithKF: Ошибка загрузки фото", error.localizedDescription)
                }
            }
        }
    }
    /// функция центрирования картинки на экране
    private func centerImageInScrollView(visibleRectSize: CGSize, newContentSize: CGSize) {
        let x = (visibleRectSize.width - newContentSize.width) / 2
        let y = (visibleRectSize.height - newContentSize.height) / 2
        if x > 0, y > 0 {
            scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: 0, right: 0)
        } else if x > 0 {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: x, bottom: 0, right: 0)
        } else if y > 0 {
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
        }
    }
    
    /// функция масштабирования картинки для отображения во весь экран
    private func rescaleImageInScrollView(image: UIImage) {
        // масштаб
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(hScale, vScale)
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // центровка
        centerImageInScrollView(visibleRectSize: visibleRectSize, newContentSize: scrollView.contentSize)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        guard image != nil else {
            return
        }
        // центровка
        centerImageInScrollView(visibleRectSize: scrollView.bounds.size, newContentSize: scrollView.contentSize)
    }
}
