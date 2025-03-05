//
//  ViewController.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

import UIKit

class CustomTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    static let reuseIdentifier = "CustomTableViewCell"
    
    private var collectionView: UICollectionView!
    
    var genres: [Genre] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var movies: [Movie] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var popularMovies: [Movie] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    enum CellType {
        case category
        case movieList
        case popularMovies
    }
    
    var cellType: CellType = .category
    
    // Separate variables for each collection view
    var categoryCollectionViewItemWidth: CGFloat = 120
    var categoryCollectionViewItemHeight: CGFloat = 100
    
    var movieListCollectionViewItemWidth: CGFloat = 120
    var movieListCollectionViewItemHeight: CGFloat = 400
    
    var popularMoviesCollectionViewItemWidth: CGFloat = 130
    var popularMoviesCollectionViewItemHeight: CGFloat = 400
    
    var categoryCollectionViewHeight: CGFloat = 100
    var movieListCollectionViewHeight: CGFloat = 400
    var popularMoviesCollectionViewHeight: CGFloat = 400
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: categoryCollectionViewHeight) // default height; will be updated in updateLayout()
        ])
    }
    
    func updateLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        switch cellType {
        case .category:
            layout.itemSize = CGSize(width: categoryCollectionViewItemWidth, height: categoryCollectionViewItemHeight)
            collectionView.heightAnchor.constraint(equalToConstant: categoryCollectionViewHeight).isActive = true
        case .movieList:
            layout.itemSize = CGSize(width: movieListCollectionViewItemWidth, height: movieListCollectionViewItemHeight)
            collectionView.heightAnchor.constraint(equalToConstant: movieListCollectionViewHeight).isActive = true
        case .popularMovies:
            layout.itemSize = CGSize(width: popularMoviesCollectionViewItemWidth, height: popularMoviesCollectionViewItemHeight)
            collectionView.heightAnchor.constraint(equalToConstant: popularMoviesCollectionViewHeight).isActive = true
        }
        collectionView.setCollectionViewLayout(layout, animated: false)
    }
    
    // MARK: - UICollectionView DataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch cellType {
        case .category:
            return genres.count
        case .movieList:
            return movies.count
        case .popularMovies:
            return popularMovies.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Remove previous subviews (for cell reuse)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch cellType {
        case .category:
            let genre = genres[indexPath.row]
            cell.contentView.backgroundColor = .lightGray
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: categoryCollectionViewItemWidth, height: categoryCollectionViewItemHeight))
            label.text = genre.name
            label.textColor = .black
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            
        case .movieList:
            let movie = movies[indexPath.row]
            cell.contentView.backgroundColor = .clear
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: movieListCollectionViewItemWidth, height: movieListCollectionViewItemHeight))
                imageView.contentMode = .scaleAspectFill
                //                imageView.clipsToBounds = true
                imageView.loadImage(from: url)
                cell.contentView.addSubview(imageView)
            }
            
        case .popularMovies:
            let movie = popularMovies[indexPath.row]
            cell.contentView.backgroundColor = .clear
            if let posterPath = movie.posterPath,
               let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: popularMoviesCollectionViewItemWidth, height: popularMoviesCollectionViewItemHeight))
                imageView.contentMode = .scaleAspectFill
                //                imageView.clipsToBounds = true
                imageView.loadImage(from: url)
                cell.contentView.addSubview(imageView)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection if needed
        
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}

protocol GenreTableViewCellDelegate: AnyObject {
    func didSelectGenre(genre: Genre)
}


class ViewController: UIViewController, GenreTableViewCellDelegate {
    
    private let movieViewModel = MovieViewModel()
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        setupViews()
        setupViewModel()
        movieViewModel.loadData(categoryID: 28)
    }
    
    private func setupViewModel() {
        movieViewModel.onGenresFetched = { [weak self] in
            self?.tableView.reloadData()
        }
        movieViewModel.onMoviesFetched = { [weak self] in
            self?.tableView.reloadData()
        }
        movieViewModel.onPopularMoviesFetched = { [weak self] in
            self?.tableView.reloadData()
        }
        movieViewModel.onError = { [weak self] errorMessage in
            self?.showErrorAlert(message: errorMessage)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Genre selection delegate method
    func didSelectGenre(genre: Genre) {
        print("Selected Genre: \(genre.name)")
        movieViewModel.loadMovies(categoryID: genre.id)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as! CustomTableViewCell
        
        if indexPath.row == 0 {
            cell.cellType = .category
            cell.genres = movieViewModel.genres
            cell.categoryCollectionViewHeight = 100
            cell.categoryCollectionViewItemWidth = 150
            cell.categoryCollectionViewItemHeight = 100
        } else if indexPath.row == 1 {
            cell.cellType = .movieList
            cell.movies = movieViewModel.movies
            cell.movieListCollectionViewHeight = 400
            cell.movieListCollectionViewItemWidth = 120
            cell.movieListCollectionViewItemHeight = 400
        } else if indexPath.row == 2 {
            cell.cellType = .popularMovies
            cell.popularMovies = movieViewModel.popularMovies
            cell.popularMoviesCollectionViewHeight = 400
            cell.popularMoviesCollectionViewItemWidth = 120
            cell.popularMoviesCollectionViewItemHeight = 400
        }
        cell.backgroundColor = .red
        
        cell.updateLayout()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 200 // Height for Category row
        case 1:
            return 400 // Height for Movie List row (collection view + padding)
        case 2:
            return 400 // Height for Popular Movies row (collection view + padding)
        default:
            return 0
        }
    }
}
