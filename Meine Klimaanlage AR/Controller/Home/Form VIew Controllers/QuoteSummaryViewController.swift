//
//  QuoteSummaryViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-07-12.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit

class QuoteSummaryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    public var quote: ACQuote!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        setUpTableView()
    }
    
    private func updateUI() {
        self.title = "Quote Summary"
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationItem.setHidesBackButton(true, animated: true)
    }

    private func setUpTableView() {
        tableView.register(UINib(nibName: "QuoteSummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteSummaryTableViewCell")
    }

}

extension QuoteSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteSummaryTableViewCell") as? QuoteSummaryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.setUpCell(with: quote)
        cell.quoteSummaryCellDelegate = self
        
        return cell
    }
}

extension QuoteSummaryViewController: QuoteSummaryCellDelegate {
    func userPressedPhoto(with image: UIImage) {
        imageTapped(with: image)
    }
    
    @IBAction func imageTapped(with image: UIImage) {
        let newImageView = UIImageView(image: image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        let swipe = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        newImageView.addGestureRecognizer(swipe)
        
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
}
