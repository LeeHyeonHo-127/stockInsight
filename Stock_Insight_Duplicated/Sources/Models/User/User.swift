import Foundation
import UIKit

// MARK: - User

struct User: Codable{
    var user_id: String
    var pw: String
    var name: String
}

class UserManager {
    static let shared = UserManager()
    
    private var user: User?

    
    func setUser(_ newUser: User) {
        user = newUser
    }
    
    func deleteUser(){
        user = nil
    }
    
    func getUser() -> User? {
        return user
    }
    
    func getUserID() -> String?{
        return user?.user_id
    }
    
    func getUserName() -> String?{
        return user?.name
    }

    
    func setUserName(name : String){
        user?.name = name
    }
}

