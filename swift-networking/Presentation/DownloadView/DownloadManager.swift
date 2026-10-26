//
//  DownloadManager.swift
//  swift-networking
//
//  Created by Vokal-Ican on 26/10/26.
//


import Foundation

final class DownloadManager: NSObject {

    // MARK: - Callbacks

    var onProgress: ((Double, Int64, Int64) -> Void)?
    var onFinish: ((URL) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Properties

    private var session: URLSession!
    private var task: URLSessionDownloadTask?
    private var resumeData: Data?

    // MARK: - Init

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - Actions

    func start(url: URL) {
        task?.cancel()
        resumeData = nil
        task = session.downloadTask(with: url)
        task?.resume()
    }

    func pause() {
        task?.cancel { [weak self] data in
            self?.resumeData = data
            // DEBUG
            print("Resume data:", data?.count ?? 0, "bytes")
        }
        task = nil
    }

    func resume() {
        guard let resumeData else { return }
        task = session.downloadTask(withResumeData: resumeData)
        task?.resume()
        self.resumeData = nil
    }

    func cancel() {
        task?.cancel()
        task = nil
        resumeData = nil
    }

    func invalidate() {
        session.invalidateAndCancel()
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadManager: URLSessionDownloadDelegate {

    // MARK: Progress
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {

        let progress = totalBytesExpectedToWrite > 0
            ? Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            : 0

        DispatchQueue.main.async { [weak self] in
            self?.onProgress?(progress, totalBytesWritten, totalBytesExpectedToWrite)
        }
    }
    
    // MARK: Finished

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {

        if let http = downloadTask.response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Server bermasalah (\(http.statusCode))")
            }
            return
        }

        let fileName = downloadTask.response?.suggestedFilename
            ?? downloadTask.originalRequest?.url?.lastPathComponent
            ?? "download.mp3"
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destination = documents.appendingPathComponent(fileName)

        do {
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: location, to: destination)

            DispatchQueue.main.async { [weak self] in
                self?.onFinish?(destination)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.onError?("Gagal menyimpan file")
            }
        }
    }
    
    // MARK: Completed

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {

        guard let error = error as? URLError else { return }
        guard error.code != .cancelled else { return }

        let message: String
        switch error.code {
        case .notConnectedToInternet: message = "Tidak ada koneksi internet"
        case .timedOut:               message = "Koneksi terlalu lambat"
        default:                      message = "Unduhan gagal"
        }

        DispatchQueue.main.async { [weak self] in
            self?.onError?(message)
        }
    }
}
