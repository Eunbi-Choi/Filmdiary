//
//  LoginViewController.swift
//  FinalProject
//
//  Created by electrozone on 6/19/25.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이메일"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("로그인", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        return btn
    }()

    private let signupButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorTheme.background
        setupUI()
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        [emailTextField, passwordTextField, loginButton, signupButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        emailTextField.backgroundColor = ColorTheme.cardBackground
        emailTextField.textColor = ColorTheme.text
        emailTextField.attributedPlaceholder = NSAttributedString(string: "이메일", attributes: [.foregroundColor: ColorTheme.secondaryText])
        emailTextField.layer.borderColor = ColorTheme.accent.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 10
        passwordTextField.backgroundColor = ColorTheme.cardBackground
        passwordTextField.textColor = ColorTheme.text
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "비밀번호", attributes: [.foregroundColor: ColorTheme.secondaryText])
        passwordTextField.layer.borderColor = ColorTheme.accent.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 10
        loginButton.backgroundColor = ColorTheme.main
        loginButton.setTitleColor(ColorTheme.text, for: .normal)
        loginButton.layer.cornerRadius = 12
        loginButton.layer.shadowColor = ColorTheme.accent.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        loginButton.layer.shadowOpacity = 0.15
        loginButton.layer.shadowRadius = 4
        signupButton.setTitleColor(ColorTheme.accent, for: .normal)
        signupButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        signupButton.backgroundColor = .clear
        signupButton.layer.cornerRadius = 8
        let titleLabel = UILabel()
        titleLabel.text = "로그인"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = ColorTheme.text
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            
            signupButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            signupButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signupButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loginTapped() {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
            } else {
                print("로그인 성공!")
                
                guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }

                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let homeVC = storyboard.instantiateViewController(withIdentifier: "tabBarController")

                let navController = UINavigationController(rootViewController: homeVC)
                sceneDelegate.window?.rootViewController = navController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    @objc private func signupTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signupVC = storyboard.instantiateViewController(withIdentifier: "signupVC")
        self.present(signupVC, animated: true, completion: nil)
    }
}
