//
//  TestData.swift
//  zorro-ios-app1
//
//  Created by José Antonio Hijar on 3/16/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

struct BannerTestData {
    
    static func banners() -> [Banner] {
        var banners = [Banner]()
        let images = ["home1" , "banner1-comunidadred", "banner2-sicobro", "banner3-promotions", "banner4-location"]
        for index in 1...5 {
            if( index == 1 ) {
                var bannerCarrousel = Banner(name:"Carousel \(index)",
                    description: "This is my Carousel \(index)",
                    enabled:  true,
                    imageSrc: images[index - 1],
                    target: BannerTarget.CARROUSEL,
                    targetUrl: ""
                )
                bannerCarrousel.carruselImages = [
                    Banner(name:"BC1",
                        description: "Element 1",
                        enabled:  true,
                        imageSrc: "home-carrousel1",
                        target: BannerTarget.AD,
                        targetUrl: ""
                    ),
                    Banner(name:"BC2",
                        description: "home-carrousel2",
                        enabled:  true,
                        imageSrc: "home2",
                        target: BannerTarget.AD,
                        targetUrl: ""
                    )
                ]
                banners.append(bannerCarrousel)
            } else {
                banners.append(
                    Banner(name:"Banner \(index)",
                        description: "This is my Banner \(index)",
                        enabled:  true,
                        imageSrc: images[index - 1],
                        target: BannerTarget.AD,
                        targetUrl: ""
                    )
                )
            }
        }
        return banners
    }
}
