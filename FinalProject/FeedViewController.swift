//
//  FeedViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/19/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class FeedViewController: UIViewController {
    
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["나의 기록", "전체"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DiaryCell.self, forCellReuseIdentifier: "DiaryCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private var myDiaries: [Diary] = []
    private var allDiaries: [Diary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "피드"
        
        setupUI()
        fetchMyDiaries()
        
        segmentedControl.addTarget(self, action: #selector(segmentedChanged), for: .valueChanged)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func segmentedChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            fetchMyDiaries()
        } else {
            fetchAllDiaries()
        }
    }
    
    private func fetchMyDiaries() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("filmDiaries").document(uid).collection("myDiary").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("내 기록 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            self.myDiaries = documents.compactMap { Diary(dictionary: $0.data()) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchAllDiaries() {
        allDiaries = []
        let db = Firestore.firestore()
        db.collection("filmDiaries").getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("전체 기록 불러오기 실패: \(error.localizedDescription)")
                return
            }
            guard let userDocs = snapshot?.documents else { return }
            let group = DispatchGroup()
            var tempDiaries: [Diary] = []
            for userDoc in userDocs {
                let uid = userDoc.documentID
                group.enter()
                db.collection("filmDiaries").document(uid).collection("myDiary").getDocuments { (diarySnapshot, error) in
                    if let diaryDocs = diarySnapshot?.documents {
                        for doc in diaryDocs {
                            if let diary = Diary(dictionary: doc.data()), diary.privacy == 2 {
                                tempDiaries.append(diary)
                            }
                        }
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.allDiaries = tempDiaries
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 {
            return myDiaries.count
        } else {
            return allDiaries.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
            return UITableViewCell()
        }
        let diary: Diary
        if segmentedControl.selectedSegmentIndex == 0 {
            diary = myDiaries[indexPath.row]
            cell.configure(with: diary, showNickname: false)
        } else {
            diary = allDiaries[indexPath.row]
            cell.configure(with: diary, showNickname: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 상세보기 등 추후 구현
    }
}

// MARK: - Diary Model
struct Diary {
    let nickname: String
    let movieTitle: String
    let viewingDate: String
    let posterPath: String
    let diaryTitle: String
    let diaryContent: String
    let quote: String
    let privacy: Int
    let tag: [String]
    
    init?(dictionary: [String: Any]) {
        self.nickname = dictionary["nickname"] as? String ?? ""
        self.movieTitle = dictionary["movieTitle"] as? String ?? ""
        self.viewingDate = dictionary["viewingDate"] as? String ?? ""
        self.posterPath = dictionary["posterPath"] as? String ?? ""
        self.diaryTitle = dictionary["diaryTitle"] as? String ?? ""
        self.diaryContent = dictionary["diaryContent"] as? String ?? ""
        self.quote = dictionary["quote"] as? String ?? ""
        self.privacy = dictionary["privacy"] as? Int ?? 0
        self.tag = dictionary["tag"] as? [String] ?? []
    }
}

// MARK: - DiaryCell
class DiaryCell: UITableViewCell {
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let diaryTitleLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let tagStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .secondaryLabel
        diaryTitleLabel.font = .systemFont(ofSize: 15)
        diaryTitleLabel.textColor = .label
        nicknameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nicknameLabel.textColor = .systemBlue
        nicknameLabel.isHidden = true
        tagStackView.translatesAutoresizingMaskIntoConstraints = false
        
        [posterImageView, titleLabel, dateLabel, diaryTitleLabel, nicknameLabel, tagStackView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            posterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            posterImageView.widthAnchor.constraint(equalToConstant: 60),
            posterImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            nicknameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            nicknameLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            
            dateLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            
            tagStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            tagStackView.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            tagStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),
            tagStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            diaryTitleLabel.topAnchor.constraint(equalTo: tagStackView.bottomAnchor, constant: 6),
            diaryTitleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            diaryTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            diaryTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with diary: Diary, showNickname: Bool) {
        titleLabel.text = diary.movieTitle
        dateLabel.text = diary.viewingDate
        diaryTitleLabel.text = diary.diaryTitle
        nicknameLabel.text = "@" + diary.nickname
        nicknameLabel.isHidden = !showNickname
        updateTagStackView(with: diary.tag)
        if !diary.posterPath.isEmpty {
            let urlString = "https://image.tmdb.org/t/p/w500" + diary.posterPath
            if let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.posterImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
        } else {
            posterImageView.image = UIImage(systemName: "film")
        }
    }
    
    private func updateTagStackView(with tags: [String]) {
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in tags {
            let label = PaddingLabel()
            label.text = tag
            label.font = .systemFont(ofSize: 12)
            label.textColor = .white
            label.backgroundColor = .systemBlue
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            tagStackView.addArrangedSubview(label)
        }
    }
}

// 커스텀 패딩 라벨
class PaddingLabel: UILabel {
    var insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

