//
//  MovieDetailViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/18/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MovieDetailViewController: UIViewController {
    
    var movie: Movie?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = ColorTheme.background
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorTheme.background
        return view
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = ColorTheme.main
        imageView.layer.shadowColor = ColorTheme.text.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 12
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorTheme.text
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = ColorTheme.accent
        label.textAlignment = .center
        return label
    }()
    
    private let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorTheme.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let voteCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = ColorTheme.secondaryText
        label.textAlignment = .center
        return label
    }()
    
    private let wishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("위시리스트", for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = ColorTheme.accent
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.layer.shadowColor = ColorTheme.accent.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(didTapWishButton), for: .touchUpInside)
        return button
    }()
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("기록하기", for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = ColorTheme.main
        button.setTitleColor(ColorTheme.text, for: .normal)
        button.tintColor = ColorTheme.text
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 20, bottom: 14, right: 20)
        button.layer.shadowColor = ColorTheme.text.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.textColor = ColorTheme.text
        label.backgroundColor = ColorTheme.cardBackground
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorTheme.background
        
        // 네비게이션 바 스타일링
        navigationController?.navigationBar.tintColor = ColorTheme.accent
        navigationController?.navigationBar.barTintColor = ColorTheme.background
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: ColorTheme.text
        ]
        
        setupUI()
        configureWithMovie()
        wishButton.addTarget(self, action: #selector(didTapWishButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(releaseDateLabel)
        contentView.addSubview(voteCountLabel)
        contentView.addSubview(wishButton)
        contentView.addSubview(recordButton)
        contentView.addSubview(overviewLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        voteCountLabel.translatesAutoresizingMaskIntoConstraints = false
        wishButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        overviewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            posterImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 220),
            posterImageView.heightAnchor.constraint(equalToConstant: 330),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            ratingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            releaseDateLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 8),
            releaseDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            releaseDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            voteCountLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 8),
            voteCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            voteCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            wishButton.topAnchor.constraint(equalTo: voteCountLabel.bottomAnchor, constant: 24),
            wishButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            wishButton.heightAnchor.constraint(equalToConstant: 48),
            
            recordButton.topAnchor.constraint(equalTo: voteCountLabel.bottomAnchor, constant: 24),
            recordButton.leadingAnchor.constraint(equalTo: wishButton.trailingAnchor, constant: 16),
            recordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            recordButton.heightAnchor.constraint(equalToConstant: 48),
            recordButton.widthAnchor.constraint(equalTo: wishButton.widthAnchor),
            
            overviewLabel.topAnchor.constraint(equalTo: wishButton.bottomAnchor, constant: 24),
            overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            overviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func configureWithMovie() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title ?? movie.original_title ?? "제목 없음"
        ratingLabel.text = "★ \(String(format: "%.1f", movie.vote_average))"
        releaseDateLabel.text = "개봉일: \(movie.release_date ?? "알 수 없음")"
        voteCountLabel.text = "평가 수: \(movie.vote_count)개"
        overviewLabel.text = movie.overview ?? "줄거리가 없습니다."
        
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
    
    @objc private func didTapWishButton() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(uid)
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).collection("wishList").document(titleLabel.text ?? "").setData(["title": titleLabel.text ?? ""])
        
        let alert = UIAlertController(title: nil, message: "위시리스트에 추가되었습니다.", preferredStyle: .alert)

        // 1~2초 뒤에 자동으로 닫히게
        self.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("WishListUpdated"), object: nil)
    }
}
