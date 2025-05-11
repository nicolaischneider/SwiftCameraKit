import UIKit
import SimpleConstraints
import os

class MediaReviewView: UIView {
        
    // MARK: - View Objects
    
    // image/video
    let userImage = UIImageView.view(image: nil, cornerRadius: 15, shadow: false, contentMode: .scaleAspectFill)
    let userVideoContainer = UIView.view(corner: 15, shadow: false, background: nil, clipsToBounds: true)
    
    var dismissView: (() -> Void)?
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
        print("loading MediaReviewView")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configs
    
    func configure (
        image: UIImage,
        dismissView: @escaping () -> Void
    ) {
        userImage.isHidden = false
        userVideoContainer.isHidden = true
        userImage.image = image
        self.dismissView = dismissView
    }
    
    func configure (
        loadVideo: ((UIView) -> Void)?,
        dismissView: @escaping () -> Void
    ) {
        userImage.isHidden = true
        userVideoContainer.isHidden = false
        loadVideo?(userVideoContainer)
        self.dismissView = dismissView
    }
    
    func updateImage (_ image: UIImage) {
        userImage.image = image
    }
}

extension MediaReviewView {
    
    // MARK: - Constraints
    
    private func setupView () {
        
        // image
        unsafeConstraints(
            userImage,
            constraints: [
                Straint(straint: .bottom, anchor: .bottom(self, -10)),
                Straint(straint: .top, anchor: .top(self, 5)),
                Straint(straint: .centerX, anchor: .centerX(self, 0)),
                Straint(straint: .ratioWidth, anchor: .ratio(9/16))
            ])
        
        unsafeConstraints(
            userVideoContainer,
            constraints: [
                Straint(straint: .bottom, anchor: .bottom(self, -10)),
                Straint(straint: .top, anchor: .top(self, 5)),
                Straint(straint: .centerX, anchor: .centerX(self, 0)),
                Straint(straint: .ratioWidth, anchor: .ratio(9/16))
            ])
    }
}
