//
//  Intro.swift
//  ArmMash
//
//  Created by Benji Loya on 20.12.2024.
//

import SwiftUI

// MARK: Intro Model And Sample Intro's
struct Intro: Identifiable {
    var id: String = UUID().uuidString
    var systemImageName: String
    var title: String
    var subtitle: String
}

var intros: [Intro] = [
    .init(
        systemImageName: "sparkles",
        title: "Премиум детейлинг",
        subtitle: "Глубокая очистка, полировка и защита кузова и салона. Авто как новое — внутри и снаружи."
    ),
    .init(
        systemImageName: "calendar.badge.clock",
        title: "Удобная запись",
        subtitle: "Выберите услугу, дату и время за пару касаний. Подтверждение и напоминания — автоматически."
    ),
    .init(
        systemImageName: "shield.checkerboard",
        title: "Защитные покрытия",
        subtitle: "Керамика для долговременной защиты. Подберем решение под ваш стиль вождения."
    ),
    .init(
        systemImageName: "bell.badge",
        title: "Напоминания о сервисе",
        subtitle: "Своевременные уведомления о обновлении защиты и сезонных акциях."
    )
]

// MARK: Dummy Text
let dummyText = "Профессиональный детейлинг-сервис: быстрая запись, прозрачный процесс, напоминания — всё для идеального вида вашего автомобиля."
