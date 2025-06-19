//
//  MovieTableViewCell.swift
//  FinalProject
//
//  Created by electrozone on 6/18/25.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorTheme.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = ColorTheme.text.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = ColorTheme.main
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 2
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = ColorTheme.secondaryText
        label.numberOfLines = 2
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ColorTheme.accent
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(posterImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(overviewLabel)
        cardView.addSubview(ratingLabel)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            posterImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            posterImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            posterImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            posterImageView.widthAnchor.constraint(equalToConstant: 90),
            
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            
            ratingLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            overviewLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title ?? movie.original_title ?? "제목 없음"
        overviewLabel.text = movie.overview ?? "줄거리가 없습니다."
        ratingLabel.text = "★ \(String(format: "%.1f", movie.vote_average))"
        
        if let posterPath = movie.poster_path {
            let imageUrl = "https://image.tmdb.org/t/p/w500\(posterPath)"
            downloadImage(from: imageUrl)
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.tintColor = ColorTheme.accent
        }
    }
    
    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                self?.posterImageView.image = UIImage(data: data)
            }
        }.resume()
    }
} 