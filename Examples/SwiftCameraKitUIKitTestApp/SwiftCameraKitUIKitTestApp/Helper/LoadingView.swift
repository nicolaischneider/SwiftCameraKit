import UIKit
import SimpleConstraints

class LoadingView: UIView {
    
    private var activityIndicator = LoadingIndicatorMediumView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(_ show: Bool) {
        self.alpha = show ? 1 : 0
    }
    
    private func setupView() {
        
        self.centerWithSize(activityIndicator,
                            centerX: nil,
                            centerY: nil,
                            height: 30,
                            width: 30)
        
        backgroundColor = UIColor(white: 0.2, alpha: 0.4)
    }
}

class LoadingIndicatorMediumView: UIView {
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        indicator.style = .medium
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        translatesAutoresizingMaskIntoConstraints = false
        startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        backgroundColor = .clear // or you can set any background color you like
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
}
