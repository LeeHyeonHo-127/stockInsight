import UIKit
import Charts

class StockDetailViewController: UIViewController, ChartViewDelegate {
    
    //label, textfield
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var stockNameLabel: UILabel!
    @IBOutlet var stockCodeLabel: UILabel!
    @IBOutlet var presentPriceLabel: UILabel!
    @IBOutlet var changePriceLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    @IBOutlet var firstChartViewStateLabel: UILabel!
    
    
    @IBOutlet var secondChartViewPrice: UILabel!
    @IBOutlet var secondChartViewStateLabel: UILabel!
    @IBOutlet var secondChartViewStateLabel2: UILabel!
    @IBOutlet var secondChartViewChangePriceLabel: UILabel!
    @IBOutlet var secondChartViewChangePercentageLabel: UILabel!
    @IBOutlet var changeChartViewAcrossImageView: UIImageView!
    
    
    
    
    //button
    @IBOutlet var presentPriceButton: UIButton!
    @IBOutlet var LSTMButton: UIButton!
    @IBOutlet var sentimentalButton: UIButton!
    
    @IBOutlet var presentPriceButton2: UIButton!
    @IBOutlet var predict5DayButton: UIButton!
    @IBOutlet var predict10DayButton: UIButton!
    
    
    
    //view
    @IBOutlet var predicePriceView: UIView!
    @IBOutlet var indexView: UIView!
    
    //charView
    var predictLineChartView: LineChartView!
    var indexLineChartView: LineChartView!
    
    //data
    var presentStockData: Stock?
    
    //dummy
    var gradientColor = UIColor.stockInsightBlue
    var datasetName: String = "5d_predict_SE00"
    
    var presentStockData_Dummy: Stock_Dummy?



    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingView()
        self.makeStarButton()
        
        //ChartView 설정
        self.predictLineChartView = configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .presentPrice)
        self.indexLineChartView = configureChartView(isPredict: true, color: UIColor.systemYellow,chartDataType: .presentPrice)
        self.predicePriceView.addSubview(predictLineChartView)
        self.indexView.addSubview(indexLineChartView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = .black
    }
    
    //MARK: - 설정 함수
    
    //뷰 세팅
    func settingView(){
        guard let currentPrice = self.presentStockData_Dummy?.currentPrice else {return}
        guard let change = self.presentStockData_Dummy?.change else {return}
        let changePrice = 1600
        
        //현재 주가 데이터 출력
        self.stockNameLabel.text = "현대차"
        self.stockCodeLabel.text = self.presentStockData_Dummy?.stockCode
        self.presentPriceLabel.text = "\(Int(currentPrice))"
        self.changePriceLabel.text = "+\(changePrice)(\(change)%)"
        self.arrowImageView.image = UIImage(systemName: "arrow.up")
        
        //corner layer 설정
        self.presentPriceButton.layer.cornerRadius = 5
        self.LSTMButton.layer.cornerRadius = 5
        self.sentimentalButton.layer.cornerRadius = 5
        self.presentPriceButton2.layer.cornerRadius = 5
        self.predict5DayButton.layer.cornerRadius = 5
        self.predict10DayButton.layer.cornerRadius = 5
        self.predicePriceView.layer.cornerRadius = 5
        self.indexView.layer.cornerRadius = 5
    }
    
    //즐겨찾기 버튼 추가
    func makeStarButton(){
        var isbookmarked = false
        print("StockDetailViewController _ makeStarButton in")
        
        //현재 종목이 즐겨찾기된 종목인지 확인후 즐겨찾기 버튼 설정
        if let bookmarkList = self.getBookmarkList(){
            print("StockDetailViewController _ bookmarkList = \(bookmarkList)")
            bookmarkList.forEach{
                if($0.stockCode == self.presentStockData_Dummy?.stockCode){
                    let starButton = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: self, action: #selector(starButtonTapped))
                    self.navigationItem.rightBarButtonItem = starButton
                    self.navigationItem.rightBarButtonItem?.tintColor = .systemYellow
                    print("StockDetailViewController _ makeStarButton _ 이 종목은 즐겨찾기에 있는 종목 떄문에 별이 색칠!")
                    isbookmarked = true
                    return
                }
            }
        }
        
        if (isbookmarked == false){
            print("StockDetailViewController _ makeStarButton | 현재 종목은 즐겨찾기한 종목이 아님")
            //현재 종목이 즐겨찾기 된 종목이 아니라면
            let starButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(starButtonTapped))
            self.navigationItem.rightBarButtonItem = starButton
        }
        
     
    }
    
    //즐겨찾기 버튼이 눌렸을 시 동작하는 함수
    @objc func starButtonTapped() {
        if self.navigationItem.rightBarButtonItem?.image == UIImage(systemName: "star") {
            self.addBookmark()
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star.fill")
            self.navigationItem.rightBarButtonItem?.tintColor = .systemYellow
            }
        else {
            self.deleteBookmark()
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
            self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        }
    }
    
    //chartView 생성
    func configureChartView(isPredict: Bool, color: UIColor, chartDataType: ChartDataType ) -> LineChartView{
        let gradient = fillGradient()
        let data = setDataEntry()
        let lineChartView = setLineChartView()
        lineChartView.delegate = self
        return lineChartView
        
        // 그라디언트 채우기 설정
        func fillGradient()-> CGGradient{
            let gradientColor = color
            let gradientColors = [gradientColor.cgColor, UIColor.black.cgColor] as CFArray
            let colorLocations: [CGFloat] = [1.0, 0.0]
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                            colors: gradientColors,
                                            locations: colorLocations) else {
                fatalError("그라디언트 생성 실패했습니다.")
            }
            return gradient
        }
        
        // 데이터 엔트리 생성
        func setDataEntry() -> LineChartData{
            var entries: [ChartDataEntry] = []
            var stockData: [[Date: Double]]? = []
            
            switch chartDataType{
            case .presentPrice:
                stockData = self.presentStockData_Dummy?.Prices
            case .predict5day:
                stockData = self.presentStockData_Dummy?.dayFivePrices
            case .predict10day:
                stockData = self.presentStockData_Dummy?.dayTenPrices
            default:
                stockData = parseCSVFile(datasetName: "5d_predict_SE00")
            }
            
            
            
            //x,y 값 생성
            for entry in stockData! {
                if let date = entry.keys.first, let value = entry.values.first {
                    let xValue = date.timeIntervalSince1970
                    let yValue = value
                    let dataEntry = ChartDataEntry(x: xValue, y: yValue)
                    
                    entries.append(dataEntry)
                }
            }
            
            
            // 데이터셋 생성
            let dataSet = LineChartDataSet(entries: entries, label: "data")
            dataSet.gradientPositions
            dataSet.setColor(color) // 그래프 선 색상 설정
            dataSet.lineWidth = 1.0 // 그래프 선 두께 설정
            dataSet.drawCirclesEnabled = false // 데이터 포인트에 원형 마커 표시 여부 설정
            dataSet.drawValuesEnabled = true //
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true // 채우기 활성화
            dataSet.mode = .cubicBezier
            dataSet.cubicIntensity = 0.2
            
            // 데이터 배열 설정
            let data = LineChartData(dataSet: dataSet)
            return data
        }
        
        //lineChartView 생성
        func setLineChartView()->LineChartView{
            // 차트 뷰 설정
            var lineChartView = LineChartView(frame: self.predicePriceView.bounds)
            lineChartView.translatesAutoresizingMaskIntoConstraints = false //autoLayout 지정 속성_ fals = autuLayout 사용
            lineChartView.contentMode = .scaleToFill
            
            //차트 뷰 데이터 설정
            lineChartView.data = data
            
            //차트 뷰 grid 설정
            lineChartView.xAxis.drawGridLinesEnabled = false
            lineChartView.leftAxis.drawGridLinesEnabled = false
            
            
            //차트 뷰 뷰 설정
            lineChartView.xAxis.labelPosition = .bottom // x축 레이블 위치 설정
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: []) // x축 레이블 포맷터 설정 (일단 빈 값으로 설정)
            lineChartView.rightAxis.enabled = false // 오른쪽 축 비활성화
            lineChartView.leftAxis.enabled = false
            lineChartView.legend.enabled = false // 범례 비활성화
            lineChartView.chartDescription.enabled = false // 차트 설명 비활성화
            lineChartView.pinchZoomEnabled = true        // 핀치 줌 기능 비활성화
            lineChartView.scaleXEnabled = true           // X축 스케일 기능 비활성화
            lineChartView.scaleYEnabled = true           // Y축 스케일 기능 비활성화
            lineChartView.doubleTapToZoomEnabled = true
            lineChartView.isUserInteractionEnabled = true
            lineChartView.noDataText = "" //데이터 없을 때 보일 문자열
            lineChartView.xAxis.valueFormatter = DateAxisValueFormatter()
            lineChartView.xAxis.labelCount = 0 // x축 레이블 개수 설정
            lineChartView.xAxis.granularity = 0 // x축 레이블 간격 설정
            lineChartView.xAxis.labelRotationAngle = 0 // x축 레이블 회전 설정
            
            if lineChartView.scaleX >= 2.0 && lineChartView.scaleY >= 2.0 {
                print("==============TRUE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(true) // 그래프에 값 표시 활성화
            } else {
                print("==============FALSE=========================")
                print("scaleX = \(lineChartView.scaleX), scaleY = \(lineChartView.scaleY)")
                lineChartView.data?.setDrawValues(false) // 그래프에 값 표시 비활성화
            }
            
            if chartDataType == .predict5day || chartDataType == .predict10day {
                let dateString = "2023/06/07"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let date = dateFormatter.date(from: dateString)
                let doubleValue = date?.timeIntervalSince1970
                
                let limitLine = ChartLimitLine(limit: doubleValue!, label: "") // 특정 x 값에 대한 제한선 생성
                limitLine.lineWidth = 1 // 제한선의 너비 설정
                limitLine.lineColor = .systemRed // 제한선의 색상 설정
                lineChartView.xAxis.addLimitLine(limitLine) // 제한선을 왼쪽 축에 추가
                lineChartView.notifyDataSetChanged()
                lineChartView.setNeedsDisplay()
            }
            
//            //descrpitionLabel
//            descriptionLabel.font = .systemFont(ofSize: 15, weight: .bold)
//            descriptionLabel.textColor = .black
//            contentView.addSubview(descriptionLabel)
//            descriptionLabel.snp.makeConstraints {
//                $0.centerX.equalToSuperview()
//                $0.top.equalToSuperview().offset(10)
//            }
            // 터치 제스처 추가
    //            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleChartTap(_:)))
    //            lineChartView.addGestureRecognizer(tapGesture)
    //
            return lineChartView
        }
    }
    
    
    
    //MARK: - 버튼 함수
    
    //현재 주가 버튼1
    @IBAction func presentPriceButtonTapped(_ sender: Any) {

        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.stockInsightBlue, chartDataType: .presentPrice)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.presentPriceButton.backgroundColor = .darkGray
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .black
    }
    
    //LSTM 예측 버튼
    @IBAction func LSTMPredictButtonTapped(_ sender: Any) {
        
        self.predictLineChartView.removeFromSuperview()
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemYellow, chartDataType: .predict5day)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .darkGray
        self.sentimentalButton.backgroundColor = .black
    }
    
    //감성분석 예측 버튼
    @IBAction func sentimentalPredictButtonTapped(_ sender: Any) {
        self.predictLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .presentPrice)
        self.predicePriceView.addSubview(self.predictLineChartView)
        
        
        self.presentPriceButton.backgroundColor = .black
        self.LSTMButton.backgroundColor = .black
        self.sentimentalButton.backgroundColor = .darkGray
    }
    
    //현재 주가 버튼 2
    @IBAction func presentPriceButton2Tapped(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSPI)
        self.indexView.addSubview(self.indexLineChartView)
        
        
        self.presentPriceButton2.backgroundColor = .darkGray
        self.predict5DayButton.backgroundColor = .black
        self.predict10DayButton.backgroundColor = .black
    
    }
    
    //5일 예측 버튼
    @IBAction func predict5DayButton(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSDAQ)
        self.indexView.addSubview(self.indexLineChartView)
        
        
        self.presentPriceButton2.backgroundColor = .black
        self.predict5DayButton.backgroundColor = .darkGray
        self.predict10DayButton.backgroundColor = .black
    }
    
    //10일 예측 버튼
    @IBAction func predict10DayButton(_ sender: Any) {
        self.indexLineChartView.removeFromSuperview()
        self.indexLineChartView = self.configureChartView(isPredict: true, color: UIColor.systemGreen, chartDataType: .KOSPI200)
        self.indexView.addSubview(self.indexLineChartView)
        
        self.presentPriceButton2.backgroundColor = .black
        self.predict5DayButton.backgroundColor = .black
        self.predict10DayButton.backgroundColor = .darkGray
    }
    
    
    
    
    //MARK: - Data 관련 함수
    
    //즐겨찾기 추가 함수
    func addBookmark(){
        guard let userID = UserManager.shared.getUser()?.user_id else {return}
        print("addBookMark _ userID : \(userID)")
        
        guard let stockName = self.presentStockData_Dummy?.stockName else {return}
        guard let stockCode = self.presentStockData_Dummy?.stockCode else {return}
        let bookmark = Bookmark(stockName: stockName, stockCode: stockCode)
        
        
        var bookmarkList = self.getBookmarkList()
        
        //bookmarkList가 비었다면
        if bookmarkList == nil || bookmarkList!.isEmpty{
            let makeBookmarkList: [Bookmark] = [bookmark]
            print("addBookmark = 새로만든 makrBookmarkList = \(makeBookmarkList)")
            if let newBookmarkList = try? JSONEncoder().encode(makeBookmarkList) {
                UserDefaults.standard.set(newBookmarkList, forKey: userID)
                print("addBookMark _ newBookMarkList : \(newBookmarkList)")
            }
        }
        //bookmarkList가 비어있지 않다면
        else{
            bookmarkList!.append(bookmark)
            print("addBookMark _ 추가한 bookmarkList : \(bookmarkList)")
            
            if let bookmarkListEncoded = try? JSONEncoder().encode(bookmarkList!) {
                UserDefaults.standard.set(bookmarkListEncoded, forKey: userID)
                print("addBookMark _ bookmarkListEncoded : \(bookmarkListEncoded)")
            }
            UserDefaults.standard.setValue(bookmarkList, forKey: userID)
        }
    }
    
    //즐겨찾기 삭제 함수
    func deleteBookmark(){
        guard let userID = UserManager.shared.getUser()?.user_id else {return}
        print("deleteBookmark _ userID : \(userID)")
        
        guard let stockName = self.presentStockData_Dummy?.stockName else {return}
        guard let stockCode = self.presentStockData_Dummy?.stockCode else {return}
        let bookmark = Bookmark(stockName: stockName, stockCode: stockCode)
        
        var bookmarkList = self.getBookmarkList()
        
        if bookmarkList != nil{
            print("deleteBookmark _ 삭제하기 전 bookmarkList = \(bookmarkList)")
            bookmarkList?.removeAll{$0.stockCode == self.presentStockData_Dummy?.stockCode}
            print("deleteBookmark _ 삭제한 후 bookmarkList = \(bookmarkList)")
            
            if let bookmarkListEncoded = try? JSONEncoder().encode(bookmarkList!) {
                UserDefaults.standard.set(bookmarkListEncoded, forKey: userID)
                print("deleteBookmark _ bookmarkListEncoded : \(bookmarkListEncoded)")
            }
            return
        }
        
        print("deleteBookmark _ bookmarkList 는 비었습니다.")
    }
    
    //즐겨찾기 데이터 가져오기
    func getBookmarkList() -> [Bookmark]?{
        guard let userID = UserManager.shared.getUser()?.user_id else {return nil}
        
        if let bookmarkListEncoded = UserDefaults.standard.data(forKey: userID){
            let bookmarkListDecoded = try? JSONDecoder().decode([Bookmark].self, from: bookmarkListEncoded)
            print("StockDetailViewController_ getBookMarkList() -> bookmarkList:\(bookmarkListDecoded)")
            return bookmarkListDecoded
        }
        return nil
    }

    
    //종목 검색 함수
    func searchStockWithAPI(stockName: String){
        GetStockService.shared.getStock(stockName: stockName, completion: { (networkResult) in
            switch networkResult{
            case.success(let data):
                guard let searchData = data as? Stock else {return}
                self.presentStockData = searchData
                
                //종목 상세화면으로 이동 함수
                
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
    
    
    //MARK: - 기타 함수
    
    //CSV 파싱 함수
    func parseCSVFile(datasetName: String) -> [[Date: Double]] {
        var dictionaryArray: [[Date: Double]] = []

        guard let path = Bundle.main.path(forResource: datasetName, ofType: "csv") else {
            return dictionaryArray
        }

        do {
            let csvString = try String(contentsOfFile: path, encoding: .utf8)
            let lines = csvString.components(separatedBy: "\n")

            let trimmedLines = lines.map { line -> String in
                var trimmedLine = line
                if let commaIndex = line.firstIndex(of: ",") {
                    let startIndex = line.index(after: commaIndex)
                    trimmedLine = String(line[startIndex...])
                }
                return trimmedLine
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"

            for line in trimmedLines[1...] {
                let temp = line.components(separatedBy: ",")
                let fields = temp.map { $0.replacingOccurrences(of: "\r", with: "") }

                if let dateString = fields.first, let valueString = fields.last,
                   let date = dateFormatter.date(from: dateString),
                   let value = Double(valueString) {
                    let dictionary: [Date: Double] = [date: value]
                    dictionaryArray.append(dictionary)
                }
            }
        } catch {
            print("Error reading CSV file: \(error)")
        }
        return dictionaryArray
    }
    
    
}



