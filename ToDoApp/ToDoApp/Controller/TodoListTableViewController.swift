//
//  TodoListTableViewController.swift
//  ToDoApp
//
//  Created by 土井　麻菜美 on 2018/08/21.
//  Copyright © 2018年 Manami. All rights reserved.
//

import UIKit

import UserNotifications

class TodoListTableViewController: UITableViewController {
    @IBOutlet var customTableView: UITableView!
    //TodoCollectionクラスのインスタンスを定義
    let todoCollection = TodoCollection.sharedInstance
    var todo = Todo()
    override func viewDidLoad() {
        super.viewDidLoad()
        todoCollection.fetchTodos()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //Todoの数だけrowを作成
        return self.todoCollection.todos.count
    }
    //セルの中に表示される内容を指定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = customTableView.dequeueReusableCell(withIdentifier: "customCell") as!  TableViewCell
        let todo = self.todoCollection.todos[indexPath.row]
        cell.cellLabel.text = todo.title
        cell.descriptLabel.text = todo.descript
        cell.dateLabel.text = todo.date
        if todo.todoDone {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        // Configure the cell...
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = self.todoCollection.todos[indexPath.row]
        if todo.todoDone {
            todo.todoDone = false
        }else {
            todo.todoDone = true
        }
        customTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        self.todoCollection.save()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.tableView.reloadData()
    }
    //セルをスワイプした時にボタンを表示
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    //編集ボタンを押した時の処理
    func editAction(at indexPath: IndexPath) ->UIContextualAction {
         todo = self.todoCollection.todos[indexPath.row]
        //パスの番号を取得
        todo.todoId = indexPath.row
        let action = UIContextualAction(style: .normal, title: "Edit") {(action, view, completation) in
          self.performSegue(withIdentifier: "Edit", sender: self)
        }
        //文字の代わりにアイコンを配置し、backgroungColorを設定
        action.image = #imageLiteral(resourceName: "edit.png")
        action.backgroundColor = UIColor(red: 216/255, green: 212/255, blue: 215/255, alpha: 1)
        return action
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //編集ボタンをクリックした時にセルの中にある情報をNewTodoViewControllerに渡す
        if segue.identifier == "Edit" {
            let nav = segue.destination as! UINavigationController
            let todoController = nav.topViewController as! NewTodoViewController
            todoController.editTodoTitle = todo.title
            todoController.editDescription = todo.descript
            todoController.editDate = todo.date
            todoController.editId = todo.id
            todoController.editAble = todo.isEditAble
            todoController.pathId = todo.todoId
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        customTableView.estimatedRowHeight = 20 //セルの高さ
        return UITableViewAutomaticDimension //自動設定
    }
    //deleteボタンを押して時の処理
    func deleteAction(at indexPath: IndexPath) ->UIContextualAction {
        //ローカル通知を削除するためのIDを設定
        let todo = self.todoCollection.todos[indexPath.row]
        let id = "\(todo.id)"
        let action = UIContextualAction(style: .normal, title: "Delete"){(action, view, completation) in
            //削除をするかの確認を行うためのアラートを表示
            let alert = UIAlertController(title: "ToDoを削除しますか？", message: "削除されたToDoは復元できません", preferredStyle: UIAlertControllerStyle.alert)
          //アラートにボタンを追加
             let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.todoCollection.todos.remove(at: indexPath.row)
            self.todoCollection.save()
           self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.middle)
            // 通知の削除
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                        }
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
             }
            //アラートを表示
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            completation(true)
        }
        //文字の代わりにアイコンを配置し、backgroungColorを設定
        action.image = #imageLiteral(resourceName: "trash.png")
        action.backgroundColor = UIColor(red: 244/255, green: 198/255, blue: 207/255, alpha: 1)
        return action
    }
}
