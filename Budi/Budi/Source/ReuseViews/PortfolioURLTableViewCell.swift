//
//  PortfolioURLTableViewCell.swift
//  Budi
//
//  Created by 인병윤 on 2021/12/26.

import UIKit
import Combine

class PortfolioURLTableViewCell: UITableViewCell {

    static let cellId = "PortfolioURLTableViewCell"
    var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var portfolioUrlFaviconImageView: UIImageView!
    @IBOutlet weak var portfolioUrlLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func configureParsing(urlString: String) {
        portfolioUrlLabel.text = urlString
        guard let url = URL(string: urlString) else { return }
        switch url.host {
        case "www.behance.net":
            portfolioUrlFaviconImageView.image = UIImage(named: "Behance")
        case "www.linkedin.com":
            portfolioUrlFaviconImageView.image = UIImage(named: "Linkedin")
        case "www.instagram.com":
            portfolioUrlFaviconImageView.image = UIImage(named: "Instagram")
        default:
            portfolioUrlFaviconImageView.image = UIImage(named: "Others")
        }
    }
}
