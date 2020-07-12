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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }

    private func setUpTableView() {
        tableView.register(UINib(nibName: "PreviewQuoteTableViewCell", bundle: nil), forCellReuseIdentifier: "PreviewQuoteTableViewCell")
    }

}

extension QuoteSummaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PreviewQuoteTableViewCell") as? PreviewQuoteTableViewCell else {
            return UITableViewCell()
        }
        
        return cell
    }
}
