//
//  AKVideoChatViewController.swift
//  AppRTCDemo
//
//  Created by akanchi on 2021/1/10.
//

import UIKit
import WebRTC

class AKVideoChatViewController: UIViewController {
    private var remoteView: RTCEAGLVideoView!
    private var localView: RTCEAGLVideoView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white

        self.setupViews()
        self.setupConstraints()
    }

    func setupViews() {

    }

    func setupConstraints() {

    }
}
