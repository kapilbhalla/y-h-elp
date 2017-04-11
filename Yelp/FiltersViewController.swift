//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Bhalla, Kapil on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController (filtersViewController: FiltersViewController,
                                didUpdateFilters filters: [String:AnyObject])
}

struct Filter {
    var name: String?
    var value: String?
    var isOn: Bool = false
    
    init(name: String, value: String?, isOn: Bool) {
        self.name = name
        self.value = value
        self.isOn = isOn
    }
}


struct SearchFilters {
    var sortBy: Filter?
    var categories: [Filter]?
    var deals: Filter?
    var distance: Filter?
}


class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
            SwitchCellDelegate, DropDownCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // Devlare and initialize the filters -table view sections
    let sectionTitles = ["", "Distance", "Sort By", "Category"]
    var featuredFilter: [Filter] = [Filter(name: "Offering a Deal", value: "Offering a Deal" , isOn: false)]
    var sortByFilter: [Filter] = [Filter]()
    var distanceFilter: [Filter] = [Filter]()
    var categoryFilter: [Filter] = [Filter]()
    
    var isDistanceFilterCollapsed = true
    var isSortByFilterCollapsed = true
    var showAll = false
    var searchFilters: SearchFilters?

    
    var categories: [[String:String]]!
    weak var delegate: FiltersViewControllerDelegate?
    
    // Dictionary that keeps account of the switch cell for each row.
    var switchStates = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        tableView.dataSource = self
        tableView.delegate = self
        
        initFilters (currentSearchFilter: searchFilters!)

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.barTintColor = UIColor.red
    }

    func initFilters (currentSearchFilter: SearchFilters) {
        if let dealsOn = currentSearchFilter.deals {
            featuredFilter[0].isOn = dealsOn.isOn
        }
        
        self.initSortBy(currentSortBy: currentSearchFilter.sortBy)
        self.initDistance(currentDistance: currentSearchFilter.distance)
        self.initCategories(currentCategories: currentSearchFilter.categories)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onSearchBotton(_ sender: Any) {
        dismiss(animated: true)
        
        // if delegate exists then call the filters view controller method and pass self.
        
        var filters = [String : AnyObject]()
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates {
            
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if (selectedCategories.count > 0) {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    func checkboxChanged(cell: DropDownCell, isChecked: Bool) {
        self.updateFilter(indexPath: cell.cellIndexPath, isOn: isChecked)
    }

    // This is a handler for clocking of the switch cell implemented through protocol
    // the switch cell view has a protocol declared - any one who implements the protocol will get call in the implemented function.
    func switchCell(switchCell: SwitchCell, didChangeValue currentValue: Bool) {
        //let indexPath = tableView.indexPath(for: switchCell)!
        
        //switchStates[indexPath.row] = currentValue
        
        updateFilter(indexPath: switchCell.cellIndexPath, isOn: currentValue)
        
        print ("filters view controller - handler for the switchCell clicking")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFor(tableView: tableView, indexPath: indexPath)
    }

    open func titleForSectionHeader(index: Int) -> String {
        return sectionTitles[index]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rowSelected(indexPath: indexPath)
    }

    
    open func numberOfRowsInSection(section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return  isDistanceFilterCollapsed ? 1 : distanceFilter.count
        case 2:
            return isSortByFilterCollapsed ? 1 : sortByFilter.count
        case 3:
            return showAll ? categoryFilter.count : 8
        default:
            return 0
        }
    }

    
    open func cellFor(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            cell.switchLabel.text = featuredFilter[indexPath.row].name
            //cell.filterSwitch.on = featuredFilter[indexPath.row].isOn
            cell.delegate = self
            cell.cellIndexPath = indexPath
            return cell
            
        case 1:
            if isDistanceFilterCollapsed {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as! DropDownCell
                if (distanceFilter != nil && distanceFilter.count > 0){
                    cell.name.text = distanceFilter.filter({$0.isOn})[0].name
                    cell.iconImage?.image = #imageLiteral(resourceName: "Expand")
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as! DropDownCell
                cell.name.text = distanceFilter[indexPath.row].name
                //cell.delegate = self
                cell.cellIndexPath = indexPath
                
                if distanceFilter[indexPath.row].isOn {
                    cell.iconImage.image = #imageLiteral(resourceName: "Checked-80")
                }
                else {
                    cell.iconImage.image = #imageLiteral(resourceName: "Full Moon Filled-100")
                }
                
                return cell
            }
        case 2:
            if isSortByFilterCollapsed {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as! DropDownCell
                if (sortByFilter != nil && sortByFilter.count > 0){
                    cell.name.text = sortByFilter.filter({$0.isOn})[0].name
                    cell.iconImage?.image = #imageLiteral(resourceName: "Expand")
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell") as! DropDownCell
                cell.name.text = sortByFilter[indexPath.row].name
                //cell.delegate = self
                cell.cellIndexPath = indexPath
                
                if sortByFilter[indexPath.row].isOn {
                    cell.iconImage.image = #imageLiteral(resourceName: "Checked-80")
                }
                else {
                    cell.iconImage.image = #imageLiteral(resourceName: "Full Moon Filled-100")
                }
                
                return cell
            }
            
        case 3:
            
            if !showAll && indexPath.row == 7 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell")
                return cell!
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            if( categoryFilter != nil && categoryFilter.count > 0){
                cell.switchLabel.text = categoryFilter[indexPath.row].name
                cell.onSwitch.isOn = categoryFilter[indexPath.row].isOn
                cell.delegate = self
                cell.cellIndexPath = indexPath
            }
            return cell
            
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            cell.cellIndexPath = indexPath
            cell.delegate = self
            return cell
        }
    }
    
    func filtersUpdated() {
        tableView.reloadData()
    }
    
    func rowSelected(indexPath: IndexPath) {
        
        switch indexPath.section {
        case 1:
            if indexPath.row == 0 {
                if !isDistanceFilterCollapsed {
                    self.updateFilter(indexPath: indexPath)
                }
                isDistanceFilterCollapsed = !isDistanceFilterCollapsed
                filtersUpdated()
            }
            else {
                isDistanceFilterCollapsed = true
                self.updateFilter(indexPath: indexPath)
                filtersUpdated()
            }
            
        case 2:
            
            if indexPath.row == 0 {
                if !isSortByFilterCollapsed {
                    self.updateFilter(indexPath: indexPath)
                }
                isSortByFilterCollapsed = !isSortByFilterCollapsed
                filtersUpdated()
            }
            else {
                isSortByFilterCollapsed = true
                self.updateFilter(indexPath: indexPath)
                filtersUpdated()
            }
        case 3:
            if !showAll && indexPath.row == 7 {
                showAll = true
                filtersUpdated()
            }
            
            
        default: print()
        }
    }

    func updateFilter(indexPath: IndexPath, isOn: Bool = false) {
        switch indexPath.section {
        case 0:
            featuredFilter[indexPath.row].isOn = !featuredFilter[indexPath.row].isOn
        case 1:
            let index = self.distanceFilter.index(where: { $0.isOn })
            
            if indexPath.row != index {
                distanceFilter[index!].isOn = false
                distanceFilter[indexPath.row].isOn = true
            }
            //inform VC to update the table
            filtersUpdated()
            
        case 2:
            
            let index = self.sortByFilter.index(where: { $0.isOn })
            
            if indexPath.row != index {
                sortByFilter[index!].isOn = false
                sortByFilter[indexPath.row].isOn = true
            }
            //inform VC to update the table
            filtersUpdated()
            
        case 3:
            categoryFilter[indexPath.row].isOn = !categoryFilter[indexPath.row].isOn
            
        default: NSLog("Not a valid filter")
        }
    }
    
    func getUpdatedSearchFilter() -> SearchFilters {
        var filter = SearchFilters()
        
        //update deals
        filter.deals = featuredFilter[0]
        
        //update distanceFilter
        let distanceFilter =  self.distanceFilter.filter { $0.isOn }
        filter.distance = distanceFilter[0]
        
        let sortByFilter =  self.sortByFilter.filter { $0.isOn }
        filter.sortBy = sortByFilter[0]
        
        filter.categories = self.categoryFilter.filter { $0.isOn }
        
        return filter
    }
    
    private func initCategories(currentCategories: [Filter]?) {
        for item in yelpCategories() {
            let flag = currentCategories?.filter({ $0.name == item["name"]! }) ?? []
            categoryFilter.append(Filter(name: item["name"]!, value: item["code"], isOn: flag.count > 0))
        }
    }
    
    private func initDistance(currentDistance: Filter?) {
        for item in yelpDistance() {
            distanceFilter.append(Filter(name: item["distance"]!, value: item["meters"], isOn: item["distance"] == currentDistance?.name ? true : false))
        }
    }
    private func initSortBy(currentSortBy: Filter?) {
        sortByFilter.append(Filter(name: "Best Match", value: "0" , isOn: currentSortBy?.value == "0" ? true : false))
        sortByFilter.append(Filter(name: "Distance", value: "1" , isOn: currentSortBy?.value == "1" ? true : false))
        sortByFilter.append(Filter(name: "Highest Rating", value: "2" , isOn: currentSortBy?.value == "2" ? true : false))
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForSectionHeader(index: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Background color
        view.tintColor = UIColor.white
        view.backgroundColor = UIColor.white
        
        // Text Color
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = UIColor.darkGray
    }
    
    func yelpDistance() -> [[String:String]]  {
        return   [["distance" : "Auto", "meters": "-1"],
                  ["distance" : "0.3 Miles", "meters": "483"],
                  ["distance" : "1 Miles", "meters": "1609"],
                  ["distance" : "5 Miles", "meters": "8047"],
                  ["distance" : "20 Miles", "meters": "32187"]]
    }
    
    func yelpCategories () ->  [[String:String]] { return [["name" : "Afghan", "code": "afghani"],
                      ["name" : "African", "code": "african"],
                      ["name" : "American, New", "code": "newamerican"],
                      ["name" : "American, Traditional", "code": "tradamerican"],
                      ["name" : "Arabian", "code": "arabian"],
                      ["name" : "Argentine", "code": "argentine"],
                      ["name" : "Armenian", "code": "armenian"],
                      ["name" : "Asian Fusion", "code": "asianfusion"],
                      ["name" : "Asturian", "code": "asturian"],
                      ["name" : "Australian", "code": "australian"],
                      ["name" : "Austrian", "code": "austrian"],
                      ["name" : "Baguettes", "code": "baguettes"],
                      ["name" : "Bangladeshi", "code": "bangladeshi"],
                      ["name" : "Barbeque", "code": "bbq"],
                      ["name" : "Basque", "code": "basque"],
                      ["name" : "Bavarian", "code": "bavarian"],
                      ["name" : "Beer Garden", "code": "beergarden"],
                      ["name" : "Beer Hall", "code": "beerhall"],
                      ["name" : "Beisl", "code": "beisl"],
                      ["name" : "Belgian", "code": "belgian"],
                      ["name" : "Bistros", "code": "bistros"],
                      ["name" : "Black Sea", "code": "blacksea"],
                      ["name" : "Brasseries", "code": "brasseries"],
                      ["name" : "Brazilian", "code": "brazilian"],
                      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                      ["name" : "British", "code": "british"],
                      ["name" : "Buffets", "code": "buffets"],
                      ["name" : "Bulgarian", "code": "bulgarian"],
                      ["name" : "Burgers", "code": "burgers"],
                      ["name" : "Burmese", "code": "burmese"],
                      ["name" : "Cafes", "code": "cafes"],
                      ["name" : "Cafeteria", "code": "cafeteria"],
                      ["name" : "Cajun/Creole", "code": "cajun"],
                      ["name" : "Cambodian", "code": "cambodian"],
                      ["name" : "Canadian", "code": "New)"],
                      ["name" : "Canteen", "code": "canteen"],
                      ["name" : "Caribbean", "code": "caribbean"],
                      ["name" : "Catalan", "code": "catalan"],
                      ["name" : "Chech", "code": "chech"],
                      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                      ["name" : "Chicken Shop", "code": "chickenshop"],
                      ["name" : "Chicken Wings", "code": "chicken_wings"],
                      ["name" : "Chilean", "code": "chilean"],
                      ["name" : "Chinese", "code": "chinese"],
                      ["name" : "Comfort Food", "code": "comfortfood"],
                      ["name" : "Corsican", "code": "corsican"],
                      ["name" : "Creperies", "code": "creperies"],
                      ["name" : "Cuban", "code": "cuban"],
                      ["name" : "Curry Sausage", "code": "currysausage"],
                      ["name" : "Cypriot", "code": "cypriot"],
                      ["name" : "Czech", "code": "czech"],
                      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                      ["name" : "Danish", "code": "danish"],
                      ["name" : "Delis", "code": "delis"],
                      ["name" : "Diners", "code": "diners"],
                      ["name" : "Dumplings", "code": "dumplings"],
                      ["name" : "Eastern European", "code": "eastern_european"],
                      ["name" : "Ethiopian", "code": "ethiopian"],
                      ["name" : "Fast Food", "code": "hotdogs"],
                      ["name" : "Filipino", "code": "filipino"],
                      ["name" : "Fish & Chips", "code": "fishnchips"],
                      ["name" : "Fondue", "code": "fondue"],
                      ["name" : "Food Court", "code": "food_court"],
                      ["name" : "Food Stands", "code": "foodstands"],
                      ["name" : "French", "code": "french"],
                      ["name" : "French Southwest", "code": "sud_ouest"],
                      ["name" : "Galician", "code": "galician"],
                      ["name" : "Gastropubs", "code": "gastropubs"],
                      ["name" : "Georgian", "code": "georgian"],
                      ["name" : "German", "code": "german"],
                      ["name" : "Giblets", "code": "giblets"],
                      ["name" : "Gluten-Free", "code": "gluten_free"],
                      ["name" : "Greek", "code": "greek"],
                      ["name" : "Halal", "code": "halal"],
                      ["name" : "Hawaiian", "code": "hawaiian"],
                      ["name" : "Heuriger", "code": "heuriger"],
                      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                      ["name" : "Hot Dogs", "code": "hotdog"],
                      ["name" : "Hot Pot", "code": "hotpot"],
                      ["name" : "Hungarian", "code": "hungarian"],
                      ["name" : "Iberian", "code": "iberian"],
                      ["name" : "Indian", "code": "indpak"],
                      ["name" : "Indonesian", "code": "indonesian"],
                      ["name" : "International", "code": "international"],
                      ["name" : "Irish", "code": "irish"],
                      ["name" : "Island Pub", "code": "island_pub"],
                      ["name" : "Israeli", "code": "israeli"],
                      ["name" : "Italian", "code": "italian"],
                      ["name" : "Japanese", "code": "japanese"],
                      ["name" : "Jewish", "code": "jewish"],
                      ["name" : "Kebab", "code": "kebab"],
                      ["name" : "Korean", "code": "korean"],
                      ["name" : "Kosher", "code": "kosher"],
                      ["name" : "Kurdish", "code": "kurdish"],
                      ["name" : "Laos", "code": "laos"],
                      ["name" : "Laotian", "code": "laotian"],
                      ["name" : "Latin American", "code": "latin"],
                      ["name" : "Live/Raw Food", "code": "raw_food"],
                      ["name" : "Lyonnais", "code": "lyonnais"],
                      ["name" : "Malaysian", "code": "malaysian"],
                      ["name" : "Meatballs", "code": "meatballs"],
                      ["name" : "Mediterranean", "code": "mediterranean"],
                      ["name" : "Mexican", "code": "mexican"],
                      ["name" : "Middle Eastern", "code": "mideastern"],
                      ["name" : "Milk Bars", "code": "milkbars"],
                      ["name" : "Modern Australian", "code": "modern_australian"],
                      ["name" : "Modern European", "code": "modern_european"],
                      ["name" : "Mongolian", "code": "mongolian"],
                      ["name" : "Moroccan", "code": "moroccan"],
                      ["name" : "New Zealand", "code": "newzealand"],
                      ["name" : "Night Food", "code": "nightfood"],
                      ["name" : "Norcinerie", "code": "norcinerie"],
                      ["name" : "Open Sandwiches", "code": "opensandwiches"],
                      ["name" : "Oriental", "code": "oriental"],
                      ["name" : "Pakistani", "code": "pakistani"],
                      ["name" : "Parent Cafes", "code": "eltern_cafes"],
                      ["name" : "Parma", "code": "parma"],
                      ["name" : "Persian/Iranian", "code": "persian"],
                      ["name" : "Peruvian", "code": "peruvian"],
                      ["name" : "Pita", "code": "pita"],
                      ["name" : "Pizza", "code": "pizza"],
                      ["name" : "Polish", "code": "polish"],
                      ["name" : "Portuguese", "code": "portuguese"],
                      ["name" : "Potatoes", "code": "potatoes"],
                      ["name" : "Poutineries", "code": "poutineries"],
                      ["name" : "Pub Food", "code": "pubfood"],
                      ["name" : "Rice", "code": "riceshop"],
                      ["name" : "Romanian", "code": "romanian"],
                      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                      ["name" : "Rumanian", "code": "rumanian"],
                      ["name" : "Russian", "code": "russian"],
                      ["name" : "Salad", "code": "salad"],
                      ["name" : "Sandwiches", "code": "sandwiches"],
                      ["name" : "Scandinavian", "code": "scandinavian"],
                      ["name" : "Scottish", "code": "scottish"],
                      ["name" : "Seafood", "code": "seafood"],
                      ["name" : "Serbo Croatian", "code": "serbocroatian"],
                      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                      ["name" : "Singaporean", "code": "singaporean"],
                      ["name" : "Slovakian", "code": "slovakian"],
                      ["name" : "Soul Food", "code": "soulfood"],
                      ["name" : "Soup", "code": "soup"],
                      ["name" : "Southern", "code": "southern"],
                      ["name" : "Spanish", "code": "spanish"],
                      ["name" : "Steakhouses", "code": "steak"],
                      ["name" : "Sushi Bars", "code": "sushi"],
                      ["name" : "Swabian", "code": "swabian"],
                      ["name" : "Swedish", "code": "swedish"],
                      ["name" : "Swiss Food", "code": "swissfood"],
                      ["name" : "Tabernas", "code": "tabernas"],
                      ["name" : "Taiwanese", "code": "taiwanese"],
                      ["name" : "Tapas Bars", "code": "tapas"],
                      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                      ["name" : "Tex-Mex", "code": "tex-mex"],
                      ["name" : "Thai", "code": "thai"],
                      ["name" : "Traditional Norwegian", "code": "norwegian"],
                      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                      ["name" : "Trattorie", "code": "trattorie"],
                      ["name" : "Turkish", "code": "turkish"],
                      ["name" : "Ukrainian", "code": "ukrainian"],
                      ["name" : "Uzbek", "code": "uzbek"],
                      ["name" : "Vegan", "code": "vegan"],
                      ["name" : "Vegetarian", "code": "vegetarian"],
                      ["name" : "Venison", "code": "venison"],
                      ["name" : "Vietnamese", "code": "vietnamese"],
                      ["name" : "Wok", "code": "wok"],
                      ["name" : "Wraps", "code": "wraps"],
                      ["name" : "Yugoslav", "code": "yugoslav"]]
    }
}
