import Foundation

private func mayHaveCode(_ message: String) -> Bool {
    if (message.range(
        of: #"authentication|code|security|login|auth|password"#,
        options: .regularExpression
    ) != nil) {
        return true
    }

    return false
}

func extractOneTimePassword(fromMessage: String) -> String? {
    if (fromMessage.lengthOfBytes(using: .utf16) > 10000) {
        return nil
    }

    if !mayHaveCode(fromMessage) {
        return nil
    }
    
    let regex = try! NSRegularExpression.init(pattern: #"[^\/]\b[0-9]{4,8}(-[0-9]{4,8})?\b"#)
    
    let matches = regex.matches(
        in:fromMessage,
        range: NSRange(location: 0, length: fromMessage.utf16.count)
    )
    
    for match in matches {
        let range = match.range(at:0)
        if let messageRange = Range(range, in: fromMessage) {
            let code = fromMessage[messageRange]
            if (code.contains("=")) {
                continue
            }
            if (code.contains("-")) {
                continue
            }
            
            let filteredCode = code.filter("0123456789.".contains)
            if filteredCode.lengthOfBytes(using: .utf16) > 0 {
                return filteredCode
            }
        }
    }

    return nil
}
