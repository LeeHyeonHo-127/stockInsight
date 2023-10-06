import Foundation


struct IndexURLStrings: Codable{
    var KOSPI: String
    var KOSDAQ: String
    var KOSPI200: String
}

struct IndexURLs{
    var KOSPI: URL
    var KOSDAQ: URL
    var KOSPI200: URL
}

struct IndexData{
    var KOSPI: [[Date : Double]]
    var KOSDAQ: [[Date : Double]]
    var KOSPI200: [[Date: Double]]
}

struct IndexDataString: Codable{
    var name: String
    var value: String
    var csvUrl: String
}


/*
 judgeSearchStock in JSON String: [{"name":"KOSPI","value":"Saved to CSV","csvUrl":"http://localhost:3000/download/KOSPI_data.csv"},{"name":"KOSDAQ","value":"Saved to CSV","csvUrl":"http://localhost:3000/download/KOSDAQ_data.csv"},{"name":"KOSPI200","value":"Saved to CSV","csvUrl":"http://localhost:3000/download/KOSPI200_data.csv"}]
 pathErr in getIndexWithAPI
 */
