//
//  DeleteUserViewController.swift
//  stock Insight
//
//  Created by 이현호 on 2023/09/01.
//

import UIKit

class DeleteUserViewController: UIViewController {
    
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var rePasswordTextField: UITextField!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var quizTextField: UITextField!
    @IBOutlet var quizAnswerTextField: UITextField!
    @IBOutlet var deleteUserButton: UIButton!

    var picker = UIPickerView()
    let quizList = [
        "첫 번째 애완동물의 이름은 무엇인가요?",
        "초등학교 시절 최고의 친구는 누구였나요?",
        "당신이 태어난 도시는 어디인가요?",
        "첫 번째 자동차의 모델은 무엇인가요?",
        "당신이 존경하는 인물은 누구인가요?",
        "당신의 어린 시절 별명은 무엇인가요?"
    ]
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configPickerView()
        self.configureTexFieldAndButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - 설정함수
    
    //pickerView 설정 함수
    func configPickerView(){
        self.picker.delegate = self
        self.picker.dataSource = self
        self.quizTextField.inputView = picker
        
        configToolbar()
    }
    
    //툴바 설정 함수
    func configToolbar(){
        let toolBar = UIToolbar()
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
//        toolBar.backgroundColor = UIColor.systemGray2
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(self.donePicker))
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(self.cancelPicker))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([doneButton,flexibleSpace,cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.quizTextField.inputAccessoryView = toolBar
        self.quizTextField.inputAccessoryView?.backgroundColor = .systemGray2
    }
    
    // "완료" 클릭 시 데이터를 textfield에 입력 후 입력창 내리기
    @objc func donePicker() {
        let row = self.picker.selectedRow(inComponent: 0)
        self.picker.selectRow(row, inComponent: 0, animated: false)
        self.quizTextField.text = self.quizList[row]
        self.quizTextField.resignFirstResponder()
    }
    
    // "취소" 클릭 시 textfield의 텍스트 값을 nil로 처리 후 입력창 내리기
    @objc func cancelPicker() {
        self.quizTextField.text = nil
        self.quizTextField.resignFirstResponder()
    }
    
    //configure TextField and Button 함수
    func configureTexFieldAndButton(){
        passwordTextField.delegate = self
        rePasswordTextField.delegate = self
        userNameTextField.delegate = self
        quizTextField.delegate = self
        quizAnswerTextField.delegate = self
        
        self.deleteUserButton.isEnabled = false
        self.passwordTextField.isSecureTextEntry = true
        self.rePasswordTextField.isSecureTextEntry = true
        self.checkImageView.isHidden = true
    }
    

    //MARK: - 버튼 함수
    @IBAction func deleteUserButtonTapped(_ sender: Any) {
        let password = passwordTextField.text ?? ""
        let rePassword = rePasswordTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        let quiz = quizTextField.text ?? ""
        let answer = quizAnswerTextField.text ?? ""
        
        if password == rePassword{
            self.deleteUserWithAPI(username: userName, password: password, quiz: quiz, answer: answer)
//            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BeginNavigationController") as? BeginNavigationController else {return}
//            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)
        }else{
            self.showAlert(title: "비밀번호가 일치하지 않습니다.")
        }
    }
    
    //MARK: - 유저 삭세 함수
    func deleteUserWithAPI(username: String, password: String, quiz: String, answer: String){
        DeleteUserService.shared.deleteUser(username: username, Password: password, quiz: quiz, answer: answer, completion: { (networkResult) in
            
            switch networkResult{
            case .success(_):
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "BeginNavigationController") as? BeginNavigationController else {return}
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(viewController, animated: true)
            case .requestErr(let msg):
                if let message = msg as? String {
                    print(message)
                }
            case .pathErr:
                print("pathErr in postSignUpWithAPI")
            case .serverErr:
                print("serverErr in postSignUpWithAPI")
            case .networkFail:
                print("networkFail in postSignUpWithAPI")
            default:
                print("networkFail in signUpWithAPI")
            }
            
        })
    }
    
    //MARK: - 기타 함수
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
}


extension DeleteUserViewController: UITextFieldDelegate{
    //return 키가 눌리면 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //return 키가 눌렸을 때 동작
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {//사용자가 텍스트 필드의 편집을 완료하고 텍스트 필드가 편집 모드에서 벗어났을 때 호출
        let isPasswordEmpty = passwordTextField.text == ""
        let isRepasswordEmpty = rePasswordTextField.text == ""
        let isUserNameEmpty = userNameTextField.text == ""
        let isQuizEmpty = quizTextField.text == ""
        let isAnswerEmpty = quizAnswerTextField.text == ""
        
        self.deleteUserButton.isEnabled = !isPasswordEmpty && !isRepasswordEmpty && !isUserNameEmpty && !isQuizEmpty && !isAnswerEmpty
        
        if(passwordTextField.text != "" && passwordTextField.text == rePasswordTextField.text){
            self.checkImageView.isHidden = false
        }else{
            self.checkImageView.isHidden = true
        }
    }
}

extension DeleteUserViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return quizList[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.quizList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.quizTextField.text = self.quizList[row]
    }
}
