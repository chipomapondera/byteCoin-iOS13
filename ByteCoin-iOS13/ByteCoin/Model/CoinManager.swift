//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didGetPrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
//    Optional delegate implements delegate methods
//    which we can notify when we have updated the price
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "B0F3A0F2-E24E-4972-B4E0-1AF1C07D1EB1"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)

            //1. Create a URL
            if let url = URL(string: urlString) {
                //2. Create a URLSession object with default configuration
                let session = URLSession(configuration: .default)
                
                //3. Give the session a task
                //            let task = session.dataTask(with: url, completionHandler: handle(data) response: error: ))
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        self.delegate?.didFailWithError(error: error!)
                        return
                    }
//                    Format the data we got back as a string to be able to print it
//                    let dataAsString = String(data: data!, encoding: .utf8)
//                    print(dataAsString!)
                    
                    if let safeData = data {
                        if let bitcoinPrice = self.parseJSON(safeData) {
                            let priceString = String(format: "%.2f", bitcoinPrice)
                            self.delegate?.didGetPrice(price: priceString, currency: currency)
                        }
                    }
                }
                
                //4. Start the task to fetch the data from bitcoin average's servers
                task.resume()
            }
        }
    
    func parseJSON(_ data: Data) -> Double? {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CoinData.self, from: data)
                let lastPrice = decodedData.rate
                print(lastPrice)
                return lastPrice
            } catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
    
    
    
}
