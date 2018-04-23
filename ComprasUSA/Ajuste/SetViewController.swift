//
//  UIViewController.swift
//  ComprasUSA
//
//  Created by admin on 4/17/18.
//  Copyright © 2018 Adriano Pogianeli. All rights reserved.
//

import UIKit
import CoreData


enum Type {
    case add
    case edit
}

class SetViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tfCotacaoDolar: UITextField!
    @IBOutlet weak var tfIofcard: UITextField!
    @IBOutlet weak var tvState: UITableView!
    
    var dataSource: [State] = []
    var prod: Product!
    
    
    // MARK: - Variables
    var produto: Product!
    var state : [State] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        tfCotacaoDolar.text = UserDefaults.standard.string(forKey: "dolar_preference")!
        tfIofcard.text = UserDefaults.standard.string(forKey: "iof_preference")!
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    UserDefaults.standard.set(Double(tfCotacaoDolar.text!), forKey: "dolar_preference")
        UserDefaults.standard.set(Double(tfIofcard.text!), forKey: "iof_preference")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvState.dataSource = self
        tvState.delegate = self
        tfCotacaoDolar.keyboardType = .decimalPad
        tfIofcard.keyboardType = .decimalPad
        
        // Chama o alert p cad de estados
        loadStates()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func loadStates() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tvState.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }

    func showAlert(type: Type, state: State?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textStateField: UITextField) in
            textStateField.placeholder = "Nome do estado"
            if let name = state?.name {
                textStateField.text = name
            }
        }
        
        alert.addTextField { (textImpostoField: UITextField) in
            textImpostoField.placeholder = "Imposto"
            textImpostoField.keyboardType = .decimalPad
            if let imposto = state?.taxes {
                textImpostoField.text = String( imposto )
            }
        }
        
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            let state1 = state ?? State(context: self.context)
            state1.name = alert.textFields?.first?.text
            let valeu = alert.textFields![1].text
            // Adicionar o tratamento p qnd o user não preencher os campos estado e imposto
            state1.taxes = Double( valeu! )!
            do {
                try self.context.save()
                self.loadStates()
            } catch {
                print(error.localizedDescription)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func btAdicionar(_ sender: Any) {
        showAlert(type: .add, state: nil)
    }
    
}

// MARK: - estensions


extension SetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .none {
            //cell.accessoryType = .checkmark
        } else {
            //cell.accessoryType = .none
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let estado = self.dataSource[indexPath.row]
            self.context.delete(estado)
            try! self.context.save()
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Editar") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let state = self.dataSource[indexPath.row]
            tableView.setEditing(false, animated: true)
            self.showAlert(type: .edit, state: state)
        }
        editAction.backgroundColor = .blue
        return [editAction, deleteAction]
    }
    
    
}

extension SetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StateTableViewCell
        let state = dataSource[indexPath.row]
        cell.lbNome?.text = state.name
        cell.lbImposto?.text = String( state.taxes )
        return cell
    }
}
