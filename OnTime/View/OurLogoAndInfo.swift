//
//  OurLogoAndInfo.swift
//  OnTime
//
//  Created by Roman Chubatyy on 25.09.2020.
//

import UIKit

class OurLogoAndInfo: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var logo: UIImageView!
    let nibName = "OurLogoAndInfo"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToWebsite))
        logo.isUserInteractionEnabled = true
        logo.addGestureRecognizer(tap)
    }
    
    func loadViewFromNib() -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    @objc func goToWebsite(sender: UITapGestureRecognizer){
        if let url = URL(string: "https://olivs.app/ontime") {
            UIApplication.shared.open(url)
        }
    }
}
