//
//  ViewController.swift
//  ScoutingParent
//
//  Created by Aidan Kaiser on 1/21/17.
//  Copyright © 2017 Aidan Kaiser. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {

    var browser : MCBrowserViewController!
    var assistant : MCAdvertiserAssistant!
    var session : MCSession!
    var peerID: MCPeerID!
    let serviceType = "SCOUTING-APP"
    var completeDataString = NSMutableString()
    var controller = UIDocumentInteractionController()
    var displayIDCheck = 1
    let defaults = UserDefaults.standard

    @IBOutlet weak var textView: UITextView!
    @IBAction func browse(_ sender: Any) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
    }
    @IBAction func openIn(_ sender: Any) {
        updateTextView()
    }
    
    func updateTextView() {
        let file = "Master.csv"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(file)
            
            //writing
            do {
                try completeDataString.write(to: path, atomically: false, encoding: String.Encoding.utf8.rawValue)
            }
            catch {/* error handling here */}
            controller = UIDocumentInteractionController(url: path)
            controller.presentOpenInMenu(from: CGRect(x:0,y:0,width:200,height:200), in: self.view!, animated: true)
        }

    }

    @IBAction func browseButton(_ sender: Any) {
        // Show the browser view controller
        self.present(self.browser, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if defaults.bool(forKey: "firstLaunch") == false
        {
        completeDataString.append("Alliance Color, Robot #, Scout Name, Able to Move (Auto), Crossed Base Line (Auto), Attempted Gear (Auto), Made Gear (Auto), Attempted Shot (Auto), Zone 1, Zone 2, Zone 3, Estimated High Goal (Auto), Fuel From Hopper (Auto), Estimated Low Goal (Auto), Zone 1 Amount (Teleop), Zone 2 Amount (Teleop), Zone 3 Amount (Teleop), Low Shots (Teleop), Made Gears, Dropped Gears, Time to Drop Gear (1-5), Shot Speed (1-5), Gears from Floor, Fuel from Floor, Attempted Climb, Able to Climb, Fuel From Hopper (Teleop), Robot Speed (1-5), Shot Accuracy (1-5), Human Player Skill (1-5), Comments\n")
            defaults.set(true, forKey: "firstLaunch")
            defaults.set(completeDataString, forKey: "completeData")
            defaults.synchronize()
        }
            
        else {
            completeDataString.append(defaults.object(forKey: "completeData") as! String)
        }
        
        if displayIDCheck == 1 {
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        self.session.delegate = self
        
        self.browser = MCBrowserViewController(serviceType:serviceType,
                                               session:self.session)
        
        self.browser.delegate = self;
        
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType,
                                               discoveryInfo:nil, session:self.session)
        self.assistant.start()
        displayIDCheck = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func browserViewControllerDidFinish(
        _ browserViewController: MCBrowserViewController)  {
        // Called when the browser view controller is dismissed (ie the Done
        // button was tapped)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        _ browserViewController: MCBrowserViewController)  {
        // Called when the browser view controller is cancelled
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, didReceive data: Data,
                 fromPeer peerID: MCPeerID)  {
        // Called when a peer sends an NSData to us
        
        DispatchQueue.main.async {
            let recievedString = NSMutableString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            self.completeDataString.append(String(describing: recievedString))
            self.defaults.set(self.completeDataString, forKey: "completeData")
            self.defaults.synchronize()
        }
    }
    
    // The following methods do nothing, but the MCSessionDelegate protocol
    // requires that we implement them.
    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress)  {
        
        // Called when a peer starts sending a file to us
    }
    
    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL, withError error: Error?)  {
        // Called when a file has finished transferring from another peer
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID)  {
        // Called when a peer establishes a stream with us
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID,
                 didChange state: MCSessionState)  {
        // Called when a connected peer changes state (for example, goes offline)
        
        
    }
}

