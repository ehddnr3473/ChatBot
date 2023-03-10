//
//  ViewController.swift
//  ChatBot
//
//  Created by 김동욱 on 2023/02/23.
//

import UIKit

final class ViewController: UIViewController {
    // MARK: - Properties
    private var model = [String]()
    
    private let queryTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Type here..."
        textField.backgroundColor = .systemPink
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let chatTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryTextField.delegate = self
        chatTableView.dataSource = self
        
        view.addSubview(queryTextField)
        view.addSubview(chatTableView)
        view.addSubview(indicatorView)
        
        NSLayoutConstraint.activate([
            queryTextField.heightAnchor.constraint(equalToConstant: 30),
            queryTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            queryTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            queryTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            chatTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chatTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            chatTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            chatTableView.bottomAnchor.constraint(equalTo: queryTextField.topAnchor, constant: -10)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = model[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            content.image = UIImage(systemName: "questionmark")
            content.imageProperties.tintColor = .systemPink
        } else {
            content.image = UIImage(systemName: "message")
            content.imageProperties.tintColor = .systemBlue
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            indicatorView.startAnimating()
            model.append(text)
            APIManager.shared.getResponse(input: text) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let output):
                    self.model.append(self.replaceNewLineWithNone(input: output))
                    DispatchQueue.main.async {
                        self.chatTableView.reloadData()
                        self.indicatorView.stopAnimating()
                    }
                case .failure(let error):
                    self.model.removeLast()
                    self.indicatorView.stopAnimating()
                    print(error)
                }
            }
        }
        queryTextField.text = nil
        return true
    }
    
    func replaceNewLineWithNone(input: String) -> String {
        input.replacingOccurrences(of: "\n", with: "")
    }
}

