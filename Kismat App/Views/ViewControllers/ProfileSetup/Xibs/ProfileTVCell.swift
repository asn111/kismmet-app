//
//  ProfileTVCell.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 11/02/2023.
//

import UIKit
import CountryPickerView

class ProfileTVCell: UITableViewCell {

    
    @IBOutlet weak var toolTipBtn: UIButton!
    @IBOutlet weak var numberView: RoundCornerView!
    @IBOutlet weak var numberTF: FormTextField!
    @IBOutlet weak var countryPickerView: CountryPickerView!
    @IBOutlet weak var generalTFView: RoundCornerView!
    @IBOutlet weak var generalTF: FormTextField!
    @IBOutlet weak var lockTipBtn: UIButton!
    
    var phoneCode = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCountryCode(code: String = "+1") {
        
        //let indexPath = IndexPath(row: placeholderArray.count, section: 0)
        //let cell = self.profileTV.cellForRow(at: indexPath) as! ProfileTFCell
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        //countryPickerView.tag = 1
        countryPickerView.showCountryNameInView = false
        countryPickerView.showPhoneCodeInView = false
        countryPickerView.showCountryCodeInView = false
        countryPickerView.setCountryByPhoneCode(code)
        countryPickerView.setCountryByName(countryPickerView.countries.filter { country in
            country.phoneCode == code
        }.first?.name ?? "United States")
        phoneCode = countryPickerView.selectedCountry.phoneCode
        Logs.show(message: "\(countryPickerView.selectedCountry.phoneCode) ,, \(countryPickerView.selectedCountry.code)")
        
    }
}
//MARK: CountryPicker Extentions
extension ProfileTVCell: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        let message = "Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)"
        phoneCode = country.phoneCode
        generalPublisher.onNext(country.phoneCode)
        Logs.show(message: "\(message)")
    }
}

extension ProfileTVCell: CountryPickerViewDataSource {
    func preferredCountries(in countryPickerView: CountryPickerView) -> [Country] {
        if countryPickerView.tag == countryPickerView.tag {
            return countryPickerView.countries
        }
        return []
    }
    
    func sectionTitleForPreferredCountries(in countryPickerView: CountryPickerView) -> String? {
        if countryPickerView.tag == countryPickerView.tag {
            return "Preferred title"
        }
        return nil
    }
    
    func showOnlyPreferredSection(in countryPickerView: CountryPickerView) -> Bool {
        return countryPickerView.tag == countryPickerView.tag
    }
    
    func navigationTitle(in countryPickerView: CountryPickerView) -> String? {
        return "Select a Country"
    }
    
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .tableViewHeader
    }
    
}



