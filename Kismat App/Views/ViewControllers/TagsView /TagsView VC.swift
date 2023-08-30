//
//  TagsView VC.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 23/05/2023.
//

import UIKit
import UIMultiPicker

class TagsView_VC: MainViewController {

    
    @IBOutlet weak var tagsTV: UITableView!
    
    @IBOutlet weak var reportBtn: RoundCornerButton!
    @IBOutlet weak var pickerView: UIView!
    
    @IBOutlet weak var headingLbl: fullyCustomLbl!
    
    @IBOutlet weak var multiPickerView: UIMultiPicker!
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        //setupMultiPickerView()
        self.presentVC(id: "ReportDialogVC", presentFullType: "no" ) { (vc:ReportDialogVC) in
            vc.userId = userId
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        /*pickerView.isHidden = true
        AppFunctions.showSnackBar(str: "Thanks for taking time to let us know.\nYour report is submitted")*/
    }
    
    var tagList = [String]()
    var reasonsList = [ReportReasonsModel]()
    var reasonsListName = [String]()
    var selectedReasonsAray = [Int]()
    
    var isFromOther = false
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getReasons()
        headingLbl.text = "#TAGS"
        registerCells()
        if isFromOther {
            reportBtn.isHidden = false
        }
    }

    func registerCells() {
        
        tagsTV.tableFooterView = UIView()
        tagsTV.separatorStyle = .none
        tagsTV.delegate = self
        tagsTV.dataSource = self
        tagsTV.register(UINib(nibName: "hashTagsTVCell", bundle: nil), forCellReuseIdentifier: "hashTagsTVCell")
        
    }

    func setupMultiPickerView() {
        
        pickerView.isHidden = false
        multiPickerView.options = reasonsListName
        
        multiPickerView.addTarget(self, action: #selector(selected(_:)), for: .valueChanged)
        
        multiPickerView.color = .darkGray
        multiPickerView.tintColor = .black
        multiPickerView.font = .systemFont(ofSize: 18, weight: .semibold)
        
        multiPickerView.highlight(0, animated: false)
    }
    @objc func selected(_ sender: UIMultiPicker) {
        
        Logs.show(message: "Selected Index: \(sender.selectedIndexes)")
        
        selectedReasonsAray = sender.selectedIndexes
        Logs.show(message: "Selected REASONS: \(selectedReasonsAray)")
        
    }
    
    //MARK: API METHODS
    
    func getReasons() {
        
        
        APIService
            .singelton
            .getReportReasons()
            .subscribe({[weak self] model in
                guard let self = self else {return}
                switch model {
                    case .next(let val):
                        AppFunctions.setIsNotifCheck(value: false)
                        if val.count > 0 {
                            self.reasonsList = val
                            self.reasonsListName = self.reasonsList.map({$0.reason})
                        } else {
                            self.hidePKHUD()
                        }
                    case .error(let error):
                        print(error)
                        self.hidePKHUD()
                    case .completed:
                        print("completed")
                        self.hidePKHUD()
                }
            })
            .disposed(by: dispose_Bag)
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

