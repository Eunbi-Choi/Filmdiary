//
//  SignupViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/19/25.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class SignupViewController: UIViewController {
    
    var baseView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var stackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = 12
        return view
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원가입"
        label.textAlignment = .center
        return label
    }()
    
    var emailTextField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "이메일을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var pwTextField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var nicknameTextField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "닉네임을 입력해주세요"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    var joinBtn: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("회원가입", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "회원가입"
        view.backgroundColor = ColorTheme.background
        addViews()
        applyConstraints()
        addTarget()
        styleUI()
    }
    
    func addViews() {
        view.addSubview(baseView)
        baseView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(pwTextField)
        stackView.addArrangedSubview(nicknameTextField)
        stackView.addArrangedSubview(joinBtn)
    }
    
    func applyConstraints() {
        let baseViewConstraints = [
            baseView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            baseView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            baseView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            baseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        let stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -30),
        ]
        
        let emailTfConstraints = [
            emailTextField.heightAnchor.constraint(equalToConstant: 50)
        ]
        NSLayoutConstraint.activate(baseViewConstraints)
        NSLayoutConstraint.activate(stackViewConstraints)
        NSLayoutConstraint.activate(emailTfConstraints)
    }
    
    func addTarget() {
        joinBtn.addTarget(self, action: #selector(didTapJoinButton(_:)), for: .touchUpInside)
    }
    
    @objc func didTapJoinButton(_ sender: UIButton) {
        print("회원가입 버튼 클릭")
        
        if let email = emailTextField.text {
            print(email)
        }
        
        if let pw = pwTextField.text {
            print(pw)
        }
        
        createUser()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func createUser() {
        guard let email = emailTextField.text else { return }
        guard let pw = pwTextField.text else { return }
        guard let nickname = nicknameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: pw) { result, error in
            if let error = error {
                print(error)
            }
            if let result = result {
                print(result)
                
                let db = Firestore.firestore()
                let userId = result.user.uid
                let newDocRef = db.collection("users").document(userId)
                
                let userData = [
                    "uid": userId,
                    "email": email,
                    "nickname": nickname
                ]
                
                newDocRef.setData(userData){ error in
                    if let error = error {
                        print("저장 오류: \(error)")
                    } else {
                        print("저장 성공: \(userId)")
                    }
                }
            }
        }
    }
    
    func styleUI() {
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = ColorTheme.text
        emailTextField.backgroundColor = ColorTheme.cardBackground
        emailTextField.textColor = ColorTheme.text
        emailTextField.attributedPlaceholder = NSAttributedString(string: "이메일을 입력해주세요", attributes: [.foregroundColor: ColorTheme.secondaryText])
        emailTextField.layer.borderColor = ColorTheme.accent.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 10
        pwTextField.backgroundColor = ColorTheme.cardBackground
        pwTextField.textColor = ColorTheme.text
        pwTextField.attributedPlaceholder = NSAttributedString(string: "비밀번호를 입력해주세요", attributes: [.foregroundColor: ColorTheme.secondaryText])
        pwTextField.layer.borderColor = ColorTheme.accent.cgColor
        pwTextField.layer.borderWidth = 1
        pwTextField.layer.cornerRadius = 10
        nicknameTextField.backgroundColor = ColorTheme.cardBackground
        nicknameTextField.textColor = ColorTheme.text
        nicknameTextField.attributedPlaceholder = NSAttributedString(string: "닉네임을 입력해주세요", attributes: [.foregroundColor: ColorTheme.secondaryText])
        nicknameTextField.layer.borderColor = ColorTheme.accent.cgColor
        nicknameTextField.layer.borderWidth = 1
        nicknameTextField.layer.cornerRadius = 10
        joinBtn.backgroundColor = ColorTheme.main
        joinBtn.setTitleColor(ColorTheme.text, for: .normal)
        joinBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        joinBtn.layer.cornerRadius = 12
        joinBtn.layer.shadowColor = ColorTheme.accent.cgColor
        joinBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        joinBtn.layer.shadowOpacity = 0.15
        joinBtn.layer.shadowRadius = 4
    }
}
