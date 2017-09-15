//
//  CycleMonitorTests.swift
//  CycleMonitor
//
//  Created by Brian Semiglia on 9/5/17.
//  Copyright © 2017 Brian Semiglia. All rights reserved.
//

import XCTest
@testable import CycleMonitor
@testable import Argo
@testable import Curry
@testable import Runes

class CycleMonitorTests: XCTestCase {
  
  static var saveFileSuccess: [AnyHashable: Any] { return
    [
      "drivers": [
        driverWith(id: "a", action: true) as [AnyHashable: Any],
        driverWith(id: "b", action: false) as [AnyHashable: Any],
        driverWith(id: "c", action: false) as [AnyHashable: Any]
      ],
      "cause": driverWith(id: "a", action: true) as [AnyHashable: Any],
      "effect": "effect",
      "context": "context",
      "pendingEffectEdit": "pendingEffectEdit"
    ]
  }
  
  static var saveFileDriversEmpty: [AnyHashable: Any] { return
    [
      "drivers": [],
      "cause": driverWith(id: "a", action: true) as [AnyHashable: Any],
      "effect": "effect",
      "context": "context",
      "pendingEffectEdit": "pendingEffectEdit"
    ]
  }
  
  static var saveFileEmptyPendingEffectEdit: [AnyHashable: Any] { return
    [
      "drivers": [
        driverWith(id: "a", action: true) as [AnyHashable: Any],
        driverWith(id: "b", action: false) as [AnyHashable: Any],
        driverWith(id: "c", action: false) as [AnyHashable: Any]
      ],
      "cause": driverWith(id: "a", action: true) as [AnyHashable: Any],
      "effect": "effect",
      "context": "context",
      "pendingEffectEdit": ""
    ]
  }
  
  static var eventDriverValid: [AnyHashable: Any] { return
    driverWith(id: "a", action: true)
  }
  
  static var testFileSuccess: [AnyHashable: Any] { return
    [
      "drivers": driversJSON,
      "cause": driversJSON.first!,
      "effect": "effect",
      "context": "context"
    ]
  }
  
  static var eventEmptyPendingEffect: Event? { return
    curry(Event.init(drivers:cause:effect:context: pendingEffectEdit:))
      <^> NonEmptyArray(possible: [
        driverWith(id: "a", action: true)
      ])
      <*> driverWith(id: "a", action: true)
      <*> ""
      <*> "context"
      <*> ""
  }
  
  static var driversJSON: [[AnyHashable: Any]] { return
    [
      driverWith(id: "a", action: true),
      driverWith(id: "b", action: false),
      driverWith(id: "c", action: false)
    ]
  }
  
  static var drivers: [Event.Driver] { return
    [
      driverWith(id: "a", action: true),
      driverWith(id: "b", action: false),
      driverWith(id: "c", action: false)
    ]
  }
  
  static func driverWith(id: String, action: Bool) -> Event.Driver { return
    Event.Driver(
      label: id + "-label",
      action: action ? id + "-action" : "",
      id: id + "-id"
    )
  }

  static func driverWith(id: String, action: Bool) -> [AnyHashable: Any] { return
    [
      "label": id + "-label",
      "action": action ? id + "-action" : "",
      "id": id + "-id"
    ]
  }

  static var eventSuccess: Event? { return
    curry(Event.init(drivers:cause:effect:context: pendingEffectEdit:))
      <^> NonEmptyArray(possible: drivers)
      <*> Event.Driver(
        label: "a-label",
        action: "a-action",
        id: "a-id"
      )
      <*> "effect"
      <*> "context"
      <*> "pendingEffectEdit"
  }
  
  func testSaveFile() {
    
    // should decode event
    XCTAssertNotEqual(
      decode(CycleMonitorTests.testFileSuccess) as Event?,
      nil
    )
    
    // should decode event driver
    XCTAssertNotEqual(
      decode(CycleMonitorTests.eventDriverValid) as Event.Driver?,
      nil
    )
    
    // should have at least one driver
    XCTAssertEqual(
      decode(CycleMonitorTests.saveFileDriversEmpty) as Event?,
      nil
    )
    
    // Should resolve empty-string pending-effect-edit to nil
    XCTAssertEqual(
      CycleMonitorTests.eventEmptyPendingEffect?.pendingEffectEdit,
      nil
    )
    
    // should encode event
    XCTAssertEqual(
      CycleMonitorTests.eventSuccess
        .map { $0.coerced() as [AnyHashable: Any] }
        .map (NSDictionary.init)
      ,
      .some(
        NSDictionary(
          dictionary: CycleMonitorTests.saveFileSuccess
        )
      )
    )
    
    // should encode driver
    XCTAssertEqual(
      NSDictionary(
        dictionary: CycleMonitorTests
          .driverWith(id: "a", action: false)
          .JSON
      ),
      NSDictionary(
        dictionary: CycleMonitorTests
          .driverWith(id: "a", action: false)
      )
    )
  }
  
}
