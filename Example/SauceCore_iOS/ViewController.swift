import UIKit
import SauceCore_iOS

class ViewController: UIViewController {
    // 라벨과 버튼 선언
    private let label = UILabel()
    private let sampleButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // 라벨 설정
        label.text = "SauceSDK"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        // 버튼 설정
        sampleButton.setTitle("OPEN PLAYER", for: .normal)
        sampleButton.backgroundColor = UIColor.blue
        sampleButton.layer.cornerRadius = 10
        sampleButton.addTarget(self, action: #selector(sampleButtonTapped), for: .touchUpInside)

        // 뷰에 라벨과 버튼 추가
        view.addSubview(label)
        view.addSubview(sampleButton)

        // 라벨과 버튼에 대한 오토레이아웃 설정
        setConstraints()
    }

    private func setConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        sampleButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // 라벨을 상단 중앙에 위치
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),

            // 버튼을 라벨 아래 50px에 위치
            sampleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 50),
            sampleButton.widthAnchor.constraint(equalToConstant: 120),
            sampleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func sampleButtonTapped() {
        print("keaton1111")
        let webVC = WebViewController()
        PIPKit.show(with: webVC)
    }
}
