

import UIKit

class ViewController: UIViewController {
    
    var httpRequestManager = HTTPRequestManager()
    
    var tableView = UITableView()
    
    var configList: [Config] = []
    
    var products: [ProductData] = [] {
        didSet{
            tableView.reloadData()
        }
    }
    
    //var merchantCouponisExpanded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        httpRequestManager.delegate = self
        
        setupTableView()

        httpRequestManager.fetchPageData()
        
        tableView.register(TitleCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(MerchantCouponContainerCell.self, forCellReuseIdentifier: "MerchantCouponContainerCell")
        tableView.register(PromoContainerCell.self, forCellReuseIdentifier: "PromoContainerCell")
        tableView.register(GuideContainerCell.self, forCellReuseIdentifier: "GuideContainerCell")
    }
    
    func setupTableView() {
        tableView.showsVerticalScrollIndicator = false
        
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ViewController: HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData) {
        
        self.configList = pageData.data.data.categories[0].config
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        print(configList)
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
        
        tableView.reloadData()
    }
    
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData) {
        
//        self.products = []
//        self.products = productData.data
//        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
//        print(products)
        
//        tableView.reloadData()
    }
    
    func manager(_ manager: HTTPRequestManager, didFailWith error: any Error) {
        print(error)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return configList.count * 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let configIndex = indexPath.row / 2
        let config = configList[configIndex]
        
        if indexPath.row % 2 == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! TitleCell
            cell.configure(with: config.detail)
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            if config.type == "MERCHANT_COUPON" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponContainerCell", for: indexPath) as! MerchantCouponContainerCell
                
                if let merchantCoupons = config.detail.merchantCoupons {
                    cell.configure(with: merchantCoupons)
                    //cell.configure(with: merchantCoupons, isExpanded: merchantCouponisExpanded)
                } else {
                    print("沒有商家優惠券")
                }
                
                cell.delegate = self
                
                cell.selectionStyle = .none
                
                return cell
                
            } else if config.type == "PRODUCT" && config.detail.layout == "HIGHLIGHT"{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PromoContainerCell", for: indexPath) as! PromoContainerCell
                
                
                return cell
                
            } else if config.type == "PRODUCT" && config.detail.layout != nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "PromoContainerCell", for: indexPath) as! PromoContainerCell
                
                cell.configure(with: config.detail)
                
                cell.delegate = self
                
                cell.selectionStyle = .none
                
                return cell
                
            } else if config.type == "GUIDE" {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "GuideContainerCell", for: indexPath) as! GuideContainerCell
                
                if let guides = config.detail.guides {
                    cell.configure(with: guides)
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            return UITableViewCell()
        }
    }
}

//MARK: - Merchant Coupon Container Cell Delegate
extension ViewController: MerchantCouponContainerCellDelegate {
    
    func didSelectMerchantCoupon(_ coupon: MerchantCoupon) {
        let imageVC = MerchantCouponImageViewController()
        imageVC.merchantCoupon = coupon
        
        let navController = UINavigationController(rootViewController: imageVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}

extension ViewController: PromoContainerCellDelegate {
    func shouldDeleteTableViewCell(_ cell: PromoContainerCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            configList.remove(at: indexPath.row / 2)
            tableView.deleteRows(at: [indexPath, previousIndexPath], with: .automatic)
        }
    }
}
