//
//  RealmManager.swift
//  ToDoList
//
//  Created by 김나연 on 2022/09/13.
//

import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private(set) var tasks: [Task] = []
    
    init() {
        openRealm()
        getTasks()
    }
    
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 3)
            
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
        } catch {
            print("Error opening Realm: \(error)")
        }
    }
    
    func addTask(_ taskTitle: String, _ taskDescription: String, _ taskDate: Date, _ descriptionVisibility: Bool, _ isCompleted: Bool) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    let newTask = Task(value: ["taskTitle": taskTitle, "taskDescription": taskDescription, "taskDate": taskDate, "descriptionVisibility": descriptionVisibility, "isCompleted": isCompleted])
                    localRealm.add(newTask)
                    getTasks()
                }
            } catch {
                print("Error add task to Realm: \(error)")
            }
        }
    }
    
    func getTasks() {
        if let localRealm = localRealm {
            let allTasks = localRealm.objects(Task.self)
            tasks = []
            allTasks.forEach { task in
                tasks.append(task)
            }
            
        }
    }
    
    func updateTask(id: ObjectId, _ taskTitle: String, _ taskDescription: String, _ taskDate: Date, _ descriptionVisibility: Bool, _ isCompleted: Bool) {
        if let localRealm = localRealm {
            do {
                let taskToUpdate = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToUpdate.isEmpty else { return }
                try localRealm.write {
                    taskToUpdate[0].taskTitle = taskTitle
                    taskToUpdate[0].taskDescription = taskDescription
                    taskToUpdate[0].taskDate = taskDate
                    taskToUpdate[0].descriptionVisibility = descriptionVisibility
                    taskToUpdate[0].isCompleted = isCompleted
                    getTasks()
                }
            } catch {
                print("Error update task \(id) to Realm: \(error)")
            }
        }
    }
    
    func deleteTask(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let taskToDelete = localRealm.objects(Task.self).filter(NSPredicate(format: "id == %@", id))
                guard !taskToDelete.isEmpty else { return }
                try localRealm.write {
                    localRealm.delete(taskToDelete)
                    getTasks()
                }
            } catch {
                print("Error deleting task \(error)")
            }
        }
    }
    
    
}
