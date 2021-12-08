//
//  ViewController.swift
//  LocalNotification
//
//  Created by faisal on 04/05/1443 AH.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var total: UILabel!
    
    @IBOutlet weak var anototal: UILabel!
    
    @IBOutlet weak var currenttimer: UILabel!
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var until: UILabel!
    
    @IBOutlet weak var logwindow: UIView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sta: UIButton!
    
    let cr=(UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var list=[Log]()
    var picklist = ["5 minutes","10 minutes","15 minutes","20 minutes","25 minutes","30 minutes"]
    var tot = 0
    var cur = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getall()
        for i in list {
            tot = tot + Int(i.duration!)!
        }
         update()
        currenttimer.isHidden=true
        until.isHidden=true
        picker.delegate=self
        picker.dataSource=self
        table.delegate=self
        table.dataSource=self
        
        // Do any additional setup after loading the view.
    }

    @IBAction func cans(_ sender: UIButton) {
        alert(mes: "", al: "Cancel current Timer?",b1:"Cancel",b2:"Back",s:0)
    }
    func canss(){
        tot=tot-cur
        let c = Log(context: cr)
        c.start="CANCELED ABOVE LISTING"
        c.fin=""
        c.duration="0"
        if cr.hasChanges {
            do {
                try cr.save()
                print("Success")
            } catch {
                print("\(error)")
            }
        }
        currenttimer.text = "\(cur) Minutes Timer Cancelled "
        currenttimer.isHidden=false
        until.isHidden=true
        anototal.isHidden=false
        update()
    }
    
    @IBAction func log(_ sender: UIButton) {
        getall()
        logwindow.isHidden = !logwindow.isHidden
        
    }
    @IBAction func add(_ sender: UIButton) {
        alert(mes: "", al: "are you sure it`s a new day?", b1: "New Day", b2: "Cancel",s:1)
    }
    func addd(){
        tot=0
        cur=0
        currenttimer.isHidden=true
        anototal.isHidden=true
        until.isHidden=true
        for i in list{
            cr.delete(i)
            
        }
        if cr.hasChanges {
            do {
                try cr.save()
                print("Success")
            } catch {
                print("\(error)")
            }
        }
        update()
    }
    
    
    @IBAction func start(_ sender: UIButton) {
        cur=(5*picker.selectedRow(inComponent: 0))+5
        print(cur)
        alert(mes: "After \(cur) minutes, you will be notified", al: "\(cur) min countdown", b1: "ok", b2: "",s:2)
    }
    func startt(){
        perform(#selector(alert), with: ["","Time is up?","ok","",4],afterDelay: TimeInterval(cur*60))
        sta.isEnabled=false
            tot=tot+cur
            let c = Log(context: cr)
            // get the current date and time
            let currentTime = Date()
            let currentTime2 = currentTime.addingTimeInterval(Double(cur)*Double(60))
            // initialize the date formatter and set the style
            let formatter = DateFormatter()
            // get the date time String from the date object
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            let a=formatter.string(from: currentTime)
            let b=formatter.string(from: currentTime2)
            c.start=a
            c.fin=b
            c.duration="\(cur)"
            if cr.hasChanges {
                do {
                    try cr.save()
                    print("Success")
                } catch {
                    print("\(error)")
                }
            }
            until.isHidden=false
            until.text="Work until: \(b)"
            currenttimer.text = "\(cur) Minutes Timer set"
            currenttimer.isHidden=false
            anototal.isHidden=false
            update()
        }
    
    func getall(){
        let req=NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        do{
            let fet = try cr.fetch(req)
            list = fet as! [Log]
            
        }catch{
            print(error)
        }
    }
    @objc func alert(mes :String,al :String,b1:String,b2:String,s:Int) {
        var con=false
        let alert = UIAlertController(title: al, message: mes, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: b1, style: .cancel, handler: { [self] action in
            switch action.style{
                case .cancel:
                    switch s{
                        case 0: canss()
                        case 1: addd()
                        case 2: startt()
                        default: sta.isEnabled=true
                    }
                    
                 default:
                    print("")
            }
        }))
        if(!b2.isEmpty){
        alert.addAction(UIAlertAction(title: b2, style: .default, handler: { [self] action in
            switch action.style{
                case .default: break
                    
                 default:
                    print("")
            }
        }))
        }
        self.present(alert, animated: true, completion: nil)
        print(con)
        
    }
    func update(){
        total.text="total time: \(tot)"
        anototal.text="\(tot/60) hours, \(tot%60) minutes"
    }
    
}
extension ViewController:UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDelegate,UITableViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return picklist.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return picklist[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        list[0].start
//        list[0].fin
//        list[0].duration
        if(list[indexPath.row].start!.contains("CANCELED")){
            cell.textLabel!.text = "\(list[indexPath.row].start!)"
        } else{ cell.textLabel!.text = "\(list[indexPath.row].start!) - \(list[indexPath.row].fin!) ... \(list[indexPath.row].duration!) minute timer"}
        
        return cell
    }
    
    
}
