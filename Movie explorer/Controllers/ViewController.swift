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
    
    var genres: [Genre] = []
    var movies: [Movie] = []
    var popularMovies: [Movie] = []
    
    enum CellType {
        case category
        case movieList
        case popularMovies
    }
    
    var cellType: CellType = .category
    
    private let categoryListHeight: CGFloat = 100
    private let movieListHeight: CGFloat = 225
    private let popularMoviesHeight: CGFloat = 225
    
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
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionCell")
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with cellType: CellType, genres: [Genre] = [], movies: [Movie] = [], popularMovies: [Movie] = []) {
        self.cellType = cellType
        self.genres = genres
        self.movies = movies
        self.popularMovies = popularMovies
        updateLayout()
    }
    
    func updateLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10

        var newHeight: CGFloat = 100
        
        switch cellType {
        case .category:
            layout.itemSize = CGSize(width: 150, height: 100)
            newHeight = categoryListHeight
        case .movieList:
            layout.itemSize = CGSize(width: 140, height: 225)
            newHeight = movieListHeight
        case .popularMovies:
            layout.itemSize = CGSize(width: 140, height: 225)
            newHeight = popularMoviesHeight
        }
        
        collectionView.setCollectionViewLayout(layout, animated: false)

        collectionView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                collectionView.removeConstraint(constraint)
            }
        }
        
        let heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: newHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch cellType {
        case .category:
            let genre = genres[indexPath.row]
            cell.contentView.backgroundColor = .lightGray
            cell.layer.cornerRadius = 10
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = genre.name
            label.textColor = .black
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            
        case .movieList, .popularMovies:
            let movie = (cellType == .movieList) ? movies[indexPath.row] : popularMovies[indexPath.row]
            cell.contentView.backgroundColor = .clear
            cell.layer.cornerRadius = 15
            cell.clipsToBounds = true
            
            if let posterPath = movie.posterPath, let url = URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)") {
                let imageView = UIImageView(frame: cell.contentView.bounds)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = 15
                imageView.clipsToBounds = true
                imageView.loadImage(from: url)
                cell.contentView.addSubview(imageView)
            }
        }
        return cell
    }
}


extension UIImageView {
    func loadImage(from url: URL) {
        let cacheKey = NSString(string: url.absoluteString)
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
        
        self.image = nil
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageCache.setObject(image, forKey: cacheKey)
                    self.image = image
                }
            }
        }
    }
}

let imageCache = NSCache<NSString, UIImage>()

protocol GenreTableViewCellDelegate: AnyObject {
    func didSelectGenre(genre: Genre)
}


class ViewController: UIViewController {

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
    
    private func setupViews() {
        view.backgroundColor = .white
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: CustomTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomTableViewCell.reuseIdentifier, for: indexPath) as! CustomTableViewCell
        
        if indexPath.row == 0 {
            cell.configure(with: .category, genres: movieViewModel.genres)
        } else if indexPath.row == 1 {
            cell.configure(with: .movieList, movies: movieViewModel.movies)
        } else if indexPath.row == 2 {
            cell.configure(with: .popularMovies, popularMovies: movieViewModel.popularMovies)
        }
        
        DispatchQueue.main.async {
            cell.updateLayout()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 100 } // Small category list
        return 225 // Large for movie list and popular movies
    }
}

