//
//  ViewController.swift
//  SwiftCameraKitUIKitTestApp
//
//  Created by knc on 11.05.25.
//

import UIKit
import SwiftCameraKit

class ViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        print("ViewController: initialized") // Debug print
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        print("ViewController: loadView called") // Debug print
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController: viewDidLoad called") // Debug print
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        print("ViewController: setupUI started") // Debug print
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "My Test App"
        titleLabel.textColor = .label // Add this to ensure visibility
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        let testButton = UIButton(type: .system)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.setTitle("Test Package", for: .normal)
        testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(testButton)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            testButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
        
        print("ViewController: setupUI completed") // Debug print
    }
    
    @objc private func testButtonTapped() {
        let cameraView = CameraHubView()
        cameraView.cameraController = SwiftCameraKit(view: cameraView.view)
        // segue
        cameraView.modalPresentationStyle = .pageSheet
        cameraView.isModalInPresentation = true
        present(cameraView, animated: true, completion: nil)
    }
}
