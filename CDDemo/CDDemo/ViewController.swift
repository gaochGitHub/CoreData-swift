//
//  ViewController.swift
//  CDDemo
//
//  Created by 高超 on 2016/11/9.
//  Copyright © 2016年 ChaoGao. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleTextFieldTop: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var subTitleTextField: UITextField!
    
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var bottomBackView: UIView!
    
    @IBAction func inputButtonAction(_ sender: UIButton) {
        if (titleTextField.text != "") && (subTitleTextField.text != "") && (contentTextField.text != "") {
            saveCoreDate()
            updateData()
        }else{

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //        saveCoreDate()
        //        deleteCoreData()
        //        updateDataWithCoreData()
        printAllDataWithCoreData()
        self.bottomBackView.addSubview(tableView)
        data = NSMutableArray(array: selectDataFromCoreData())
    }
    func layoutViews() {
        
        // 1.移动
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
            self.titleTextFieldTop.constant = -100
            
        }, completion: {
            complet in
        
        })
    }
   
    func updateData() {
        data = NSMutableArray(array: selectDataFromCoreData())
        self.tableView.reloadData()
    }
    var data = NSMutableArray()
    
    lazy var tableView : UITableView! = {
        let tabWidth = self.view.frame.size.width
        let tabHeight = self.bottomBackView.frame.size.width
        
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: tabWidth, height: tabWidth), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CDTableViewCell", bundle: nil), forCellReuseIdentifier: "CDTableViewCell")
        return tableView
    }()
    //MARK: UITableViewDelegate
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CDTableViewCell")as! CDTableViewCell
        cell.titleLable.text = (data[indexPath.row] as! CDNotifti).title
        cell.subtitleLabel.text = (data[indexPath.row] as! CDNotifti).subtitle
        cell.contentLable.text = (data[indexPath.row] as! CDNotifti).content
        let date = (data[indexPath.row] as! CDNotifti).updateDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        cell.dateLabel.text = dateFormatter.string(from: date as! Date)
        return cell
    }
    
    func sizeWithString(string: NSString, font: UIFont) -> CGSize {
        let rect = string.boundingRect(with: CGSize(width: 320, height: 80000), options: [.truncatesLastVisibleLine, .usesFontLeading, .usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return rect.size
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let content = (data[indexPath.row] as! CDNotifti).content!
        let size = self.sizeWithString(string: content as NSString, font: UIFont.systemFont(ofSize: 14))
        let height = size.height;
        print("Height:\(height)")
        return 40+height
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    //添加数据
    func saveCoreDate(){
        //加载AppDelegate
        let appDel = UIApplication.shared.delegate as! AppDelegate
        //获取管理的上下文
        let context = appDel.persistentContainer.viewContext
        //创建一个实例并给属性赋值
        let people = NSEntityDescription.insertNewObject(forEntityName: "CDNotifti", into: context)as! CDNotifti
        people.updateDate = NSDate()
        people.title = titleTextField.text
        people.subtitle = subTitleTextField.text
        people.content = contentTextField.text
        
        do {
            try context.save()
            print("保存成功")
        }catch let error{
            print("context can't save!, Error:\(error)")
        }
        
    }
    //查
    
    func selectDataFromCoreData() -> NSArray
    {
        //加载AppDelegate
        let appDel = UIApplication.shared.delegate as! AppDelegate
        //获取管理的上下文
        let context = appDel.persistentContainer.viewContext
        var dataSource = NSArray()
        let request : NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
        let entity:NSEntityDescription? = NSEntityDescription.entity(forEntityName: "CDNotifti", in: context)
        request.entity = entity
        
        do{
            dataSource = try context.fetch(request) as! [CDNotifti] as NSArray
            print("数据读取成功 ~ ~")
        }catch{
            print("get_coredata_fail!")
        }
        
        return dataSource
    }
    //查询所有数据并输出
    func printAllDataWithCoreData()
    {
        let array = selectDataFromCoreData()
        for item in array {
            let notifti = item as! CDNotifti
            print("updateDate=",notifti.updateDate ?? 0,"title=",notifti.title ?? 0,"subtitle=",notifti.subtitle ?? 0,"content=",notifti.content ?? 0)
        }
    }
    //改
    
    func updateDataWithCoreData()
    {
        //加载AppDelegate
        let appDel = UIApplication.shared.delegate as! AppDelegate
        //获取管理的上下文
        let context = appDel.persistentContainer.viewContext
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDNotifti")
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "CDNotifti", in: context)!
        let condition = "title='小公举' && id=2"
        let predicate = NSPredicate(format: condition,"")
        request.entity = entity
        request.predicate = predicate
        do{
            let userList = try context.fetch(request) as! [CDNotifti] as NSArray
            if userList.count != 0 {
                let user = userList[0] as! CDNotifti
                user.title = "小公举~"
                try context.save()
                print("修改成功 ~ ~")
            }else{
                print("修改失败，没有符合条件的联系人！")
            }
        }catch{
            print("修改失败 ~ ~")
        }
        
    }
    func deleteCoreData(condition:String)
    {
        //加载AppDelegate
        let appDel = UIApplication.shared.delegate as! AppDelegate
        //获取管理的上下文
        let context = appDel.persistentContainer.viewContext
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDNotifti")
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: "CDNotifti", in: context)!
        //        let condition = "subtitle MATCHES %@"
        let predicate = NSPredicate(format: condition,"")
        
        request.entity = entity
        request.predicate = predicate
        
        do{
            //查询满足条件的联系人
            let resultsList = try context.fetch(request) as! [CDNotifti] as NSArray
            if resultsList.count != 0 {//若结果为多条，则只删除第一条，可根据你的需要做改动
                context.delete(resultsList[0] as! NSManagedObject)
                try context.save()
                print("delete success ~ ~")
            }else{
                print("删除失败！ 没有符合条件的联系人！")
            }
        }catch{
            print("delete fail !")
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let title = (data[indexPath.row] as! CDNotifti).title!
            DispatchQueue.global().async {
                //处理耗时操作的代码块...
                print("do work")
                self.deleteCoreData(condition: "title = '\(title)' ")
                //操作完成，调用主线程来刷新界面
                DispatchQueue.main.async {
                    print("main refresh\(Thread.current)")
                    self.data.removeObject(at: indexPath.row)
                    self.tableView.reloadData()
                }
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                print("do work delay")
            })
            
        }
    }
    
    //    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
    //       let str = (data[indexPath.row] as! CDNotifti).title!
    //        return "确定删除\(str)？"
    //    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

