import Foundation

struct APIConstants{
    static let baseURL = "https://095c-218-55-7-205.ngrok-free.app"

    
    
//    static var userId: Int = UserDefaults.standard.integer(forKey: "userId") {
//        willSet(newUserId) {
//            userInfoURL = usersURL + "/\(newUserId)"
//        }
//    }
    
    //MARK: - User

    
    //로그인(post)
    static let logInURL = baseURL + "/loginProc"
    
    //로그아웃(get)
    static let logOutURL = baseURL + "/logout"
    
    //회원가입(post)
    static let signUpURL = baseURL + "/register"
    
    //비밀번호 재설정(post)
    static let resetPasswordURL = baseURL + "/reset-password"
    
    //회원 탈퇴(post)
    static let deleteUserURL = baseURL + "/logindeactivate"
    
    
    //MARK: - 즐겨찾기
    
    //즐겨찾기 추가(post)
    static let addBookmark = baseURL + "/addfavoriteProc"
    
    //즐겨찾기 조회(get)
    static let getBookmark = baseURL + "/addfavoriteList"
    
    //즐겨찾기 삭제(get?)
    static let deleteBookmark = baseURL + "/addfavoriteDelete"
    
    
    //MARK: - 주식
    
    //주식 조회(post)
    static let getStockInfo = baseURL + "/getStockInfo"
    
    //주요지수 가져오기(get)
    static let getIndexInfo = baseURL + "/mainstocks"

    
}


/*
 UserDefaults key : Value
 
 
 key : access_token   |||  value : token 값
 key : refresh_token  |||  value : token 값
 key : token값        |||   value : user 구조체
 key : userID         |||   value : 즐겨찾기 구조체


*/
