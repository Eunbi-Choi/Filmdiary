import UIKit
import FirebaseAuth
import FirebaseFirestore

class DiaryDetailViewController: UIViewController {
    let diary: Diary
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let dateLabel = UILabel()
    private let tagStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .leading
        return stack
    }()
    private let diaryTitleLabel = UILabel()
    private let diaryContentLabel = UILabel()
    private let quoteLabel = UILabel()
    
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel()
    private let commentTableView = UITableView()
    private let commentInputField = UITextField()
    private let commentSendButton = UIButton(type: .system)
    private var comments: [Comment] = []
    private var likeCount: Int = 0 { didSet { likeCountLabel.text = "좋아요 \(likeCount)" } }
    private var isLiked: Bool = false { didSet { updateLikeButtonUI() } }
    private var diaryOwnerUid: String = ""
    private var diaryId: String = ""
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ColorTheme.accent
        label.textAlignment = .center
        return label
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorTheme.secondaryText.withAlphaComponent(0.15)
        return view
    }()
    
    init(diary: Diary) {
        self.diary = diary
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorTheme.background
        title = "기록 상세"
        setupUI()
        configure()
        setupLikeAndCommentUI()
        fetchLikeAndCommentData()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        let cardView = UIView()
        cardView.backgroundColor = ColorTheme.cardBackground
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = ColorTheme.text.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 8
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        contentView.addSubview(dividerView)
        cardView.addSubview(authorLabel)
        [posterImageView, titleLabel, nicknameLabel, dateLabel, tagStackView, diaryTitleLabel, diaryContentLabel, quoteLabel].forEach {
            cardView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
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
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -24),
            authorLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            authorLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            posterImageView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            posterImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 90),
            posterImageView.heightAnchor.constraint(equalToConstant: 135),
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            nicknameLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 4),
            dateLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            tagStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            tagStackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            tagStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            diaryTitleLabel.topAnchor.constraint(equalTo: tagStackView.bottomAnchor, constant: 24),
            diaryTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            diaryTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            diaryContentLabel.topAnchor.constraint(equalTo: diaryTitleLabel.bottomAnchor, constant: 16),
            diaryContentLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            diaryContentLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            quoteLabel.topAnchor.constraint(equalTo: diaryContentLabel.bottomAnchor, constant: 24),
            quoteLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            quoteLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            quoteLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -40)
        ])
    }
    
    private func configure() {
        if !diary.posterPath.isEmpty {
            let urlString = "https://image.tmdb.org/t/p/w500" + diary.posterPath
            if let url = URL(string: urlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.posterImageView.image = UIImage(data: data)
                            self.posterImageView.tintColor = ColorTheme.accent
                        }
                    }
                }
            }
        } else {
            posterImageView.image = UIImage(systemName: "film")
            posterImageView.tintColor = ColorTheme.accent
        }
        titleLabel.text = diary.movieTitle
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = ColorTheme.text
        authorLabel.text = "글쓴이: @" + diary.nickname
        nicknameLabel.text = "@" + diary.nickname
        nicknameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nicknameLabel.textColor = ColorTheme.accent
        dateLabel.text = diary.viewingDate
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = ColorTheme.secondaryText
        diaryTitleLabel.text = "제목: " + diary.diaryTitle
        diaryTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        diaryTitleLabel.textColor = ColorTheme.text
        diaryContentLabel.text = diary.diaryContent
        diaryContentLabel.font = .systemFont(ofSize: 16)
        diaryContentLabel.textColor = ColorTheme.text
        diaryContentLabel.numberOfLines = 0
        quoteLabel.text = diary.quote.isEmpty ? "" : "명대사: \(diary.quote)"
        quoteLabel.font = .italicSystemFont(ofSize: 15)
        quoteLabel.textColor = ColorTheme.accent
        tagStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in diary.tag {
            let label = PaddingLabel()
            label.text = tag
            label.font = .systemFont(ofSize: 12)
            label.textColor = ColorTheme.text
            label.backgroundColor = ColorTheme.main
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.textAlignment = .center
            tagStackView.addArrangedSubview(label)
        }
    }
    
    private func setupLikeAndCommentUI() {
        likeButton.setTitle("♡", for: .normal)
        likeButton.titleLabel?.font = .systemFont(ofSize: 28)
        likeButton.tintColor = ColorTheme.accent
        likeButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
        likeCountLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        likeCountLabel.textColor = ColorTheme.accent
        likeCountLabel.text = "좋아요 0"
        view.addSubview(likeButton)
        view.addSubview(likeCountLabel)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            likeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            likeCountLabel.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 2),
            likeCountLabel.centerXAnchor.constraint(equalTo: likeButton.centerXAnchor)
        ])

        commentInputField.placeholder = "댓글을 입력하세요"
        commentInputField.borderStyle = .roundedRect
        commentInputField.backgroundColor = ColorTheme.cardBackground
        commentInputField.textColor = ColorTheme.text
        commentInputField.layer.borderColor = ColorTheme.accent.cgColor
        commentInputField.layer.borderWidth = 1
        commentInputField.layer.cornerRadius = 10
        commentSendButton.setTitle("등록", for: .normal)
        commentSendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)
        commentSendButton.setTitleColor(ColorTheme.accent, for: .normal)
        commentSendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        let commentInputStack = UIStackView(arrangedSubviews: [commentInputField, commentSendButton])
        commentInputStack.axis = .horizontal
        commentInputStack.spacing = 8
        view.addSubview(commentInputStack)
        commentInputStack.translatesAutoresizingMaskIntoConstraints = false
        commentInputField.translatesAutoresizingMaskIntoConstraints = false
        commentSendButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentInputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentInputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentInputStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            commentInputField.heightAnchor.constraint(equalToConstant: 36),
            commentSendButton.widthAnchor.constraint(equalToConstant: 48)
        ])

        commentTableView.dataSource = self
        commentTableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        commentTableView.separatorStyle = .none
        commentTableView.rowHeight = UITableView.automaticDimension
        commentTableView.estimatedRowHeight = 44
        commentTableView.backgroundColor = .clear
        view.addSubview(commentTableView)
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 50),
            commentTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentTableView.bottomAnchor.constraint(equalTo: commentInputStack.topAnchor, constant: -8)
        ])
    }
    
    private func updateLikeButtonUI() {
        likeButton.setTitle(isLiked ? "♥️" : "♡", for: .normal)
        likeButton.tintColor = isLiked ? .systemPink : .systemGray3
    }
    
    private func fetchLikeAndCommentData() {
        diaryOwnerUid = diary.nickname
        diaryId = diary.movieTitle
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let likesRef = db.collection("filmDiaries").document(diaryOwnerUid).collection("myDiary").document(diaryId).collection("likes")
        likesRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let docs = snapshot?.documents {
                self.likeCount = docs.count
                self.isLiked = docs.contains(where: { $0.documentID == currentUid })
            }
        }

        let commentsRef = db.collection("filmDiaries").document(diaryOwnerUid).collection("myDiary").document(diaryId).collection("comments").order(by: "date", descending: false)
        commentsRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            self.comments = snapshot?.documents.compactMap { Comment(dictionary: $0.data()) } ?? []
            self.commentTableView.reloadData()
        }
    }
    
    @objc private func toggleLike() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let likesRef = db.collection("filmDiaries").document(diaryOwnerUid).collection("myDiary").document(diaryId).collection("likes")
        if isLiked {
            likesRef.document(currentUid).delete { [weak self] _ in
                self?.isLiked = false
                self?.likeCount -= 1
            }
        } else {
            likesRef.document(currentUid).setData(["liked": true]) { [weak self] _ in
                self?.isLiked = true
                self?.likeCount += 1
            }
        }
    }
    
    @objc private func sendComment() {
        guard let text = commentInputField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        // 닉네임 가져오기
        db.collection("users").document(currentUid).getDocument { [weak self] (snapshot, error) in
            guard let self = self else { return }
            let nickname = snapshot?.get("nickname") as? String ?? "익명"
            let commentData: [String: Any] = [
                "nickname": nickname,
                "text": text,
                "date": Date().timeIntervalSince1970
            ]
            let commentsRef = db.collection("filmDiaries").document(self.diaryOwnerUid).collection("myDiary").document(self.diaryId).collection("comments")
            commentsRef.addDocument(data: commentData) { error in
                if error == nil {
                    self.commentInputField.text = ""
                    self.fetchLikeAndCommentData()
                }
            }
        }
    }
}

struct Comment {
    let nickname: String
    let text: String
    let date: TimeInterval
    init?(dictionary: [String: Any]) {
        self.nickname = dictionary["nickname"] as? String ?? "익명"
        self.text = dictionary["text"] as? String ?? ""
        self.date = dictionary["date"] as? TimeInterval ?? 0
    }
}

class CommentCell: UITableViewCell {
    private let nicknameLabel = UILabel()
    private let textLabel2 = UILabel()
    private let dateLabel = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        nicknameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nicknameLabel.textColor = ColorTheme.accent
        textLabel2.font = .systemFont(ofSize: 15)
        textLabel2.textColor = ColorTheme.text
        textLabel2.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = ColorTheme.secondaryText
        let stack = UIStackView(arrangedSubviews: [nicknameLabel, textLabel2, dateLabel])
        stack.axis = .vertical
        stack.spacing = 2
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(with comment: Comment) {
        nicknameLabel.text = "@" + comment.nickname
        textLabel2.text = comment.text
        let date = Date(timeIntervalSince1970: comment.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd HH:mm"
        dateLabel.text = formatter.string(from: date)
    }
}

extension DiaryDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }
} 
