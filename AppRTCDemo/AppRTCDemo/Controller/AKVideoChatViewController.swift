//
//  AKVideoChatViewController.swift
//  AppRTCDemo
//
//  Created by akanchi on 2021/1/10.
//

import UIKit
import WebRTC

class AKVideoChatViewController: UIViewController {
    static let SERVER_HOST_URL = "https://appr.tc"

    private var remoteView: RTCEAGLVideoView!
    private var localView: RTCEAGLVideoView!

    private var roomName: String = ""
    private var roomUrl: String = ""
    private var client: ARDAppClient?

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
