//
//  AKVideoChatViewController.swift
//  AppRTCDemo
//
//  Created by akanchi on 2021/1/10.
//

import UIKit
import SnapKit
import WebRTC

class AKVideoChatViewController: UIViewController {

    private var remoteView: RTCEAGLVideoView!
    private var localView: RTCEAGLVideoView!

    private lazy var viewModel = AKVideoChatViewModel()

    var roomName: String = "" {
        didSet {
            self.viewModel.roomName = roomName
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        self.setupViews()
        self.setupConstraints()

        self.viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewModel.connect()
    }

// MARK: - UI
    func setupViews() {
        self.remoteView = {
            let view = RTCEAGLVideoView()
            view.delegate = self
            return view
        }()
        self.view.addSubview(self.remoteView)

        self.localView = {
            let view = RTCEAGLVideoView()
            view.delegate = self
            return view
        }()
        self.view.addSubview(self.localView)
    }

    func setupConstraints() {
        self.remoteView.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
        }

        self.localView.snp.makeConstraints { (make: ConstraintMaker) in
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-30)
            make.width.height.equalTo(120)
        }
    }
}

// MARK: - AKVideoChatViewModelDelegate
extension AKVideoChatViewController: AKVideoChatViewModelDelegate {
    func localRender() -> RTCVideoRenderer {
        return self.localView
    }

    func remoteRender() -> RTCVideoRenderer {
        return self.remoteView
    }

    func resetLocalRenderFrame() {
        self.localView.renderFrame(nil)
    }

    func resetRemoteRenderFrame() {
        self.remoteView.renderFrame(nil)
    }
}

// MARK: - RTCVideoViewDelegate
extension AKVideoChatViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        print(#function + "size=\(size)")
    }
}
