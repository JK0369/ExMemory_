//
//  ViewController.swift
//  ExMemory
//
//  Created by 김종권 on 2023/12/07.
//

import UIKit

class ViewController: UIViewController {
    private let button = {
        let button = UIButton()
        button.setTitle("button", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let imageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let label = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 36)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        button.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                imageView.image = UIImage(systemName: "circle")
            },
            for: .touchUpInside
        )
        
        startDisplayLink()
    }
    
    deinit {
        stopDisplayLink()
    }
    
    private func startDisplayLink() {
        stopDisplayLink()
        displayLink = CADisplayLink(target: self, selector: #selector(recordMemory))
        displayLink?.preferredFramesPerSecond = 10
        displayLink?.add(to: .main, forMode: .default)
    }
    
    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func recordMemory() {
        let val = round(getMemoryUsedAndDeviceTotalInMegabytes().0)
        label.text = "\(val)"
    }
}

// https://gist.github.com/pejalo/671dd2f67e3877b18c38c749742350ca
func getMemoryUsedAndDeviceTotalInMegabytes() -> (Float, Float) {
        
    // https://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budget/19692719#19692719
    // https://stackoverflow.com/questions/27556807/swift-pointer-problems-with-mach-task-basic-info/27559770#27559770
    
    var used_megabytes: Float = 0
    
    let total_bytes = Float(ProcessInfo.processInfo.physicalMemory)
    let total_megabytes = total_bytes / 1024.0 / 1024.0
    
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
    
    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(
                mach_task_self_,
                task_flavor_t(MACH_TASK_BASIC_INFO),
                $0,
                &count
            )
        }
    }
    
    if kerr == KERN_SUCCESS {
        let used_bytes: Float = Float(info.resident_size)
        used_megabytes = used_bytes / 1024.0 / 1024.0
    }
    
    return (used_megabytes, total_megabytes)
}
