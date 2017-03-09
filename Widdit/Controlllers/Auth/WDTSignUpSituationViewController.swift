//
//  WDTSignUpSituationViewController.swift
//  Widdit
//
//  Created by JH Lee on 06/03/2017.
//  Copyright © 2017 Widdit. All rights reserved.
//

import UIKit

class WDTSignUpSituationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var m_tblSituation: UITableView!
    
    let aryUserStituationKeys = ["situationSchool", "situationWork", "situationOpportunity"]
    let aryUserSituations = ["Currently in school", "Have a job", "Open to new things"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        m_tblSituation.rowHeight = UITableViewAutomaticDimension
        m_tblSituation.estimatedRowHeight = 44
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onClickBtnSkip(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startApplication(true)
    }
    
    //UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryUserSituations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed(String(describing: WDTProfileSituationTableViewCell.self), owner: nil, options: nil)?.first as! WDTProfileSituationTableViewCell
        cell.m_txtTitle.text = aryUserSituations[indexPath.row]
        cell.parseKey = aryUserStituationKeys[indexPath.row]
        
        return cell
    }
    
    //UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
}
