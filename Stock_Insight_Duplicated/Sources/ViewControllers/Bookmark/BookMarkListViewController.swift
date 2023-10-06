//
//  BookMarkListViewController.swift
//  stock Insight
//
//  Created by 이현호 on 2023/05/15.
//

import UIKit
import SwiftYFinance


class BookMarkListViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var bookmarkList: [Bookmark] = []
    let refreshControl = UIRefreshControl()
    var predictStockData: PredictStock?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.color = .blue
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    //UserDefaults Test
    func USERDEFAULTSTEST_get(){
        if let data = UserDefaults.standard.data(forKey: "1"){
            let one = data as? Int
            print("===============================")
            print("USERDEFAULTSTEST_get ---> \(one)")
        }
    }
  
    //viweDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.USERDEFAULTSTEST_get()
        configureCollectionView()
//        getBookmarkStockList_dummy()
        
        getBookmarkList()
    }
    
    //viewWillAppead
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        getBookmarkList()
    }
    

    //MARK: - 설정 함수
    
    //collection layout 및 기본 설정 함수
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        refreshControl.endRefreshing()
    }

    //Attach ActivityIndicator
    private func attachActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }

    //Dettach ActivityIndicator
    private func detachActivityIndicator() {
        if self.activityIndicator.isAnimating {
            self.activityIndicator.stopAnimating()
        }
        self.activityIndicator.removeFromSuperview()
    }
    
    //MARK: - 데이터 관련 함수
    
    //즐겨찾기 데이터 가져오기
    func getBookmarkList(){
        guard let userID = UserManager.shared.getUserID() else {return}
        print("BookMarkListViewConTroller - getBookmarkList")
        print("userID = \(userID)")
        
        if let bookmarkListEncoded = UserDefaults.standard.data(forKey: userID){
            print("bookmarkListEncoded = \(bookmarkListEncoded)")
            let bookmarkListDecoded = try? JSONDecoder().decode([Bookmark].self, from: bookmarkListEncoded)
            print("BookmarkListViewController getBookMarkList() -> bookmarkList: \(bookmarkListDecoded)")
            if bookmarkListDecoded != nil{
                self.bookmarkList = bookmarkListDecoded!
                self.collectionView.reloadData()
            }else{
                self.bookmarkList = []
            }

        }
        return
    }
    
    //종목 검색 함수
    func searchStockWithAPI(stockName: String){
        self.attachActivityIndicator()
        GetStockService.shared.getStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let presentStockData = data as? StockInfo2 else {return}
                self.getPredictStock(stockCode: presentStockData.stockInfo.stockCode, stockInfo: presentStockData.stockInfo, isSearch: true)
                guard let stockName = self.predictStockData?.stockName else {return}
                
            case .requestErr(let msg):
                //API 시간 초과
                if let message = msg as? String {
                    print(message)
                }
                
            case .pathErr:
                print("pathErr in searchStockWithAPI")
            case .serverErr:
                print("serverErr in searchStockWithAPI")
            case .networkFail:
                print("networkFail in searchStockWithAPI")
            default:
                print("networkFail in searchStockWithAPI")
            }
        })
    }

    //하나의 예측 주가 데이터 구조체로 함치는 함수
    func getPredictStock(stockCode: String, stockInfo: StockInfo, isSearch: Bool){
        //var stockDataFromYF = GetStockFromYFService.shared.getStockDataFromYF(stockCode: stockCode)
        
        var predict5Price_before = stockInfo.predict5Prices
        var predict10Price_before = stockInfo.predict10Prices
        
        let symbol = stockCode + ".KS" // ".KS"는 한국 주식 시장을 나타냅니다.
        var stockData = [[Date: Double]]()
        
        // 시작 및 종료 날짜 설정
        let dateFormatter_onlyDate = DateFormatter()
        dateFormatter_onlyDate.dateFormat = "yyyy-MM-dd"
        
        let dateFormatter_DateAndTime = DateFormatter()
        dateFormatter_DateAndTime.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
        
        let startDate = dateFormatter_onlyDate.date(from: "2023-01-01")
        let endDate = Date()
        
        let calendar = Calendar.current
        
        // PredictedPrice 배열을 [[Date: Double]] 형태로 변환
        let predict5Price_transformed: [[Date: Double]] = predict5Price_before.compactMap { predict5Price_before in
            if let dateString = predict5Price_before.date,
               let priceString = predict5Price_before.price,
               let date = convertToDate(dateString),
               let price = Double(priceString) {
                return [date: price]
            }
            return nil
        }
        
        print("stockCode : \(stockCode)'s predict5Price_transformed = \(predict5Price_transformed)")
        
        let predict10Price_transformed: [[Date: Double]] = predict10Price_before.compactMap { predict10Price_before in
            if let dateString = predict10Price_before.date,
               let priceString = predict10Price_before.price,
               let date = convertToDate(dateString),
               let price = Double(priceString) {
                return [date: price]
            }
            return nil
        }
        
        print("stockCode : \(stockCode)'s predict10Price_transformed = \(predict10Price_transformed)")
        
        // 종가 데이터 가져오기
        SwiftYFinance.chartDataBy(identifier: symbol, start: startDate!, end: endDate, interval: .oneday){
            data, error in
            if let chartData = data{
                let transformedData: [[Date: Double]] = chartData.compactMap { data in
                    guard let date = data.date, let close = data.close else {
                        return [Date: Double]() // 날짜나 종가 데이터가 없으면 무시
                    }
                    return [date: Double(close)]
                }
                stockData = transformedData
                
                let predictStockData = PredictStock(stockName: stockInfo.stockName,
                                                    stockCode: stockInfo.stockCode,
                                                    currentPrice: stockInfo.currentPrice,
                                                    change: stockInfo.change,
                                                    changePercentage: stockInfo.changePercentage,
                                                    newsUrl: stockInfo.newsUrl,
                                                    magazineUrl: stockInfo.magazineUrl,
                                                    economistUrl: stockInfo.economistUrl,
                                                    predict5_Data: transformedData + predict5Price_transformed,
                                                    predict10_Data: transformedData + predict10Price_transformed,
                                                    predictSentiment: stockInfo.sentiment,
                                                    current_Data: transformedData)
                
                self.predictStockData = predictStockData
                self.detachActivityIndicator()
                
                
                guard let viewController = self.storyboard?.instantiateViewController(identifier: "StockDetailViewController") as? StockDetailViewController else {return}
                viewController.predictStockData = self.predictStockData
                self.navigationController?.pushViewController(viewController, animated: true)
//                print("self.predictStockData.predict5_Data = \(predictStockData.predict5_Data)")
                
//                print("transformedData = \(transformedData)")
            }
        }
        
        
        // 문자열을 Date로 변환하는 함수
        func convertToDate(_ dateString: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: dateString)
        }
    }
    
    

    
    //즐겨찾기에 넣을 더미 데이터 생성 함수
    private func getBookmarkStockList_dummy(){
        let stockName1 = "삼성전자"
        let stockNumber1 = "A005930 코스피"
        let bookmarkStock1 = Bookmark(stockName: stockName1, stockCode: stockNumber1)
        self.bookmarkList.append(bookmarkStock1)
//        let stockName2 = "애플"
//        let stockNumber2 = "US.PEGY 나스닥"
//        let stockImage2: UIImage = UIImage(imageLiteralResourceName: "apple_Icon")
//        let bookmarkStock2 = BookMarkStock(stockName: stockName2, stockNumber: stockNumber2, stockImage: stockImage2)
//        self.bookMarkStockList.append(bookmarkStock2)
//        let stockName3 = "마이크로소프트"
//        let stockNumber3 = "US.MSFT 나스닥"
//        let stockImage3: UIImage = UIImage(imageLiteralResourceName: "ms_Icon")
//        let bookmarkStock3 = BookMarkStock(stockName: stockName3, stockNumber: stockNumber3, stockImage: stockImage3)
//        self.bookMarkStockList.append(bookmarkStock3)
//        let stockName4 = "현대차"
//        let stockNumber4 = "A005380 코스피"
//        let stockImage4: UIImage = UIImage(imageLiteralResourceName: "hyundai_Icon")
//        let bookmarkStock4 = BookMarkStock(stockName: stockName4, stockNumber: stockNumber4, stockImage: stockImage4)
//        self.bookMarkStockList.append(bookmarkStock4)
    }
}


extension BookMarkListViewController: UICollectionViewDataSource{
    //collectionView item 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.bookmarkList.count
    }
    
    //cell 반환
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCollectionViewCell", for: indexPath) as? StarCollectionViewCell else {return UICollectionViewCell()}
        cell.nameLabel.text = self.bookmarkList[indexPath.row].stockName
        cell.stockCodeLabel.text = self.bookmarkList[indexPath.row].stockCode
        return cell
    }
}

extension BookMarkListViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var stockName = self.bookmarkList[indexPath.row].stockName
        self.searchStockWithAPI(stockName: stockName)
    }
}


extension BookMarkListViewController: UICollectionViewDelegateFlowLayout{
    //collectionView 레이아웃 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width) , height: 50)
    }
}
