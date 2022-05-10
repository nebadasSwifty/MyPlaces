//
//  MainTableView.swift
//  MyPlaces
//
//  Created by Кирилл on 08.05.2022.
//

import UIKit
import RealmSwift

class MainTableView: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let searchController = UISearchController(searchResultsController: nil)
    private var ascendingSorting = true
    private var filtredPlaces: Results<Place>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    private var places: Results<Place>!
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortingSegment: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Place.self)
        //Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    @IBAction func saveAction(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        var place = Place()
        if isFiltering {
            place = filtredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.nameLabel.text = place.name
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }

    
    //MARK: - Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { _, _ in
            StorageManager.removeObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let place: Place
            if isFiltering {
                place = filtredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        sorting()
    }
    @IBAction func reversedSortingAction(_ sender: UIBarButtonItem) {
        ascendingSorting.toggle()
        if ascendingSorting {
            reversedSortingButton.image = UIImage(systemName: "arrow.down")
        } else {
            reversedSortingButton.image = UIImage(systemName: "arrow.up")
        }
        sorting()
    }
    private func sorting() {
        if sortingSegment.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
}

//MARK: - Search Bar
extension MainTableView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
