//
//  CustomCell.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 6/3/25.
//

import Foundation
import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func didSelectGenre(_ genre: Genre)
}

class CustomTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    static let reuseIdentifier = "CustomTableViewCell"
    
    weak var delegate: CustomTableViewCellDelegate?
    
    private var collectionView: UICollectionView!
    
    var genres: [Genre] = []
    var movies: [Movie] = []
    var popularMovies: [Movie] = []
    
    enum CellType {
        case category
        case movieList
        case titleView
        case popularMovies
    }
    
    var cellType: CellType = .category
    
    private let categoryListHeight: CGFloat = 100
    private let movieListHeight: CGFloat = 225
    private let titleViewHeight: CGFloat = 44
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
        case .titleView:
            layout.itemSize = CGSize(width: 140, height: 441)
            newHeight = titleViewHeight
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
        case .titleView:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        switch cellType {
        case .category:
            let genre = genres[indexPath.row]
            cell.contentView.backgroundColor = .clear
            cell.layer.cornerRadius = 10
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = genre.name
            label.textColor = .white
            label.textAlignment = .center
            cell.contentView.addSubview(label)
            
        case .movieList, .popularMovies:
            let movie = (cellType == .movieList) ? movies[indexPath.row] : popularMovies[indexPath.row]
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
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
        case .titleView:
            let label = UILabel(frame: cell.contentView.bounds)
            label.text = "Popular Movies"
            label.textColor = .white
            label.textAlignment = .left
            cell.contentView.addSubview(label)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellType == .category {
            let selectedGenre = genres[indexPath.row]
            delegate?.didSelectGenre(selectedGenre)
            print(genres[indexPath.row])
        }
    }
}
