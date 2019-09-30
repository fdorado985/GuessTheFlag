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
  var score = 0 {
    didSet {
      if score > highestScore {
        let defaults = UserDefaults.standard
        defaults.set(score, forKey: "highestScore")
        defaults.synchronize()
      }
    }
  }
  var highestScore: Int {
    let defaults = UserDefaults.standard
    return defaults.integer(forKey: "highestScore")
  }
  var correctAnswer = 0
  var authorizationRequested: Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "localNotificationAuthorizationRequest")
  }
  var notificationsGranted: Bool {
    let defaults = UserDefaults.standard
    return defaults.bool(forKey: "notificationsGranted")
  }

  // MARK: - View cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    if !authorizationRequested {
      registerLocal() // to register notifications
    }

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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if notificationsGranted {
      scheduleWeekLocalNotifications()
    }
  }

  // MARK: - Actions

  @IBAction func buttonTapped(_ sender: UIButton) {
    var title: String

    if sender.tag == correctAnswer {
      title = "Correct"
      score += 1
    } else {
      title = "Wrong"
      score -= 1
    }

    let message = score > highestScore ? "You beat the highest score.\n" : "" + "Your score is \(score)."
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)

    ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))

    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
      sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }) { [weak self] finished in
      self?.present(ac, animated: true)
    }

  }

  // MARK: - Public Methods

  func askQuestion(action: UIAlertAction! = nil) {
    countries.shuffle()

    button1.setImage(UIImage(named: countries[0]), for: .normal)
    button2.setImage(UIImage(named: countries[1]), for: .normal)
    button3.setImage(UIImage(named: countries[2]), for: .normal)

    UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: { [weak self] in
      self?.button1.transform = .identity
      self?.button2.transform = .identity
      self?.button3.transform = .identity
    }, completion: nil)

    correctAnswer = Int.random(in: 0...2)
    title = countries[correctAnswer].uppercased()
  }

  func registerLocal() {
    let center = UNUserNotificationCenter.current() // the main center to work with notifications
    // ask for the authorization to send or not local notifications
    center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (granted, error) in
      let alert: UIAlertController
      if granted {
        alert = UIAlertController(title: "Thanks", message: "We are not trying to bother you, this will just prevent to forget to play!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self?.scheduleWeekLocalNotifications()
      } else {
        alert = UIAlertController(title: "😞 Oh", message: "We just want to help you to don't forget to play this game, if you change your mind you can activate the notifications through Settings. 👍", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
      }

      // save authorization requested
      let defaults = UserDefaults.standard
      defaults.set(true, forKey: "localNotificationAuthorizationRequest")
      defaults.set(granted, forKey: "notificationsGranted")
      defaults.synchronize()

      DispatchQueue.main.async {
        self?.present(alert, animated: true)
      }
    }
  }

  func scheduleWeekLocalNotifications() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()

    let content = UNMutableNotificationContent()
    content.title = "We miss you! 🎮"
    content.body = "Come to beat the current highest record! 🥳"
    content.categoryIdentifier = "alarm"
    content.sound = UNNotificationSound.default

    for i in 1...7 {
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(86400 * i), repeats: false)
      let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
      center.add(request)
    }
  }
}

