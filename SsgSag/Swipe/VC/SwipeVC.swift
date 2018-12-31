
let  MAX_BUFFER_SIZE = 3;
let  SEPERATOR_DISTANCE = 8;
let  TOPYAXIS = 75;
//조민지

import UIKit

class SwipeVC: UIViewController {
    
    //@IBOutlet weak var emojiView: EmojiRateView!
    @IBOutlet weak var viewTinderBackGround: UIView!
    @IBOutlet weak var buttonUndo: UIButton!
    @IBOutlet weak var viewActions: UIView!

    var currentIndex = 0
    
    var currentLoadedCardsArray = [SwipeCard]()
    var allCardsArray = [SwipeCard]()
    
    var valueArray = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewActions.alpha = 0
        buttonUndo.alpha = 0
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        viewTinderBackGround.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    @IBAction func moveToCalendar(_ sender: Any) {
        let calendarVC = CalenderVC()
        present(calendarVC, animated: true, completion: nil)
    }
    
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        print("tapped Poster")
    
        //        let tappedImage = tapGestureRecognizer.view
        //        tappedImage.
        //
        //        let storyboard = UIStoryboard(name: "Tinder", bundle: nil)
        //        let showVC = storyboard.instantiateViewController(withIdentifier: "MovieFullImageVC") as! MovieFullImageVC
        //
        //        self.present(showVC, animated: false) {
        //                showVC.fullScreen.image = tappedImage.image
        //        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.layoutIfNeeded()
        loadCardValues()
    }
    
    @objc func animateEmojiView(timer : Timer){
        //        let sender = timer.userInfo as! EmojiRateView
        //        emojiView.rateValue =  emojiView.rateValue + 0.2
        //        if sender.rateValue >= 5 {
        //            timer.invalidate()
        //            emojiView.rateValue = 2.5
        //        }
    }
    
    
    func loadCardValues() {
        
        if valueArray.count > 0 {
            
            let capCount = (valueArray.count > MAX_BUFFER_SIZE) ? MAX_BUFFER_SIZE : valueArray.count
            
            for (i,value) in valueArray.enumerated() {
                let newCard = createTinderCard(at: i,value: value)
                allCardsArray.append(newCard)
                if i < capCount {
                    currentLoadedCardsArray.append(newCard)
                }
            }
            
            for (i,_) in currentLoadedCardsArray.enumerated() {
                
                print(i)
                
                if i > 0 {
                    viewTinderBackGround.insertSubview(currentLoadedCardsArray[i], belowSubview: currentLoadedCardsArray[i - 1])
                    
                    let storyboard = UIStoryboard(name: "SwipeStoryBoard", bundle: nil)
                    let pageVC = storyboard.instantiateViewController(withIdentifier: "PageViewController")

                    pageVC.view.frame = self.currentLoadedCardsArray[i].frame
                    self.addChild(pageVC)
                    self.currentLoadedCardsArray[i].addSubview(pageVC.view)
                    self.currentLoadedCardsArray[i-1].addSubview(pageVC.view)
                    pageVC.didMove(toParent: self)
                    
                    //viewTinderBackGround.addSubview(pageVC.view)
                    //pageVC.view.frame = self.viewTinderBackGround.frame
                    //self.addChild(pageVC)
                    //self.viewTinderBackGround.addSubview(pageVC.view)
                    //pageVC.didMove(toParent: self)
                    
                } else {
                    viewTinderBackGround.addSubview(currentLoadedCardsArray[i])
                    
                    let storyboard = UIStoryboard(name: "SwipeStoryBoard", bundle: nil)
                    let pageVC = storyboard.instantiateViewController(withIdentifier: "PageViewController")
                    
                    pageVC.view.frame = self.currentLoadedCardsArray[i].frame
                    self.addChild(pageVC)
                    self.currentLoadedCardsArray[i].addSubview(pageVC.view)
                    
                    pageVC.didMove(toParent: self)
                }
            }
            
            animateCardAfterSwiping()
            
            perform(#selector(loadInitialDummyAnimation), with: nil, afterDelay: 1.0)
        }
    }
    
    @objc func loadInitialDummyAnimation() {
        
        //        let dummyCard = currentLoadedCardsArray.first;
        //        dummyCard?.shakeAnimationCard()
        //
        UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveLinear, animations: {
            self.viewActions.alpha = 1.0
        }, completion: nil)
        
        //Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateEmojiView), userInfo: emojiView, repeats: true)
    }
    
    func createTinderCard(at index: Int , value :String) -> SwipeCard {
        
        let card = SwipeCard(frame: CGRect(x: 0, y: 0, width: viewTinderBackGround.frame.size.width , height: viewTinderBackGround.frame.size.height - 50) ,value : value)
        card.delegate = self
        return card
        
    }
    
    func removeObjectAndAddNewValues() {
        
        //emojiView.rateValue =  2.5
        UIView.animate(withDuration: 0.5) {
            self.buttonUndo.alpha = 0
        }
        currentLoadedCardsArray.remove(at: 0)
        currentIndex = currentIndex + 1
        Timer.scheduledTimer(timeInterval: 1.01, target: self, selector: #selector(enableUndoButton), userInfo: currentIndex, repeats: false)
        
        if (currentIndex + currentLoadedCardsArray.count) < allCardsArray.count {
            let card = allCardsArray[currentIndex + currentLoadedCardsArray.count]
            var frame = card.frame
            frame.origin.y = CGFloat(MAX_BUFFER_SIZE * SEPERATOR_DISTANCE)
            card.frame = frame
            currentLoadedCardsArray.append(card)
            viewTinderBackGround.insertSubview(currentLoadedCardsArray[MAX_BUFFER_SIZE - 1], belowSubview: currentLoadedCardsArray[MAX_BUFFER_SIZE - 2])
            
        }
        print(currentIndex)
        animateCardAfterSwiping()
    }
    
    func animateCardAfterSwiping() {
        
        for (i,card) in currentLoadedCardsArray.enumerated() {
            let storyboard = UIStoryboard(name: "SwipeStoryBoard", bundle: nil)
            let pageVC = storyboard.instantiateViewController(withIdentifier: "PageViewController")
            
            pageVC.view.frame = self.currentLoadedCardsArray[i].frame
            self.addChild(pageVC)
            self.currentLoadedCardsArray[i].addSubview(pageVC.view)
            pageVC.didMove(toParent: self)
            
            UIView.animate(withDuration: 0.5, animations: {
                if i == 0 {
                    card.isUserInteractionEnabled = true
                }
                var frame = card.frame
                frame.origin.y = CGFloat(i * SEPERATOR_DISTANCE)
                card.frame = frame
            })
        }
    }
    
    
    @IBAction func disLikeButtonAction(_ sender: Any) {
        
        let card = currentLoadedCardsArray.first
        card?.leftClickAction()
    }
    
    @IBAction func LikeButtonAction(_ sender: Any) {
        
        let card = currentLoadedCardsArray.first
        card?.rightClickAction()
    }
    
    @IBAction func undoButtonAction(_ sender: Any) {
        
        currentIndex =  currentIndex - 1
        if currentLoadedCardsArray.count == MAX_BUFFER_SIZE {
            
            let lastCard = currentLoadedCardsArray.last
            lastCard?.rollBackCard()
            currentLoadedCardsArray.removeLast()
        }
        let undoCard = allCardsArray[currentIndex]
        undoCard.layer.removeAllAnimations()
        viewTinderBackGround.addSubview(undoCard)
        undoCard.makeUndoAction()
        currentLoadedCardsArray.insert(undoCard, at: 0)
        animateCardAfterSwiping()
        if currentIndex == 0 {
            UIView.animate(withDuration: 0.5) {
                self.buttonUndo.alpha = 0
            }
        }
    }
    
    @objc func enableUndoButton(timer: Timer){
        
        let cardIntex = timer.userInfo as! Int
        if (currentIndex == cardIntex) {
            
            UIView.animate(withDuration: 0.5) {
                self.buttonUndo.alpha = 1.0
            }
        }
    }
}

extension SwipeVC : SwipeCardDelegate{
    // action called when the card goes to the left.
    func cardGoesLeft(card: SwipeCard) {
        removeObjectAndAddNewValues()
    }
    // action called when the card goes to the right.
    func cardGoesRight(card: SwipeCard) {
        removeObjectAndAddNewValues()
    }
    func currentCardStatus(card: SwipeCard, distance: CGFloat) {
        if distance == 0 {
            // emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
            //emojiView.rateValue =  sorted
        }
    }
}

