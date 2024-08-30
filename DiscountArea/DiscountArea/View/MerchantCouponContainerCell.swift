

import UIKit

protocol MerchantCouponContainerCellDelegate: AnyObject {
    func didSelectMerchantCoupon(_ coupon: MerchantCoupon)
}

class MerchantCouponContainerCell: UITableViewCell {
    
    var merchantCouponTableView = UITableView()
 
    var delegate: MerchantCouponContainerCellDelegate?
    
    var merchantCouponList: [MerchantCoupon] = [] {
        didSet {
            merchantCouponTableView.reloadData()
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var merchantCouponisExpanded = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {

        merchantCouponTableView.dataSource = self
        merchantCouponTableView.delegate = self
        merchantCouponTableView.isScrollEnabled = false
        
        merchantCouponTableView.register(MerchantCouponTableViewCell.self, forCellReuseIdentifier: "MerchantCouponTableViewCell")
        merchantCouponTableView.register(ShowMoreCell.self, forCellReuseIdentifier: "ShowMoreCell")

        contentView.addSubview(merchantCouponTableView)

        merchantCouponTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            merchantCouponTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            merchantCouponTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            merchantCouponTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            merchantCouponTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        merchantCouponTableView.layoutIfNeeded()
        let tableViewHeight = merchantCouponTableView.contentSize.height
        
        return CGSize(width: targetSize.width, height: tableViewHeight)

    }
    
    func configure(with coupons: [MerchantCoupon]) {
        self.merchantCouponList = coupons
    }
}

//MARK: - Merchant Coupon TableView DataSource
extension MerchantCouponContainerCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if merchantCouponisExpanded || merchantCouponList.count <= 5 {
            return merchantCouponList.count
        } else {
            return 6
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !merchantCouponisExpanded && indexPath.row == 5 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMoreCell", for: indexPath) as! ShowMoreCell
            
            cell.setButtonTarget(target: self, action: #selector(showMoreTapped))
            
            let hiddenItemCount = merchantCouponList.count - 5
            cell.updateShowMoreButtonTitle(with: hiddenItemCount)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantCouponTableViewCell", for: indexPath) as! MerchantCouponTableViewCell
            
            let coupon = merchantCouponList[indexPath.row]
            cell.updateCell(from: coupon)
            
            return cell
        }
    }
    
    @objc func showMoreTapped() {
        merchantCouponisExpanded = true
        merchantCouponTableView.reloadData()

        print(merchantCouponTableView.contentSize.height)
        if let tableView = self.superview as? UITableView {
            tableView.beginUpdates()
            tableView.endUpdates()
        }

    }
}

//MARK: - Merchant Coupon TableView Delegate
extension MerchantCouponContainerCell: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let selectedCoupon = merchantCouponList[indexPath.row]
        delegate?.didSelectMerchantCoupon(selectedCoupon)
    }
}

