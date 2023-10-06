import UIKit
import Foundation

class SignUpViewController: UIViewController {

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var rePasswordTextField: UITextField!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var checkImageView: UIImageView!
    @IBOutlet var quizTextField: UITextField!
    @IBOutlet var quizAnswerTextField: UITextField!
    
    var picker = UIPickerView()
    let quizList = [
        "첫 번째 애완동물의 이름은 무엇인가요?",
        "초등학교 시절 최고의 친구는 누구였나요?",
        "당신이 태어난 도시는 어디인가요?",
        "첫 번째 자동차의 모델은 무엇인가요?",
        "당신이 존경하는 인물은 누구인가요?",
        "당신의 어린 시절 별명은 무엇인가요?"
    ]
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    
    //viewDidLoad
    override func viewDidLoad() {
        self.configureTexFieldAndButton()
        self.configPickerView()
        self.addTouchGesture_stopEditing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    

    //MARK: - 설정 함수
    
    //화면 터치시 키보드 내리는 제스쳐 추가
    func addTouchGesture_stopEditing(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(gesture)
    }
    @objc func handleTap() {
        // 화면이 터치되면 키보드를 내리는 메서드 호출
        view.endEditing(true)
    }
    
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

    
    //Attach ActivityIndicator
    private func attachActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
    }
    
    //Dettach ActivityIndicator
    private func detachActivityIndicator() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        self.activityIndicator.removeFromSuperview()
    }
    
    //configure TextField and Button 함수
    func configureTexFieldAndButton(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        rePasswordTextField.delegate = self
        userNameTextField.delegate = self
        quizTextField.delegate = self
        quizAnswerTextField.delegate = self
        
        self.signUpButton.isEnabled = false
        self.passwordTextField.isSecureTextEntry = true
        self.rePasswordTextField.isSecureTextEntry = true
        self.checkImageView.isHidden = true
    }
    
    
    //MARK: - 회원가입 버튼

    //회원가입 버튼
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let rePassword = rePasswordTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        let quiz = quizTextField.text ?? ""
        let answer = quizAnswerTextField.text ?? ""
        
        if password == rePassword{
            self.signUpWithAPI(email: email, password: password, userName: userName, quiz: quiz, answer: answer)
            print("signUpButtonTapped")
            print("quiz = \(quiz)")
            print("answer = \(answer)")

        }else{
            self.showAlert(title: "비밀번호가 일치하지 않습니다.")
        }
    }
    
    
    //MARK: 회원가입 함수
    
    func signUpWithAPI(email: String, password: String, userName: String, quiz: String, answer: String){
        self.attachActivityIndicator()

        SignUpService.shared.singUp(email: email, password: password, name: userName,resetQuestionIndex: quiz, resetAnswer: answer, completion: {(networkResult) -> Void in
            self.detachActivityIndicator()

            switch networkResult{
            case .success(let data):
                guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {return}
                self.navigationController?.pushViewController(viewController, animated: true)
                
//                if let signUpData = data as? User{
//                    print("회원가입 성공")
//                    // 회원가입 성공
//                    APIConstants.userId = signUpData.user.id
//                    UserDefaults.standard.setValue(signUpData.token, forKey: "token")
//                    UserDefaults.standard.setValue(signUpData.user.id, forKey: "userId")
//                    UserDefaults.standard.setValue("email", forKey: "loginType")
//                    UserDefaults.standard.setValue(false, forKey: "didLogin"
//
//                }else{
//                    print("회원가입 실패")
//                }
                
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
    
    
    //과거 버전
    func signUp_urlSessionVer(email: String, password: String, userName: String){
//        let urlString = "http://172.17.104.130:8080/member/save"
        let urlString = "https://watch.ngrok.app/register"
        
        guard let url = URL(string: urlString) else{
            return
        }
        
        
//        //파라미터 설정 JSON
//        let parameter: [String: Any] = [
//            "memberEmail" : email,
//            "memberPassword" : password,
//            "memberName" : userName
//        ]
        
        //파라미터 설정 JSON
        let parameter: [String: Any] = [
            "user_id" : email,
            "pw" : password,
            "name" : userName
        ]
        
        
        
        //URLRequest 설정
        var request = URLRequest(url:url)
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameter) else {
                    showAlert(title: "파라미터를 변환하는데 실패했습니다.")
                    return
                }
//        if let httpBody = parameter.data(using: .utf8) {
//                    request.httpBody = httpBody
//                } else {
//                    showAlert(title: "파라미터를 변환하는데 실패했습니다.")
//                    return
//        }
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        let task = URLSession.shared.dataTask(with: request){ [weak self](data,response, error) in
            guard let self = self else {return}
            if let error = error{
                let code = (error as NSError).code
                switch code{
                case 17007: //이미 가입한 계정일 때
                    DispatchQueue.main.async {
                        self.showAlert(title: "이미 가입한 계정입니다")
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        self.showAlert(title: "회원가입 에러", message: "\(error.localizedDescription)")
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse{
                    if httpResponse.statusCode == 200{
                        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController else {return}
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }else{
                        self.showAlert(title: "회원가입 실패 \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    //MARK: 기타 함수
    func showAlert(title: String, message: String? = nil) {
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
}




extension SignUpViewController: UITextFieldDelegate{
    //return 키가 눌리면 키보드 내리기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //return 키가 눌렸을 때 동작
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {//사용자가 텍스트 필드의 편집을 완료하고 텍스트 필드가 편집 모드에서 벗어났을 때 호출
        let isEmailEmpty = emailTextField.text == ""
        let isPasswordEmpty = passwordTextField.text == ""
        let isRepasswordEmpty = rePasswordTextField.text == ""
        let isUserNameEmpty = userNameTextField.text == ""
        let isQuizEmpty = quizTextField.text == ""
        let isAnswerEmpty = quizAnswerTextField.text == ""
        
        self.signUpButton.isEnabled = !isEmailEmpty && !isPasswordEmpty && !isRepasswordEmpty && !isUserNameEmpty && !isQuizEmpty && !isAnswerEmpty
        
        if(passwordTextField.text != "" && passwordTextField.text == rePasswordTextField.text){
            self.checkImageView.isHidden = false
        }else{
            self.checkImageView.isHidden = true
        }
    }
}

extension SignUpViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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
