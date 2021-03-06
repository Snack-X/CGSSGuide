//
//  DonationViewController.swift
//  CGSSGuide
//
//  Created by zzk on 2017/1/3.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit
import SnapKit
import GoogleMobileAds

class DonationViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var questionView1: DonationQAView!
    var questionView2: DonationQAView!

    var cv: UICollectionView!
    var gadBanner: GADBannerView!
    
    var products = [SKProduct]()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        // requestData()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    func prepareUI() {
        
        self.navigationItem.title = NSLocalizedString("捐赠", comment: "")
        
        questionView1 = DonationQAView()
        view.addSubview(questionView1)
        questionView1.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(74)
        }
        
        questionView2 = DonationQAView()
        view.addSubview(questionView2)
        questionView2.snp.makeConstraints { (make) in
            make.left.right.equalTo(questionView1)
            make.top.equalTo(questionView1.snp.bottom).offset(10)
        }
        
        questionView1.setup(question: NSLocalizedString("为什么会有这个页面？", comment: ""), answer: NSLocalizedString("CGSSGuide是一款免费应用，现在以及未来都不会增加任何需要收费开启的功能，也不会加入任何影响您使用的广告。CGSSGuide的开发和后端服务器的维护需要您的支持，如果您喜欢这款应用，请支持我们。", comment: ""))
        
        questionView2.setup(question: NSLocalizedString("捐赠的钱款将用在什么地方？", comment: ""), answer: NSLocalizedString("您的捐赠将用于CGSSGuide所使用的后端服务器费用，域名使用费用，开发者账号费用，以及服务器未来升级所需费用。", comment: ""))
        
        gadBanner = GADBannerView()
        view.addSubview(gadBanner)
        gadBanner.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.bottom.equalToSuperview()
        }
        
        // Replace this ad unit ID with your own ad unit ID.
        gadBanner.adUnitID = "ca-app-pub-6074651551939465/6109538639"
        gadBanner.rootViewController = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "105debdd40b3a6aa8e160e0f2cb4997f"]
        
        gadBanner.load(request)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize.init(width: (Screen.width - 30) / 2, height: 80)
        cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        view.addSubview(cv)
        cv.snp.makeConstraints { (make) in
            make.top.equalTo(questionView2.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(80)
        }
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = UIColor.white
        cv.register(DonationCell.self, forCellWithReuseIdentifier: "DonationCell")
        
        
        let bannerDescLabel = UILabel()
        view.addSubview(bannerDescLabel)
        bannerDescLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(gadBanner.snp.top).offset(-10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        bannerDescLabel.textColor = UIColor.darkGray
        bannerDescLabel.font = UIFont.light(size: 14)
        bannerDescLabel.numberOfLines = 0
        bannerDescLabel.textAlignment = .center
        bannerDescLabel.text = NSLocalizedString("您也可以通过点击下方的广告来支持我们。", comment: "")
    }
    
    var hud: LoadingImageView?
    func requestData() {
        let request = SKProductsRequest.init(productIdentifiers: Config.iAPProductId)
        request.delegate = self
        hud = LoadingImageView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        hud?.show(to: self.cv)
        request.start()
    }
    
    
    func reloadData() {
        self.cv.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: UICollectionViewDelegate & DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "DonationCell", for: indexPath) as! DonationCell
        
        let product = products[indexPath.item]
        cell.setup(amount: (product.priceLocale.currencySymbol ?? "") + product.price.stringValue, desc: product.localizedTitle)
        
        switch indexPath.item {
        case 0:
            cell.borderColor = Color.cool.cgColor
        case 1:
            cell.borderColor = Color.cute.cgColor
        default:
            break
        }
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        
        if SKPaymentQueue.canMakePayments() {
            CGSSLoadingHUDManager.default.show()
            SKPaymentQueue.default().add(SKPayment.init(product: product))
        } else {
            let alert = UIAlertController.init(title: NSLocalizedString("提示", comment: ""), message: NSLocalizedString("您的设备未开启应用内购买。", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.tabBarController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: StoreKitDelegate

extension DonationViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products.sorted(by: { $0.price.decimalValue < $1.price.decimalValue })
        DispatchQueue.main.async {
            self.hud?.hide()
            self.reloadData()
        }
    }
    
}


// MARK: StoreKitTransactionObserver
extension DonationViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                completeTransaction(transaction)
                finishTransaction(transaction)
            case .failed:
                failedTransaction(transaction)
                finishTransaction(transaction)
            case .restored:
                restoreTransaction(transaction)
                finishTransaction(transaction)
            case .deferred:
                finishTransaction(transaction)
            case .purchasing:
                break
            }
        }
    }
    
    
    func completeTransaction(_ transaction: SKPaymentTransaction) {
        
    }
    
    func failedTransaction(_ transaction: SKPaymentTransaction) {
        
    }
    
    func restoreTransaction(_ transaction: SKPaymentTransaction) {
        
    }
    
    func finishTransaction(_ transaction: SKPaymentTransaction) {
        CGSSLoadingHUDManager.default.hide()
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}



