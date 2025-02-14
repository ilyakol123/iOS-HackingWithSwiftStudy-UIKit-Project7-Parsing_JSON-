//
//  ViewController.swift
//  Project 7 (UIKit)
//
//  Created by Илья Колесников on 10.02.2025.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var originalPetitions: [Petition] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showCredits))
        navigationItem.leftBarButtonItems = [ UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(resetSearch)),UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(findPetition)) ]
        
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    parse(json: data)
                    return
                }
            }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            originalPetitions = petitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showError() {
            let ac = UIAlertController(title: "Loading error", message: "Loading problems occurred", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "This is using the public API", message: "We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func findPetition() {
        let ac = UIAlertController(title: "Find a Petition", message: "Enter a keyword to search for a petition", preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            guard let searchingPetition = ac?.textFields?[0].text else { return }
            self?.search(searchingPetition)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func search(_ keyword: String) {
        
        DispatchQueue.global().async {
            let filteredPetitions = self.petitions.filter { $0.title.lowercased().contains(keyword.lowercased()) }
            self.petitions = filteredPetitions
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    @objc func resetSearch() {
        petitions = originalPetitions
        tableView.reloadData()
    }

}

