//
//  CarrouselCellView.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 22/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class CarrouselCellView: UITableViewCell,
                      UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UIScrollViewDelegate,
                      UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var carrouselCollectionView: UICollectionView!
    @IBOutlet weak var pager: UIPageControl!

    var carrouselBanner : Banner? = nil
    var timer = Timer()
    var counter = 0
    var itemHeight:CGFloat = 0
    var itemWidth:CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setItemHeight(height : CGFloat) {
        self.itemHeight = height
    }
    
    func setCarrouselBanner(carBanner : Banner) {
        //print("On setCarrouselBanner")
        if(carBanner.target !=  BannerTarget.CARROUSEL) {
            return
        }
        self.carrouselBanner = carBanner
        
        pager.numberOfPages = carrouselBanner?.carruselImages?.count ?? 0
        pager.currentPage = 0
        
        self.setTimerAction()
        /*
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
         */
        
        carrouselCollectionView.alwaysBounceHorizontal = false
        carrouselCollectionView.delegate = self
        carrouselCollectionView.dataSource = self
        carrouselCollectionView.reloadData()
    }
    
    @objc func changeImage() {
        //print("On changeImage")
        if(self.carrouselBanner == nil) {
            return
        }
        let index = IndexPath.init(item: counter, section: 0)
        self.carrouselCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        pager.currentPage = counter
        counter = (counter + 1) % (carrouselBanner?.carruselImages?.count ?? 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("On numberOfItemsInSection")
        if(self.carrouselBanner == nil) {
            return 0
        }
        return carrouselBanner?.carruselImages?.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //print("On cellForItemAt")
        let size = carrouselCollectionView.frame.size
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carrCell", for: indexPath)
        if let vc = cell.viewWithTag(123) as? UIImageView {
            if(self.carrouselBanner != nil) {
                let img = UIImage(named: carrouselBanner?.carruselImages?[indexPath.row].imageSrc ?? "")
                vc.frame = CGRect(x: 0, y: 0, width: itemWidth, height: CGFloat(itemHeight))
                vc.image = img
                vc.contentMode = .scaleToFill
                //vc.frame.size.height = CGFloat(itemHeight)
                //vc.frame.size.width = self.frame.width
                //vc.sizeToFit()
                vc.layoutIfNeeded()
            }
        }
        cell.frame.size.height = itemWidth
        cell.frame.size.width = size.width
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = carrouselCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("didSelectItemAt: \(indexPath)")
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            //cause by user
            print("SCROLL scrollViewDidEndDragging")
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //caused by user
        print("SCROLL scrollViewDidEndDecelerating")
        print("SCROLL carrouselCollectionView.contentOffset \(carrouselCollectionView.contentOffset)")
        
        let xoffset = carrouselCollectionView.contentOffset.x
        let itemIndex = Int(xoffset / itemWidth)
        
        print("SCROLL Index Path: \(itemIndex)")
        
        self.timer.invalidate()
        counter = itemIndex
        print("SCROLL counter: \(counter)")
        pager.currentPage = counter
        self.setTimerAction()
    }
    
    
    private func setTimerAction() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
        }
    }
    
}
