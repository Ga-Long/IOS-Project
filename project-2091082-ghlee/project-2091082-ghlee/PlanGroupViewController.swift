//
//  ViewController.swift
//  ch09-leejaemoon-tableView
//
//  Created by jmlee on 2023/04/26.
//

import UIKit
import FSCalendar

class PlanGroupViewController: UIViewController {
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    @IBOutlet weak var planGroupTableView: UITableView!
    var planGroup: PlanGroup!
    var selectedDate: Date? = Date()     // 나중에 필요하다
    var commitCounts: [String: Int] = [:] // 일일 commit 갯수 저장
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Owner.loadOwner(sender: self)
        planGroupTableView.dataSource = self        // 테이블뷰의 데이터 소스로 등록
        planGroupTableView.delegate = self
        fsCalendar.dataSource = self                // 칼렌다의 데이터소스로 등록
        fsCalendar.delegate = self                  // 칼렌다의 딜리게이트로 등록
        
        // 단순히 planGroup객체만 생성한다
        //planGroup.setGithubID(withGithubID: Owner.getOwner()) // githubID 넘겨주기
        planGroup = PlanGroup(parentNotification: receivingNotification)
        planGroup.queryData(date: Date())       // 이달의 데이터를 가져온다. 데이터가 오면 planGroupListener가 호출된다.
        //planGroupTableView.isEditing = true
        let leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editingPlans1))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.title = "Plan Group"
        
        // 현재 날짜 정보 가져오기
        let currentDate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        
        // getCommitsForMonth 함수 호출
        getCommitsForMonth(author: "Ga-Long", year: year, month: month)
        //getCommit(author: "Ga-Long", dateString: "2023-06-07")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 여기서 호출하는 이유는 present라는 함수 ViewController의 함수인데 이함수는 ViewController의 Layout이 완료된 이후에만 동작하기 때문
        //Owner.loadOwner(sender: self)
        print(Owner.getOwner())
    }
    func receivingNotification(plan: Plan?, action: DbAction?){
        // 데이터가 올때마다 이 함수가 호출되는데 맨 처음에는 기본적으로 add라는 액션으로 데이터가 온다.
        self.planGroupTableView.reloadData()  // 속도를 증가시키기 위해 action에 따라 개별적 코딩도 가능하다.
        fsCalendar.reloadData()     // 뱃지의 내용을 업데이트 한다
        
    }
    
    @IBAction func editingPlans(_ sender: UIButton) {
        if planGroupTableView.isEditing == true{
            planGroupTableView.isEditing = false
            sender.setTitle("Edit", for: .normal)
        }else{
            planGroupTableView.isEditing = true
            sender.setTitle("Done", for: .normal)
        }
    }
    
    @IBAction func addingPlan(_ sender: UIButton) {
        //        let plan = Plan(date: nil, withData: true)        // 가짜 데이터 생성
        //        planGroup.saveChange(plan: plan, action: .Add)    // 단지 데이터베이스에 저장만한다. 그러면 receivingNotification 함수가 호출되고 tableView.reloadData()를 호출하여 생성된 데이터가 테이블뷰에 보이게 된다.
        performSegue(withIdentifier: "AddPlan", sender: self)
    }
}
extension PlanGroupViewController{
    @IBAction func editingPlans1(_ sender: UIBarButtonItem) {
        if planGroupTableView.isEditing == true{
            planGroupTableView.isEditing = false
            //sender.setTitle("Edit", for: .normal)
            sender.title = "Edit"
        }else{
            planGroupTableView.isEditing = true
            //sender.setTitle("Done", for: .normal)
            sender.title = "Done"
        }
    }
    @IBAction func addingPlan1(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "AddPlan", sender: self)
    }
    
}

extension PlanGroupViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let planGroup = planGroup{
            return planGroup.getPlans(date:selectedDate).count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .value1, reuseIdentifier: "") // TableViewCell을 생성한다
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanTableViewCell")!
        
        // planGroup는 대략 1개월의 플랜을 가지고 있다.
        let plan = planGroup.getPlans(date:selectedDate)[indexPath.row] // Date를 주지않으면 전체 plan을 가지고 온다
        
        // 적절히 cell에 데이터를 채움
        //cell.textLabel!.text = plan.date.toStringDateTime()
        //cell.detailTextLabel?.text = plan.content
        (cell.contentView.subviews[0] as! UILabel).text = plan.date.toStringDateTime()
        (cell.contentView.subviews[2] as! UILabel).text = plan.owner
        (cell.contentView.subviews[1] as! UILabel).text = plan.content
        
        return cell
        
    }
    
    
}

extension PlanGroupViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let plan = self.planGroup.getPlans(date:selectedDate)[indexPath.row]
            let title = "Delete \(plan.content)"
            let message = "Are you sure you want to delete this item?"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) -> Void in
                
                // 선택된 row의 플랜을 가져온다
                let plan = self.planGroup.getPlans(date:self.selectedDate)[indexPath.row]
                // 단순히 데이터베이스에 지우기만 하면된다. 그러면 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
                self.planGroup.saveChange(plan: plan, action: .Delete)
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
        }
        
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // 이것은 데이터베이스에 까지 영향을 미치지 않는다. 그래서 planGroup에서만 위치 변경
        let from = planGroup.getPlans(date:selectedDate)[sourceIndexPath.row]
        let to = planGroup.getPlans(date:selectedDate)[destinationIndexPath.row]
        planGroup.changePlan(from: from, to: to)
        tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
}


extension PlanGroupViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowPlan"{
            let planDetailViewController = segue.destination as! PlanDetailViewController
            // plan이 수정되면 이 saveChangeDelegate를 호출한다
            planDetailViewController.saveChangeDelegate = saveChange
            
            // 선택된 row가 있어야 한다
            if let row = planGroupTableView.indexPathForSelectedRow?.row{
                // plan을 복제하여 전달한다. 왜냐하면 수정후 취소를 할 수 있으므로
                planDetailViewController.plan = planGroup.getPlans(date:selectedDate)[row].clone()
            }
        }
        if segue.identifier == "AddPlan"{
            let planDetailViewController = segue.destination as! PlanDetailViewController
            planDetailViewController.saveChangeDelegate = saveChange
            
            // 빈 plan을 생성하여 전달한다
            planDetailViewController.plan = Plan(date:selectedDate, withData: false)
            planGroupTableView.selectRow(at: nil, animated: true, scrollPosition: .none)
            
        }
    }
    
    
    // prepare함수에서 PlanDetailViewController에게 전달한다
    func saveChange(plan: Plan){
        
        // 만약 현재 planGroupTableView에서 선택된 row가 있다면,
        // 즉, planGroupTableView의 row를 클릭하여 PlanDetailViewController로 전이 한다면
        if planGroupTableView.indexPathForSelectedRow != nil{
            planGroup.saveChange(plan: plan, action: .Modify)
        }else{
            // 이경우는 나중에 사용할 것이다.
            planGroup.saveChange(plan: plan, action: .Add)
        }
    }
    
}

extension PlanGroupViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜가 선택되면 호출된다
        selectedDate = date.setCurrentTime()
        planGroup.queryData(date: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        planGroup.queryData(date: calendar.currentPage)
        
        // page가 바뀔 때마다 getCommitsForMonth 호출
        let currentPage = calendar.currentPage
        let year = Calendar.current.component(.year, from: currentPage)
        let month = Calendar.current.component(.month, from: currentPage)
        
        getCommitsForMonth(author: "Ga-Long", year: year, month: month)
    }
    
    // 이함수를 fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let plans = planGroup.getPlans(date: date)
        if plans.count > 0 {
            return "[\(plans.count)]"    // date에 해당한 plans의 갯수를 뱃지로 출력한다
        }
        return nil
    }
    
    // subtitle 글자 색 검정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        return UIColor.black
    }
    // title 오늘 글자색 검정
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let today = Calendar.current.isDateInToday(date)
        if today {
            return UIColor.black   // 오늘의 subtitle 색상을 빨간색으로 설정
        }
        return appearance.titleDefaultColor
    }
    
    
    
    //주어진 날짜를 문자열로 변환
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    // 현재 페이지에서 totalCounts에 따라 새싹 무늬 나타냄
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let startDate = calendar.currentPage.startOfMonth()
        let endDate = calendar.currentPage.endOfMonth()
        
        if date >= startDate && date <= endDate {
            if Calendar.current.isDateInToday(date) {
                let grassImage = UIImage(named: "grass")?.rotate(degrees: 180)
                let yellowColor = UIColor.yellow.withAlphaComponent(0.3) // 투명도가 0.3인 노란색
                
                let combinedImage = UIGraphicsImageRenderer(size: grassImage?.size ?? CGSize.zero).image { _ in
                    yellowColor.setFill()
                    UIBezierPath(rect: CGRect(origin: .zero, size: grassImage?.size ?? CGSize.zero)).fill()
                    grassImage?.draw(at: .zero)
                }
                
                return UIColor(patternImage: combinedImage)
            } else {
                let image = UIImage(named: "grass")?.rotate(degrees: 180)
                return UIColor(patternImage: image!)
            }
            
        }
        
        // 그 외의 경우 기본 배경색 사용
        return nil
    }
    
    
    
}

//180도 회전
extension UIImage {
    func rotate(degrees: CGFloat) -> UIImage? {
        let radians = degrees * CGFloat.pi / 180.0
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.rotate(by: radians)
        draw(in: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rotatedImage
    }
}

extension PlanGroupViewController{
    // url 접근
    func getCommitResource(author: String, year: Int, month: Int) {
        let calendar = Calendar.current
        let now = Date()
        // 현재 년도와 이번 달
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        // 시작 날
        let startDateComponents = DateComponents(year: year, month: month, day: 1)
        guard let startDate = calendar.date(from: startDateComponents),
              var finalEndDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
            return
        }
        
        if year == calendar.component(.year, from: now) && month == calendar.component(.month, from: now) {
            finalEndDate = now
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
                
        var currentDate = startDate
        
        let group = DispatchGroup() // Dispatch Group 생성 - 비동기 처리
        let dispatchQueue = DispatchQueue(label: "com.example.apiQueue")

//        print("2. currentDate: \(currentDate),finalEndDate: \(finalEndDate) ")
        while currentDate <= finalEndDate {
            print("2. currentDate: \(currentDate),finalEndDate: \(finalEndDate) ")

            group.enter() // Dispatch Group에 진입
            
            let dateString = dateFormatter.string(from: currentDate)
            let urlString = "https://api.github.com/search/commits?q=author:\(author)+committer-date:\(dateString)"
            
            if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    defer {
                        group.leave() // Dispatch Group에서 빠져나옴
                    }
                    
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            if let totalCount = json?["total_count"] as? Int, totalCount > 0 {
                                dispatchQueue.sync {
                                    self.commitCounts[dateString] = totalCount
                                    
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                    // 모든 작업이 완료되었을 때 출력
                    if currentDate == finalEndDate {
                        let sortedCounts = self.commitCounts.sorted { $0.key < $1.key }
                        for (date, count) in sortedCounts {
                            print("Date: \(date), Count: \(count)")
                        }
                    }
                }
                
                task.resume()
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate

            
        }
        
        
    }
    //실험 - 가져와지는데..
    //    func getCommit(author: String, dateString: String){
    //        let urlString = "https://api.github.com/search/commits?q=author:\(author)+committer-date:\(dateString)"
    //        if let url = URL(string: urlString) {
    //            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
    //                if let error = error {
    //                    print("Error: \(error)")
    //                    return
    //                }
    //
    //                if let data = data {
    //                    do {
    //                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    //                        if let totalCount = json?["total_count"] as? Int {
    //                            DispatchQueue.main.async {
    //                                print("tatalCount: \(totalCount)")
    //                            }
    //                        }
    //                    } catch {
    //                        print("Error parsing JSON: \(error)")
    //                    }
    //                }
    //            }
    //
    //            task.resume()
    //        }
    //
    //    }
    
    
    
    
    //한달 단위로 가져오기
    func getCommitsForMonth(author: String, year: Int, month: Int) {
        let calendar = Calendar.current
        let startDateComponents = DateComponents(year: year, month: month, day: 1)
        let endDateComponents = DateComponents(year: year, month: month + 1, day: 1)
        
        if let startDate = calendar.date(from: startDateComponents),
           let endDate = calendar.date(from: endDateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            print("1. startDateString: \(startDateString) endDateString: \(endDateString) ")
            //getCommitResource(author: author, startDate: startDateString, endDate: endDateString, commitDate: startDateString)
            getCommitResource(author: author, year: year, month: month)
        }
    }
    
    
    
}
