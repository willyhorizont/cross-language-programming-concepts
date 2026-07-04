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
            const cur_t = c["d"];
            if (v === null || v === undefined) {
                r += "null";
                continue;
            }
            if (typeof v === "boolean") {
                r += v ? "true" : "false";
                continue;
            }
            if (typeof v === "string") {
                r += "\"" + v + "\"";
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
                const child_t = cur_t + 1;
                s.push({
                    "t": "r",
                    "v": p ? "\n" + String(t.repeat(cur_t)) + "]" : "]",
                    "d": cur_t
                });
                for (let i = v.length - 1; i >= 0; i -= 1) {
                    s.push({
                        "t": "v",
                        "v": v[i],
                        "d": child_t
                    });
                    if (i > 0) {
                        s.push({
                            "t": "r",
                            "v": p ? ",\n" + String(t.repeat(child_t)) : ",",
                            "d": child_t
                        });
                    }
                }
                s.push({
                    "t": "r",
                    "v": p ? "[\n" + String(t.repeat(child_t)) : "[",
                    "d": child_t
                });
                continue;
            }
            if (typeof v === "object") {
                const de = Object.entries(v);
                if (de.length === 0) {
                    r += "{}";
                    continue;
                }
                const child_t = cur_t + 1;
                s.push({
                    "t": "r",
                    "v": p ? "\n" + String(t.repeat(cur_t)) + "}" : "}",
                    "d": cur_t
                });
                for (let i = de.length - 1; i >= 0; i -= 1) {
                    const [dk, dictValue] = de[i];
                    s.push({
                        "t": "v",
                        "v": dictValue,
                        "d": child_t
                    });
                    s.push({
                        "t": "r",
                        "v": p ? "\"" + String(dk) + "\": " : "\"" + String(dk) + "\":",
                        "d": child_t
                    });
                    if (i > 0) {
                        s.push({
                            "t": "r",
                            "v": p ? ",\n" + String(t.repeat(child_t)) : ",",
                            "d": child_t
                        });
                    }
                }
                s.push({
                    "t": "r",
                    "v": p ? "{\n" + String(t.repeat(child_t)) : "{",
                    "d": child_t
                });
                continue;
            }
            r += "\"" + String(v.constructor.name) + "\"";
        }
        return r;
    };
    return {
        jsonStringify,
    };
});
