//
//  ViewController.swift
//  healthBot
//
//  Created by Yuwei Liu on 2023-11-07.
//

import UIKit
import HealthKit
import OpenAI


class ViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    private var temperatureSamples: Array<HKSample> = []
    
    @IBOutlet weak var textview: UITextView!
    
    @IBOutlet weak var clear: UIButton!
    
    private var kit: HKHealthStore! {
        return HKHealthStore()
    }
    
    private let queryTypeTemp = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
    private let queryTemp = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
    private let querySex = HKSampleType.characteristicType(forIdentifier: .biologicalSex)!
    private let queryBirth = HKSampleType.characteristicType(forIdentifier: .dateOfBirth)!
//
//    private let queryType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
//    private let querySample = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
//
    var resultMessage: String = ""
    var healthAdvice:String = ""
//    HKQuantityTypeIdentifier.stepCount.rawValue,
//               HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue,
//               HKQuantityTypeIdentifier.sixMinuteWalkTestDistance.rawValue,
//               HKCharacteristicTypeIdentifier.bloodType.rawValue,
//               HKCharacteristicTypeIdentifier.dateOfBirth.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 4
        clear.layer.cornerRadius = 4
        
        // Do any additional setup after loading the view.

//       button.setTitle("hi", for: .normal)
        if HKHealthStore.isHealthDataAvailable(){
            self.resultMessage = "h2"
            //  Write Authorize
            let queryTypeArray: Set<HKSampleType> = []
            //  Read Authorize
            let querySampleArray: Set<HKObjectType> = [queryTemp,querySex,queryBirth]
            kit.requestAuthorization(toShare: queryTypeArray, read: querySampleArray) { (success, error) in
                if success{
                    self.resultMessage = "success"
                    //print(self.resultMessage)
                    
                    print(self.querySex)
                    print(self.queryBirth)
                    self.getTemperatureData()
                } else {
                    print("hi")
                    self.resultMessage = "fail"
                    //self.showAlert(title: "Fail", message: "Unable to access to Health App", buttonTitle: "OK")
                }
            }
        } else {
            // show alert
            self.resultMessage = "fail2"
            //showAlert(title: "Fail", message: "设备不支持使用健康", buttonTitle: "退出")
        }
        //print(self.resultMessage)
//        DispatchQueue.main.async {
//            self.messageLabel.text = result
//        }
    }
   
//
    func getTemperatureData(){

        
        // 时间查询条件对象
        let calendar = Calendar.current
        let todayStart =  calendar.date(from: calendar.dateComponents([.year,.month,.day], from: Date()))
        //let dayPredicate = HKQuery.predicateForSamples(withStart: todayStart,
                                                   //    end: Date(timeInterval: 24*60*60,since: todayStart!),
                                                  //     options: HKQueryOptions.strictStartDate)

        // 创建查询对象
        let temperatureSampleQuery = HKSampleQuery(sampleType: queryTemp, // 要获取的类型对象
                                                   predicate: nil, // 时间参数，为空时则不限制时间
                                                   limit: 10, // 获取数量
                                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) // 获取到的数据排序方式
        { (query, results, error) in
            // print(results)
            /// 获取到结果之后 results 是返回的 [HKSample]?
            if let samples = results {
                // 挨个插入到 tableView 中
                for sample in samples {
         
                    DispatchQueue.main.async {
                        self.temperatureSamples.append(sample)

                    }
                }
            }
        }

        // 执行查询操作
        kit.execute(temperatureSampleQuery)
    }
    
    func getSexData(){

        
        // 时间查询条件对象
        let calendar = Calendar.current
        let todayStart =  calendar.date(from: calendar.dateComponents([.year,.month,.day], from: Date()))
//        let dayPredicate = HKQuery.predicateForSamples(withStart: todayStart,
//                                                       end: Date(timeInterval: 24*60*60,since: todayStart!),
//                                                       options: HKQueryOptions.strictStartDate)

        // 创建查询对象
        let temperatureSampleQuery = HKSampleQuery(sampleType: queryTemp, // 要获取的类型对象
                                                   predicate: nil, // 时间参数，为空时则不限制时间
                                                   limit: 10, // 获取数量
                                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) // 获取到的数据排序方式
        { (query, results, error) in
            // print(results)
            /// 获取到结果之后 results 是返回的 [HKSample]?
            if let samples = results {
                // 挨个插入到 tableView 中
                for sample in samples {
         
                    DispatchQueue.main.async {
                        self.temperatureSamples.append(sample)

                    }
                }
            }
        }

        // 执行查询操作
        kit.execute(temperatureSampleQuery)
    }
    
    func callOpenAIModelAPI(question: String) {
        
        // OpenAI configuration
        //let openAI = OpenAI(apiToken: "")
        let configuration = OpenAI.Configuration(token: "your token", organizationIdentifier: "org-jh7uuOZUv6DT47YwyhjBJlei", timeoutInterval: 60.0)
        let openAI = OpenAI(configuration: configuration)
        
        // request query
        let query = CompletionsQuery(model: .textDavinci_001, prompt: question, temperature: 0.8, maxTokens: 250, topP: 1, frequencyPenalty: 0, presencePenalty: 0, stop: ["\\n"])
      
        //let result = openAI.completions(query: query)
        openAI.completions(query: query) { result in
            switch result {
            case .success(let response):
                // 处理来自服务器的响应
                print("Response: \(response.choices[0].text)")
                let content = response.choices[0].text
                self.messageLabel.animate(newText: content, characterDelay: 0.07)
                // 可以将数据显示在您的 app 中
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        
    }

        
    func callSpassmedAPI(question: String) async {
        // 这个session可以使用刚才创建的。
        let session = URLSession(configuration: .default)
     
        let url = "https://spass-api-1da65389f5b1.herokuapp.com/chat"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
   
        request.httpMethod = "POST"
        
    
        
        
        let jsonstr = "{\"chat_history\":[{\"role\":\"user\",\"content\":\""+question+"\"}],\"model_to_use\": \"openai\"}"
        let jsondata = jsonstr.data(using: .utf8)
        print("hi")

        
       
       
        //request.httpBody = postString.data(using: .utf8)
        do {
            // convert parameters to Data and assign dictionary to httpBody of request
            let ok =  try JSONSerialization.jsonObject(with: jsondata!, options: .mutableContainers)
            request.httpBody = try JSONSerialization.data(withJSONObject: ok, options: .prettyPrinted)
            print(ok)
            print("here")
                
          } catch let error {
            print(error.localizedDescription)
            return
          }
        
        let task = try await URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
        
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Check if there is data
            guard let responseData = data else {
                print("No data received")
                return
            }

            do {
                // Parse the response data
                
                let jsonResponse = try NSString(data: responseData, encoding: String.Encoding.ascii.rawValue)! as String

                // Handle the response as needed
                print("Response: \(jsonResponse)")
                self.messageLabel.animate(newText: jsonResponse, characterDelay: 0.07)

            } catch let parsingError {
                print("Error while parsing response: \(parsingError.localizedDescription)")
            }
        }

        // Start the request
        task.resume()
    }

//        let request = OpenAI.CompletionRequest(prompt: "你好，")
//
//            // 发送请求
//        // 设置请求参数
//        let completionRequest = OpenAI.CompletionRequest(prompt: "Hello,")
//
//              // 发送请求
//              openAI.createCompletion(request: completionRequest) { result in
//                  switch result {
//                  case .success(let response):
//                      // 处理来自服务器的响应
//                      print("Response: \(response.choices)")
//                      // 可以将数据显示在您的 app 中
//                  case .failure(let error):
//                      print("Error: \(error)")
//                  }
//              }
//        }
    
//
//
//    /// 自定义方法：输入 HKSample 输出 日期和温度
//    func getTemperatureAndDate(sample: HKSample) -> (Date, Double) {
//        let quantitySample = sample as! HKQuantitySample
//        let date = sample.startDate
//        let temperature = quantitySample.quantity.doubleValue(for: .degreeCelsius())
//        return (date, temperature)
//    }
//
//    // MARK: - Table view data source
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return temperatureSamples.count
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath)
//        let (date, temperature) = getTemperatureAndDate(sample: temperatureSamples[indexPath.row])
//        cell.textLabel?.text = String(temperature)
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
//        dateFormatter.locale = Locale(identifier: "zh_CN")
//
//        cell.detailTextLabel?.text = dateFormatter.string(from: date)
//        return cell
//    }
//
//    // MARK: - Tool Methods - Alert
//    func showAlert(title: String, message: String, buttonTitle: String) {
//        let alert = UIAlertController(title: title,
//                                      message: message,
//                                      preferredStyle: .alert)
//        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
//        })
//        alert.addAction(okAction)
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//

    @IBAction func clickClear(_ sender: UIButton) {
        self.textview.text = ""
    }
    
    @IBAction func clickButton(_ sender: UIButton) {
        let sample = temperatureSamples[0] as! HKQuantitySample
        let temp = round(sample.quantity.doubleValue(for: .degreeCelsius()) * 100) / 100.0
        let content = "Your temperature is " + String(temp) + " degrees celsius."// temperatureSamples[0].startDate
        print(content)
       
        await callSpassmedAPI(question: self.textview.text)
          
                
                
                
                
            
            
            
            // History: extract health data
            //        print(sender.tag)
            //        let biologicalSex = try? kit.biologicalSex()
            //        var sex: String
            //
            //        if biologicalSex?.biologicalSex == .female {
            //            print("Female")
            //            sex = "Female"
            //        } else if biologicalSex?.biologicalSex == .male {
            //            print("Male")
            //            sex = "Male"
            //        } else if biologicalSex?.biologicalSex == .other {
            //            print("Other")
            //            sex = "Other"
            //        } else {
            //            print("Not available")
            //            sex = ""
            //        }
            //
            //        let dateOfBirth = try? kit.dateOfBirthComponents()
            //        var age: Int
            //
            //        if ((dateOfBirth?.isValidDate) != nil) {
            //            print("Avalible")
            //            age = 2023 - (dateOfBirth?.year ?? 2024)
            //        } else {
            //            print("Not available")
            //            age = -1
            ////            let interval = DateInterval(from: dateBirth as! Decoder, to: )
            //        }
            ////
            ////       let usersAge = ageComponents.year
            ////
            ////        let dateOfBirth = try? kit.dateOfBirthComponents()
            ////
            ////        var age = -1
            ////
            ////        if dateOfBirth != nil {
            ////            let now = Date()
            ////            let calendar = Calendar.current
            ////
            ////            let years = calendar.dateComponents([.year], from: calendar.date(dateOfBirth), to: now)).year
            ////            age = years ?? -1
            ////            let now = Date()
            ////            let calendar = Calendar.current
            ////
            ////            if let years = calendar.dateComponents([.year], from: dateOfBirth, to: now).year {
            ////                age = years
            ////            }
            //
            ////        }
            //
            //
            //        if button.currentTitle == "Get My Information" {
            //            let sample = temperatureSamples[0] as! HKQuantitySample
            //            let temp = round(sample.quantity.doubleValue(for: .degreeCelsius()) * 100) / 100.0
            //            let content = "Your are a " + String(age) + " years old " + sex + " with temperature " + String(temp) + " degrees celsius."// temperatureSamples[0].startDate
            //            self.messageLabel.animate(newText:content, characterDelay: 0.1)
            //            button.setTitle("Get Health Advice", for: .normal)
            //            let question = "My temperature is " + String(temp) + " degrees celsius. I am a " + String(age) + " years old " + sex + ". Can I get some health advice?"
            //            print(question)
            //            callOpenAIModelAPI(question: question)
            //
            //        } else {
            //            let content = healthAdvice// temperatureSamples[0].startDate
            //            self.messageLabel.animate(newText:content, characterDelay: 0.1)
            //           // messageLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            //            //messageLabel.text = healthAdvice
            //            button.setTitle("Enter a Chat with SpassBot", for: .normal)
            //
            //        }
            
            
            
            
        
    }

}
//

//
//  TemperatureTableViewController.swift
//  BodyTemparature
//
//  Created by Kyle on 2020/2/10.
//  Copyright © 2020 Cyan Maple. All rights reserved.
//
//
//import UIKit
//import HealthKit
//
///// 获取 Health 中的体温数据
//class TemperatureTableViewController: UITableViewController {
//
//    // 存储查询到的数据
//    private var temperatureSamples: Array<HKSample> = []
//
//
//    private var kit: HKHealthStore! {
//        return HKHealthStore()
//    }
//
//    private let queryType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!
//    private let querySample = HKSampleType.quantityType(forIdentifier: .bodyTemperature)!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        navigationItem.title = "体温记录 top 10"
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add",
//                                                            style: .plain,
//                                                            target: self,
//                                                            action: #selector(buttonPressed))
//
//
//        // 如果 iOS 11+ 显示大标题
//        if #available(iOS 11.0, *) {
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//        }
//
//
//        if HKHealthStore.isHealthDataAvailable(){
//            //  Write Authorize
//            let queryTypeArray: Set<HKSampleType> = [queryType]
//            //  Read Authorize
//            let querySampleArray: Set<HKObjectType> = [querySample]
//            kit.requestAuthorization(toShare: queryTypeArray, read: querySampleArray) { (success, error) in
//                if success{
//                    self.getTemperatureData()
//                } else {
//                    self.showAlert(title: "Fail", message: "Unable to access to Health App", buttonTitle: "OK")
//                }
//            }
//        } else {
//            // show alert
//            showAlert(title: "Fail", message: "设备不支持使用健康", buttonTitle: "退出")
//        }
//    }
//
//
//    @objc func buttonPressed() {
//        print("Button Pressed")
//        // TODO: Add temperature in modal view
//    }
//
//
//
//    func getTemperatureData(){
//
//        /*
//        // 时间查询条件对象
//        let calendar = Calendar.current
//        let todayStart =  calendar.date(from: calendar.dateComponents([.year,.month,.day], from: Date()))
//        let dayPredicate = HKQuery.predicateForSamples(withStart: todayStart,
//                                                       end: Date(timeInterval: 24*60*60,since: todayStart!),
//                                                       options: HKQueryOptions.strictStartDate) */
//
//        // 创建查询对象
//        let temperatureSampleQuery = HKSampleQuery(sampleType: querySample, // 要获取的类型对象
//                                                   predicate: nil, // 时间参数，为空时则不限制时间
//                                                   limit: 10, // 获取数量
//                                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) // 获取到的数据排序方式
//        { (query, results, error) in
//            /// 获取到结果之后 results 是返回的 [HKSample]?
//            if let samples = results {
//                // 挨个插入到 tableView 中
//                for sample in samples {
//                    DispatchQueue.main.async {
//                        self.temperatureSamples.append(sample)
//                        self.tableView.insertRows(at: [IndexPath(row: self.temperatureSamples.firstIndex(of: sample)!, section:0)],
//                                                  with: .right   )
//                    }
//                }
//            }
//        }
//
//        // 执行查询操作
//        kit.execute(temperatureSampleQuery)
//    }
//
//
//    /// 自定义方法：输入 HKSample 输出 日期和温度
//    func getTemperatureAndDate(sample: HKSample) -> (Date, Double) {
//        let quantitySample = sample as! HKQuantitySample
//        let date = sample.startDate
//        let temperature = quantitySample.quantity.doubleValue(for: .degreeCelsius())
//        return (date, temperature)
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return temperatureSamples.count
//    }
//
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TemperatureCell", for: indexPath)
//        let (date, temperature) = getTemperatureAndDate(sample: temperatureSamples[indexPath.row])
//        cell.textLabel?.text = String(temperature)
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
//        dateFormatter.locale = Locale(identifier: "zh_CN")
//
//        cell.detailTextLabel?.text = dateFormatter.string(from: date)
//        return cell
//    }
//
//    // MARK: - Tool Methods - Alert
//    func showAlert(title: String, message: String, buttonTitle: String) {
//        let alert = UIAlertController(title: title,
//                                      message: message,
//                                      preferredStyle: .alert)
//        let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
//        })
//        alert.addAction(okAction)
//        DispatchQueue.main.async {
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//}
extension UILabel {

    func animate(newText: String, characterDelay: TimeInterval) {

        DispatchQueue.main.async {

            self.text = ""
            var cnt: Int = 0

            for (index, character) in newText.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    if (character != " " || cnt < 30) {
                        self.text?.append(character)
                        cnt += 1
                    }
                    else {
                        self.text?.append("\n")
                        self.text?.append(character)
                        cnt = 0
                        
                    }
                    
                }
            }
        }
    }

}
