//
//  Task.swift
//

import UIKit

// The Task model
struct Task: Codable {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    
    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    var id: String = UUID().uuidString
}





// MARK: - Task + UserDefaults
extension Task {
    // Save an array of tasks to UserDefaults.
    static func save(_ tasks: [Task]) {
        do {
            // Encode the array of tasks to data using a JSONEncoder instance.
            let encoder = JSONEncoder()
            let encodedTasks = try encoder.encode(tasks)
            
            // Save the encoded tasks data to UserDefaults with a key.
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }

    
    // Retrieve an array of saved tasks from UserDefaults.
    static func getTasks() -> [Task] {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks") {
            do {
                // Decode the tasks data into an array of Task objects using a JSONDecoder instance.
                let decoder = JSONDecoder()
                let decodedTasks = try decoder.decode([Task].self, from: tasksData)
                return decodedTasks
            } catch {
                print("Error decoding tasks: \(error)")
            }
        }
        return []
    }

    // Add a new task or update an existing task with the current task.
    func save() {
        var tasks = Task.getTasks()

        if let existingTaskIndex = tasks.firstIndex(where: { $0.id == self.id }) {
            // Update the existing task
            tasks.remove(at: existingTaskIndex)
            tasks.insert(self, at: existingTaskIndex)
        } else {
            // Add in the new task at the end of the array
            tasks.append(self)
        }

        // Save the updated tasks array to UserDefaults
        Task.save(tasks)
    }
    static func overallProgress() -> Float {
        let tasks = getTasks()
        let completedTasksCount = tasks.filter { $0.isComplete }.count
        let totalTasksCount = tasks.count
        if totalTasksCount == 0 {
            return 0 // Avoid division by zero
        }
        return Float(completedTasksCount) / Float(totalTasksCount)
    }
}

