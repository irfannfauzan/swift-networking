//
//  DownloadViewController.swift
//  swift-networking
//
//  Created by Vokal-Ican on 26/10/26.
//

import UIKit

class DownloadViewController: UIViewController {

    // MARK: - Properties

    private let downloadURL = URL(string: "https://proof.ovh.net/files/10Mb.dat")!
    
    private let manager = DownloadManager()

    // MARK: - UI

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Siap mengunduh"
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.text = "0 MB / 0 MB"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0
        progress.tintColor = .systemIndigo
        return progress
    }()

    private lazy var startButton = makeButton(title: "Mulai") { [weak self] in self?.startTapped() }
    private lazy var pauseButton = makeButton(title: "Jeda") { [weak self] in self?.pauseTapped() }
    private lazy var resumeButton = makeButton(title: "Lanjut") { [weak self] in self?.resumeTapped() }
    private lazy var cancelButton = makeButton(title: "Batal") { [weak self] in self?.cancelTapped() }

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [startButton, pauseButton, resumeButton, cancelButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusLabel, progressView, detailLabel, buttonStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindManager()
        updateButtons(isDownloading: false, canResume: false)
    }

    deinit {
        manager.invalidate()
    }

    // MARK: - Setup

    private func setupLayout() {
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func makeButton(title: String, action: @escaping () -> Void) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        return UIButton(configuration: config, primaryAction: UIAction { _ in action() })
    }
    
    private func makeButtonV2(title: String, action: @escaping ()-> Void) ->UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        return UIButton(configuration: config, primaryAction: UIAction {_ in action() })
    }

    private func bindManager() {
        manager.onProgress = { [weak self] progress, written, total in
            self?.progressView.setProgress(Float(progress), animated: true)
            self?.statusLabel.text = "Mengunduh \(Int(progress * 100))%"
            self?.detailLabel.text = "\(Self.mb(written)) / \(Self.mb(total))"
        }

        manager.onFinish = { [weak self] fileURL in
            self?.statusLabel.text = "File mu berhasil didownload! ✅"
            self?.detailLabel.text = "File: \(fileURL.lastPathComponent) Disimpan di: \(fileURL.path)"
            self?.updateButtons(isDownloading: false, canResume: false)
            print("File tersimpan di:", fileURL.path)
        }

        manager.onError = { [weak self] message in
            self?.statusLabel.text = message
            self?.updateButtons(isDownloading: false, canResume: false)
        }
    }

    // MARK: - Actions

    private func startTapped() {
        progressView.setProgress(0, animated: false)
        statusLabel.text = "Memulai..."
        manager.start(url: downloadURL)
        updateButtons(isDownloading: true, canResume: false)
    }

    private func pauseTapped() {
        manager.pause()
        statusLabel.text = "Dijeda"
        updateButtons(isDownloading: false, canResume: true)
    }

    private func resumeTapped() {
        manager.resume()
        statusLabel.text = "Melanjutkan..."
        updateButtons(isDownloading: true, canResume: false)
    }

    private func cancelTapped() {
        manager.cancel()
        progressView.setProgress(0, animated: true)
        statusLabel.text = "Dibatalkan"
        detailLabel.text = "0 MB / 0 MB"
        updateButtons(isDownloading: false, canResume: false)
    }

    // MARK: - Helpers

    private func updateButtons(isDownloading: Bool, canResume: Bool) {
        startButton.isEnabled = !isDownloading
        pauseButton.isEnabled = isDownloading
        resumeButton.isEnabled = canResume
        cancelButton.isEnabled = isDownloading || canResume
    }

    private static func mb(_ bytes: Int64) -> String {
        String(format: "%.1f MB", Double(bytes) / 1_048_576)
    }
}
