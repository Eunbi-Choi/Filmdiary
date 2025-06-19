//
//  SearchViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/18/25.
//

import UIKit

class SearchViewController: UIViewController {
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "영화 제목을 검색하세요"
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.tintColor = ColorTheme.accent
        controller.searchBar.barTintColor = ColorTheme.background
        return controller
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(MovieTableViewCell.self, forCellReuseIdentifier: "MovieTableViewCell")
        table.backgroundColor = ColorTheme.background
        table.separatorStyle = .none
        return table
    }()
    
    private var movies: [Movie] = []
    private var searchTask: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 기존 뷰의 모든 서브뷰 제거
        view.subviews.forEach { $0.removeFromSuperview() }
        
        view.backgroundColor = ColorTheme.background
        title = "영화 검색"
        
        // 네비게이션 바 스타일링
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: ColorTheme.text
        ]
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: ColorTheme.text
        ]
        navigationController?.navigationBar.tintColor = ColorTheme.accent
        navigationController?.navigationBar.barTintColor = ColorTheme.background
        
        setupSearchController()
        setupTableView()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func searchMovies(query: String) {
        searchTask?.cancel()
        
        let task = DispatchWorkItem { [weak self] in
            APICaller.shared.getSearchResults(query: query) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let movies):
                        self?.movies = movies
                        self?.tableView.reloadData()
                    case .failure(let error):
                        print("검색 오류: \(error)")
                        self?.movies = []
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        
        searchTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
}

// MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            movies = []
            tableView.reloadData()
            return
        }
        
        searchMovies(query: query)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        let detailVC = MovieDetailViewController()
        detailVC.movie = movie
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
