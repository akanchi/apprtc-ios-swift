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
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?


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
}

// MARK: - ARDAppClientDelegate
extension AKVideoChatViewModel: ARDAppClientDelegate {
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        print(#function + "state=\(state.rawValue)")
    }

    func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        print(#function + "state=\(state.rawValue)")
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        print(#function)
    }

    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        print(#function)
        if let r = self.delegate?.localRender() {
            self.localVideoTrack?.remove(r)
            self.localVideoTrack = nil
            self.delegate?.resetLocalRenderFrame()
        }

        self.localVideoTrack = localVideoTrack

        if let r = self.delegate?.localRender() {
            self.localVideoTrack?.add(r)
        }
    }

    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        print(#function)
        self.remoteVideoTrack = remoteVideoTrack

        if let r = self.delegate?.remoteRender() {
            self.remoteVideoTrack?.add(r)
        }
    }

    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        print(#function + "error=\(String(describing: error))")
    }

    func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        print(#function)
    }

    func appClient(_ client: ARDAppClient!, didCreateLocalFileCapturer fileCapturer: RTCFileVideoCapturer!) {
        print(#function)
    }
}
