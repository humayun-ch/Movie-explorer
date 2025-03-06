//
//  ViewController.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

import UIKit

class ViewController: UIViewController {

    private let movieViewModel = MovieViewModel()
    private var tableView: UITableView!
    private var moviesLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMoviesLabel()
        setupDataWithTableView()
        setupViewModel()
        movieViewModel.loadData(categoryID: 28)
    }
    
    private func setupMoviesLabel() {
        moviesLabel = UILabel()
        moviesLabel.text = "Movies"
        moviesLabel.font = UIFont.boldSystemFont(ofSize: 32)
        moviesLabel.textAlignment = .left
        moviesLabel.textColor = .white
        
        moviesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(moviesLabel)
        view.backgroundColor = .purple.withAlphaComponent(0.5)
        
        NSLayoutConstraint.activate([
            moviesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            moviesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
    }
    
    private func setupViewModel() {
        movieViewModel.onGenresFetched = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.tableView.reloadData()
            }
        }
        movieViewModel.onMoviesFetched = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.tableView.reloadData()
            }
        }
        movieViewModel.onPopularMoviesFetched = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupDataWithTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(hexString: "151515")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: moviesLabel.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//Delegate extension
extension ViewController: CustomTableViewCellDelegate {
    func didSelectGenre(_ genre: Genre) {
        movieViewModel.loadMovies(categoryID: genre.id)
        movieViewModel.onMoviesFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
            }
        }
    }
}

//Table view extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as! CustomTableViewCell
        
        if indexPath.row == 0 {
            cell.configure(with: .category, genres: movieViewModel.genres)
            cell.delegate = self
        } else if indexPath.row == 1 {
            cell.configure(with: .movieList, movies: movieViewModel.movies)
        } else if indexPath.row == 2 {
            cell.configure(with: .titleView, popularMovies: movieViewModel.popularMovies)
        } else if indexPath.row == 3 {
            cell.configure(with: .popularMovies, popularMovies: movieViewModel.popularMovies)
        }
        
        DispatchQueue.main.async {
            cell.updateLayout()
        }
        cell.backgroundColor = .clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 100 }
        if indexPath.row == 2 { return 44 }
        return 225
    }
}

