//
//  Home.swift
//  ToDoList
//
//  Created by Suji Lee on 2022/09/04.
//

import SwiftUI
import RealmSwift

struct Home: View {
    @StateObject var realmManager = RealmManager()
    @ObservedObject var headerViewUtil: HeaderViewUtil
    @State private var showModal = false
    @State private var selectedTask: Task? = nil
    @Namespace var animation // TODO: 애니메이션 좀 과한 느낌... 줄이거나 없애면 어떨까여
    @State var currentDate: Date = Date()
    var tasks: [Task] { return realmManager.tasks.filter({ task in
        return isSameDay(date1: task.taskDate, date2: headerViewUtil.currentDay)}) }
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView(headerViewUtil: headerViewUtil)
                if !tasks.isEmpty
                {
                    let notDone = tasks.filter({task in return !task.isCompleted})
                    let isDone = tasks.filter({task in return task.isCompleted})
                    List {
                        Section {
                            ForEach(notDone) { task in
                                TaskCardView(task: task)
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                                    .swipeActions(edge: .leading) {
                                        Button (action: { realmManager.updateTask(id: task.id, task.taskTitle, task.taskDescription, task.taskDate, task.descriptionVisibility, true)}) {
                                            Label("Done", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            withAnimation(.linear(duration: 0.4)) {
                                                //taskViewModel.deleteTask(indexSet: )
                                                print("delete")
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        Section {
                            ForEach(isDone) { task in
                                TaskDoneCardView(task: task)
                                    .swipeActions(edge: .leading) {
                                        Button (action: { realmManager.updateTask(id: task.id, task.taskTitle, task.taskDescription, task.taskDate, task.descriptionVisibility, false)}) {
                                            Label("Not Done", systemImage: "xmark")
                                        }
                                        .tint(.yellow)
                                    }
                                    .onTapGesture {
                                        selectedTask = task
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            withAnimation(.linear(duration: 0.4)) {
                                                //taskViewModel.deleteTask(indexSet: )
                                                print("delete")
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .sheet(item: $selectedTask) {
                        UpdateModalView(task: $0)
                            .environmentObject(realmManager)
                    }
                    .frame(minHeight: 500)
                    .background(Color.clear)
                    .onAppear() {
                        UITableView.appearance().backgroundColor = UIColor.clear
                        UITableViewCell.appearance().backgroundColor = UIColor.clear
                    }
                } else {
                    NoTaskView()
                    Spacer()
                }
            }
            .navigationTitle("TEAM SUNA")
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink("Calendar", destination: CalendarView(currentDate: $currentDate)
                .environmentObject(realmManager)))
        }
        .environmentObject(realmManager)
        //        .safeAreaInset(edge: .bottom) {
        //            Button {
        //                showModal = true
        //            } label: {
        //                Text("+")
        //                    .foregroundColor(.purple)
        //                    .font(.system(size: 30))
        //                    .frame(maxWidth: .infinity)
        //            }
        //            .sheet(isPresented: $showModal) {
        //                ModalView(taskDate: $currentDate)
        //                    .environmentObject(realmManager)
        //            }
        //            .padding(.horizontal)
        //            .padding(.top, 5)
        //            .background(.ultraThinMaterial)
        //        }
        .safeAreaInset(edge: .bottom, alignment: .center) {
            Button {
                showModal = true
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundColor(.purple)
                    .font(.largeTitle)
                    .padding(.trailing)
            }
            .sheet(isPresented: $showModal) {
                // TODO: currentDate util 이랑 달라서 하나로 맞춰야 함
                ModalView(taskDate: $currentDate)
                    .environmentObject(realmManager)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(headerViewUtil: HeaderViewUtil())
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

