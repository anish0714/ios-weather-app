//
//  ViewController.swift
//  WeatharApp
//
//  Created by user192032 on 7/13/21.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    
    
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var weather: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    
    let apiKey = "521b4b834c8b65916ead071942e41796"
    let apiUrl = "https://api.openweathermap.org/"
    let cityName = "Waterloo,ca"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getWeatherData()
    }

    func getWeatherData(){
                   let session = URLSession.shared
                    let queryUrl = URL(string:"\(apiUrl)data/2.5/weather?q=\(cityName)&units=metric&appid=\(apiKey)")!

                   let task = session.dataTask(with: queryUrl){
                       data, response, error in

                       if error != nil || data == nil {
                           print("SERVER IS DOWN")
                           return
                       }
                      
                       let r = response as? HTTPURLResponse
                       guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                           print("Server error \(String(describing: r?.statusCode))")
                           return
                       }
                       guard let mime = response.mimeType, mime == "application/json" else {
                           print("Incorrect MIME type: \(String(describing: r?.mimeType))")
                           return
                       }
                       
                       do{
                           let jsonObject = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                           print(jsonObject ?? "Error - API not working")
                           let cityName = jsonObject?["name"] as! String
                           let weatherType = jsonObject?["weather"] as? [Any]
                           let desc = (weatherType?[0] as? [String:Any])?["description"] as? String
                           let icon = (weatherType?[0] as? [String:Any])?["icon"] as? String
                           let mainObj = jsonObject?["main"] as? [String:Any]
                           let cityTemp = mainObj?["temp"] as? Double
                           let cityHumidity = mainObj?["humidity"] as? Double
                           
                        let windData = jsonObject?["wind"] as? [String:Any]
                        let cityWind = windData?["speed"] as? Double
                           
                           DispatchQueue.main.async {
                               self.city.text = cityName
                               self.weather.text = desc
                               
                               self.temperature.text = "\(cityTemp!) ℃"
                               self.humidity.text = "Humidity: \(cityHumidity!) %"
                            self.wind.text = "Wind: \(cityWind!) km/h"
                            
                            let weatherIconUrl = URL(string:"https://openweathermap.org/img/wn/\(icon!)@2x.png")!
                               self.weatherImg.imageFrom(url: weatherIconUrl)
                           }
                           
                       }catch {
                           print("JSON Error")
                       }
                   }
                   
                   task.resume()
               }
}
extension UIImageView{
  func imageFrom(url:URL){
    DispatchQueue.global().async { [weak self] in
      if let data = try? Data(contentsOf: url){
        if let image = UIImage(data:data){
          DispatchQueue.main.async{
            self?.image = image
          }
        }
      }
    }
  }
}

