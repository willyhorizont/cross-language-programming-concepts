((root, factory) => {
    // UMD (Universal Module Definition)
    if ((typeof window !== "undefined") && (typeof document !== "undefined")) {
        // Web Browser environment non module script (script with no type="module")
        root.WillyHorizont = (root.WillyHorizont || {});
        root.WillyHorizont.Utils = factory(root);
        return;
    }
    if ((typeof module !== "undefined") && ("exports" in module) && (typeof module.exports !== "undefined")) {
        // Node.js CommonJS environment may also support Web Browser environment module script (script with type="module") and Node.js ES Module (ESM) environment
        module.exports = factory(root);
        return;
    }
    // Unknown / unsupported environment
})(globalThis, (root) => {
    const escapeString = (s) => {
        if (s === null || s === undefined) return "";
        let r = String(s);
        r = r.replace(/\\/g, "\\\\");
        r = r.replace(/"/g, "\\\"");
        r = r.replace(/\n/g, "\\n");
        r = r.replace(/\r/g, "\\r");
        r = r.replace(/\t/g, "\\t");
        return r;
    };
    const jsonStringify = (a, { pretty = false } = {}) => {
        const p = pretty;
        const t = " ".repeat(4);
        const s = [{ "t": "v", "v": a, "d": 0 }];
        let r = "";
        while (s.length > 0) {
            const c = s.pop();
            if (c["t"] === "r") {
                r += c["v"];
                continue;
            }
            const v = c["v"];
            const curD = c["d"];
            if (v === null || v === undefined) {
                r += "null";
                continue;
            }
            if (typeof v === "boolean") {
                r += v ? "true" : "false";
                continue;
            }
            if (typeof v === "string") {
                r += "\"" + escapeString(v) + "\"";
                continue;
            }
            if (typeof v === "number") {
                r += v.toString();
                continue;
            }
            if (typeof v === "function") {
                r += "\"[object Function]\"";
                continue;
            }
            if (Array.isArray(v)) {
                if (v.length === 0) {
                    r += "[]";
                    continue;
                }
                const childD = curD + 1;
                s.push({
                    "t": "r",
                    "v": p ? "\n" + String(t.repeat(curD)) + "]" : "]",
                    "d": curD
                });
                for (let i = v.length - 1; i >= 0; i -= 1) {
                    s.push({
                        "t": "v",
                        "v": v[i],
                        "d": childD
                    });
                    if (i > 0) {
                        s.push({
                            "t": "r",
                            "v": p ? ",\n" + String(t.repeat(childD)) : ",",
                            "d": childD
                        });
                    }
                }
                s.push({
                    "t": "r",
                    "v": p ? "[\n" + String(t.repeat(childD)) : "[",
                    "d": childD
                });
                continue;
            }
            if (typeof v === "object") {
                const dpL = Object.entries(v);
                if (dpL.length === 0) {
                    r += "{}";
                    continue;
                }
                const childD = curD + 1;
                s.push({
                    "t": "r",
                    "v": p ? "\n" + String(t.repeat(curD)) + "}" : "}",
                    "d": curD
                });
                for (let i = dpL.length - 1; i >= 0; i -= 1) {
                    const [dK, dV] = dpL[i];
                    s.push({
                        "t": "v",
                        "v": dV,
                        "d": childD
                    });
                    s.push({
                        "t": "r",
                        "v": p ? "\"" + String(dK) + "\": " : "\"" + String(dK) + "\":",
                        "d": childD
                    });
                    if (i > 0) {
                        s.push({
                            "t": "r",
                            "v": p ? ",\n" + String(t.repeat(childD)) : ",",
                            "d": childD
                        });
                    }
                }
                s.push({
                    "t": "r",
                    "v": p ? "{\n" + String(t.repeat(childD)) : "{",
                    "d": childD
                });
                continue;
            }
            r += "\"" + String(v.constructor.name) + "\"";
        }
        return r;
    };
    return {
        escapeString,
        jsonStringify,
    };
});
