//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Juan Francisco Dorado Torres on 5/27/19.
//  Copyright © 2019 Juan Francisco Dorado Torres. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Outlets

  @IBOutlet var button1: UIButton!
  @IBOutlet var button2: UIButton!
  @IBOutlet var button3: UIButton!

  // MARK: - Public Properties

  var countries = [String]()
  var score = 0
  var correctAnswer = 0

  // MARK: - View cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    countries += ["estonia", "france", "germany",
                  "ireland", "italy", "monaco",
                  "nigeria", "poland", "russia",
                  "spain", "uk", "us"]

    button1.layer.borderWidth = 1
    button2.layer.borderWidth = 1
    button3.layer.borderWidth = 1

    button1.layer.borderColor = UIColor.lightGray.cgColor
    button2.layer.borderColor = UIColor.lightGray.cgColor
    button3.layer.borderColor = UIColor.lightGray.cgColor

    askQuestion()
  }

  // MARK: - Public Methods

  func askQuestion() {
    countries.shuffle()

    button1.setImage(UIImage(named: countries[0]), for: .normal)
    button2.setImage(UIImage(named: countries[1]), for: .normal)
    button3.setImage(UIImage(named: countries[2]), for: .normal)

    correctAnswer = Int.random(in: 0...2)
    title = countries[correctAnswer].uppercased()
  }
}

