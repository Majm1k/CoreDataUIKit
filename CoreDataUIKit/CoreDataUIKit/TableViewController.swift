//
//  TableViewController.swift
//  CoreDataUIKit
//
//  Created by Дмитрий Рузайкин on 30.08.2021.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    var tasks: [TasksDB] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //запрос по которому получаем данные
        let fetchRequest: NSFetchRequest<TasksDB> = TasksDB.fetchRequest()
        
        do{
            tasks = try context.fetch(fetchRequest)
        }catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - ADD TASKS IN CORE DATA
    //Пытаемся достать до контейнера, где находится контекст, что бы начать запись в core data
    func saveTasks(withTitle title: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Создаем в context объект (добираемся до сущности)
        guard let entity = NSEntityDescription.entity(forEntityName: "TasksDB", in: context) else {return}
        
        //Добираемся до объекта
        let tasksObject = TasksDB(entity: entity, insertInto: context)
        tasksObject.title = title
        
        //запись объекта в core data
        do{
            try context.save()
            tasks.insert(tasksObject, at: 0) //добавляем данные на таблицу
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        
        
    }
    
    //MARK: - TABLE VIEW
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //У каждой нашей записи в массиве есть свой id, так и в ячейке определенные id и записываем (tasks[indexPath.row]), чтобы эти id совпадали, то есть будут отображаться данные с массива
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
    
    //MARK: - ALERT CONTROLLER
    @IBAction func AddTasks(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Новая задача", message: "Введите задачу", preferredStyle: .alert)
        let saveTasks = UIAlertAction(title: "Сохранить", style: .default) { action in
            let textField = alertController.textFields?.first //пишем first, тк будет 1 поле для ввода
            if let newTask = textField?.text{
                self.saveTasks(withTitle: newTask) //Добавили функцию добавления в core data
                self.tableView.reloadData()
            }
        }
        alertController.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in }
        
        alertController.addAction(saveTasks)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - DELETE TASKS
    
    //почти тоже самое, что и сохранение, которое выше
    @IBAction func deleteTasks(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<TasksDB> = TasksDB.fetchRequest()
        
        if let tasks = try? context.fetch(fetchRequest){
            for tasks in tasks{
                context.delete(tasks)
            }
        }
        do{
            try context.save()
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
}
