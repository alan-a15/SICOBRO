//
//  SplashScreenView.swift
//  zorro-ios-app1
//
//  Created by José Antonio Hijar on 17/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import SwiftUI
import Dispatch

struct SplashScreenView : View {
        
    @ObservedObject var timer = TimerFire()
    
    @State private var isActive = false
    @State var showDefault = true
    
    //var firstView = BannersView()
    
    var body: some View {
        let mainView =
             ZStack {
                if showDefault {
                    GeometryReader { geometry in
                        VStack() {
                            Image("logo-zorro-navbar")
                                .resizable()
                                .aspectRatio(3/2, contentMode: .fit)
                                .frame(width: geometry.size.width * 0.25)
                            Image("slogan_white")
                                .resizable()
                                .aspectRatio(5/2, contentMode: .fit)
                                .frame(width: geometry.size.width * 0.40)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }.background(Color("helperColor"))
                }
                
                if !showDefault {
                    BannersView().transition(.move(edge: .trailing))
                }
                
        }.onAppear {
            self.timer.FireTimer()
        }
        .onReceive(timer.$completed, perform: { completed in
            withAnimation {
                self.showDefault = !completed
            }
        })
            
        return mainView
    }
    
    func goToFirstView(time: Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(time)) {
            print("Go to first View")
            self.isActive = true
        }
    }

}


/// TO-DO: Customize this code
let TIME_MOVENEXT = 2
var timerCount : Int = 0

class TimerFire : ObservableObject{
    var workingTimer = Timer()
    @Published var completed = false

    @objc func FireTimer() {
        print("FireTimer")
        workingTimer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(TimerFire.timerUpdate),
            userInfo: nil,
            repeats: true)
    }

    @objc func timerUpdate(timeCount: Int) {
        timerCount += 1
        let timerText = "timerCount:\(timerCount)"
        print(timerText)

        if timerCount == TIME_MOVENEXT {
            print("timerCount == TIME_MOVENEXT")

            workingTimer.invalidate()
            print("workingTimer.invalidate()")
            timerCount = 0

            //
            //want to have a transition to SecondView here
            //
            self.completed = true
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
