// AUDIT REFERENCE: Section 8.4, 2.6
// STATUS: NEW
import UIKit

class ContentView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var games: [String] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        loadGames()
    }

    func loadGames() {
        let documentsDir = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first ?? ""
        let gamesDir = documentsDir + "/Games"
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(atPath: gamesDir) else { return }
        games = files.filter { $0.hasSuffix(".iso") || $0.hasSuffix(".chd") || $0.hasSuffix(".cso") }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { games.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = games[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MetalViewController()
        present(vc, animated: true)
    }
}
