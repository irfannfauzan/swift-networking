//
//  PicsumViewController.swift
//  swift-networking
//
//  Created by Vokal-Ican on 25/10/26.
//

import UIKit

class PicsumViewController: UIViewController {
    
    //MARK: - State
    
    private enum ViewState {
        case loading
        case empty
        case loaded([PicsumModel])
        case error(String)
    }
    
    //MARK: - Properties
    
    private var state: ViewState = .loading {
        didSet { render() }
    }
    
    private let cellID = "PicsumCell"
    
    private var picsum: [PicsumModel] = []
    
    private let services = PicsumService()
    
    private var loadTask: Task<Void, Never>?
    
    private func render() {
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            messageStack.isHidden = true
        case .error(let message):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = message
            retryButton.isHidden = false
        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageStack.isHidden = false
            messageLabel.text = "Empty!"
            retryButton.isHidden = true
        case .loaded(let items):
            loadingIndicator.stopAnimating()
            tableView.isHidden = false
            messageStack.isHidden = true
            picsum = items
            tableView.reloadData()
        }
    }
    
    private func loadPicsum() {
        state = .loading
        
        loadTask?.cancel()
        
        loadTask = Task { [weak self] in
            
            guard let self else { return }
                
            do {
                let items = try await services.fetchPicsum()
                guard !Task.isCancelled else { return }
                state = items.isEmpty ? .empty : .loaded(items)
            }  catch {
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
            primaryAction: UIAction { [weak self] _ in self?.loadPicsum() }
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
            loadPicsum()
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

extension PicsumViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        picsum.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let item = picsum[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.author
        content.secondaryText = "ID \(item.id)"
        cell.contentConfiguration = content

        return cell
    }
}
