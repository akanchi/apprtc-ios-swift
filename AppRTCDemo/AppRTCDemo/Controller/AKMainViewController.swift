//
//  ViewController.swift
//  AppRTCDemo
//
//  Created by akanchi on 2021/1/4.
//

import UIKit
import SnapKit

class AKMainViewController: UIViewController {
    private var instructionsLabel: UILabel!
    private var roomIdInputTextField: UITextField!
    private var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.navigationController?.navigationBar.isHidden = true

        self.setupViews()
        self.setupConstraints()
    }

// MARK: - UI
    func setupViews() {
        self.view.backgroundColor = .init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)

        self.instructionsLabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            label.textColor = .white
            label.text = "Please enter a room name."
            return label
        }()
        self.view.addSubview(self.instructionsLabel)

        self.roomIdInputTextField = {
            let textField = UITextField()
            textField.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            textField.textColor = .white
            let attr = [NSAttributedString.Key.foregroundColor: UIColor.red]
            textField.attributedPlaceholder = NSMutableAttributedString(string: "Please enter a room name", attributes: attr)
            return textField
        }()
        self.view.addSubview(self.roomIdInputTextField)

        self.joinButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.init(red: 66/255, green: 133/255, blue: 244/255, alpha: 1)
            button.layer.cornerRadius = 5
            button.layer.masksToBounds = true
            button.setTitle("JOIN", for: .normal)
            button.addTarget(self, action: #selector(onJoinAction), for: .touchUpInside)
            return button
        }()
        self.view.addSubview(self.joinButton)
    }

    func setupConstraints() {
        self.instructionsLabel.snp.makeConstraints { (make: ConstraintMaker) in
            make.leading.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(80)
        }

        self.roomIdInputTextField.snp.makeConstraints { (make: ConstraintMaker) in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalTo(self.instructionsLabel.snp.bottom).offset(20)
        }

        self.joinButton.snp.makeConstraints { (make: ConstraintMaker) in
            make.top.equalTo(self.roomIdInputTextField.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-30)
            make.width.equalTo(84)
            make.height.equalTo(30)
        }
    }

// MARK: - Join点击事件
    @objc
    private func onJoinAction(sender: UIButton!) {
        let chatVC = AKVideoChatViewController()
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}

