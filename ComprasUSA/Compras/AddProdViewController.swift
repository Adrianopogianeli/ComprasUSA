//
//  AddProdViewController.swift
//  ComprasUSA
//
//  Created by admin on 4/19/18.
//  Copyright © 2018 Adriano Pogianeli. All rights reserved.
//

import UIKit
import CoreData

class AddProdViewController: UIViewController {

    
    
    @IBOutlet weak var tfProdName: UITextField!
    @IBOutlet weak var ivProd: UIImageView!
    @IBOutlet weak var tfProdSt: UITextField!
    @IBOutlet weak var tfProdVal: UITextField!
    @IBOutlet weak var btAddProd: UIButton!
    @IBOutlet weak var swCartao: UISwitch!
    
    
    var pickerView: UIPickerView!
    var produto: Product!
    var smallImage: UIImage!
    var dataSource: [State] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btAddProd.isEnabled = false
        btAddProd.backgroundColor = .black
        
        tfProdName.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tfProdSt.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tfProdVal.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tfProdVal.keyboardType = .decimalPad
        
        if produto != nil{
            tfProdName.text = produto.name
            tfProdSt.text = produto.state?.name
            tfProdVal.text = String( produto.value )
            swCartao.setOn(produto.credcard, animated: false)
            btAddProd.setTitle("Atualizar", for: .normal)
            if let image = produto.image as? UIImage {
                ivProd.image = image
            }
            
            btAddProd.isEnabled = true
            btAddProd.backgroundColor = .blue
        }
        setupPickerView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddProdViewController.handleTap))
        ivProd.addGestureRecognizer(tapGesture)
        
    }
    
    deinit {
        tfProdName.removeTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tfProdSt.removeTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tfProdVal.removeTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
@objc    func editingChanged(_ textField: UITextField) {
        guard
            let nomeProduto = tfProdName.text, !nomeProduto.isEmpty,
            let estadoProduto = tfProdSt.text, !estadoProduto.isEmpty,
            let valor = tfProdVal.text, !valor.isEmpty
            else {
                btAddProd.isEnabled = false
                btAddProd.backgroundColor = .gray
                return
        }
        btAddProd.isEnabled = true
        btAddProd.backgroundColor = .blue
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadState()
    }
    
    func loadState() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setupPickerView() {
        pickerView = UIPickerView()
        pickerView.backgroundColor = .white
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        
        tfProdSt.inputView = pickerView
        tfProdSt.inputAccessoryView = toolbar
    }
    
@objc    func cancel() {
        tfProdSt.resignFirstResponder()
    }
    
@objc    func done() {
        tfProdSt.text = dataSource[pickerView.selectedRow(inComponent: 0)].name
        cancel()
    }
    
@objc    func handleTap() {
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    
    
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
        ivProd.image = smallImage
    }
    
    @IBAction func addProd(_ sender: Any) {
        if produto == nil { produto = Product(context: context) }
        produto.name = tfProdName.text
        produto.image = ivProd.image
        if let indexState = dataSource.index(where: { $0.name  == tfProdSt.text!}) {
            produto.state = dataSource[indexState]
        }
        produto.value = Double( tfProdVal.text! )!
        produto.credcard = swCartao.isOn
        if smallImage != nil {
            produto.image = smallImage
        }
        do {
            try context.save()
            close()
        } catch {
            print(error.localizedDescription)
            close()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension AddProdViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivProd.image = smallImage
        dismiss(animated: true, completion: nil)
    }
}

extension AddProdViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row].name
    }
}

extension AddProdViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
}
