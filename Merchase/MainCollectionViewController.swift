//
//  MainCollectionViewController.swift
//  Merchase
//
//  Created by Sam Patzer on 6/19/19.
//  Copyright © 2019 wizage. All rights reserved.
//

import UIKit
import AWSMobileClient

private let reuseIdentifier = "Item"

extension ListItemsQuery.Data.ListItem.Item : Hashable{
    public static func == (lhs: ListItemsQuery.Data.ListItem.Item, rhs: ListItemsQuery.Data.ListItem.Item) -> Bool {
        return lhs.id == rhs.id;
    }
    
    public func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var cartButton : CartButtonItem!
    
    enum Section{
        case main
    }
    
    
    
    private var pagenation : String = ""
    private var numberOfRows = 0
    private var cartNumber = 0
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItemsQuery.Data.ListItem.Item>! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //Login first if not logged in.
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                switch(userState){
                    case .signedOut:
                        AWSMobileClient.sharedInstance()
                            .showSignIn(navigationController: self.navigationController!,
                                        signInUIOptions: SignInUIOptions(
                                            canCancel: false,
                                            logoImage: UIImage(named: "MyCustomLogo"),
                                            backgroundColor: UIColor.black)) { (result, err) in
                                                //handle results and errors
                    }
                    default:
                        print("logged in")
                }
                
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        configureDataSource()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //cartButton.addBadge(number: 2)
    }
    
    func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, ListItemsQuery.Data.ListItem.Item>(collectionView: self.collectionView){ (collectionView: UICollectionView, indexPath: IndexPath, identifier:ListItemsQuery.Data.ListItem.Item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                                for: indexPath) as! ProductCollectionViewCell
            cell.backgroundColor = .blue
            cell.text.text = "\(identifier.name)"
            return cell
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.appSyncClient.fetch(query: ListItemsQuery(limit:20), cachePolicy: .fetchIgnoringCacheData){(results, error) in
            self.pagenation = results?.data?.listItems?.nextToken ?? ""
            self.numberOfRows = results?.data?.listItems?.items?.count ?? 0
            let snapshot = NSDiffableDataSourceSnapshot<Section, ListItemsQuery.Data.ListItem.Item>()
            snapshot.appendSections([.main])
            snapshot.appendItems((results?.data?.listItems?.items)! as! [ListItemsQuery.Data.ListItem.Item])
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (pagenation != "" && numberOfRows-1 == indexPath.row+10){
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.appSyncClient.fetch(query: ListItemsQuery(limit: 20, nextToken: pagenation), cachePolicy: .fetchIgnoringCacheData){(results, error) in
                self.numberOfRows = self.numberOfRows + (results?.data?.listItems?.items?.count ?? 0)
                self.pagenation = results?.data?.listItems?.nextToken ?? ""
                let snapshot = self.dataSource.snapshot()
                snapshot.appendItems((results?.data?.listItems?.items)! as! [ListItemsQuery.Data.ListItem.Item])
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: (screenWidth/3)-6, height: (screenWidth/3)-6);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
 

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
*/
    // MARK: UICollectionViewDelegate

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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //add stuff to cart
        cartNumber = cartNumber + 1
        cartButton.updateBadge(number: cartNumber)
    }

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
