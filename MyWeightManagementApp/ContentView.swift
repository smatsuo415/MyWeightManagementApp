//
//  ContentView.swift
//  MyWeightManagementApp
//
//  Created by Shugo Matsuo on 2021/03/21.
//

import SwiftUI
import CoreData

struct UserListsView: View, Identifiable{
    var id: Int
    let name: String
    
    var body: some View {
        HStack{
            Text(String(id))
                .font(.largeTitle)
                .frame(width: 75, height: 75)
                .foregroundColor(Color.white)
                .background(Color.blue)
            Text(name)
                .font(.title)
                .padding(10)
                .foregroundColor(Color.blue)
        }
    }
}

struct WeightManagementView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let user:UserListsView
    @State var val: Date = Date()
    @State var sWeight: String = ""
    @State var graphFlag: Bool = true

    struct UserData :Identifiable{
        var id: Int
        var name: String = ""
        var date: Date = Date()
        var weight: String = ""
    }
    @State var userDataList:[UserData] = []
    
    /// データ取得処理
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timeStamp, ascending: true)],
            predicate: nil
    ) private var items: FetchedResults<Item>
    
    // 日付情報の文字列変換
    var dateFormat: DateFormatter {
    
        let dformat = DateFormatter()
        dformat.dateStyle = .long
        dformat.timeStyle = .none
        dformat.dateFormat = "yyyy/MM/dd"
        return dformat
    }
    
    var body: some View {
        VStack{
            Text(user.name)
                .font(.largeTitle)
            
            Spacer(minLength: 10)
            
            Form{
                if( !graphFlag ){
                    List{
                        ForEach(items) { item in
                            if( item.name! == user.name ){
                                Text("\(item.name!) : \(dateFormat.string(from: item.timeStamp!)) : \(String(item.weight))")
                                    .font(.title)
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
                else {
                    Text("グラフ表示")
                }
            }

            Divider()
            
            Toggle(isOn: $graphFlag, label: {
                Text("グラフ表示")
            })
            .padding(10)
            
            // デバッグ用 items全削除ボタン
//            Button(action: {
//                for item in items {
//                    viewContext.delete(item)
//                }
//
//                try? viewContext.save()
//            },
//                label: {
//                    Text("消去")
//                        .font(.largeTitle)
//                        .background(Color.blue)
//                        .foregroundColor(Color.white)
//                        .padding(5)
//                }
//            )
                
            Divider()
            
            HStack{
                DatePicker("", selection: $val, displayedComponents:.date)
                
                Spacer(minLength: 10)
                
                Text("体重：")
                TextField("weight", text: Binding(
                            get: {sWeight},
                            set: {sWeight = $0.filter{"0123456789".contains($0)}}))
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer(minLength: 10)
                
                Button(action: {
                    print("[btn]sWeight = \(sWeight)")

                    /// 体重新規登録処理
                    let newItem = Item(context: viewContext)
                    newItem.name = user.name
                    newItem.weight = NSString(string: sWeight).floatValue
                    newItem.timeStamp = val
                    
                    try? viewContext.save()
                }, label: {
                    Text("登録")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .padding(5)
                })
            }
        }
    }
    
    /// 体重情報の削除
    /// - Parameter offsets: 要素番号のコレクション
    func deleteItem(offsets: IndexSet) {
        
        for index in offsets {
            
            print("[Del] index: \(index)")
            viewContext.delete(items[index])
        }
        
        try? viewContext.save()
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// データ取得処理
    @FetchRequest(
        entity: User.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \User.nid, ascending: true)],
            predicate: nil
    ) private var users: FetchedResults<User>
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timeStamp, ascending: true)],
            predicate: nil
    ) private var items: FetchedResults<Item>
    
    @State var userName:String = ""
    
    var body: some View {
        VStack{
            Text("体重管理アプリ")
                .padding()
                .border(Color.gray, width:3)
    
            NavigationView{
                VStack{
                    Form{
                        List{
                            ForEach(users) {user in
                                let userNameData = UserListsView(id: Int(user.nid), name: user.name!)
                                NavigationLink(destination:WeightManagementView(user:userNameData)){
                                    userNameData
                                }
                            }
                            .onDelete(perform: deleteUser)
                        }
                    }.navigationBarTitle("Select User")
                        
                    Spacer(minLength: 10)
                    
                    HStack{
                        TextField("name", text: $userName)
                            .padding(10)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                        Button(action: {
                            if(userName != "") {
                                var userFlag = false
                                for user in users {
                                    if( user.name == userName ) {
                                        userFlag = true
                                    }
                                }
                                if( !userFlag ) {
                                    /// ユーザー新規登録処理
                                    let newUser = User(context: viewContext)
                                    newUser.name = userName
                                    newUser.nid = Int16(users.count + 1)
                                    
                                    print("[Add] user.name : \(userName)")
                                    print("[Add] users.count prev : \(users.count)")
                                    
                                    try? viewContext.save()
                                    
                                    print("[Add] users.count after : \(users.count)")
                                }
                            }
                        }, label:{
                            Text("追加")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .padding(5)
                        })
                    }
                }
            }
        }
    }
    
    /// ユーザーの削除
    /// - Parameter offsets: 要素番号のコレクション
    func deleteUser(offsets: IndexSet) {
        
        for index in offsets {
            
            print("[Del] index: \(index)")
            print("[Del] users.count prev : \(users.count)")
            
            // 削除ユーザーの体重情報削除
            for item in items {
                if( users[index].name == item.name) {
                    viewContext.delete(item)
                }
            }
            
            // 残りユーザーのID繰上げ
            if( index + 1 < users.count ){
                for index2 in index + 1...users.count - 1 {
                    print("[Del] index2: \(index2)")
                    users[index2].nid = Int16(index2)
                }
            }
            
            viewContext.delete(users[index])
        }
        
        try? viewContext.save()

        print("[Del] users.count after : \(users.count)")
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
