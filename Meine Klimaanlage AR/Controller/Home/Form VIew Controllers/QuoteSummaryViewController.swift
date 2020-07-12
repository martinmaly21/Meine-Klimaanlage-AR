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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewQuoteTableViewCell") as? QuoteSummaryTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}
