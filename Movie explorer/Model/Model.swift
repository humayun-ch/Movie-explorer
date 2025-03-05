//
//  Model.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
}

