//
//  HomeView.swift
//  Peter008_1
//
//  Created by DONG SHENG on 2022/6/22.
//

// TODO: 待補 GameOver 動畫 以及 計分板(CoreData Or API)
import SwiftUI
import AVKit

class SoundManager{
    
    static let instance = SoundManager()
    
    var player: AVAudioPlayer?
    var player2: AVAudioPlayer?
    var player3: AVAudioPlayer?
    
    enum SoundOption: String{
        case sound1 // 按鈕點下的聲音
        case sound2 // 答錯音效
        case sound3 // 答對音效
    }
    
    // 按鈕點下的聲音
    func playSound(sound: SoundOption){
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: ".mp3") else { return }
        do{
            player = try AVAudioPlayer(contentsOf: url)
            
            // 音量
            if sound == SoundOption.sound1{
                player?.volume = 0.3 // 小聲一點
            } else {
                player?.volume = 1
            }
            player?.play()
            
        } catch let error {
            print("播放音效發生錯誤: \(error.localizedDescription)")
        }
    }
}

class HomeViewModel: ObservableObject{
    
    @Published var question: [String] = [] // 抽到的題目
    @Published var charactersInGuess: [String] = [] // 儲存玩家正在猜的
    
    @Published var numberOfLife: Int = 7    // 猜錯7次 Game Over
    @Published var totalWins: Int = 0
    @Published var totalLosses: Int = 0
    
    @Published var appleMove: [Bool] = [Bool](repeating: false, count: 3)
    
    // 二維Bool Array 給 button 判斷是否點下
    @Published var showButton: [[Bool]] = [
        [Bool](repeating: false, count: 10),
        [Bool](repeating: false, count: 9),
        [Bool](repeating: false, count: 7)
    ]
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 題庫 (可以改接API)
    private var word: [String] = [
        "BBABA","APPle", "dAy","HelLow","BAG","care","bottom","bread","coat","computeR"
    ]
    
//  Keyboard 也可以合併成一個 Array - - - - - - - - - - - - - - (可以更換成其他語言練習)
    let buttonFirstLine: [String] = [
        "Q","W","E","R","T","Y","U","I","O","P"
    ]
    let buttonSecondLine: [String] = [
        "A","S","D","F","G","H","J","K","L"
    ]
    let buttonThirdLine: [String] = [
        "Z","X","C","V","B","N","M"
    ]
    
    // 題目初始化
    func gameStart(){
        // 隨機從題庫抽一題 轉換成大寫 將 String -> [String] ，並預設一個沒獲取到element時 的 假值
        // Ex: "APPLE" -> ["A","P","P","L","E"]
        self.question = word.randomElement()?.uppercased().map{ String($0) } ?? ["E","R","R","O","R"]
        // 將 玩家猜的陣列長度 與 抽到的題目陣列長度 設為一樣
        self.charactersInGuess = [String](repeating: "_", count: question.count)
        
        // 按鈕復原 如果沒加時間差 最後一個點擊的按鈕 不會復原
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showButton = [
                [Bool](repeating: false, count: 10),
                [Bool](repeating: false, count: 9),
                [Bool](repeating: false, count: 7)
            ]
        }
        self.numberOfLife = 7
    }
    
    // 點擊 Button 的動作
    func buttonAction(tap: String){
        
        SoundManager.instance.playSound(sound: .sound1)  // 按鈕點擊聲
        
        if question.contains(where: { $0 == tap }){
            // .enumerated 為每一項提供對應序號(index) 找到相符的後 更改 charactersInGuess(玩家正在猜的)
            for (index ,char) in question.enumerated(){
                if char == tap{
                    self.charactersInGuess[index] = tap
                    guard charactersInGuess != question else { win() ; return }
                }
            }
        } else {
            guard numberOfLife > 1 else { lose() ; return }
            self.numberOfLife -= 1
        }
    }
    
    func win(){
        SoundManager.instance.playSound(sound: .sound3) // 成功音效
        self.totalWins += 1
        gameStart()
    }
    
    func lose(){
        SoundManager.instance.playSound(sound: .sound2) // 失敗音效

        self.totalLosses += 1
        withAnimation(.easeInOut){
            self.appleMove[self.totalLosses - 1] = true
        }
        // 總錯誤次數三次(毒蘋果三顆) -> gameOver
        guard totalLosses != 3 else { gameOver() ; return }
        gameStart()
    }
    
    func gameOver(){
        self.showButton = [
            [Bool](repeating: true, count: 10),
            [Bool](repeating: true, count: 9),
            [Bool](repeating: true, count: 7)
        ]
    }
}

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    Image("Image2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 220)
                        .overlay(
                            ZStack {
                                Image("Image3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: viewModel.appleMove[0] ? 490 : 0 ,y: viewModel.appleMove[0] ? 75 : 45)
                                
                                Image("Image3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: viewModel.appleMove[1] ? 490 : 0 ,y: viewModel.appleMove[1] ? 45 : 45)
                                
                                Image("Image3")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .offset(x: viewModel.appleMove[2] ? 490 : 0 ,y: viewModel.appleMove[2] ? 15 : 45)
                            }
                        )
                    Spacer()
                    
                    Image("Image1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 230)
                }
                .frame(width: 810, height: 300, alignment: .top) // 固定框架大小丟頻果才準
                .ignoresSafeArea()
                
                Spacer()
            }
            
            VStack{
                Spacer()
                
                HStack(spacing: 50){
                    
                    Text("")
                        .onReceive(viewModel.timer) { _ in
                            <#code#>
                        }
                    
                    Text("本題剩餘次數 : \(viewModel.numberOfLife)")
                }
                Spacer()

                HStack {
                    ForEach(viewModel.charactersInGuess ,id: \.self) {
                        Text($0)
                    }
                }
                Spacer()
                
                HStack(spacing: 30){
                    Text("成功 : \(viewModel.totalWins)")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                     
                        
                    
                    
                    Text("失敗 : \(viewModel.totalLosses)")
                        .font(.title2.bold())
                        .foregroundColor(.red)
                }
                
                keyboardView
            }
            .padding()
          
        }
        .onAppear {
            viewModel.gameStart()
        }
        .ignoresSafeArea()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}

extension HomeView{
    
    private var keyboardView: some View{
        VStack{
            HStack{
                ForEach(viewModel.buttonFirstLine.indices ,id: \.self){ index in
                    Button {
                        viewModel.buttonAction(tap: viewModel.buttonFirstLine[index])
                        viewModel.showButton[0][index] = true
                        
                    } label: {
                        Text(viewModel.buttonFirstLine[index])
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(viewModel.showButton[0][index] ? .gray : .brown )
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.showButton[0][index])
                }
            }
            HStack{
                ForEach(viewModel.buttonSecondLine.indices ,id: \.self){ index in
                    Button {
                        viewModel.buttonAction(tap: viewModel.buttonSecondLine[index])
                        viewModel.showButton[1][index] = true
                        
                    } label: {
                        Text(viewModel.buttonSecondLine[index])
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(viewModel.showButton[1][index] ? .gray : .brown)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.showButton[1][index])
                }
            }
            HStack{
                ForEach(viewModel.buttonThirdLine.indices ,id: \.self){ index in
                    Button {
                        viewModel.buttonAction(tap: viewModel.buttonThirdLine[index])
                        viewModel.showButton[2][index] = true
                        
                    } label: {
                        Text(viewModel.buttonThirdLine[index])
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(viewModel.showButton[2][index] ? .gray : .brown)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.showButton[2][index])
                }
            }
        }
    }
}
