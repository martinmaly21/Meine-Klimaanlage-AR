//
//  HomeViewController.swift
//  Meine Klimaanlage AR
//
//  Created by Martin Maly on 2020-06-07.
//  Copyright © 2020 Tim Kohmann. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    //MARK: - UI
    @IBOutlet weak var collectionView: UICollectionView!
    
     //MARK: - Data
    let brands: [ACBrand] = [.daikin, .mitsubishiMotors, .panasonic]
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private var itemsPerRow: CGFloat {
        let items = Int(view.frame.width / 250)
        return CGFloat(items)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Home"
        
        registerCollectionViewCells()
    }
    
    private func registerCollectionViewCells() {
        collectionView.register(UINib(nibName: "ACUnitBrandsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ACUnitBrandsCollectionViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ACUnitSegue",
            let sender = sender as? ACUnitBrandsCollectionViewCell,
            let detailPage = segue.destination as? ACUnitListViewController {
            detailPage.title = sender.brand.rawValue
            detailPage.brand = sender.brand
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ACUnitBrandsCollectionViewCell",
            for: indexPath
            ) as? ACUnitBrandsCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setUpCell(with: brands[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return brands.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ACUnitBrandsCollectionViewCell else { return }
        
        if brands[indexPath.row] == .panasonic {
            performSegue(withIdentifier: "ACUnitSegue", sender: selectedCell)
        } else {
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ACUnitBrandsCollectionViewCell else { return }
        selectedCell.highlightCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? ACUnitBrandsCollectionViewCell else { return }
        selectedCell.unHighlightCell()
    }
}

extension HomeViewController : UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = availableWidth / itemsPerRow

    //+ 30 is for label
    return CGSize(width: widthPerItem, height: widthPerItem + 40)
  }

    
  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}
