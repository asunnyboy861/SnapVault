import SwiftUI
import MessageUI

struct ContactSupportView: View {
    @State private var showMailComposer = false
    @State private var showMailAlert = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Contact Support")
                .font(.title2.bold())

            Text("We'd love to hear from you!\nSend us an email and we'll get back to you as soon as possible.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                if MFMailComposeViewController.canSendMail() {
                    showMailComposer = true
                } else {
                    showMailAlert = true
                }
            } label: {
                Label("Send Email", systemImage: "envelope")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("Or email us directly:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("iocompile67692@gmail.com")
                    .font(.subheadline)
                    .textSelection(.enabled)
                    .foregroundStyle(.blue)
            }
            .padding(.top, 8)

            Spacer()
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMailComposer) {
            MailComposerView()
        }
        .alert("Cannot Send Email", isPresented: $showMailAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please set up a mail account on your device, or email us directly at iocompile67692@gmail.com")
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.setToRecipients(["iocompile67692@gmail.com"])
        composer.setSubject("SnapVault Support Request")
        composer.setMessageBody("""
        
        ---
        App: SnapVault
        Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
        Device: \(UIDevice.current.model)
        iOS: \(UIDevice.current.systemVersion)
        """, isHTML: false)
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
