//
//  PreferenceVC.swift
//  SsgSag
//
//  Created by CHOMINJI on 2019. 1. 5..
//  Copyright © 2019년 wndzlf. All rights reserved.
//

import UIKit

class PreferenceVC: UIViewController {
    
    let unActiveButtonImages: [String] = [
        "btPreferenceIdeaUnactive",
        "btPreferenceEconomyUnactive",
        "btPreferenceDesignUnactive",
        "btPreferenceLiteratureUnactive",
        "btPreferenceArtUnactive",
        "btPreferenceMarketingUnactive",
        "btPreferenceSocietyUnactive",
        "btPreferenceCameraUnactive",
        "btPreferenceStartupUnactive",
        "btPreferenceHealthUnactive",
        "btPreferenceSholarshipUnactive",
        "btPreferenceTechUnactive"
    ]
    
    let activeButtonImages: [String] = [
        "btPreferenceIdeaActive",
        "btPreferenceEconomyActive",
        "btPreferenceDesignActive",
        "btPreferenceLiteratureActive",
        "btPreferenceArtActive",
        "btPreferenceMarketingActive",
        "btPreferenceSocietyActive",
        "btPreferenceCameraActive",
        "btPreferenceStartupActive",
        "btPreferenceHealthActive",
        "btPreferenceSholarshipActive",
        "btPreferenceTechActive"
    ]
    
    var selectedValue: [Bool] = []
    
    @IBOutlet var preferenceButtons: [UIButton]!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPreferenceButtons()
        saveButton.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func postData() {
        
        var selectedInterests: [Int] = []
        for i in 0..<selectedValue.count {
            if selectedValue[i] == true {
                selectedInterests.append(i)
            }
        }
        print(selectedInterests)
        let json: [String: Any] = [
            "userInterest" : selectedInterests
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "http://52.78.86.179:8080/user/reInterestReq1")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = UserDefaults.standard.object(forKey: "SsgSagToken") as! String
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        NetworkManager.shared.getData(with: request) { (data, error, res) in
            guard let data = data else {
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("responseJSON \(responseJSON)")
                if let statusCode = responseJSON["status"] {
                    let status = statusCode as! Int
                    if status == 200 {
                        self.simplerAlert(title: "저장되었습니다")
                        self.getData()
                    } else {
                        self.simplerAlert(title: "저장에 실패하였습니다")
                    }
                }
            }
        }
       
        
    }
    
    func getData() {
        let url = URL(string: "http://52.78.86.179:8080/user/interest")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = UserDefaults.standard.object(forKey: "SsgSagToken") as! String
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        NetworkManager.shared.getData(with: request) { (data, error, res) in
            guard let data = data else {
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(Interests.self, from: data)
                
                print(apiResponse.data?.interests)
                
                self.setUpFirstStatus(interests: apiResponse.data?.interests)
                
            } catch (let err) {
                print(err.localizedDescription)
            }
        }
    }
    
    func setUpFirstStatus(interests: [Int]?) {
        guard let interests = interests else {
            saveButton.isUserInteractionEnabled = false
            return
        }
        
        for interest in interests {
            selectedValue[interest] = true
            preferenceButtons[interest].setImage(UIImage(named: activeButtonImages[interest]), for: .normal)
            preferenceButtons[interest].isSelected = true
        }
    }
    
    @IBAction func touchUpBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchUpPreferenceButtons(_ sender: UIButton) {
        print(sender.tag)
        myButtonTapped(myButton: sender, tag: sender.tag)
    }
    
    @IBAction func touchUpSaveButton(_ sender: Any) {
        postData()
    }
    
    func setUpPreferenceButtons() {
        var count = 0
        for button in preferenceButtons {
            button.tag = count
            count += 1
        }
        preferenceButtons.forEach { (button) in
            button.isSelected = false
        }
        for _ in 0 ..< count {
            selectedValue.append(false)
        }
    }
    
    func myButtonTapped(myButton: UIButton, tag: Int) {
        if myButton.isSelected {
            myButton.isSelected = false;
            selectedValue[myButton.tag] = false
            myButton.setImage(UIImage(named: unActiveButtonImages[tag]), for: .normal)
            saveButton.isUserInteractionEnabled = false
        } else {
            myButton.isSelected = true;
            selectedValue[myButton.tag] = true
            myButton.setImage(UIImage(named: activeButtonImages[tag]), for: .normal)
            saveButton.isUserInteractionEnabled = true
        }
        
        if selectedValue.contains(true) {
            saveButton.setImage(UIImage(named: "btSaveMypageActive"), for: .normal)
        } else {
            saveButton.setImage(UIImage(named: "btSaveMypageUnactive"), for: .normal)
        }
    }
    
}

