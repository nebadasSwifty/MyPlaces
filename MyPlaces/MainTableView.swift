//
//  MainTableView.swift
//  MyPlaces
//
//  Created by Кирилл on 08.05.2022.
//

import UIKit

class MainTableView: UITableViewController {

    let restarauntNames = ["NEBAR", "New Bar", "Alibi", "На работе",
                           "Огонёк", "Бла бла бар", "AIR", "Гастроли",
                           "А ты где?", "Свой бар", "Негодяи"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restarauntNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = restarauntNames[indexPath.row]
        cell.imageView?.image = UIImage(named: restarauntNames[indexPath.row])
        return cell
    }
    
}
