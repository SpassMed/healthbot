//
//  ViewController.swift
//  healthBot
//
//  Created by Yuwei Liu on 2023-11-07.
//

import UIKit
import HealthKit

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

    var resultMessage: String = ""
    var healthAdvice:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        button.layer.cornerRadius = 4
        clear.layer.cornerRadius = 4

        if HKHealthStore.isHealthDataAvailable(){
            self.resultMessage = "h2"
            //  Write Authorize
            let queryTypeArray: Set<HKSampleType> = []
            //  Read Authorize
            let querySampleArray: Set<HKObjectType> = [queryTemp,querySex,queryBirth]
            kit.requestAuthorization(toShare: queryTypeArray, read: querySampleArray) { (success, error) in
                if success{
                    self.resultMessage = "success"
                    self.getTemperatureData()
                } else {
                    self.resultMessage = "fail"
                }
            }
        } else {
            self.resultMessage = "fail2"
        }
    }

    func getTemperatureData(){

        
        let calendar = Calendar.current
        let todayStart =  calendar.date(from: calendar.dateComponents([.year,.month,.day], from: Date()))
        let temperatureSampleQuery = HKSampleQuery(sampleType: queryTemp, // 要获取的类型对象
                                                   predicate: nil, // 时间参数，为空时则不限制时间
                                                   limit: 10, // 获取数量
                                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) // 获取到的数据排序方式
        { (query, results, error) in
            if let samples = results {
                for sample in samples {
         
                    DispatchQueue.main.async {
                        self.temperatureSamples.append(sample)

                    }
                }
            }
        }

        kit.execute(temperatureSampleQuery)
    }
    
    func getSexData(){

        
        let calendar = Calendar.current
        let todayStart =  calendar.date(from: calendar.dateComponents([.year,.month,.day], from: Date()))

        let temperatureSampleQuery = HKSampleQuery(sampleType: queryTemp, 
                                                   predicate: nil, 
                                                   limit: 10, 
                                                   sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) // 获取到的数据排序方式
        { (query, results, error) in
            if let samples = results {
                for sample in samples {
         
                    DispatchQueue.main.async {
                        self.temperatureSamples.append(sample)

                    }
                }
            }
        }

        kit.execute(temperatureSampleQuery)
    }
    
    

        
    func callSpassmedAPI(question: String) async {
        let session = URLSession(configuration: .default)
     
        let url = "https://spass-api-1da65389f5b1.herokuapp.com/chat"
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("*/*", forHTTPHeaderField: "accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        
        let jsonstr = "{\"chat_history\":[{\"role\":\"user\",\"content\":\""+question+"\"}],\"model_to_use\": \"openai\"}"
        let jsondata = jsonstr.data(using: .utf8)
     
        
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
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let responseData = data else {
                print("No data received")
                return
            }

            do {
                
                let jsonResponse = try NSString(data: responseData, encoding: String.Encoding.ascii.rawValue)! as String

               
                print("Response: \(jsonResponse)")
                self.messageLabel.animate(newText: jsonResponse, characterDelay: 0.07)

            } catch let parsingError {
                print("Error while parsing response: \(parsingError.localizedDescription)")
            }
        }

        task.resume()
    }

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
            //            let interval = DateInterval(from: dateBirth as! Decoder, to: )
            //        }
            //
            //       let usersAge = ageComponents.year
            //
            //        let dateOfBirth = try? kit.dateOfBirthComponents()
            //
            //        var age = -1
            //
            //        if dateOfBirth != nil {
            //            let now = Date()
            //            let calendar = Calendar.current
            //
            //            let years = calendar.dateComponents([.year], from: calendar.date(dateOfBirth), to: now)).year
            //            age = years ?? -1
            //            let now = Date()
            //            let calendar = Calendar.current
            //
            //            if let years = calendar.dateComponents([.year], from: dateOfBirth, to: now).year {
            //                age = years
            //            }
            //
            //        }
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
