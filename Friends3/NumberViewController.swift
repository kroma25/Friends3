//
//  NumberViewController.swift
//  Frindes2
//
//  Created by Przemyslaw Kromólski on 10/02/2020.
//  Copyright © 2020 Przemyslaw Kromólski. All rights reserved.
// #1 Wstępne ustawienia
// https://www.ioscreator.com/tutorials/customizing-table-view-ios-tutorial
// #2 Przycisk dodawanie i odejmowanie
// https://www.youtube.com/watch?v=Wu5l4e5uW4w
// #3 Przyciski i
// https://www.youtube.com/watch?v=wUVfE8cY2Hw
// #4 CoreData
// https://wojciechkulik.pl/ios/getting-started-with-core-data-using-swift-4
// #5 Subtitle
// https://www.ralfebert.de/ios-examples/uikit/uitableviewcontroller/#cell_styles
// #6 max wartość w tablicy
// https://www.hackingwithswift.com/example-code/language/how-to-find-the-highest-value-in-an-array
// #7 cell
// https://stackoverflow.com/questions/26561461/outlets-cannot-be-connected-to-repeating-content-ios
// #8 cell cutom
// https://www.youtube.com/watch?v=l2Ld-EA9FAU
// #9 problem z wyskakujacym komunikatem w konsoli
// https://stackoverflow.com/questions/25902288/detected-a-case-where-constraints-ambiguously-suggest-a-height-of-zero
//#10 timer do wyliczenia DialDT
// https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
//#11 Update and delete
// https://www.youtube.com/watch?v=XH-osAmaU5E
//#12 alert 
// https://www.youtube.com/watch?v=HNLQaQyw5xo
//#13 alert z picardview
// https://stackoverflow.com/questions/43505011/set-textfield-and-pickerview-in-uialertview
//#14 dodanie ikonki zamista napisu
// https://stackoverflow.com/questions/29335104/how-add-custom-image-to-uitableview-cell-swipe-to-delete
//#15 widok odzielnej karty,cien i zakrąglenie
// https://www.youtube.com/watch?v=ZEuoaTF1bok
//#16 Usuniecie szarej lini miedzy wierszami
//https://stackoverflow.com/questions/26653883/delete-lines-between-uitableviewcells-in-uitableview
//

import UIKit
import CoreData


class Test: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timeHasPassed: UILabel!
    @IBOutlet weak var backgroundCardView: UIView!
    
    
    
}

class NumberViewController: UITableViewController {

    var titleCell = [String]()//pusta
    var subTitleCell = [Date]()//pusta
    var uniqueIdCell = [Double]()//pusta
    var tempUniqueCell: Double = 0

    
    
    // MARK: - addButtonTapped
    //dodawnie komórki
    @IBAction func addButtonTapped() {
        let alert = UIAlertController(title: "Dodaj kogoś:", message: nil, preferredStyle: .alert)
        alert.addTextField{ (numberTF) in
            numberTF.placeholder = "Wprowadź tekst"
        }
        alert.addTextField{ (numberTF2) in
            numberTF2.placeholder = "Gdzie?"
        }

        let action = UIAlertAction(title: "Dodaj", style: .default) { (_) in //dodaj przysick
            guard let textCellGet = alert.textFields?.first?.text else { return }
            guard let textCellGet2 = alert.textFields?.last?.text else {return}
            
            var timestamp = Date() //
            self.titleCell.append(textCellGet)
            self.subTitleCell.append(timestamp) // ma brac z bazy w zasadzie nie musi
           
            print(textCellGet2)
            self.tableView.reloadData()
            
            
            self.addDataBase(labelText: textCellGet, date: timestamp)
            
            self.uniqueIdCell.append(self.tempUniqueCell)
            
            //self.fetchDataBase() //odczyt bazy
            //self.deleteAllData() //usuwanie bazy
        }
        let action2 = UIAlertAction(title: "Anuluj", style: .cancel, handler: nil) //canel przycisk

        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true)

    }//koniec przycisku
    
    @IBAction func reload(_ sender: Any) { //start licznika
        //self.tableView.reloadData()
        starttime()
    }
    
    
    
    @IBAction func refresh(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    
    // MARK: - licznik rzeczywisty
    func starttime(){
         let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            print("reset")
            self.tableView.reloadData()
        })
    }

    // MARK: - mathTimeStamp
    func mathTimeStamp(indexPathRow:Int) -> String{
    var actualTimeStamp = Date() // aktualna data
    let differnceBetwenTwoTimes = actualTimeStamp.timeIntervalSince(self.subTitleCell[indexPathRow])
        //konwersja z second na czas
        func timeString(time: TimeInterval) -> String {
                let hour = Int(time) / 3600
                let minute = Int(time) / 60 % 60
                let second = Int(time) % 60

                // return formated string
                return String(format: "%02i:%02i:%02i", hour, minute, second)
            }
           
    var time:String = timeString(time: TimeInterval(Int(differnceBetwenTwoTimes)))

        return time
    }

    // MARK: - addDataBase
    //dodawanie pozycji do bazy
    func addDataBase (labelText: String, date: Date){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CellInfo", in: context)
        let newCellInfo = NSManagedObject(entity: entity!, insertInto: context)
        newCellInfo.setValue(fetchUniqId(), forKey: "uniqueId")
        //newCellInfo.setValue(uniqueIdCell1, forKey: "uniqueId")
        newCellInfo.setValue(labelText, forKey: "name")
        newCellInfo.setValue(date, forKey: "timeStamp")
        print("DODANO!")
        
        do {
           try context.save()
          } catch {
           print("Failed saving in CoreData")
        }
    }
    
    // MARK: - fetchUniqId
    // znajdz wolnee uniqId za zakresu -32,768 to 32,767 - wybiera Max - poprawic
    
    func fetchUniqId() -> Double {
        var uniqueId:Double = 1
        var listOfUniqId = [Double]() //pusta lista
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CellInfo")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                //print(data.value(forKey: "uniqueId") as! Double)
                listOfUniqId.append(data.value(forKey: "uniqueId") as! Double)
          }
            
        } catch {
            
            print("Failed")
        }
        let max:Double = listOfUniqId.max()!
        uniqueId = max + 1
        self.tempUniqueCell = uniqueId
        return uniqueId
    }
    
    // MARK: - updateDataBase
    func updateDataBase (){
    
        
    }
    
    // MARK: - deleteRowDataBase
    func deleteRowDataBase (uniqueId: Double)  {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CellInfo")
        request.predicate = NSPredicate(format: "uniqueId == %f", uniqueId)
        request.returnsObjectsAsFaults = false
        do {
            let entity = try context.fetch(request)
            for data in entity as! [NSManagedObject] {
            print("### USUWAM!!! ###")
            print("UniqueId: ",data.value(forKey: "uniqueId")as! Double)
            print("Name: ",data.value(forKey: "name")as! String)
            print("TimeStamp: ",data.value(forKey: "timeStamp"))
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
            try context.save()
            print("### USUNIETO!!! ###")
            }
            } catch {
            print("Failed")
                }
    }
    
    // MARK: - deleteAllData
    //usuwa cala baze
    func deleteAllData(){

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "CellInfo"))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
    // MARK: - Funkcja załaduj baze
    // zaladuj i wydrukuj cala baze
    func fetchDataBase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CellInfo")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let entity = try context.fetch(request)
            for data in entity as! [NSManagedObject]
                {
                    print("UniqueId: ",data.value(forKey: "uniqueId")as! Double)
                    print("Name: ",data.value(forKey: "name")as! String)
                    print("TimeStamp: ",data.value(forKey: "timeStamp"))
                    print("####")
                    self.uniqueIdCell.append(data.value(forKey: "uniqueId") as! Double)
                    self.titleCell.append(data.value(forKey: "name") as! String)
                    self.subTitleCell.append(data.value(forKey: "timeStamp") as! Date)
                }
            } catch {
                    print("Failed")
                    }
    }
    
    // MARK: - Start
    //start
    override func viewDidLoad() {
        
        fetchDataBase()//zalodowanie listy
        super.viewDidLoad()
        
        //timeFunction()
        //tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //deleteRowDataBase(uniqueId: 3)
        //deleteAllData() //usuwanie bazy
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // return the number of rows
        return titleCell.count
    }

    //wczytywanie tabelki na poczatku
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Test
       
        cell.titleLabel.text = titleCell[indexPath.row] //tytuł
        cell.subtitleLabel.text = "\(subTitleCell[indexPath.row])" //data utworzenia
        cell.idLabel.text = String(uniqueIdCell[indexPath.row])
        cell.timeHasPassed.text = mathTimeStamp(indexPathRow: indexPath.row) //wyliczenia
       
       // tableView.rowHeight = 100
        // Configure the cell...
        
    //Kolory
        cell.backgroundColor = UIColor.gray
        cell.backgroundCardView.layer.cornerRadius = 3.0
        cell.backgroundCardView.layer.masksToBounds = false
        cell.backgroundCardView.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.gray
        
        
        return cell
    }

 
    
    
    // MARK: - prawy przycisk obsługa
    //Obsługa prawa strony komórki
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = editAction(at:indexPath)
        let delete = deleteAction(at:indexPath)

        delete.image = UIImage(named: "dupa") //zmiana wygladu przycisku
        delete.backgroundColor = .gray //odpowiedni kolor
        

       
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    // MARK: - editAction
    //Funkcja edycji
    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let todo = titleCell[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Edit" ) {(action, view, completion) in
            todo.isEmpty
                        
        }
        return action
    }
    
    // MARK: - deleteAction
    //Funkcja usuwanie
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let todo = titleCell[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete" ) {(action, view, completion) in
            todo.isEmpty
            self.deleteRowDataBase(uniqueId: self.uniqueIdCell[indexPath.row]) //usuniecie z CoreData
            self.titleCell.remove(at: indexPath.row) //usuniecie z tabeli tytuli
            self.subTitleCell.remove(at: indexPath.row) //usuniecie z tabeli daty
            self.uniqueIdCell.remove(at: indexPath.row) //usuniecie z tabeli id
            self.tableView.deleteRows(at: [indexPath], with: .automatic) //usuniecie wiersza
            
        }
        return action
    }
    
    // MARK: - lewy przycisk obsługa
    //Obsługa lewa strony komórki
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reset = resetAction(at:indexPath)
        
        return UISwipeActionsConfiguration(actions: [reset])
    }

    // MARK: - resetAction
    //Funkcja resetu
    func resetAction(at indexPath: IndexPath) -> UIContextualAction {
        let tempTitleCell = titleCell[indexPath.row]
        let tempSubTitleCell = subTitleCell[indexPath.row]
        let tempUniqueIdCell = uniqueIdCell[indexPath.row]
        
        let action = UIContextualAction(style: .destructive, title: "Reset") { (action, view, completion) in
            tempTitleCell.isEmpty
            //usuwanie wszystkiego
            self.deleteRowDataBase(uniqueId: self.uniqueIdCell[indexPath.row]) //usuniecie z CoreData
            self.titleCell.remove(at: indexPath.row) // usunie
            self.subTitleCell.remove(at: indexPath.row)
            self.uniqueIdCell.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            //Dodanie tego co usunieto
            var timestamp = Date()
            self.titleCell.append(tempTitleCell) // dodanie tego co usunałem
            self.subTitleCell.append(timestamp)
            self.addDataBase(labelText: tempTitleCell, date: timestamp) //dodanie do CoreData
            self.uniqueIdCell.append(self.tempUniqueCell)
            
            self.tableView.reloadData()
        }
        
        return action
    }
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


