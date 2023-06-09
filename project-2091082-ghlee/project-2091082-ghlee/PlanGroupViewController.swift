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
    var commitByDayCount: [String: Int] = [:] // 일일 commit 갯수 저장
    var commitByMessage: [[String: Any]] = [] //List
    
    @IBOutlet weak var commitMessageLabel: UILabel!
    @IBOutlet weak var totalCommitLabel: UILabel!
    var CselectedDate: Date?
    
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
        
        // UILongPressGestureRecognizer 추가
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        totalCommitLabel.addGestureRecognizer(longPressGesture)
        
        
        CselectedDate = Date()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        calendarCurrentPageDidChange(fsCalendar) // 이 함수 안에 getMonth() 함수가 있음
        
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
    
    @objc func longPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            
            // ShowCommitMessageVC를 Storyboard ID를 이용하여 인스턴스화
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let showCommitMessageVC = storyboard.instantiateViewController(withIdentifier: "ShowCommitMessageVC") as! ShowCommitMessageViewController
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: CselectedDate!) // 선택된 날짜의
            let commitMessages = commitByMessage.filter { ($0["date"] as? String) == dateString }
            
            // ShowCommitMessageViewController에 commitMessages를 전달
            showCommitMessageVC.commitMessages = commitMessages
            
            // 모달로 표시
            present(showCommitMessageVC, animated: true, completion: nil)
        }
        
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
        
        // todoSwitch 버튼 생성
        let todoSwitch = UISwitch(frame: CGRect())
        todoSwitch.addTarget(self, action: #selector(todoSwitchChanged(_:)), for: .valueChanged) // switch 변경이 있으면 todoSwitchChanged 함수 호출
        cell.accessoryView = todoSwitch
        todoSwitch.isOn = plan.todo // 앱을 다시 시작해도 todoSwith는 해당 plan의 todo bool 값으로 결정
        
        return cell
        
        
    }
    
    @objc func todoSwitchChanged(_ sender: UISwitch) {
        
        guard let cell = sender.superview as? UITableViewCell,
              let indexPath = self.planGroupTableView.indexPath(for: cell) else {
            return
        }
        //Plan의 switch값이 변경되면 다시 저장
        let plan = self.planGroup.getPlans(date: self.selectedDate)[indexPath.row].clone()
        plan.todo = sender.isOn
        // 저장 로직 작성
        
        self.saveChange(plan: plan)
        
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
    // FSCalendar의 캘린더에서 날짜를 선택할 때
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // 선택된 날짜를 selectedDate에 업데이트합니다.
        CselectedDate = date
        
        // 날짜가 선택되면 호출된다
        selectedDate = date.setCurrentTime()
        planGroup.queryData(date: date)
        
        // commitInfo 선택된 날짜에 맞게 label들을 바꿈
        updateCommitInfo(for: date)
        
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        planGroup.queryData(date: calendar.currentPage)
        
        // page가 바뀔 때마다 getCommitsForMonth 호출
        let currentPage = calendar.currentPage
        let year = Calendar.current.component(.year, from: currentPage)
        let month = Calendar.current.component(.month, from: currentPage)
        
        getCommitsForMonth(year: year, month: month)
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
        //print("grass 입히기 실행 =========================")
        let startDate = calendar.currentPage.startOfMonth()
        let endDate = calendar.currentPage.endOfMonth()
        
        if date >= startDate && date <= endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            
            // 오늘은 노란색 배경
            if Calendar.current.isDateInToday(date) {
                return UIColor.yellow.withAlphaComponent(0.3)// 투명도가 0.3인 노란색
            }
            
            else if commitByDayCount.keys.contains(dateString) {
                let grassImage = UIImage(named: "grass")?.rotate(degrees: 180)
                
                // 이미지를 입히는 로직 작성
                let combinedImage = UIGraphicsImageRenderer(size: grassImage?.size ?? CGSize.zero).image { _ in
                    grassImage?.draw(at: .zero)
                }
                
                return UIColor(patternImage: combinedImage)
            } else {
                return nil
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
    
    func getCommit(startDate: String, endDate: String, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        // 전역변수 초기화..
        commitByDayCount = [:]
        commitByMessage = []
        
        print("getCommit() 실행  =============================")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // 원본 날짜 형식
        
        let apiKey = Bundle.main.apiKey // API 키 가져오기
        
        let urlString = "https://api.github.com/search/commits?q=author:\(Owner.getOwner())+committer-date:\(startDate)..\(endDate)&api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        let session = URLSession(configuration: .default)
        let request = URLRequest(url: url)
        
        // 해당 url로 요청보내기
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                let statusCodeError = NSError(domain: "Invalid HTTP response", code: response.statusCode, userInfo: nil)
                completion(nil, statusCodeError)
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let items = json?["items"] as? [[String: Any]] {
                        
                        
                        for item in items {
                            // "message" 필드
                            if let message = item["commit"] as? [String: Any],
                               let commitMessage = message["message"] as? String {
                                // 커밋 메시지 가져오기
                                //print("Commit Message: \(commitMessage)")
                                
                                // committer 객체 내부의 "date" 필드 추출
                                if let commit = item["commit"] as? [String: Any],
                                   let committer = commit["committer"] as? [String: Any],
                                   let commitDateString = committer["date"] as? String,
                                   let commitDate = dateFormatter.date(from: commitDateString) {
                                    
                                    let formattedDateFormatter = DateFormatter()
                                    formattedDateFormatter.dateFormat = "yyyy-MM-dd" // 원하는 출력 형식
                                    let formattedCommitDate = formattedDateFormatter.string(from: commitDate)
                                    // 커밋 날짜 가져오기
                                    //print("Commit Date: \(formattedCommitDate)")
                                    
                                    if let repository = item["repository"] as? [String: Any],
                                       let fullname = repository["full_name"] as? String {
                                        // fullname 사용
                                        //print("Repository Full Name: \(fullname)")
                                        // 새로운 사전 대신 딕셔너리를 배열에 추가
                                        let commitData: [String: Any] = [
                                            "date": formattedCommitDate,
                                            "message": commitMessage,
                                            "repoFullname": fullname
                                        ]
                                        self.commitByMessage.append(commitData)
                                    }
                                    
                                }
                            }
                            
                        }
                    }
                    
                    completion(self.commitByMessage, nil)
                    
                    
                } catch {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    //한달 단위로 데이터 가져오기
    //달력의 년도, 달로 yyyy-MM-dd 형태로 format 함수
    func getCommitsForMonth(year: Int, month: Int) {
        //print(year, month)
        let currentDate = Date() // 현재 날짜와 시간 가져오기
        let calendar = Calendar.current
        
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentDay = calendar.component(.day, from: currentDate)
        
        if year > currentYear || (year == currentYear && month > currentMonth) {
            // 인자로 받은 year과 month가 현재 연도와 월보다 크다면 실행 중지
            return
        }
        
        var day: Int = currentDay
        if year == currentYear && month == currentMonth{
            // 현재 연도와 월이 함수에 전달된 연도와 월과 동일하다면 현재 날짜로 설정
            day = currentDay
        }else{
            // 그렇지 않으면 마지막 날을 가져옴
            if let date = calendar.date(from: DateComponents(year: year, month: month)),
               let range = calendar.range(of: .day, in: .month, for: date) {
                day = range.count
            }
            
        }
        
        // day 변수를 사용하여 작업 수행
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let endDateString = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        let startDateString = "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", 1))"
        
        if let endDate = dateFormatter.date(from: endDateString),
           let startDate = dateFormatter.date(from: startDateString){
            let formattedEndDate = dateFormatter.string(from: endDate)
            let formattedStartDate = dateFormatter.string(from: startDate)
            print("\(formattedStartDate) ~ \(formattedEndDate)")
            
            // 1. Github Commit API 가져오고 변수 commitByMessage 채움
            getCommit(startDate: formattedStartDate, endDate: formattedEndDate) { commitByMessage, error in
                DispatchQueue.main.async { // 메인 큐에서 실행
                    self.getDayCommit() //2. 커밋한 날짜마다 커밋 갯수 저장
                    self.fsCalendar.reloadData() //3. UI load
                    self.planGroupTableView.reloadData()
                    
                    if year == currentYear && month == currentMonth {
                        self.setOwnerMonthTotal() //4. 한 달에 commit한 일 수 구하기
                    }
                    // 처음에 label들 실행
                    if let selectedDate = self.CselectedDate {
                        self.updateCommitInfo(for: selectedDate)
                    }
                }
            }
            
        } else {
            print("Invalid date string: \(endDateString)")
        }
        
    }
    
    // 커밋한 날짜들, 얼마나 커밋했는지
    func getDayCommit(){
        print("getDayCommit() 실행  =============================")
        if !commitByMessage.isEmpty { //commitByMessage 비어 있지 않으면
            for commit in commitByMessage {
                if let dateString = commit["date"] as? String { //"date" 값을 가지고와
                    if let count = commitByDayCount[dateString] { // 해당 date의 commitByDayCount를 가지고 와서 +1
                        commitByDayCount[dateString] = count + 1
                    } else {
                        commitByDayCount[dateString] = 1
                    }
                }
            }
        }
        
        // commitByDayCount 활용하여 원하는 작업 수행
        //        let sortedCommitByDayCount = commitByDayCount.sorted { $0.key < $1.key }
        //
        //        for (date, count) in sortedCommitByDayCount {
        //            print("Date: \(date), Commit Count: \(count)")
        //        }
        
        
    }
    
    //한 달에 commit한 일 수 구하기
    func setOwnerMonthTotal(){
        print("setOwnerMonthTotal() 실행 =============================")
        // commitByDayCount가 비어 있지 않고 Owner.getMontaotal()이 -1이 아닌 경우에만 실행
        if !commitByDayCount.isEmpty && Owner.getMonthTotal() < commitByDayCount.count {
            let size = commitByDayCount.count
            Owner.setMonthTotal(monthTotal: size)
            print("CommitByDayCount size: \(Owner.getMonthTotal())")
        }
    }
    
    // 선택된 날짜의 commit 내용, 갯수 출력
    func updateCommitInfo(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        if let commitMessage = commitByMessage.first(where: { ($0["date"] as? String) == dateString })?["message"] as? String {
            commitMessageLabel.text = commitMessage
        } else {
            commitMessageLabel.text = ""
        }
        
        let commitCount = commitByDayCount[dateString] ?? 0
        let commitText = commitCount == 1 ? "commit" : "commits"
        totalCommitLabel.text = "총 \(commitCount) 개의 \(commitText)"
    }
    
}


