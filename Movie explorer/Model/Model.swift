//
//  Model.swift
//  Movie explorer
//
//  Created by Humayun Kabir on 4/3/25.
//

struct Genre: Decodable {
    let id: Int
    let name: String
}

struct GenreResponse: Decodable {
    let genres: [Genre]
}

struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
}

struct MovieResponse: Decodable {
    let results: [Movie]
}

