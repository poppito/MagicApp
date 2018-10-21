//
//  CardRecommenDationViewController.swift
//  io.embry.litapp
//
//  Created by pawson on 21/10/18.
//  Copyright © 2018 embry.io. All rights reserved.
//

import UIKit

class CardRecommendationViewController: UIViewController,
                                        UITextFieldDelegate,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout,
                                        UICollectionViewDataSource {


    @IBOutlet weak var labelInstruction: UILabel!
    @IBOutlet weak var textAmountEntry: UITextField!
    @IBOutlet weak var cardCollectionView: UICollectionView!

    var isBill = false
    var cards = [CardModel]()
    
    private var amount : Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (isBill) {
            labelInstruction.text = "How much is your bill?"
        } else {
            labelInstruction.text = "How much is the item you're wanting to buy?"
        }
        textAmountEntry.returnKeyType = .done
        textAmountEntry.delegate = self
        addDoneButton()
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        cardCollectionView.collectionViewLayout = flowLayout
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        let creditCardImg = UIImage(named: "visa-2")
        let debitCardImg = UIImage(named: "visa-1")
        
        let card1 = CardModel(img: creditCardImg, isCreditCard: true, balance: 1200, pointsBalance: 43000, minimumPayment: 75)
        let card2 = CardModel(img: debitCardImg, isCreditCard: false, balance: 4500, pointsBalance: nil, minimumPayment: nil)
        
        cards.append(card1)
        cards.append(card2)
        
        cardCollectionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textAmountEntry.becomeFirstResponder()
    }
    
    private func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textAmountEntry.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        amount = Int(textAmountEntry.text ?? "0")
        let setAmount = amount ?? 0
        textAmountEntry.text = "$\(setAmount)"
        cardCollectionView.reloadData()
        cardCollectionView.isHidden = false
        textAmountEntry.resignFirstResponder()
    }
    
    //MARK:- collectionview delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as? CardCell
        
        let card = cards[indexPath.item]
        if (card.isCreditCard!) {
            let points = (amount ?? 0) * 2
            let minPaymentIncrease = Int(Double(card.minimumPayment!) * 0.017) + card.minimumPayment!
            cell?.cardImg.image = card.img!
            cell?.recommendation.text = "This is the recommended card for this purchase if you can make a minimum repayment $\(minPaymentIncrease) as you'll be able to add an extra \(points) points making your balance \(card.pointsBalance! + points) points"
            
        }
        else {
            let balanceComparison = amount ?? 0
            cell?.cardImg.image = card.img!
            if (balanceComparison > card.balance) {
                cell?.recommendation.text = "Your current balance is $\(card.balance). You will need to save more to buy this item."
            } else {
             cell?.recommendation.text = "Your current balance is $\(card.balance)."
            }
        }
        return cell!
    }
    
    @IBAction func didTapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

struct CardModel {
    var img: UIImage!
    var isCreditCard : Bool?
    var balance = 0
    var pointsBalance: Int?
    var minimumPayment: Int?
}
