//
//  LocationSearchViewController.swift
//  Budi
//
//  Created by 인병윤 on 2021/11/08.
//

import UIKit

class LocationSearchViewController: UIViewController {

    private let allLocation = Location().location
    private var correct: [String] = []
    private let alert = AlertView()
    private let blackBackView = UIView()

    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "시, 구로 검색"
        search.setImage(UIImage(systemName: "magnifyingglass"), for: UISearchBar.Icon.search, state: .normal)
        search.setImage(UIImage(systemName: "xmark.circle.fill"), for: .clear, state: .normal)
        search.tintColor = UIColor.init(white: 0, alpha: 0.12)
        search.backgroundImage = UIImage()
        search.backgroundColor = .none
        search.layer.cornerRadius = 0
        search.searchTextField.backgroundColor = .white
        return search
    }()

    private let nowLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("현위치", for: .normal)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.budiGreen
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.tintColor = .white

        button.addTarget(self, action: #selector(locationButtonAction), for: .touchUpInside)
        return button
    }()

    @objc
    func locationButtonAction() {
        print("준비중")
    }

    @objc
    func dismissAlert() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blackBackView.alpha = 0.0
            self.alert.alpha = 0.0
        }, completion: { _ in
            self.blackBackView.removeFromSuperview()
            self.alert.removeFromSuperview()
        })
    }

    @objc
    func projectWriteAtcion() {
        // 일단 아무것도 하지 않으니 (뷰가 안만들어진듯) dismiss
        UIView.animate(withDuration: 0.2, animations: {
            self.blackBackView.alpha = 0.0
            self.alert.alpha = 0.0
        }, completion: { _ in
            self.blackBackView.removeFromSuperview()
            self.alert.removeFromSuperview()
        })
    }

    private let searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = .white
        tableView.separatorInset.left = 0

        return tableView
    }()

    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.init(white: 0, alpha: 0.38)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()

    @objc
    func nextAction() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        nextButton.isEnabled = false
        configureLayout()
        configureTableView()
        configureAlert()

    }

    private func configureAlert() {

        alert.showAlert(title: "버디 위치기반 서비스 이용약관에 동의하시겠습니까?", cancelTitle: "취소", doneTitle: "동의")
        blackBackView.backgroundColor = .black
        blackBackView.alpha = 0.0
        alert.alpha = 0.0
        view.addSubview(blackBackView)
        blackBackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alert)
        alert.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blackBackView.topAnchor.constraint(equalTo: view.topAnchor),
            blackBackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackBackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blackBackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alert.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alert.widthAnchor.constraint(equalToConstant: 343),
            alert.heightAnchor.constraint(equalToConstant: 208)
        ])

        UIView.animate(withDuration: 0.2, animations: {
            self.blackBackView.alpha = 0.5
            self.alert.alpha = 1.0
        })
    }

    private func configureTableView() {
        searchTableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellId)
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }

    private func configureLayout() {

        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: 40, width: view.bounds.width - 16, height: 1.0)
        bottomLine.backgroundColor = UIColor.init(white: 0, alpha: 0.12).cgColor
        searchBar.layer.addSublayer(bottomLine)
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchBar.widthAnchor.constraint(equalToConstant: view.bounds.width - 16),
            searchBar.heightAnchor.constraint(equalToConstant: 40)
        ])

        view.addSubview(nowLocationButton)
        nowLocationButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nowLocationButton.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            nowLocationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nowLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nowLocationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nowLocationButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 83)
        ])

        view.addSubview(searchTableView)
        searchTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchTableView.topAnchor.constraint(equalTo: nowLocationButton.bottomAnchor, constant: 18),
            searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor)
        ])

    }

}

extension LocationSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let location = Location().location
        if !searchText.isEmpty {
            for idx in location {
                if idx.contains(searchText) {
                    print(idx)
                    if !correct.contains(idx) {
                        correct.append(idx)
                    }
                }
            }
            searchTableView.reloadData()
        } else {
            correct = []
            searchTableView.reloadData()
        }
    }
}

extension LocationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        correct.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellId, for: indexPath) as? SearchTableViewCell else { return UITableViewCell() }
        if correct.count > 0 {
            cell.configureCellLabel(text: correct[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let data = correct[indexPath.row]
        nextButton.backgroundColor = UIColor.budiGreen
        nextButton.isEnabled = true
        NotificationCenter.default.post(name: NSNotification.Name("LocationNextActivation"), object: data)
    }
}
