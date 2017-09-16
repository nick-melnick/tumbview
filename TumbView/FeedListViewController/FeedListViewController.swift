//
//  FeedListViewController.swift
//  TumbView
//
//  Created by Nick Melnick on 9/15/17.
//  Copyright © 2017 Nick Melnick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreData
import ADMozaicCollectionViewLayout
import PullToRefresh

private let reuseIdentifier = "PhotoCell"

let padding:CGFloat = 2.0

enum ADMozaikLayoutType {
    case portrait
    case landscape
}

class FeedListViewController: UICollectionViewController {

    var viewModel: FeedListViewModel!
    
    fileprivate var landscapeLayout: ADMozaikLayout!
    fileprivate var portraitLayout: ADMozaikLayout!
    
    fileprivate let refresher = PullToRefresh()
    
    var shouldReloadCollectionView = true
    var blockOperation: BlockOperation!

    override func viewDidLoad() {
        super.viewDidLoad()

        landscapeLayout = ADMozaikLayout(delegate: self)
        portraitLayout = ADMozaikLayout(delegate: self)
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        // Register cell classes
        self.collectionView?.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.addPullToRefresh(refresher, action: { [weak self] in
            self?.viewModel.getNewPosts({ [weak self] in
                self?.collectionView?.endRefreshing(at: .top)
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getNewPosts()
        self.setCollectionViewLayout(animated: true, ofType: view.frame.width > view.frame.height ? .landscape : .portrait)
    }
    
    deinit {
        collectionView?.removePullToRefresh(collectionView!.topPullToRefresh!)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = viewModel.numberOfSections()
        return count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.itemsIn(section: section)
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.itemFor(collectionView:collectionView,forCellAtIndexPath:indexPath)
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItemIn(collectionView: collectionView, atIndexPath: indexPath)
    }
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension FeedListViewController: ADMozaikLayoutDelegate {

    //MARK: - Orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: nil, animation: nil) { (context) in
            self.setCollectionViewLayout(animated: false, ofType: size.width > size.height ? .landscape : .portrait)
        }
    }
    
    private var portraitLayoutGeometryInfo: ADMozaikLayoutSectionGeometryInfo {
        let columnsCount:Int = 2
        let width:CGFloat = collectionView!.bounds.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let paddings:CGFloat = padding * CGFloat(columnsCount) - padding
        let widthItem:CGFloat = (width - paddings) / CGFloat(columnsCount)
        let heightItem = widthItem
        var columns:[ADMozaikLayoutColumn] = []
        for _ in 1...columnsCount {
            columns.append(ADMozaikLayoutColumn(width: widthItem))
        }
        let geometryInfo = ADMozaikLayoutSectionGeometryInfo(rowHeight: heightItem,
                                                             columns: columns,
                                                             minimumInteritemSpacing: padding,
                                                             minimumLineSpacing: padding)
        
        return geometryInfo
    }
    
    private var landscapeLayoutGeometryInfo: ADMozaikLayoutSectionGeometryInfo {
        let columnsCount:Int = 3
        let width:CGFloat = collectionView!.bounds.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let paddings:CGFloat = padding * CGFloat(columnsCount) - padding
        let widthItem:CGFloat = (width - paddings) / CGFloat(columnsCount)
        let heightItem = widthItem
        var columns:[ADMozaikLayoutColumn] = []
        for _ in 1...columnsCount {
            columns.append(ADMozaikLayoutColumn(width: widthItem))
        }
        let geometryInfo = ADMozaikLayoutSectionGeometryInfo(rowHeight: heightItem,
                                                             columns: columns,
                                                             minimumInteritemSpacing: padding,
                                                             minimumLineSpacing: padding)
        
        return geometryInfo
    }
    
    //MARK: - ADMozaikLayoutDelegate
    
    func collectonView(_ collectionView: UICollectionView, mozaik layout: ADMozaikLayout, geometryInfoFor section: ADMozaikLayoutSection) -> ADMozaikLayoutSectionGeometryInfo {
        if collectionView.frame.width > collectionView.frame.height {
            return landscapeLayoutGeometryInfo
        } else {
            return portraitLayoutGeometryInfo
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, mozaik layout: ADMozaikLayout, mozaikSizeForItemAt indexPath: IndexPath) -> ADMozaikLayoutSize {
        return ADMozaikLayoutSize(numberOfColumns: 1, numberOfRows: 1)
    }
    
    //MARK: - Helpers
    
    fileprivate func setCollectionViewLayout(animated: Bool, ofType type: ADMozaikLayoutType) {
        collectionView?.collectionViewLayout.invalidateLayout()
        if type == .landscape {
            collectionView?.setCollectionViewLayout(self.landscapeLayout, animated: animated)
        } else {
            collectionView?.setCollectionViewLayout(self.portraitLayout, animated: animated)
        }
    }
    
    
}

extension FeedListViewController:NSFetchedResultsControllerDelegate {
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            collectionView?.reloadData()
    }
}
