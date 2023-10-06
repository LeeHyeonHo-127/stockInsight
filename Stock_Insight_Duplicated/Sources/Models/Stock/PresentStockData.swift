import Foundation

struct PresentStockData: Codable{
    var currentPrice: Double
    var change: Double
    var stockCode: String
    var newsURL: String
    var magazineURL: String
    var economisURL: String
}


struct PresentStockData_Dummy{
    var currentPrice: Double
    var change: Double
    var stockCode: String
    var newsURL: String
    var magazineURL: String
    var economisURL: String
}
