//
//  HomeViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2021-05-01.
//  Copyright © 2021 Tim Kohmann. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var itemsPerRow: CGFloat {
        let items = Int(view.frame.width / 250)
        return CGFloat(items)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        registerCollectionViewCells()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
    }
    
    private func registerCollectionViewCells() {
        collectionView.register(
            UINib(
                nibName: "CreateQuoteCollectionViewCell",
                bundle: nil),
            forCellWithReuseIdentifier: "CreateQuoteCollectionViewCell"
        )
        
        collectionView.register(
            UINib(
                nibName: "QuoteCollectionViewCell",
                bundle: nil),
            forCellWithReuseIdentifier: "QuoteCollectionViewCell"
        )
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Meine Klimaanlage"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }
    
    @objc func didPullToRefresh() {
        print("Reload")
        collectionView.refreshControl?.endRefreshing()
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CreateQuoteCollectionViewCell",
                for: indexPath
                ) as? CreateQuoteCollectionViewCell else {
                fatalError("Could not create CreateQuoteCollectionViewCell")
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "QuoteCollectionViewCell",
                for: indexPath
                ) as? QuoteCollectionViewCell else {
                fatalError("Could not create QuoteCollectionViewCell")
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfCreateQuoteCells = 4
        return numberOfCreateQuoteCells
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        switch selectedCell {
        case is CreateQuoteCollectionViewCell: break
            
        case is QuoteCollectionViewCell: break //TODO
        default:
            fatalError("Unexpected cell type")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CreateQuoteCollectionViewCell {
            selectedCell.highlightCell()
        } else if let selectedCell = collectionView.cellForItem(at: indexPath) as? QuoteCollectionViewCell {
            selectedCell.highlightCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? CreateQuoteCollectionViewCell {
            selectedCell.unHighlightCell()
        } else if let selectedCell = collectionView.cellForItem(at: indexPath) as? QuoteCollectionViewCell {
            selectedCell.unHighlightCell()
        }
    }
}

extension HomeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        //+ 30 is for label
        return CGSize(width: widthPerItem, height: widthPerItem + 40)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return sectionInsets.left
    }
}
