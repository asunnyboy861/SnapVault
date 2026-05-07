import UserNotifications
import Foundation

@Observable
final class NotificationService {
    static let shared = NotificationService()
    var isNotificationAuthorized = false

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isNotificationAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func scheduleExpirationNotification(for item: SnapItem) async {
        guard let expDate = item.expirationDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Temporary Screenshot Expiring"
        content.body = "A \(item.category.rawValue) screenshot expires soon. Tap to review."
        content.sound = .default
        content.userInfo = ["snapItemId": item.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: expDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: item.id.uuidString,
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func scheduleCleanupReminder(count: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Screenshots Need Cleaning"
        content.body = "You have \(count) screenshots that can be cleaned up. Free up space now!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(
            identifier: "cleanup-reminder",
            content: content,
            trigger: trigger
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func removeNotification(for id: UUID) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
