import Foundation
import SQLite

struct Message {
    let guid: String
    let date: Date
    let text: String
    let isFromMe: Bool
}

struct MessageTable {
    static let Name = "message"
    static let FieldGuid = Expression<String>("guid")
    static let FieldDate = Expression<Int64>("date")
    static let FieldText = Expression<String>("text")
    static let FieldIsFromMe = Expression<Bool>("is_from_me")

    
    private static let IMESSAGE_DATE_MULT: Int64 = 1000000000;

    static func query() -> Table {
        return Table("message")
            .select(FieldGuid, FieldDate, FieldText, FieldIsFromMe)
            .where(FieldText != "");
    }
    
    static func toTableTime(_ date: Date) -> TimeInterval {
        return TimeInterval(Int64(date.timeIntervalSinceReferenceDate) * IMESSAGE_DATE_MULT)
    }
    
    static func fromTableTime(_ time: TimeInterval) -> Date {
        return Date.init(timeIntervalSinceReferenceDate:time / Double(IMESSAGE_DATE_MULT));
    }
    
    static func makeMessage(fromRow: Row) throws -> Message {
        return Message(
            guid: try fromRow.get(MessageTable.FieldGuid),
            date: MessageTable.fromTableTime(TimeInterval(try fromRow.get(MessageTable.FieldDate))),
            text: try fromRow.get(MessageTable.FieldText),
            isFromMe: try fromRow.get(MessageTable.FieldIsFromMe)
        )
    }
    
    static func get(fromDatabase: URL, withQuery: Table) throws -> [Message] {
        do {
            let db = try Connection(fromDatabase.path, readonly: true)
            var results: [Message] = []
            for message in try db.prepare(withQuery) {
                results.append(try MessageTable.makeMessage(fromRow: message))
            }
            
            return results
        } catch {
            throw error
        }
    }
}

final class FileListener {
    private var file: URL;
    private var fileDescriptor: CInt = -1;
    private var monitor: DispatchSourceFileSystemObject?;

    init(file: URL) {
        self.file = file
    }

    func startListening(onChange: @escaping () -> Void) throws {
        do {
            fileDescriptor = open(file.path, O_EVTONLY)
            if(fileDescriptor < 0) {
                throw OTPFinderError.failedOpeningMessagesDir
            }
            
            monitor = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .all)
            if (monitor == nil) {
                throw OTPFinderError.failedCreatingDispatchSrc
            }
            
            monitor?.setEventHandler(handler: onChange)
            monitor?.setCancelHandler {
                [weak self] in self?.cleanupListener()
            }
            
            monitor?.resume()
        } catch {
            cleanupListener()
            throw error
        }
    }
    
    func cleanupListener() {
        print("Cleaning up listener")
        if (fileDescriptor < 0) {
            return
        }
        
        close(self.fileDescriptor)
        fileDescriptor = -1
        monitor?.cancel()
        monitor = nil
    }

}

final class MessagesListener : ObservableObject{
    private static let IMESSAGE_DB_LOCATION = "Library/Messages/chat.db";
    private static let IMESSAGE_DB_WAL_LOCATION = "Library/Messages/chat.db-wal";
    private static let IMESSAGE_DB_URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
        MessagesListener.IMESSAGE_DB_LOCATION)
    private var messagesDBListener = FileListener(file: MessagesListener.IMESSAGE_DB_URL)
    private var messagesWALListener = FileListener(
        file: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(
            MessagesListener.IMESSAGE_DB_WAL_LOCATION)
   )
    private var lastProcessed: Date?
    
    private var seenMessages: [String: Bool] = [:]
    
    private var isListeningForMessages: Bool = false
    
    func isListening() -> Bool {
        return self.isListeningForMessages
    }
    
    func startListening(onMessages: @escaping ([Message]) -> Void) throws {
        do {
            let changeHandler: () -> Void = {
                [weak self] in
                    self?.onMessagesChange(onMessages:onMessages)
            }
            
            print("Listening to primary db")
            try messagesDBListener.startListening(onChange:changeHandler)
            print("Listening to write-ahead log")
            try messagesWALListener.startListening(onChange:changeHandler)
            self.isListeningForMessages = true;
        }
        catch {
            self.isListeningForMessages = false;
        }
    }
    
    func cleanupListener() {
        messagesDBListener.cleanupListener()
        messagesWALListener.cleanupListener()
    }

    func onMessagesChange(onMessages: @escaping ([Message]) -> Void) {
        if lastProcessed != nil && lastProcessed! > Date().addingTimeInterval(-1) {
            return
        }
        
        lastProcessed = Date()
        let since = Date().addingTimeInterval(-1 * 60)
        print("Processing messages since \(since)")
        do {
            let messages = try MessageTable.get(
                fromDatabase: MessagesListener.IMESSAGE_DB_URL,
                withQuery: MessageTable
                    .query()
                    .where(MessageTable.FieldDate > Int64(MessageTable.toTableTime(since)))
                    .order(MessageTable.FieldDate.desc)
            )

            var newMessages: [Message] = []
            for message in messages {
                if seenMessages[message.guid] == nil {
                    seenMessages[message.guid] = true
                    newMessages.append(message)
                }
            }
            onMessages(messages)
        } catch {
            print(error)
        }
    }
}

