//
//  GithubViewController.swift
//  swift-networking
//
//  Created by Vokal-Ican on 24/10/26.
//

import UIKit

class GithubViewController: UIViewController {
    
    private enum ViewModel {
        case loading
        case error(String)
        case empty
        case loaded([GithubModel])
    }
    
    private var state: ViewModel = .loading {
        didSet {
            render()
        }
    }
    
    private let cellID = "GithubCell"
    
    private let services = GithubService()
    
    private(set) var github: [GithubModel] = []
    
    private var loadTask: Task<Void, Never>?
    
    private func render() {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            messageStack.isHidden = true
        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            retryButton.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = "Tidak ada data"
        case .loaded(let data):
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            messageStack.isHidden = true
            github = data
            tableView.reloadData()
        case .error(let error):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = error
        }
        
    }
    
    private func loadData() {
        state = .loading
        
        loadTask?.cancel()
        
        loadTask = Task { [weak self] in
            
            guard let self else { return }
            
            do {
                let res = try await services.fetchGithub()
                guard !Task.isCancelled else { return }
                state = res.isEmpty ? .empty : .loaded(res)
                
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(error.localizedDescription)
            }
            
        }
    }

    // MARK: - UI
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Coba lagi"
        let button = UIButton(
            configuration: config,
            primaryAction: UIAction { [weak self] _ in self?.loadData() }
        )
        return button
    }()

    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageLabel, retryButton])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if case .loading = state {
            loadData()
        }
    }

    // MARK: - Setup Layout

    private func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(messageStack)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            messageStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
}

// MARK: - UITableViewDataSource

extension GithubViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        github.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let item = github[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.login
        content.secondaryText = "ID \(item.id)"
        cell.contentConfiguration = content

        return cell
    }
}
