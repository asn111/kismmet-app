//
//  TagsView VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 23/05/2023.
//

import UIKit

class TagsView_VC: MainViewController {

    
    @IBOutlet weak var tagsTV: UITableView!
    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    
    var tagList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headingLbl.text = "#TAGS"
        registerCells()
    }

    func registerCells() {
        
        tagsTV.tableFooterView = UIView()
        tagsTV.separatorStyle = .none
        tagsTV.delegate = self
        tagsTV.dataSource = self
        tagsTV.register(UINib(nibName: "hashTagsTVCell", bundle: nil), forCellReuseIdentifier: "hashTagsTVCell")
        
    }


}

//MARK: TableView Extention
extension TagsView_VC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : hashTagsTVCell = tableView.dequeueReusableCell(withIdentifier: "hashTagsTVCell", for: indexPath) as! hashTagsTVCell
        
        cell.tagsLbl.text = tagList[indexPath.row].capitalized.trimmingCharacters(in: .whitespaces)
        cell.tagsLbl.isUserInteractionEnabled = false

        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

