

import UIKit

class ViewController: UIViewController {
    
    var httpRequestManager = HTTPRequestManager()
    
    var merchantCouponTableView = UITableView()
    
    var configList: [Config] = []
    
    var merchantCouponList: [MerchantCoupon] = []
    
    var merchantCouponisExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        merchantCouponTableView.dataSource = self
        merchantCouponTableView.delegate = self
        httpRequestManager.delegate = self
        
        merchantCouponTableView.register(MerchantCouponTableViewCell.self, forCellReuseIdentifier: "MerchantCouponTableViewCell")
        merchantCouponTableView.register(ShowMoreCell.self, forCellReuseIdentifier: "ShowMoreCell")
        
        setupTableView()
        
        httpRequestManager.fetchPageData()
//        httpRequestManager.fetchProductData(productList: ["2247",
//                                                          "38965",
//                                                          "138901"])
    }
    
    func setupTableView() {
        merchantCouponTableView.showsVerticalScrollIndicator = false
        
        view.addSubview(merchantCouponTableView)
        
        merchantCouponTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            merchantCouponTableView.topAnchor.constraint(equalTo: view.topAnchor),
            merchantCouponTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            merchantCouponTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            merchantCouponTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
        self.configList = pageData.data.data.categories[2].config
        print(configList)
        
        if let merchantCouponConfig = configList.first(where: { $0.type == "MERCHANT_COUPON" }) {
            
            if let merchantCoupons = merchantCouponConfig.detail.merchantCoupons {
                self.merchantCouponList = merchantCoupons
                
            } else {
                print("沒有商家優惠券")
            }
        } else {
            print("該國家類別無 MERCHANT_COUPON")
        }
        print(self.merchantCouponList)
        merchantCouponTableView.reloadData()
        merchantCouponisExpanded = false
    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if merchantCouponisExpanded || self.merchantCouponList.count <= 5 {
            return self.merchantCouponList.count
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !merchantCouponisExpanded && indexPath.row == 5 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreCell", for: indexPath) as! ShowMoreCell
            
            cell.setButtonTarget(target: self, action: #selector(showMoreTapped))
            
            let hiddenItemCount = self.merchantCouponList.count - 5
            cell.updateShowMoreButtonTitle(with: hiddenItemCount)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponTableViewCell", for: indexPath) as! MerchantCouponTableViewCell
            
            let coupon = self.merchantCouponList[indexPath.row]
            cell.updateCell(from: coupon)
            
            return cell
        }
    }
    
    @objc func showMoreTapped() {
        merchantCouponisExpanded = true
        merchantCouponTableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let merchantCoupon = merchantCouponList[indexPath.row]
        
        let imageVC = MerchantCouponImageViewController()
        imageVC.merchantCoupon = merchantCoupon
        
        let navController = UINavigationController(rootViewController: imageVC)
        
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}

