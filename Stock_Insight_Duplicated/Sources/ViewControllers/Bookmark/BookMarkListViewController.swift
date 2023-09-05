//
//  BookMarkListViewController.swift
//  stock Insight
//
//  Created by 이현호 on 2023/05/15.
//

import UIKit


class BookMarkListViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var bookmarkList: [Bookmark] = []
    let refreshControl = UIRefreshControl()
    
  
    //viweDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
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

    
    //MARK: - 데이터 관련 함수
    
    //즐겨찾기 데이터 가져오기
    func getBookmarkList(){
        guard let userID = UserManager.shared.getUser()?.user_id else {return}
        
        if let bookmarkListEncoded = UserDefaults.standard.data(forKey: userID){
            let bookmarkListDecoded = try? JSONDecoder().decode([Bookmark].self, from: bookmarkListEncoded)
            print("BookmarkListViewController getBookMarkList() -> bookmarkList:\(bookmarkListDecoded)")
            self.bookmarkList = bookmarkListDecoded!
            self.collectionView.reloadData()
        }
        return
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
        cell.settingCell()
        return cell
    }
}

extension BookMarkListViewController: UICollectionViewDelegate{
}


extension BookMarkListViewController: UICollectionViewDelegateFlowLayout{
    //collectionView 레이아웃 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width) , height: 50)
    }
}
