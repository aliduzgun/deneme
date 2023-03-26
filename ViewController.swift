import UIKit

class ViewController: UIViewController {
    var fastingTime = 16 * 60 * 60
    var timer = Timer()
    var isTimerRunning = false
    var timePicker:UIDatePicker?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var bitisSaati: UILabel!
    @IBOutlet weak var baslangicTextField: UITextField!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        timePicker = UIDatePicker()
        timePicker?.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker?.preferredDatePickerStyle = .wheels
        }
        timePicker?.locale = Locale(identifier: "tr_TR")
        baslangicTextField.inputView = timePicker
        timePicker?.addTarget(self, action: #selector(self.saatGoster(timePicker:)), for: .valueChanged)
        let dokunmaAlgilama = UITapGestureRecognizer(target: self, action: #selector(self.dokunmaAlgilamaMetod))
        view.addGestureRecognizer(dokunmaAlgilama)
        
        label.text = timeString(time: TimeInterval(fastingTime))
        if let date = UserDefaults.standard.object(forKey: "startDate") as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            baslangicTextField.text = dateFormatter.string(from: date)
            if let endDate = Calendar.current.date(byAdding: .second, value: fastingTime, to: date) {
                bitisSaati.text = dateFormatter.string(from: endDate)
            } else {
                bitisSaati.text = ""
            }
        } else {
            baslangicTextField.text = ""
            bitisSaati.text = ""
        }
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeTimer), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    @IBAction func buttonPressed(_ sender: Any) {
        if isTimerRunning {
            timer.invalidate()
            isTimerRunning = false
            fastingTime = 16 * 60 * 60
            label.text = timeString(time: TimeInterval(fastingTime))
            baslangicTextField.text = "00:00"
                   bitisSaati.text = "00:00"
            button.setTitle("Başlat", for: .normal)
        } else {
            runTimer()
            isTimerRunning = true
            button.setTitle("Durdur", for: .normal)
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            baslangicTextField.text = dateFormatter.string(from: now)
            if let endDate = Calendar.current.date(byAdding: .second, value: fastingTime, to: now) {
                bitisSaati.text = dateFormatter.string(from: endDate)
            } else {
                bitisSaati.text = ""
            }
            UserDefaults.standard.set(now, forKey: "startDate")
        }
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    @objc func updateTimer() {
        if let startDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
            let elapsedTime = Date().timeIntervalSince(startDate)
            let remainingTime = max(fastingTime - Int(elapsedTime), 0)
            if remainingTime == 0 {
                timer.invalidate()
                label.text = "Orucunuz tamamlandı!"
                baslangicTextField.text = "00:00"
                       bitisSaati.text = "00:00"
            } else {
                label.text = timeString(time: TimeInterval(remainingTime))
            }
        }
    }
    func timeString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    @objc func pauseTimer() {
        timer.invalidate()
        UserDefaults.standard.set(fastingTime, forKey: "fastingTime")
        UserDefaults.standard.set(Date(), forKey: "pauseDate")

    }
    @objc func resumeTimer() {
        if let pauseDate = UserDefaults.standard.object(forKey: "pauseDate") as? Date {
            let pauseInterval = -pauseDate.timeIntervalSinceNow
            if var remainingTime = UserDefaults.standard.object(forKey: "fastingTime") as? Int {
                remainingTime = remainingTime - Int(pauseInterval)
                if remainingTime < 0 {
                    remainingTime = 0
                }
                fastingTime = remainingTime
                runTimer()
                label.text = timeString(time: TimeInterval(fastingTime))
                button.setTitle("Durdur", for: .normal)
                isTimerRunning = true
                if let startDate = UserDefaults.standard.object(forKey: "startDate") as? Date {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    baslangicTextField.text = dateFormatter.string(from: startDate)
                    if let endDate = Calendar.current.date(byAdding: .second, value: fastingTime, to: startDate) {
                        bitisSaati.text = dateFormatter.string(from: endDate)
                    } else {
                        bitisSaati.text = ""
                    }
                }
            }
        }
    }
    @objc func saatGoster(timePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        baslangicTextField.text = dateFormatter.string(from: timePicker.date)
        UserDefaults.standard.set(timePicker.date, forKey: "startDate")
        updateTimer()
        if let startDate = timePicker.date as? Date {
            if let endDate = Calendar.current.date(byAdding: .second, value: fastingTime, to: startDate) {
                bitisSaati.text = dateFormatter.string(from: endDate)
            } else {
                bitisSaati.text = ""
            }
        }
    }

    
   /*  @objc func saatGoster(timePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        baslangicTextField.text = dateFormatter.string(from: timePicker.date)
        UserDefaults.standard.set(timePicker.date, forKey: "startDate")
        updateTimer()
            
    } */



    @objc func dokunmaAlgilamaMetod(){
        view.endEditing(true)
        
    }
}


