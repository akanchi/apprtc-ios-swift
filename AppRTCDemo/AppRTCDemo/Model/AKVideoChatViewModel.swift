//
//  AKVideoChatViewModel.swift
//  AppRTCDemo
//
//  Created by akanchi on 2021/1/10.
//

import UIKit
import WebRTC

let SERVER_HOST_URL: String = "https://appr.tc"

protocol AKVideoChatViewModelDelegate: class {
    func localRender() -> RTCVideoRenderer
    func remoteRender() -> RTCVideoRenderer
    func resetLocalRenderFrame()
    func resetRemoteRenderFrame()
    func remoteDisconnected()
}

class AKVideoChatViewModel: NSObject {
    weak var delegate: AKVideoChatViewModelDelegate?

    var roomName: String = "" {
        didSet {
            self.roomUrl = SERVER_HOST_URL + "/r/" + roomName
        }
    }
    private var roomUrl: String = ""
    private var client: ARDAppClient?
    private(set) var localVideoTrack: RTCVideoTrack?
    private(set) var remoteVideoTrack: RTCVideoTrack?

    var localCapturer: RTCCameraVideoCapturer?

    var isAudioMute: Bool = false {
        didSet {
            if isAudioMute {
                self.client?.muteAudioIn()
            } else {
                self.client?.unmuteAudioIn()
            }
        }
    }
    var isVideoMute: Bool = false {
        didSet {
            if isVideoMute {
                self.muteVideoIn()
            } else {
                self.unmuteVideoIn()
            }
        }
    }


    func connect() {
        self.client = {
            let c = ARDAppClient(delegate: self)
            return c
        }()

        self.client?.connectToRoom(withId: self.roomName,
                                   settings: ARDSettingsModel(),
                                   isLoopback: false)
    }

    func disconnect() {
        if let c = self.client {
            if let r = self.delegate?.localRender() {
                self.localVideoTrack?.remove(r)
            }

            if let r = self.delegate?.remoteRender() {
                self.remoteVideoTrack?.remove(r)
            }

            self.localVideoTrack = nil
            self.remoteVideoTrack = nil

            self.delegate?.resetLocalRenderFrame()
            self.delegate?.resetRemoteRenderFrame()

            c.disconnect()
        }
    }

    func startCapture() {
        var device: AVCaptureDevice? = nil
        let cameraDevices: [AVCaptureDevice] = RTCCameraVideoCapturer.captureDevices()
        for c in cameraDevices {
            if c.position == .front {
                device = c
            }
            print("\(c.description)")
        }

        if let d = device {
            let format = RTCCameraVideoCapturer.supportedFormats(for: d).last
            guard let f = format else { return }
            let fps = f.videoSupportedFrameRateRanges.first?.maxFrameRate ?? 30
            self.localCapturer?.startCapture(with: d, format: f, fps: Int(fps)) { (error) in
                if error != nil {
                    print("开始捕获, error=\(error)")
                } else {
                    print("开始捕获, 无错误")
                }
            }
        }
    }

    func muteVideoIn() {
        if let r = self.delegate?.localRender() {
            self.localVideoTrack?.remove(r)
            self.delegate?.resetLocalRenderFrame()
            self.localCapturer?.stopCapture()
        }
    }

    func unmuteVideoIn() {
        if let r = self.delegate?.localRender() {
            self.localVideoTrack?.add(r)
            self.startCapture()
        }
    }
}

// MARK: - ARDAppClientDelegate
extension AKVideoChatViewModel: ARDAppClientDelegate {
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        DispatchQueue.main.async {
            switch (state) {
            case .connected:
                print("Client connected.")
            case .connecting:
                print("Client connecting.")
            case .disconnected:
                print("Client disconnected.")
                if let r = self.delegate?.remoteRender() {
                    self.remoteVideoTrack?.remove(r)
                }
                self.remoteVideoTrack = nil
                self.delegate?.resetRemoteRenderFrame()
                self.delegate?.remoteDisconnected()
            @unknown default:
                print("Client unknown state.")
            }
        }
    }

    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        print(#function + "state=\(state.rawValue)")
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        print(#function + "\(localCapturer)")
        DispatchQueue.main.async {
            self.localCapturer = localCapturer
        }
    }

    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        print(#function + "localVideoTrack\(String(describing: localVideoTrack))")
        DispatchQueue.main.async {
            if let r = self.delegate?.localRender() {
//                self.localVideoTrack?.remove(r)
//                self.localVideoTrack = nil
//                self.delegate?.resetLocalRenderFrame()
                self.localVideoTrack = localVideoTrack
                self.localVideoTrack?.add(r)
            }

            self.startCapture()
        }
    }

    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        print(#function + "remoteVideoTrack\(String(describing: remoteVideoTrack))")
        DispatchQueue.main.async {
            self.remoteVideoTrack = remoteVideoTrack

            if let r = self.delegate?.remoteRender() {
                self.remoteVideoTrack?.add(r)
            }
        }
    }

    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        print(#function + "error=\(String(describing: error))")
        self.disconnect()
    }

    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        print(#function)
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        print(#function)
    }
}
