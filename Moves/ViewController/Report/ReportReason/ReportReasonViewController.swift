//
//  ReportReasonViewController.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import UIKit

class ReportReasonViewController: UIViewController,UITextViewDelegate {
    
    var viewModel = ReasonViewModel()
    var showReportReasons: ReportResponse?
    var videoId = ""
    var profileId = ""
    
    
    @IBOutlet weak var reasonTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.apiCall()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.statusBarStyle = .darkContent
        
        self.tabBarController?.tabBar.isHidden = true

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func apiCall(){
        self.viewModel.showAllReportReasons()
        self.observeEvent()
    }
    
    private func setup() {
        self.reasonTableView.delegate = self
        self.reasonTableView.dataSource = self
        self.reasonTableView.rowHeight = 50
        self.reasonTableView.register(UINib(nibName: "ReportReasonTableViewCell", bundle: nil), forCellReuseIdentifier: "ReportReasonTableViewCell")
        self.reasonTableView.reloadData()
    }
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .error(let error):
                print("error", error)
                DispatchQueue.main.async {
                    if let error = error {
                         if let dataError = error as? Moves.DataError {
                             switch dataError {
                             case .invalidResponse:
                                 Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                             case .invalidURL:
                                 Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                             case .network(_):
                                 Utility.showMessage(message: "Unreachable network. Please try again", on: self.view)
                             case .invalidData:
                                 print("invalidData")
                             case .decoding(_):
                                 print("decoding")
                             }
                         } else {
                             if isDebug {
                                 Utility.showMessage(message: "Something went wrong. Please try again", on: self.view)
                             }
                         }
                     }
                }
            case .showReportReasons(showReportReasons: let showReportReasons):
                self.showReportReasons = showReportReasons
                DispatchQueue.main.async {
                    self.reasonTableView.reloadData()
                }
            case .reportVideo(reportVideo: let reportVideo):
                print("reportVideo")
            case .repostVideo(repostVideo: let repostVideo):
                print("repostVideo")
            case .repostUser(repostUser: let repostUser):
                break
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension ReportReasonViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showReportReasons?.msg?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportReasonTableViewCell", for: indexPath) as!  ReportReasonTableViewCell
        let title = showReportReasons?.msg?[indexPath.row].reportReason.title
        cell.lblReason.text = title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = showReportReasons?.msg?[indexPath.row].reportReason.id
        let title = showReportReasons?.msg?[indexPath.row].reportReason.title
        
        let newViewController = ReportDescriptionViewController(nibName: "ReportDescriptionViewController", bundle: nil)
        newViewController.videoId = videoId
        newViewController.profileId = profileId
        newViewController.reportId = id?.toString() ?? ""
        newViewController.titleText = title ?? ""
        newViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(newViewController, animated: true)
        
    }
}


