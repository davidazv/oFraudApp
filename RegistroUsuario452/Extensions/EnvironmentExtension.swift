import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var authController = AuthenticationController(httpClient: HTTPClient())
}
