//
//  ViewController.swift
//  TimeManagerS
//
//  Created by Huafang Zhang on 2023-02-16.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var bigStatusButn: UIButton!
    @IBOutlet weak var detailReportButn: UIButton!
    @IBOutlet weak var statusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var currentStatusStartTimeLabel: UILabel!
    @IBOutlet weak var currentStatusLastTimeLabel: UILabel!
    @IBOutlet weak var todayWorkHourLabel: UILabel!
    @IBOutlet weak var todayStudyHourLabel: UILabel!
    @IBOutlet weak var todayExerciseHourLabel: UILabel!
    @IBOutlet weak var thisWeekWorkHourLabel: UILabel!
    @IBOutlet weak var thisWeekStudyHourLabel: UILabel!
    @IBOutlet weak var thisWeekExerciseHourLabel: UILabel!
    @IBOutlet weak var thisMonthWorkHourLabel: UILabel!
    @IBOutlet weak var thisMonthStudyHourLabel: UILabel!
    @IBOutlet weak var thisMonthExerciseHourLabel: UILabel!

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var tableBGView: UIView!
    @IBOutlet weak var closeTableViewButn: UIButton!
    @IBOutlet weak var recordTitleView: UIView!
    @IBOutlet weak var dailyTitleView: UIView!
    var myTableView: UITableView  =   UITableView()
    var itemsToLoad: [String] = ["One", "Two", "Three"]

    var statusArray = ["WORK", "STUDY", "EXERCISE"]
    var statusTitleArray = ["Work", "Study", "Exercise"]
    var statusIndex = 0
    
    var tableSegmentedIndex = 0
    var arrayDailyStrings = [String]()
    var arrayWeeklyStrings = [String]()
    var arrayMonthlyStrings = [String]()
    
    var isStartRecording = false
    var lastRecordStartDateTime = Date()
    weak var timerMain: Timer?
    
    var todayWorkInterval : Double = 0.0
    var todayStudyInterval : Double = 0.0
    var todayExerciseInterval : Double = 0.0
    var thisWeekWorkInterval : Double = 0.0
    var thisWeekStudyInterval : Double = 0.0
    var thisWeekExerciseInterval : Double = 0.0
    
    var dataModel = DataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(">>>>>>>Start viewDidLoad() \(Date())")
        // Do any additional setup after loading the view.

        self.bigStatusButn.layer.cornerRadius = self.bigStatusButn.frame.width/2.0
//        self.bigStatusButn.layer.borderWidth = 1
//        self.bigStatusButn.layer.borderColor = UIColor.black.cgColor
        self.bigStatusButn.clipsToBounds = true
        self.bigStatusButn.allowTextToScale()
        
//        self.detailReportButn.backgroundColor = .clear
        self.detailReportButn.layer.cornerRadius = 5
        self.detailReportButn.layer.borderWidth = 1
        self.detailReportButn.layer.borderColor = UIColor.black.cgColor
                
        let defaults = UserDefaults.standard
        self.statusIndex = defaults.integer(forKey: keyStatusIndex)
        self.isStartRecording = defaults.bool(forKey: keyIsStartRecording)
        self.lastRecordStartDateTime = defaults.object(forKey: keyLastRecordStartDateTime) as? Date ?? Date()
//        print(">>>>>>> \(self.statusIndex) : \(self.isStartRecording) :\(self.lastRecordStartDateTime)")
        self.statusSegmentedControl.selectedSegmentIndex = self.statusIndex
        self.statusSegmentedControl.tintColor = UIColor.yellow
//        self.statusSegmentedControl.backgroundColor = UIColor.gray
        
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(localeChanged), name: NSLocale.currentLocaleDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: UIApplication.significantTimeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dayChanged), name: .NSCalendarDayChanged, object: nil)
        
        timerLoopFunc()
        timerMain = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerLoopFunc), userInfo: nil, repeats: true)

        LoadPrintData(self.bigStatusButn)
        
        if (self.tableSegmentedIndex == 0)
        {
            self.dailyTitleView.isHidden = true
            self.recordTitleView.isHidden = false
        }
        else
        {
            self.dailyTitleView.isHidden = false
            self.recordTitleView.isHidden = true
        }

//        print(">>>>>>>End viewDidLoad() \(Date())")
    }
    
    deinit {
//        print("deinit")
        timerMain?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get main screen bounds
        let screenSize: CGRect = self.tableBGView.frame//UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        myTableView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        myTableView.dataSource = self
        myTableView.delegate = self
        
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        self.tableBGView.addSubview(myTableView)
        self.containView.isHidden = true
        
    }
    
    @IBAction func clickDetailReportButn(_ sender: Any)
    {
        //
        self.containView.isHidden = false
        
        self.myTableView.reloadData()
    }
    
    @IBAction func clickCloseTableViewButn(_ sender: Any)
    {
        //
        self.containView.isHidden = true
    }

    @IBAction func clickBigStatusButn(_ sender: Any)
    {
        let defaults = UserDefaults.standard
        
        if self.isStartRecording
        {
            self.isStartRecording = false

            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .weekday, .weekOfYear, .hour, .minute, .second], from: lastRecordStartDateTime)
            let year = components.year
            let month = components.month
            let day = components.day
            let weekday = components.weekday
            let weekOfYear = components.weekOfYear
            let hour = components.hour
            let minute = components.minute
            let second = components.second

//            print("clickBigStatusButn : \(year!) : \(month!) : \(day!) : \(weekday!) : \(weekOfYear!) : \(hour!) : \(minute!) : \(second!)")

            let endTime = Date()
            let timerInterval = endTime - lastRecordStartDateTime
//            print("clickBigStatusButn timerInterval : \(timerInterval)")

            //save current data: statusIndex, statusName, startTime, endtime, timerInterval, year, month, day, weekday, weekofyear
            dataModel.saveTrack.append(SavedTracks(nIndex : Int32(self.statusIndex), strName:self.statusArray[self.statusIndex], startDTime:self.lastRecordStartDateTime, endDTime: endTime, dbInterval: timerInterval, nYear: Int32(year!), nMonth: Int32(month!), nDay: Int32(day!), nWeekDay: Int32(weekday!), nWeekOfYear: Int32(weekOfYear!) ))
            
            dataModel.saveData()
            
            self.getStatistics4CurrentSavedData()
            
//            self.myTableView.reloadData()
        }
        else
        {
            self.isStartRecording = true
            lastRecordStartDateTime = Date()
            defaults.set(self.lastRecordStartDateTime, forKey: keyLastRecordStartDateTime)
        }
        
        defaults.set(self.isStartRecording, forKey: keyIsStartRecording)
        
        updateUI()
        
    }
    
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl!)
    {
//        print("Selected Segment Index is : \(sender.selectedSegmentIndex)")
        
        self.statusIndex = sender.selectedSegmentIndex
        
        let defaults = UserDefaults.standard
        defaults.set(self.statusIndex, forKey: keyStatusIndex)
    }
    
    @IBAction func segmentedTableValueChanged(_ sender: UISegmentedControl!)
    {
//        print("Selected SegmentTable Index is : \(sender.selectedSegmentIndex)")
        
        self.tableSegmentedIndex = sender.selectedSegmentIndex
        
        if (self.tableSegmentedIndex == 0)
        {
            self.dailyTitleView.isHidden = true
            self.recordTitleView.isHidden = false
        }
        else
        {
            self.dailyTitleView.isHidden = false
            self.recordTitleView.isHidden = true
        }
        
        self.myTableView.reloadData()
        
    }
    
    @objc func localeChanged(_ notification: Notification) {
//        print("Locale changed")
    }
    
    @objc func dayChanged(_ notification: Notification) {
//        print("Day changed")
        //待处理： 如果一直开着，跨过了午夜如何处理？
    }
    
    @objc func timerLoopFunc() {
//        print("In the timer loop function")

        if self.isStartRecording
        {
            //update the time label
            let curDateTime = Date()
            let timerInterval = curDateTime - lastRecordStartDateTime

            self.currentStatusLastTimeLabel.text = DWDateTool.getTimeStringFromInterval(Int(timerInterval))
            
        }
        else
        {
        }
    }
    
    func updateUI()
    {
        if self.isStartRecording
        {
            self.statusSegmentedControl.isEnabled = false
            self.bigStatusButn.setTitle("STOP", for: UIControl.State.normal)

            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let timezone = NSTimeZone.system
            formatter.timeZone = timezone
            let stringDateTime = formatter.string(from: lastRecordStartDateTime)
            self.currentStatusStartTimeLabel.text = String(format: "\(statusTitleArray[self.statusSegmentedControl.selectedSegmentIndex]) started at \(stringDateTime)")
            self.currentStatusStartTimeLabel.isHidden = false

        }
        else
        {
            self.statusSegmentedControl.isEnabled = true
            self.bigStatusButn.setTitle("START", for: UIControl.State.normal)
            
            self.currentStatusLastTimeLabel.text = "00:00:00"
            self.currentStatusStartTimeLabel.isHidden = true

        }
    }

    @IBAction func saveData(_ sender: UIButton) {
        dataModel.saveData()
//        print("saveData succeed")
    }
    
    @IBAction func LoadPrintData(_ sender: UIButton) {

        dataModel.loadData()
        self.getStatistics4CurrentSavedData()
    }
    
    func getStatistics4CurrentSavedData(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        let timezone = NSTimeZone.system
        formatter.timeZone = timezone
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekOfYear,/* .weekday, .hour, .minute, .second*/], from: Date())
        let year = components.year
        let month = components.month
        let day = components.day
//        let weekday = components.weekday
        let weekOfYear = components.weekOfYear
//        let hour = components.hour
//        let minute = components.minute
//        let second = components.second

        todayWorkInterval = 0.0
        todayStudyInterval = 0.0
        todayExerciseInterval = 0.0
        thisWeekWorkInterval = 0.0
        thisWeekStudyInterval = 0.0
        thisWeekExerciseInterval = 0.0

//        var stopLoopDay = false
//        var stopLoopWeek = false
        var lastSavedTrack : SavedTracks?
        var dbDailyWorkInterval = 0.0
        var dbDailyStudyInterval = 0.0
        var dbDailyExerInterval = 0.0
        var dbWeeklyWorkInterval = 0.0
        var dbWeeklyStudyInterval = 0.0
        var dbWeeklyExerInterval = 0.0
        var dbMonthlyWorkInterval = 0.0
        var dbMonthlyStudyInterval = 0.0
        var dbMonthlyExerInterval = 0.0
        
        self.arrayDailyStrings.removeAll()
        self.arrayWeeklyStrings.removeAll()
        self.arrayMonthlyStrings.removeAll()

        let nCount = dataModel.saveTrack.count
        for i in 0..<nCount
        {
            let curIndex = nCount - 1 - i
            let curSavedTracks = dataModel.saveTrack[curIndex]
            if (i == 0)
            {
                lastSavedTrack = dataModel.saveTrack[curIndex]
                if (curSavedTracks.statusIndex == 0)
                {
                    dbDailyWorkInterval += curSavedTracks.timerInterval
                    dbWeeklyWorkInterval += curSavedTracks.timerInterval
                    dbMonthlyWorkInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 1)
                {
                    dbDailyStudyInterval += curSavedTracks.timerInterval
                    dbWeeklyStudyInterval += curSavedTracks.timerInterval
                    dbMonthlyStudyInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 2)
                {
                    dbDailyExerInterval += curSavedTracks.timerInterval
                    dbWeeklyExerInterval += curSavedTracks.timerInterval
                    dbMonthlyExerInterval += curSavedTracks.timerInterval
                }
            }
            else
            {
                if ((curSavedTracks.startYear == lastSavedTrack!.startYear) && (curSavedTracks.startMonth == lastSavedTrack!.startMonth) && (curSavedTracks.startDay == lastSavedTrack!.startDay))
                {
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbDailyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbDailyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbDailyExerInterval += curSavedTracks.timerInterval
                    }
                }
                else
                {//This is another day, 1. push the old data to the Array. 2. reset the data.  3.recalculate the data
                    
                    let strWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyWorkInterval))
                    
                    let strStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyStudyInterval))
                    
                    let strExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyExerInterval))

                    let strTmpDaily = String(format: "%d/%02d/%02d \(arrayWeek[Int(lastSavedTrack!.startWeekDay)-1]) (\(strWorkDuration)) (\(strStudyDuration)) (\(strExerDuration))", (lastSavedTrack!.startYear), (lastSavedTrack!.startMonth), (lastSavedTrack!.startDay))
//                    let strTmp = "\(lastSavedTrack!.startYear)/\(lastSavedTrack!.startMonth)/\(lastSavedTrack!.startDay) \(arrayWeek[Int(lastSavedTrack!.startWeekDay)-1]) (\(strWorkDuration)) (\(strStudyDuration)) (\(strExerDuration))"
                    arrayDailyStrings.insert(strTmpDaily, at: 0)
                    
                    dbDailyWorkInterval = 0.0
                    dbDailyStudyInterval = 0.0
                    dbDailyExerInterval = 0.0
                    
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbDailyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbDailyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbDailyExerInterval += curSavedTracks.timerInterval
                    }
                }
                
                
                if ((curSavedTracks.startYear == lastSavedTrack!.startYear) && (curSavedTracks.startWeekOfYear == lastSavedTrack!.startWeekOfYear))
                {// 待处理: 一年的第一周和一年的最后一周怎么处理？
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbWeeklyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbWeeklyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbWeeklyExerInterval += curSavedTracks.timerInterval
                    }
                }
                else
                {//This is another week, 1. push the old data to the Array. 2. reset the data.  3.recalculate the data
                    
                    let strWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyWorkInterval))
                    let strStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyStudyInterval))
                    let strExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyExerInterval))
                    
                    let strWeekRange = DWDateTool.getWeekRangeforDate(Int((lastSavedTrack!.startYear)), Int((lastSavedTrack!.startMonth)), Int((lastSavedTrack!.startDay)))
                    let strTmp = "\(strWeekRange) (\(strWorkDuration)) (\(strStudyDuration)) (\(strExerDuration))"
                    arrayWeeklyStrings.insert(strTmp, at: 0)
                    
                    dbWeeklyWorkInterval = 0.0
                    dbWeeklyStudyInterval = 0.0
                    dbWeeklyExerInterval = 0.0
                    
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbWeeklyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbWeeklyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbWeeklyExerInterval += curSavedTracks.timerInterval
                    }
                }
                
                if ((curSavedTracks.startYear == lastSavedTrack!.startYear) && (curSavedTracks.startMonth == lastSavedTrack!.startMonth))
                {//
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbMonthlyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbMonthlyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbMonthlyExerInterval += curSavedTracks.timerInterval
                    }
                }
                else
                {//This is another month, 1. push the old data to the Array. 2. reset the data.  3.recalculate the data
                    
                    let strWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyWorkInterval))
                    let strStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyStudyInterval))
                    let strExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyExerInterval))
                    
                    let strTmp = String(format: "\(lastSavedTrack!.startYear)/%02d  \(arrayMonth[Int(lastSavedTrack!.startMonth)-1])  (\(strWorkDuration)) (\(strStudyDuration)) (\(strExerDuration))", (lastSavedTrack!.startMonth))
                    arrayMonthlyStrings.insert(strTmp, at: 0)
                    
                    dbMonthlyWorkInterval = 0.0
                    dbMonthlyStudyInterval = 0.0
                    dbMonthlyExerInterval = 0.0
                    
                    if (curSavedTracks.statusIndex == 0)
                    {
                        dbMonthlyWorkInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 1)
                    {
                        dbMonthlyStudyInterval += curSavedTracks.timerInterval
                    }
                    else if (curSavedTracks.statusIndex == 2)
                    {
                        dbMonthlyExerInterval += curSavedTracks.timerInterval
                    }
                }
                lastSavedTrack = dataModel.saveTrack[curIndex]
            }
//            print(">>>>>> Line\(curIndex) : \(curSavedTracks.statusIndex) : \(curSavedTracks.statusName) : \(formatter.string(from: curSavedTracks.startDateTime)) : \(formatter.string(from: curSavedTracks.endDateTime)) : \(curSavedTracks.timerInterval) : \(curSavedTracks.startYear) : \(curSavedTracks.startMonth) : \(curSavedTracks.startDay) : \(curSavedTracks.startWeekDay) : \(curSavedTracks.startWeekOfYear)")
            
            if ((curSavedTracks.startYear == year!) && (curSavedTracks.startMonth == month!) && (curSavedTracks.startDay == day!))
            {
                if (curSavedTracks.statusIndex == 0)
                {
                    todayWorkInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 1)
                {
                    todayStudyInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 2)
                {
                    todayExerciseInterval += curSavedTracks.timerInterval
                }
            }
//            else
//            {
//                stopLoopDay = true
//            }
            
            if ((curSavedTracks.startYear == year!) && (curSavedTracks.startWeekOfYear == weekOfYear!))
            {// 待处理: 一年的第一周和一年的最后一周怎么处理？
                if (curSavedTracks.statusIndex == 0)
                {
                    thisWeekWorkInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 1)
                {
                    thisWeekStudyInterval += curSavedTracks.timerInterval
                }
                else if (curSavedTracks.statusIndex == 2)
                {
                    thisWeekExerciseInterval += curSavedTracks.timerInterval
                }
            }
//            else
//            {
//                stopLoopWeek = true
//            }
            
//            if (stopLoopDay && stopLoopWeek)
//            {
//                break
//            }
        }
        
        //Need to handle the last recording for Daily/Weekly/Monthly array.
        //1. push the old data to the Arrays. 2. reset the data.
        
        let strDailyWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyWorkInterval))
        let strDailyStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyStudyInterval))
        let strDailyExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbDailyExerInterval))
        let strTmpDaily = String(format: "%d/%02d/%02d \(arrayWeek[Int(lastSavedTrack!.startWeekDay)-1]) (\(strDailyWorkDuration)) (\(strDailyStudyDuration)) (\(strDailyExerDuration))", (lastSavedTrack!.startYear), (lastSavedTrack!.startMonth), (lastSavedTrack!.startDay))
        arrayDailyStrings.insert(strTmpDaily, at: 0)
        
        
        let strWeeklyWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyWorkInterval))
        let strWeeklyStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyStudyInterval))
        let strWeeklyExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbWeeklyExerInterval))
        
        let strWeekRange = DWDateTool.getWeekRangeforDate(Int((lastSavedTrack!.startYear)), Int((lastSavedTrack!.startMonth)), Int((lastSavedTrack!.startDay)))
        let strTmpWeekly = "\(strWeekRange) (\(strWeeklyWorkDuration)) (\(strWeeklyStudyDuration)) (\(strWeeklyExerDuration))"
        arrayWeeklyStrings.insert(strTmpWeekly, at: 0)
        
        
        let strMonthWorkDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyWorkInterval))
        let strMonthStudyDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyStudyInterval))
        let strMonthExerDuration = DWDateTool.getTimeStringFromInterval(Int(dbMonthlyExerInterval))
        
        let strTmpMonthly = String(format: "\(lastSavedTrack!.startYear)/%02d  \(arrayMonth[Int(lastSavedTrack!.startMonth)-1])  (\(strMonthWorkDuration)) (\(strMonthStudyDuration)) (\(strMonthExerDuration))", (lastSavedTrack!.startMonth))
        arrayMonthlyStrings.insert(strTmpMonthly, at: 0)
        
        dbDailyWorkInterval = 0.0
        dbDailyStudyInterval = 0.0
        dbDailyExerInterval = 0.0
        
        dbWeeklyWorkInterval = 0.0
        dbWeeklyStudyInterval = 0.0
        dbWeeklyExerInterval = 0.0
        
        dbMonthlyWorkInterval = 0.0
        dbMonthlyStudyInterval = 0.0
        dbMonthlyExerInterval = 0.0
        
        
        //Update the labels
        self.todayWorkHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(todayWorkInterval))
        
        self.todayStudyHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(todayStudyInterval))
        
        self.todayExerciseHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(todayExerciseInterval))
        
        self.thisWeekWorkHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(thisWeekWorkInterval))
        
        self.thisWeekStudyHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(thisWeekStudyInterval))
        
        self.thisWeekExerciseHourLabel.text = DWDateTool.getTimeStringFromInterval(Int(thisWeekExerciseInterval))

//        print("LoadData succeed!")
    }
    
    
    ///////////////////////////////////////////TableView Begin
    ///
    func getTableItemCount() -> Int
    {
        if (self.tableSegmentedIndex == 0)
        {
            let nCount = dataModel.saveTrack.count
            return (nCount > maxTableItemCount) ? maxTableItemCount : nCount
        }
        else if (self.tableSegmentedIndex == 1)
        {
            let nCount = arrayDailyStrings.count
            return (nCount > maxTableItemCount) ? maxTableItemCount : nCount
        }
        else if (self.tableSegmentedIndex == 2)
        {
            let nCount = arrayWeeklyStrings.count
            return (nCount > maxTableItemCount) ? maxTableItemCount : nCount
        }
        else
        {
            let nCount = arrayMonthlyStrings.count
            return (nCount > maxTableItemCount) ? maxTableItemCount : nCount
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return getTableItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath as IndexPath)
        
        var nCount = dataModel.saveTrack.count//self.tableSegmentedIndex == 0
        if (self.tableSegmentedIndex == 1)
        {
            nCount = arrayDailyStrings.count
        }
        else if (self.tableSegmentedIndex == 2)
        {
            nCount = arrayWeeklyStrings.count
        }
        else  if (self.tableSegmentedIndex == 3)
        {
            nCount = arrayMonthlyStrings.count
        }
        let curIndex = nCount - 1 - indexPath.row
        let curSavedTracks = dataModel.saveTrack[curIndex]
        
        let strLastTime = DWDateTool.getTimeStringFromInterval(Int(curSavedTracks.timerInterval))
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([ .hour, .minute, .second], from: curSavedTracks.startDateTime)
        let hour1 = components.hour
        let minute1 = components.minute
        let second1 = components.second
        
        let components2 = calendar.dateComponents([ .hour, .minute, .second], from: curSavedTracks.endDateTime)
        let hour2 = components2.hour
        let minute2 = components2.minute
        let second2 = components2.second
        
        let strPeroid = String(format: "%02d:%02d:%02d - %02d:%02d:%02d", hour1!, minute1!, second1!, hour2!, minute2!, second2!)
        
        // \(arrayWeek[Int(curSavedTracks.startWeekDay)-1])
        let strTmp = String(format: "%d/%02d/%02d \(curSavedTracks.statusName.prefix(5)) \(strLastTime) (\(strPeroid))", (curSavedTracks.startYear), (curSavedTracks.startMonth), (curSavedTracks.startDay) )
        
        if (self.tableSegmentedIndex == 0)
        {
            cell.textLabel?.text = strTmp
        }
        else if (self.tableSegmentedIndex == 1)
        {
            cell.textLabel?.text = self.arrayDailyStrings[curIndex]
        }
        else if (self.tableSegmentedIndex == 2)
        {
            cell.textLabel?.text = self.arrayWeeklyStrings[curIndex]
        }
        else
        {
            cell.textLabel?.text = self.arrayMonthlyStrings[curIndex]
        }
        
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    private func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
//        print("User selected table row \(indexPath.row) and item \(itemsToLoad[indexPath.row])")
    }
    
    ///////////////////////////////////////////TableView End

}

