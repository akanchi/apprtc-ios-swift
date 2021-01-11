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

    private var localVideoSize: CGSize = .zero
    private var remoteVideoSize: CGSize = .zero

    private var buttonContainerView: UIView!
    private var audioButton: UIButton!
    private var videoButton: UIButton!
    private var hangupButton: UIButton!

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

        self.checkCameraAuthorization()
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

        self.buttonContainerView = {
            let view = UIView()
            return view
        }()
        self.view.addSubview(self.buttonContainerView)

        self.audioButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "audioOn"), for: .normal)
            button.setImage(UIImage(named: "audioOff"), for: .selected)
            button.addTarget(self, action: #selector(onAudioAction), for: .touchUpInside)
            return button
        }()
        self.buttonContainerView.addSubview(self.audioButton)

        self.videoButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "videoOn"), for: .normal)
            button.setImage(UIImage(named: "videoOff"), for: .selected)
            button.addTarget(self, action: #selector(onVideoAction), for: .touchUpInside)
            return button
        }()
        self.buttonContainerView.addSubview(self.videoButton)

        self.hangupButton = {
            let button = UIButton()
            button.setImage(UIImage(named: "hangup"), for: .normal)
            button.addTarget(self, action: #selector(onHangupAction), for: .touchUpInside)
            return button
        }()
        self.buttonContainerView.addSubview(self.hangupButton)
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

        self.buttonContainerView.snp.makeConstraints { (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
        }

        self.audioButton.snp.makeConstraints { (make: ConstraintMaker) in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(40)
        }

        self.videoButton.snp.makeConstraints { (make: ConstraintMaker) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.audioButton.snp.bottom).offset(20)
            make.width.height.equalTo(40)
        }

        self.hangupButton.snp.makeConstraints { (make: ConstraintMaker) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalTo(self.videoButton.snp.bottom).offset(20)
            make.width.height.equalTo(40)
        }
    }

    func checkCameraAuthorization() {
        // 权限检查
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 已授权
            print("已经授予相机权限")
            break;
        case .notDetermined:
            // 未曾向用户展示权限弹窗，可以请求权限
            print("未曾向用户展示权限弹窗，可以请求权限")
            print("请求权限中")
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                print("\(granted ? "成功" : "拒绝")授权")
            }

            break;
        default:
            // 用户上次拒绝授予权限
            print("用户上次拒绝授予权限")
            break;
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

    func remoteDisconnected() {
        self.videoView(self.remoteView, didChangeVideoSize: self.remoteVideoSize)
    }
}

// MARK: - RTCVideoViewDelegate
extension AKVideoChatViewController: RTCVideoViewDelegate {
    func videoView(_ videoView: RTCVideoRenderer, didChangeVideoSize size: CGSize) {
        print(#function + "size=\(size)")

        DispatchQueue.main.async {
            let orientation = UIDevice.current.orientation

            UIView.animate(withDuration: 0.4) {
                let containerWidth: CGFloat = self.view.frame.size.width
                let containerHeight: CGFloat = self.view.frame.size.height
                let defaultAspectRatio: CGSize = CGSize(width: 4, height: 3)
                if videoView.isEqual(self.localView) {
                    self.localVideoSize = size
                    let aspectRatio: CGSize = __CGSizeEqualToSize(size, .zero) ? defaultAspectRatio : size
                    var videoRect: CGRect = self.view.bounds
                    if let _ = self.viewModel.remoteVideoTrack {
                        videoRect = CGRect(x: 0, y: 0, width: self.view.frame.size.width/4.0, height: self.view.frame.size.height/4.0)
                        if orientation == .landscapeLeft || orientation == .landscapeRight {
                            videoRect = CGRect(x: 0, y: 0, width: self.view.frame.size.height/4.0, height: self.view.frame.size.width/4.0)
                        }
                    }

                    let viedoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)

                    //Resize the localView accordingly
                    self.localView.snp.remakeConstraints { (make: ConstraintMaker) in
                        make.size.equalTo(viedoFrame.size)
                        if let _ = self.viewModel.remoteVideoTrack {
                            make.trailing.equalToSuperview().offset(-30)
                            make.bottom.equalToSuperview().offset(-30)
                        } else {
                            make.trailing.equalToSuperview().offset(-30)
                            make.bottom.equalToSuperview().offset(-30)
                        }
                    }
                } else if videoView.isEqual(self.remoteView) {
                    //Resize Remote View
                    self.remoteVideoSize = size;
                    let aspectRatio: CGSize = __CGSizeEqualToSize(size, .zero) ? defaultAspectRatio : size
                    let videoRect: CGRect = self.view.bounds
                    let viedoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)

                    self.remoteView.snp.remakeConstraints { (make: ConstraintMaker) in
                        make.center.equalToSuperview()
                        make.size.equalTo(viedoFrame.size)
                    }
                }

                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - 点击事件
extension AKVideoChatViewController {
    @objc
    private func onAudioAction(sender: UIButton!) {
        sender.isSelected = !self.viewModel.isAudioMute
        self.viewModel.isAudioMute = !self.viewModel.isAudioMute
    }

    @objc
    private func onVideoAction(sender: UIButton!) {
        sender.isSelected = !self.viewModel.isVideoMute
        self.viewModel.isVideoMute = !self.viewModel.isVideoMute
    }

    @objc
    private func onHangupAction(sender: UIButton!) {
        self.viewModel.disconnect()
        self.navigationController?.popViewController(animated: true)
    }
}
