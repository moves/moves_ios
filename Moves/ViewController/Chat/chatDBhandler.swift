import Foundation
import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

class ChatDBhandler {
    static let shared = ChatDBhandler()
    
    // MARK: - Send text message
    
    func sendMessage(senderID: String, receiverID: String, senderName: String, receiverName: String, receiverPic: String, message: String, pic_url: String, timestamp: String, time: String, completionHandler: @escaping (_ result: Bool) -> Void) {
        let rootRef = Database.database().reference()
        let messagesRef = rootRef.child("chat")
        
        let currentUserChatRef = "chat/\(senderID)-\(receiverID)"
        let chatUserChatRef = "chat/\(receiverID)-\(senderID)"
        
        messagesRef.child(currentUserChatRef).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                self.sendMessageToDatabase(senderID: senderID, receiverID: receiverID, senderName: senderName, receiverName: receiverName, receiverPic: receiverPic, message: message, pic_url: pic_url, timestamp: timestamp, time: time){ result in
                    if result{
                        completionHandler(true)
                    }
                }
            } else {
                // Chat node does not exist, create it and send the message
                /*rootRef.child("chat/\(senderID)-\(receiverID)").setValue(["initialized": true]) { (error, _) in
                    if let error = error {
                        print("Error initializing chat node: ", error.localizedDescription)
                        completionHandler(false)
                        return
                    }
                    rootRef.child("chat/\(receiverID)-\(senderID)").setValue(["initialized": true]) { (error, _) in
                        if let error = error {
                            print("Error initializing chat node: ", error.localizedDescription)
                            completionHandler(false)
                            return
                        }
                        self.sendMessageToDatabase(senderID: senderID, receiverID: receiverID, senderName: senderName, receiverName: receiverName, receiverPic: receiverPic, message: message, pic_url: pic_url, timestamp: timestamp, time: time, completionHandler: completionHandler)
                    }
                }*/
                self.sendMessageToDatabase(senderID: senderID, receiverID: receiverID, senderName: senderName, receiverName: receiverName, receiverPic: receiverPic, message: message, pic_url: pic_url, timestamp: timestamp, time: time) { result in
                    if result{
                        completionHandler(true)
                    }
                }
            }
        }
    }

    private func sendMessageToDatabase(senderID: String, receiverID: String, senderName: String, receiverName: String, receiverPic: String, message: String, pic_url: String, timestamp: String, time: String, completionHandler: @escaping (_ result: Bool) -> Void) {
        
        let rootRef = Database.database().reference()
        let messagesRef = rootRef.child("chat")
        let messageID = messagesRef.childByAutoId().key

        // Current user and chat references
       // let currentUserChatRef = "chat/\(senderID)-\(receiverID)"
        //let chatUserChatRef = "chat/\(receiverID)-\(senderID)"
        
        // Push new message
        let SenderToReceiver = messagesRef.child("\(senderID)-\(receiverID)").child(messageID!)
        let ReceiverToSender = messagesRef.child("\(receiverID)-\(senderID)").child(messageID!)
        
        // Message data
        let messageData: [String: Any] = [
            "receiver_id": receiverID,
            "sender_id": senderID,
            "chat_id": messageID,
            "text": message,
            "type": "text",
            "pic_url": pic_url,
            "status": "0",
            "time": "",
            "sender_name": senderName,
            "timestamp": timestamp
        ]
        
        
        let messageData2: [String: Any] = [
            "receiver_id": receiverID,
            "sender_id": senderID,
            "chat_id": messageID,
            "text": message,
            "type": "text",
            "pic_url": receiverPic,
            "status": "0",
            "time": "",
            "sender_name": receiverName,
            "timestamp": timestamp
        ]
        
        
        
        // Update messages for both users
//        let updates = [
//            "\(currentUserChatRef)/\(messageID)": messageData,
//            "\(chatUserChatRef)/\(messageID)": messageData
//        ]
     //   print(updates)
        SenderToReceiver.setValue(messageData2) { [weak self] (error, _) in
            if let error = error {
                print("Error in updating message in id :\(senderID): ", error.localizedDescription)
                completionHandler(false)
                return
            }
        }
        ReceiverToSender.setValue(messageData) {  [weak self] (error, _) in
            if let error = error {
                print("Error in updating messagein id :\(receiverID) ", error.localizedDescription)
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
        InboxMessage(senderID: senderID, receiverID: receiverID, senderName: senderName, receiverName: receiverName, receiverPic: receiverPic, message: message, pic_url: pic_url, timestamp: timestamp, time: time) { result in
            if result{
                print("Inbox node update")
                completionHandler(true)
            }
        }

    }
    func InboxMessage(senderID: String, receiverID: String, senderName: String, receiverName: String, receiverPic: String, message: String, pic_url: String, timestamp: String, time: String,completionHandler: @escaping (_ result: Bool) -> Void) {
        // Update inbox references
        let rootRef = Database.database().reference()
        let inboxSenderRef = "Inbox/\(senderID)/\(receiverID)"
        let inboxReceiverRef = "Inbox/\(receiverID)/\(senderID)"
        
        // Sender and receiver message details
        let senderMessage: [String: Any] = [
            "rid": receiverID,
            "name": receiverName,
            "pic": receiverPic,
            "msg": message,
            "status": "0",
            "timestamp": timestamp,
            "date": time
        ]
        
        let receiverMessage: [String: Any] = [
            "rid": senderID,
            "name": senderName,
            "pic": pic_url,
            "msg": message,
            "status": "1",
            "timestamp": timestamp,
            "date": time
        ]
        
        // Update inbox for both users
        let inboxUpdates = [
            inboxSenderRef: senderMessage,
            inboxReceiverRef: receiverMessage
        ]
        
        rootRef.updateChildValues(inboxUpdates) { (error, _) in
            if let error = error {
                print("Error in updating inbox: ", error.localizedDescription)
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }

    // MARK: - Fetch messages
    func fetchMessage(senderID: String, receiverID: String, completionHandler: @escaping (_ result: Bool, _ messages: [String: Any]) -> Void) {
        let messagesRef = Database.database().reference().child("chat").child("\(senderID)-\(receiverID)")
        messagesRef.observe(.value, with: { [weak self]  (dataSnapshot) in
            if let dict = dataSnapshot.value as? [String: Any] {
                completionHandler(true, dict)
            } else {
                completionHandler(false, [:])
            }
        }, withCancel: { (error) in
            print("Error fetching messages: \(error.localizedDescription)")
            completionHandler(false, [:])
        })
    }

    // MARK: - Update message
    func updateMessage(chatID: String, senderID: String, receiverID: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let rootRef = Database.database().reference()
        
        // Update message type to "delete" in senderID-receiverID path
        let messageRef1 = rootRef.child("chat").child("\(senderID)-\(receiverID)").child(chatID)
        messageRef1.child("type").setValue("delete") { error, _ in
            if let error = error {
                print("Error updating message type: \(error.localizedDescription)")
                completionHandler(false)
            } else {
                // Now update message type to "delete" in receiverID-senderID path
                let messageRef2 = rootRef.child("chat").child("\(receiverID)-\(senderID)").child(chatID)
                messageRef2.child("type").setValue("delete") { error, _ in
                    if let error = error {
                        print("Error updating message type: \(error.localizedDescription)")
                        completionHandler(false)
                    } else {
                        completionHandler(true)
                    }
                }
            }
        }
    }

    // MARK: - Delete conversation
    func deleteConversation(senderID: String, receiverID: String, completionHandler: @escaping (_ success: Bool) -> Void) {
        let inboxRef1 = Database.database().reference().child("Inbox").child(senderID).child(receiverID)
        let inboxRef2 = Database.database().reference().child("Inbox").child(receiverID).child(senderID)
        
        inboxRef1.removeValue { error, _ in
            if let error = error {
                print("Error removing inbox entry for \(senderID)-\(receiverID): \(error.localizedDescription)")
                completionHandler(false)
                return
            }
            
            inboxRef2.removeValue { error, _ in
                if let error = error {
                    print("Error removing inbox entry for \(receiverID)-\(senderID): \(error.localizedDescription)")
                    completionHandler(false)
                    return
                }
                
                let chatRef1 = Database.database().reference().child("chat").child("\(senderID)-\(receiverID)")
                let chatRef2 = Database.database().reference().child("chat").child("\(receiverID)-\(senderID)")
                
                chatRef1.removeValue { error, _ in
                    if let error = error {
                        print("Error removing chat messages for \(senderID)-\(receiverID): \(error.localizedDescription)")
                        completionHandler(false)
                        return
                    }
                    
                    chatRef2.removeValue { error, _ in
                        if let error = error {
                            print("Error removing chat messages for \(receiverID)-\(senderID): \(error.localizedDescription)")
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                    }
                }
            }
        }
    }


    // MARK: - Fetch user inbox
    func fetchUserInbox(userID: String, completionHandler: @escaping (_ result: Bool, _ conversations: [[String: Any]]) -> Void) {
        let inboxRef = Database.database().reference().child("Inbox").child(userID)
        inboxRef.observe(.value, with: { snapshot in
            var conversations: [[String: Any]] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let conversation = snap.value as? [String: Any] {
                    conversations.append(conversation)
                }
            }
            
            completionHandler(true, conversations)
        }, withCancel: { error in
            print("Error fetching user inbox: \(error.localizedDescription)")
            completionHandler(false, [])
        })
    }

}
