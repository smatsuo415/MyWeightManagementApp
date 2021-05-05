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
    let user:UserListsView
    @State var val: Date = Date()
    @State var sWeight: String = ""

    struct UserData :Identifiable{
        var id: Int
        var name: String = ""
        var date: Date = Date()
        var weight: String = ""
    }
    @State var userDataList:[UserData] = []
    
    var body: some View {
        VStack{
            Text(user.name)
                .font(.largeTitle)
            
            Spacer(minLength: 10)
            
            Form{
                List(userDataList) {userData in
                    HStack{
                        Text(userData.name)
                            .font(.title)
                        Text(":")
                            .font(.title)
                        Text(String(userData.weight))
                            .font(.title)
                    }
                }
            }
            
            HStack{
                DatePicker("", selection: $val, displayedComponents:.date)
                
                Spacer(minLength: 10)
                
                Text("体重：")
                TextField("weight", text: $sWeight)
                    .padding(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                
                Spacer(minLength: 10)
                
                Button(action: {
                    print("[btn]sWeight = \(sWeight)")
                    let data = UserData(id: userDataList.count + 1,
                                        name: user.name,
                                        date: val,
                                        weight: sWeight
                                        )
                    userDataList.append(data)

                }, label:{
                    Text("登録")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .padding(5)
                })
            }
        }
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
