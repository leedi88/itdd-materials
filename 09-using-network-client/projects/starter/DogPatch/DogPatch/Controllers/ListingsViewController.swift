/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ListingsViewController: UIViewController {
  
  // MARK: - Outlets
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.register(ErrorTableViewCell.nib,
                         forCellReuseIdentifier: ErrorTableViewCell.identifier)
    }
  }
   
  // MARK: - Instance Properties
  // 나중에 mock object로 교체할 수 있도록 var로 선언 -> 그냥 코드상 바꾸는 거라면 의미가 있는건가
  var networkClient: DogPatchService = DogPatchClient.shared
  
  var viewModels: [DogViewModel] = []
  var dataTask: URLSessionTaskProtocol?
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRefreshControl()
  }
  
  private func setupRefreshControl() {
    let refreshControl = UIRefreshControl()
    tableView.refreshControl = refreshControl
    
    refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    refreshControl.attributedTitle = NSAttributedString(string: "Loading...")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshData()
  }
  
  // MARK: - Refresh
  @objc func refreshData() {
    guard dataTask == nil else { return }
    tableView.refreshControl?.beginRefreshing()
    
    dataTask = networkClient.getDogs() { [weak self] dogs, error in
      self?.dataTask = nil
      self?.tableView.reloadData()
      self?.viewModels = dogs?.map { DogViewModel(dog: $0) } ?? []
      self?.tableView.refreshControl?.endRefreshing()
    }
  }
}

// MARK: - UITableViewDataSource
extension ListingsViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    guard !tableView.refreshControl!.isRefreshing  else {
      return 0
    }
    return max(viewModels.count, 1)
  }
  
  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard viewModels.count > 0 else {
      return errorCell(tableView, indexPath)
    }
    return listingCell(tableView, indexPath)
  }
  
  private func errorCell(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: ErrorTableViewCell.identifier, for: indexPath)
  }
  
  private func listingCell(_ tableView: UITableView, _ indexPath: IndexPath) -> ListingTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ListingTableViewCell.identifier) as! ListingTableViewCell
    let viewModel = viewModels[indexPath.row]
    viewModel.configure(cell)
    return cell
  }
}

// MARK: - UITableViewDelegate
extension ListingsViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
