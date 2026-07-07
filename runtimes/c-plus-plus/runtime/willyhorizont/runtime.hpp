#pragma once

#include <iostream>
#include <variant>
#include <string>
#include <vector>
#include <unordered_map>
#include <functional>
#include <memory>
#include <utility>
#include <cstdint>
#include <sstream>
#include <algorithm>
#include <stdexcept>
#include <concepts>

namespace XL {
    struct None {
        bool operator==(const None&) const {
            return true;
        }
    };

    class Type;

    using Bool = bool;
    using Int = int64_t;
    using Float = double;
    using String = std::string;
    using ListValue = std::vector<Type>;
    using DictValue = std::unordered_map<std::string, Type>;
    using Pair = std::pair<std::string, XL::Type>;
    struct Iterator {
        std::shared_ptr<ListValue> list_ptr;
        size_t index = 0;

        Iterator(std::shared_ptr<ListValue> l, size_t start_idx = 0) : list_ptr(l), index(start_idx) {}

        Type next();
    };

    using Closure = std::function<Type(const Type&)>;

    class Type {
    public: 
        std::variant<
            None,
            Bool,
            Int,
            Float,
            String,
            std::shared_ptr<ListValue>,
            std::shared_ptr<DictValue>,
            Closure,
            std::shared_ptr<Iterator>
        > value;

        Type() : value(None{}) {}
        Type(None v) : value(v) {}
        Type(Bool v) : value(v) {}
        Type(Int v) : value(v) {}
        Type(Float v) : value(v) {}
        Type(String v) : value(v) {}
        Type(const char* v) : value(String(v)) {}
        Type(ListValue v) : value(std::make_shared<ListValue>(std::move(v))) {}
        Type(DictValue v) : value(std::make_shared<DictValue>(std::move(v))) {}
        Type(Closure v) : value(v) {}
        Type(std::shared_ptr<Iterator> v) : value(v) {}

        template <typename F>
        requires std::invocable<F, const Type&> && (!std::is_same_v<std::decay_t<F>, Type>)
        Type(F&& f) {
            value = Closure(std::forward<F>(f));
        }

        template <typename... Args>
        Type call(Args&&... args) const {
            if (auto c = std::get_if<Closure>(&value)) {
                ListValue a;
                a.reserve(sizeof...(args));
                (a.push_back(Type(std::forward<Args>(args))), ...);
                return (*c)(Type(std::move(a)));
            }
            throw std::runtime_error("XlError: Expected Closure.");
        }

        Type iter() const {
            if (auto list_ptr = std::get_if<std::shared_ptr<ListValue>>(&value)) {
                return Type(std::make_shared<Iterator>(*list_ptr, 0));
            }
            throw std::runtime_error("XlError: Object is not iterable.");
        }

        Type next() const {
            if (auto it_ptr = std::get_if<std::shared_ptr<Iterator>>(&value)) {
                return (*it_ptr)->next();
            }
            throw std::runtime_error("XlError: Object is not an iterator.");
        }
    };

    inline Type Iterator::next() {
        if (list_ptr && index < list_ptr->size()) {
            Type el = (*list_ptr)[index];
            index += 1;
            return el;
        }
        return Type(None{});
    }

    template <typename... Args>
    Type List(Args&&... args) {
        ListValue l;
        l.reserve(sizeof...(args));
        (l.push_back(Type(std::forward<Args>(args))), ...);
        return Type(std::move(l));
    }

    template <typename... Args>
    Type Dict(Args&&... args) {
        DictValue d;
        (d.insert(std::forward<Args>(args)), ...);
        return Type(std::move(d));
    }

    inline std::string string_repeat(std::string s, size_t n) {
        std::string r = "";
        for (size_t i = 0; i < n; i += 1) {
            r += s;
        }
        return r;
    }

    inline std::vector<std::pair<std::string, Type>> dict_to_pair_list(const DictValue& dv) {
        return std::vector<std::pair<std::string, Type>>(dv.begin(), dv.end());
    }

    inline Bool to_bool(const Type& t) {
        return std::get<Bool>(t.value);
    }

    inline Int to_int(const Type& t) {
        return std::get<Int>(t.value);
    }

    inline Float to_float(const Type& t) {
        return std::get<Float>(t.value);
    }

    inline const String& to_string(const Type& t) {
        return std::get<String>(t.value);
    }

    inline std::shared_ptr<ListValue> to_list(const Type& t) {
        return std::get<std::shared_ptr<ListValue>>(t.value);
    }

    inline std::shared_ptr<DictValue> to_dict(const Type& t) {
        return std::get<std::shared_ptr<DictValue>>(t.value);
    }

    inline const Closure& to_closure(const Type& t) {
        return std::get<Closure>(t.value);
    }

    struct JifyOpt {
        bool pretty = false;
    };

    struct JifyState {
        std::string t;
        Type v;
        std::string r;
        size_t d = 0;
    };

    inline std::string json_stringify(const Type& a, JifyOpt o = {}) {
        bool p = o.pretty; 
        std::string t = "    ";
        std::vector<JifyState> s;
        s.push_back({ .t = "v", .v = a, .r = "", .d = 0 });
        std::string r = "";
        while (!s.empty()) {
            JifyState c = s.back();
            s.pop_back();
            if (c.t == "r") {
                r += c.r;
                continue;
            }
            Type v = c.v;
            size_t cur_d = c.d;
            if (std::holds_alternative<None>(v.value)) {
                r += "null";
                continue;
            }
            if (auto br = std::get_if<Bool>(&v.value)) {
                r += (*br ? "true" : "false");
                continue;
            }
            if (auto sr = std::get_if<String>(&v.value)) {
                r += "\"" + *sr + "\"";
                continue;
            }
            if (auto ir = std::get_if<Int>(&v.value)) {
                r += std::to_string(*ir);
                continue;
            }
            if (auto fr = std::get_if<Float>(&v.value)) {
                r += std::to_string(*fr);
                continue;
            }
            if (std::holds_alternative<Closure>(v.value)) {
                r += "\"[object Function]\"";
                continue;
            }
            if (auto lr = std::get_if<std::shared_ptr<ListValue>>(&v.value)) {
                const auto& lv = *lr;
                if (lv->empty()) {
                    r += "[]";
                    continue;
                }
                size_t child_d = cur_d + 1;
                s.push_back({
                    .t = "r",
                    .v = None{},
                    .r = p ? ("\n" + string_repeat(t, cur_d) + "]") : "]",
                    .d = cur_d
                });
                for (ptrdiff_t i = static_cast<ptrdiff_t>(lv->size()) - 1; i >= 0; i -= 1) {
                    s.push_back({
                        .t = "v",
                        .v = (*lv)[i],
                        .r = "",
                        .d = child_d
                    });
                    if (i > 0) {
                        s.push_back({
                            .t = "r",
                            .v = None{},
                            .r = p ? (",\n" + string_repeat(t, child_d)) : ",",
                            .d = child_d
                        });
                    }
                }
                s.push_back({
                    .t = "r",
                    .v = None{},
                    .r = p ? ("[\n" + string_repeat(t, child_d)) : "[",
                    .d = child_d
                });
                continue;
            }
            if (auto dr = std::get_if<std::shared_ptr<DictValue>>(&v.value)) {
                const auto& dv = *dr;
                if (dv->empty()) {
                    r += "{}";
                    continue;
                }
                size_t child_d = cur_d + 1;
                s.push_back({
                    .t = "r",
                    .v = None{},
                    .r = p ? ("\n" + string_repeat(t, cur_d) + "}") : "}",
                    .d = cur_d
                });
                std::vector<std::pair<std::string, Type>> dpl(dv->begin(), dv->end());
                for (ptrdiff_t i = static_cast<ptrdiff_t>(dpl.size()) - 1; i >= 0; i -= 1) {
                    const std::string& dk = dpl[i].first;
                    const Type& dv = dpl[i].second;
                    s.push_back({
                        .t = "v",
                        .v = dv,
                        .r = "",
                        .d = child_d
                    });
                    s.push_back({
                        .t = "r",
                        .v = None{},
                        .r = p ? ("\"" + dk + "\": ") : ("\"" + dk + "\":"),
                        .d = child_d
                    });
                    if (i > 0) {
                        s.push_back({
                            .t = "r",
                            .v = None{},
                            .r = p ? (",\n" + string_repeat(t, child_d)) : ",",
                            .d = child_d
                        });
                    }
                }
                s.push_back({
                    .t = "r",
                    .v = None{},
                    .r = p ? ("{\n" + string_repeat(t, child_d)) : "{",
                    .d = child_d
                });
                continue;
            }
            r += "\"[object \\\"C++ Object\\\"]\"";
        }
        return r;
    }
}
