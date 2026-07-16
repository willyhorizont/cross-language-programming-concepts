import Foundation

public struct WillyHorizont {
    public struct Runtime {
        public struct Xl {
            public static func escapeString(_ s: Any?) -> String {
                guard let s = s else {
                    return ""
                }
                var r = String(describing: s)
                r = r.replacingOccurrences(of: "\\", with: "\\\\")
                r = r.replacingOccurrences(of: "\"", with: "\\\"")
                r = r.replacingOccurrences(of: "\n", with: "\\n")
                r = r.replacingOccurrences(of: "\r", with: "\\r")
                r = r.replacingOccurrences(of: "\t", with: "\\t")
                return r
            }
            
            public static func jsonStringify(_ a: Any?, pretty: Bool = false) -> String {
                let p = pretty
                let t = String(repeating: " ", count: 4)
                var s: [[String: Any]] = [["t": "v", "v": a as Any, "d": 0]]
                var r = ""
                while !s.isEmpty {
                    let c = s.removeLast()
                    if c["t"] as! String == "r" {
                        r += c["v"] as! String
                        continue
                    }
                    var v = c["v"]
                    let curD = c["d"] as! Int
                    while let curV = v {
                        let vV = Mirror(reflecting: curV)
                        if vV.displayStyle == .optional {
                            if vV.children.isEmpty {
                                v = nil
                                break
                            } else {
                                v = vV.children.first!.value
                            }
                        } else {
                            break
                        }
                    }
                    if v == nil {
                        r += "null"
                        continue
                    }
                    if let vB = v! as? Bool {
                        r += vB ? "true" : "false"
                        continue
                    }
                    if let vS = v! as? String {
                        r += "\"" + escapeString(vS) + "\""
                        continue
                    }
                    if let vI = v! as? Int {
                        r += String(vI)
                        continue
                    }
                    if let vF = v! as? Double {
                        r += String(vF)
                        continue
                    }
                    let vC = Mirror(reflecting: v!)
                    if (vC.displayStyle == nil && String(describing: v!).contains("->")) || 
                        String(describing: Swift.type(of: v!)).contains("->") {
                        r += "\"[object Function]\""
                        continue
                    }
                    if let vL = v! as? [Any?] {
                        if vL.isEmpty {
                            r += "[]"
                            continue
                        }
                        let childD = curD + 1
                        s.append([
                            "t": "r",
                            "v": p ? "\n" + String(repeating: t, count: curD) + "]" : "]",
                            "d": curD
                        ])
                        for i in stride(from: vL.count - 1, through: 0, by: -1) {
                            s.append([
                                "t": "v",
                                "v": vL[i] as Any,
                                "d": childD
                            ])
                            if i > 0 {
                                s.append([
                                    "t": "r",
                                    "v": p ? ",\n" + String(repeating: t, count: childD) : ",",
                                    "d": childD
                                ])
                            }
                        }
                        s.append([
                            "t": "r",
                            "v": p ? "[\n" + String(repeating: t, count: childD) : "[",
                            "d": childD
                        ])
                        continue
                    }
                    if let vD = v! as? [String: Any?] {
                        if vD.isEmpty {
                            r += "{}"
                            continue
                        }
                        let childD = curD + 1
                        let dpL = Array(vD)
                        s.append([
                            "t": "r",
                            "v": p ? "\n" + String(repeating: t, count: curD) + "}" : "}",
                            "d": curD
                        ])
                        for i in stride(from: dpL.count - 1, through: 0, by: -1) {
                            let dp = dpL[i]
                            s.append([
                                "t": "v",
                                "v": dp.value as Any,
                                "d": childD
                            ])
                            s.append([
                                "t": "r",
                                "v": p ? "\"\(dp.key)\": " : "\"\(dp.key)\":",
                                "d": childD
                            ])
                            if i > 0 {
                                s.append([
                                    "t": "r",
                                    "v": p ? ",\n" + String(repeating: t, count: childD) : ",",
                                    "d": childD
                                ])
                            }
                        }
                        s.append([
                            "t": "r",
                            "v": p ? "{\n" + String(repeating: t, count: childD) : "{",
                            "d": childD
                        ])
                        continue
                    }
                    r += "\"\(Swift.type(of: v!))\""
                }
                return r
            }
        }
    }
}
