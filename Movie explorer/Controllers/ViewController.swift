//
//  ViewController.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let movieViewModel = MovieViewModel()
    
    private var genresTableView: UITableView!
    private var moviesTableView: UITableView!
    private var popularMoviesTableView: UITableView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupViewModel()
        
        movieViewModel.loadData(categoryID: 28)
    }
    
    // MARK: - Setup ViewModel Binding
    
    private func setupViewModel() {
        movieViewModel.onGenresFetched = { [weak self] in
            self?.genresTableView.reloadData()
        }
        
        movieViewModel.onMoviesFetched = { [weak self] in
            self?.moviesTableView.reloadData()
        }
        
        movieViewModel.onPopularMoviesFetched = { [weak self] in
            self?.popularMoviesTableView.reloadData()
        }
        
        movieViewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // Setup Genres TableView
        genresTableView = UITableView()
        genresTableView.translatesAutoresizingMaskIntoConstraints = false
        genresTableView.delegate = self
        genresTableView.dataSource = self
        genresTableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreCell")
        view.addSubview(genresTableView)
        
        // Setup Movies TableView
        moviesTableView = UITableView()
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        view.addSubview(moviesTableView)
        
        // Setup Popular Movies TableView
        popularMoviesTableView = UITableView()
        popularMoviesTableView.translatesAutoresizingMaskIntoConstraints = false
        popularMoviesTableView.delegate = self
        popularMoviesTableView.dataSource = self
        popularMoviesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PopularMovieCell")
        view.addSubview(popularMoviesTableView)
        
        // Set up Constraints
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Genres TableView
            genresTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            genresTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            genresTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            genresTableView.heightAnchor.constraint(equalToConstant: 150),
            
            // Movies TableView
            moviesTableView.topAnchor.constraint(equalTo: genresTableView.bottomAnchor),
            moviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moviesTableView.heightAnchor.constraint(equalToConstant: 250),
            
            // Popular Movies TableView
            popularMoviesTableView.topAnchor.constraint(equalTo: moviesTableView.bottomAnchor),
            popularMoviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            popularMoviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            popularMoviesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Genres TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == genresTableView {
            return movieViewModel.genres.count
        } else if tableView == moviesTableView {
            return movieViewModel.movies.count
        } else if tableView == popularMoviesTableView {
            return movieViewModel.popularMovies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == genresTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
            let genre = movieViewModel.genres[indexPath.row]
            cell.textLabel?.text = "\(genre.id)"
            return cell
        } else if tableView == moviesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
            let movie = movieViewModel.movies[indexPath.row]
            cell.textLabel?.text = movie.title
            return cell
        } else if tableView == popularMoviesTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopularMovieCell", for: indexPath)
            let movie = movieViewModel.popularMovies[indexPath.row]
            cell.textLabel?.text = movie.title
            return cell
        }
        return UITableViewCell()
    }
    
    // MARK: - Handle Table Row Selection (Optional)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == genresTableView {
            let genre = movieViewModel.genres[indexPath.row]
            print("Selected Genre: \(genre.name)")
        } else if tableView == moviesTableView {
            let movie = movieViewModel.movies[indexPath.row]
            print("Selected Movie: \(movie.title)")
        } else if tableView == popularMoviesTableView {
            let movie = movieViewModel.popularMovies[indexPath.row]
            print("Selected Popular Movie: \(movie.title)")
        }
    }
}

