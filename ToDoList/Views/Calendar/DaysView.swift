//
//  DaysView.swift
//  ToDoList
//
//  Created by 김나연 on 2022/09/20.
//

import SwiftUI
import RealmSwift

struct DaysView: View {
    @ObservedResults(Task.self) var tasks
    @Binding var currentDate: Date
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    var oneMonth: [DateValue]

    @State private var backToHome = false

    
    var body: some View {
        if backToHome {
            Home()
        } else {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(oneMonth) { value in
                    DayView(value: value)
//                        .onTapGesture(count: 1) {
//                            currentDate = value.date
//                            print("text")
//                        }
//                        .onTapGesture(count: 2) {
//                            backToHome = true
//                            print(backToHome)
//                        }
                        .gesture(TapGesture(count: 2).onEnded {
                            backToHome = true
                            print(backToHome)
                        })
                        .simultaneousGesture(TapGesture().onEnded {
                            currentDate = value.date
                            print("text")
                        })
                }
            }
        }

    }

    
    func DayView(value: DateValue) -> some View {
        VStack {
            if value.day != -1 {
                ZStack {
                    Circle()
                        .fill(Color(#colorLiteral(red: 0.3254901961, green: 0.1058823529, blue: 0.5764705882, alpha: 1)))
                        .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        .frame(width: 40, height: 40, alignment: .top)
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : isSameDay(date1: Date(), date2: value.date) ? .blue : .primary)
                }
                let todayTask = tasks.filter{ isSameDay(date1: $0.taskDate, date2: value.date) }
                if !todayTask.isEmpty {
                    Circle()
                        .fill(isAllDone(Array(todayTask)) ? Color(#colorLiteral(red: 0, green: 0.4931138158, blue: 0.01805076376, alpha: 1)) : Color(#colorLiteral(red: 0.8214151263, green: 0, blue: 0.2262543738, alpha: 1)))
                        .frame(width: 8, height: 8, alignment: .top)
                        .padding(EdgeInsets(top: -13, leading: 0, bottom: 0, trailing: 0))
                        .offset(x: 1.2, y: 0)
                } else {
                    Spacer()
                }
            }
        }
        .padding(.vertical, 8)
        .frame(height: 50, alignment: .top)
    }
    
    func isAllDone(_ tasks: [Task]) -> Bool {
        for task in tasks {
            if !task.isCompleted {
                return false
            }
        }
        return true
    }
}
