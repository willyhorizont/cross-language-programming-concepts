#ifndef WILLYHORIZONT_RUNTIME_XL_H
#define WILLYHORIZONT_RUNTIME_XL_H

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <stdarg.h>

typedef void* None;
typedef bool Bool;
typedef const char* String;
typedef int Int;
typedef float Float;

typedef enum {
    NONE,
    BOOL,
    STRING,
    INT,
    FLOAT,
    LIST,
    DICT,
    LAMBDA,
    ITERATOR
} Types;

struct Xl;

typedef struct {
    struct Xl** value;
    size_t len;
    size_t size;
} List;

#define DICT_SIZE 32

typedef struct Pair {
    String key;
    struct Xl* value;
    struct Pair* next;
} Pair;

typedef struct {
    Pair* items[DICT_SIZE];
    size_t len;
} Dict;

typedef struct Xl* (*Lambda)(struct Xl* ctx_ref, struct Xl* vararg);

typedef struct Iterator {
    struct Xl* list_ref;
    size_t index;
} Iterator;

typedef struct Xl {
    Types type;
    union {
        None none_value;
        Bool bool_value;
        String string_value;
        Int int_value;
        Float float_value;
        List* list_ref;
        Dict* dict_ref;
        Lambda lambda_value;
        Iterator* iterator_ref;
    };
    struct Xl* ctx_ref;
} Xl;

typedef struct {
    bool pretty;
} JifyOpt;

typedef enum { J_V, J_R } JifyStkElT;

typedef struct {
    JifyStkElT t;
    struct Xl* v;
    String r;
    int d;
} JifyStkEl;

typedef struct {
    JifyStkEl* value;
    size_t len;
    size_t size;
} JifyStk;

typedef struct {
    char* value;
    size_t len;
    size_t size;
} StringBuilder;

static inline void fr_mm(Xl* a);

static inline Xl* mk_n() {
    Xl* r = malloc(sizeof(Xl));
    r->type = NONE;
    r->none_value = NULL;
    r->ctx_ref = NULL;
    return r;
}
static inline Xl* mk_b(Bool v) {
    Xl* r = malloc(sizeof(Xl));
    r->type = BOOL;
    r->bool_value = v;
    r->ctx_ref = NULL;
    return r;
}
static inline Xl* mk_s(String v) {
    Xl* r = malloc(sizeof(Xl));
    r->type = STRING;
    r->string_value = v ? strdup(v) : NULL;
    r->ctx_ref = NULL;
    return r;
}
static inline Xl* mk_i(Int v) {
    Xl* r = malloc(sizeof(Xl));
    r->type = INT;
    r->int_value = v;
    r->ctx_ref = NULL;
    return r;
}
static inline Xl* mk_f(Float v) {
    Xl* r = malloc(sizeof(Xl));
    r->type = FLOAT;
    r->float_value = v;
    r->ctx_ref = NULL;
    return r;
}

static inline void l_psh(List* l, Xl* el) {
    if (l->len >= l->size) {
        l->size *= 2;
        l->value = realloc(l->value, sizeof(Xl*) * l->size);
    }
    l->value[l->len] = el;
    l->len += 1;
}

static inline size_t h_s(String str) {
    unsigned int h = 2166136261U;
    while (*str != '\0') {
        h ^= (unsigned char)*str;
        h *= 16777619;
        str += 1;
    }
    return (size_t)(h % DICT_SIZE);
}

static inline void set(Dict* d, String k, Xl* v) {
    size_t i = h_s(k);
    Pair* h = d->items[i];
    while (h != NULL) {
        if (strcmp(h->key, k) == 0) {
            fr_mm(h->value);
            h->value = v;
            return;
        }
        h = h->next;
    }
    Pair* n = malloc(sizeof(Pair));
    n->key = k;
    n->value = v;
    n->next = d->items[i];
    d->items[i] = n;
    d->len += 1;
}

static inline Xl* d_g(Xl* a, String k) {
    if (a == NULL || a->type != DICT || a->dict_ref == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    Dict* d = a->dict_ref;
    size_t i = h_s(k);
    Pair* h = d->items[i];
    while (h != NULL) {
        if (strcmp(h->key, k) == 0) {
            return h->value;
        }
        h = h->next;
    }
    fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
    exit(1);
}

static inline Xl* mk_l(Xl* first_el, ...) {
    Xl* r = malloc(sizeof(Xl));
    List* l = malloc(sizeof(List));
    l->len = 0;
    l->size = 4;
    l->value = malloc(sizeof(Xl*) * l->size);
    List* lr = l;
    if (first_el != NULL) {
        l_psh(lr, first_el);
        va_list args;
        va_start(args, first_el);
        Xl* el;
        while ((el = va_arg(args, Xl*)) != NULL) {
            l_psh(lr, el);
        }
        va_end(args);
    }
    r->type = LIST;
    r->list_ref = lr;
    r->ctx_ref = NULL;
    return r;
}

static inline Pair mk_p(String k, Xl* v) {
    return (Pair){ .key = k, .value = v, .next = NULL };
}

static inline Xl* mk_d(Pair fp, ...) {
    Xl* r = malloc(sizeof(Xl));
    Dict* d = malloc(sizeof(Dict));
    d->len = 0;
    for (size_t i = 0; i < DICT_SIZE; i += 1) {
        d->items[i] = NULL;
    }
    Dict* dr = d;
    if (fp.key != NULL) {
        set(dr, fp.key, fp.value);
        va_list args;
        va_start(args, fp);
        Pair p;
        while (1) {
            p = va_arg(args, Pair);
            if (p.key == NULL) break;
            set(dr, p.key, p.value);
        }
        va_end(args);
    }
    r->type = DICT;
    r->dict_ref = dr;
    r->ctx_ref = NULL;
    return r;
}

static inline Xl* mk_c(Lambda c_ref, Xl* ctx_ref) {
    Xl* r = malloc(sizeof(Xl));
    r->type = LAMBDA;
    r->lambda_value = c_ref;
    r->ctx_ref = ctx_ref;
    return r;
}

static inline Xl* c_c(Xl* this_ref, Xl* va) {
    if (this_ref == NULL || this_ref->type != LAMBDA || this_ref->lambda_value == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    Xl* ctx_ref = (this_ref->ctx_ref != NULL) ? this_ref->ctx_ref : NULL;
    return this_ref->lambda_value(ctx_ref, mk_l(va, NULL));
}

static inline Xl* l_itr(Xl* l) {
    if (l == NULL || l->type != LIST || l->list_ref == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    Iterator* itrr = malloc(sizeof(Iterator));
    itrr->list_ref = l;
    itrr->index = 0;
    Xl* r = malloc(sizeof(Xl));
    r->type = ITERATOR;
    r->iterator_ref = itrr;
    r->ctx_ref = NULL;
    return r;
}

static inline Xl* itr_nxt(Xl* itr) {
    if (itr == NULL || itr->type != ITERATOR || itr->iterator_ref == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    Iterator* itrr = itr->iterator_ref;
    if (itrr->index >= itrr->list_ref->list_ref->len) {
        return mk_n();
    }
    Xl* r = itrr->list_ref->list_ref->value[itrr->index];
    itrr->index += 1;
    return r;
}

static inline StringBuilder* mk_sb() {
    StringBuilder* sb = malloc(sizeof(StringBuilder));
    sb->len = 0;
    sb->size = 16;
    sb->value = malloc(sb->size);
    sb->value[0] = '\0';
    return sb;
}

static inline void sb_apd(StringBuilder* sb, String s) {
    if (s == NULL) return;
    size_t s_len = strlen(s);
    if (s_len == 0) return;
    while (sb->len + s_len >= sb->size) {
        sb->size *= 2;
        sb->value = realloc(sb->value, sb->size);
    }
    strcpy(sb->value + sb->len, s);
    sb->len += s_len;
    sb->value[sb->len] = '\0';
}

static inline void sb_apdf(StringBuilder* sb, String fmt, ...) {
    char buf[64];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);
    sb_apd(sb, buf);
}

static inline Xl* s_jn(Xl* frs_el, ...) {
    StringBuilder* sb = mk_sb();
    if (frs_el != NULL && frs_el->type == STRING) {
        sb_apd(sb, frs_el->string_value);
        va_list args;
        va_start(args, frs_el);
        Xl* nxt;
        while ((nxt = va_arg(args, Xl*)) != NULL) {
            if (nxt->type == STRING) {
                sb_apd(sb, nxt->string_value);
            }
        }
        va_end(args);
    }
    Xl* r = mk_s(sb->value);
    free(sb->value);
    free(sb);
    return r;
}

static inline Xl* s_rpt(String this_str, Int count) {
    if (count <= 0 || this_str == NULL || strlen(this_str) == 0) {
        return mk_s("");
    }
    StringBuilder* sb = mk_sb();
    for (Int i = 0; i < count; i += 1) {
        sb_apd(sb, this_str);
    }
    Xl* r = mk_s(sb->value);
    free(sb->value);
    free(sb);
    return r;
}

static inline void prnt(String fst, ...) {
    StringBuilder* sb = mk_sb();
    if (fst != NULL) {
        sb_apd(sb, fst);
        va_list args;
        va_start(args, fst);
        String nxt;
        while ((nxt = va_arg(args, String)) != NULL) {
            sb_apd(sb, nxt);
            if (strlen(nxt) > 1 || (nxt[0] != ']' && nxt[0] != '[' && nxt[0] != ',' && nxt[0] != '{' && nxt[0] != '}')) {
                free((void*)nxt); 
            }
        }
        va_end(args);
    }
    printf("%s\n", sb->value);
    free(sb->value);
    free(sb);
}

static inline void s_esc(StringBuilder* r, String s) {
    if (s == NULL) return;
    size_t s_len = strlen(s);
    for (size_t i = 0; i < s_len; i += 1) {
        char c = s[i];
        switch (c) {
            case '\\':
                sb_apd(r, "\\\\");
                break;
            case '"':
                sb_apd(r, "\\\"");
                break;
            case '\n':
                sb_apd(r, "\\n");
                break;
            case '\r':
                sb_apd(r, "\\r");
                break;
            case '\t':
                sb_apd(r, "\\t");
                break;
            default:
                sb_apdf(r, "%c", c);
                break;
        }
    }
}

static inline String jify(Xl* a, JifyOpt o) {
    bool p = o.pretty;
    Xl* t = s_rpt(" ", 4);
    void jify_stk_push(JifyStk* s, JifyStkEl el) {
        if (s->len >= s->size) {
            s->size = s->size == 0 ? 4 : s->size * 2;
            s->value = realloc(s->value, sizeof(JifyStkEl) * s->size);
        }
        s->value[s->len] = el;
        s->len += 1;
    }
    JifyStk s = { .value = NULL, .len = 0, .size = 0 };
    jify_stk_push(&s, (JifyStkEl){ .t = J_V, .v = a, .r = "", .d = 0 });
    StringBuilder* r = mk_sb();
    List* gcor = malloc(sizeof(List));
    gcor->len = 0;
    gcor->size = 4;
    gcor->value = malloc(sizeof(Xl*) * gcor->size);
    while (s.len > 0) {
        s.len -= 1;
        JifyStkEl c = s.value[s.len];
        if (c.t == J_R) {
            sb_apd(r, c.r);
            continue;
        }
        Xl* v = c.v;
        int cur_d = c.d;
        if (v == NULL || v->type == NONE) {
            sb_apd(r, "null");
            continue;
        }
        switch (v->type) {
            case BOOL:
                sb_apd(r, v->bool_value ? "true" : "false");
                break;
            case STRING:
                sb_apd(r, "\"");
                s_esc(r, v->string_value);
                sb_apd(r, "\"");
                break;
            case INT:
                sb_apdf(r, "%d", v->int_value);
                break;
            case FLOAT:
                sb_apdf(r, "%g", v->float_value);
                break;
            case LAMBDA:
                sb_apd(r, "\"[object Function]\"");
                break;
            case LIST: {
                if (v->list_ref == NULL || v->list_ref->len == 0) {
                    sb_apd(r, "[]");
                    continue;
                }
                int child_dl = cur_d + 1;
                Xl* stlcb = s_rpt(t->string_value, cur_d);
                Xl* slcb = p ? s_jn(mk_s("\n"), stlcb, mk_s("]"), NULL) : mk_s("]");
                jify_stk_push(&s, (JifyStkEl){
                    .t = J_R,
                    .v = NULL,
                    .r = slcb->string_value,
                    .d = cur_d,
                });
                l_psh(gcor, stlcb);
                l_psh(gcor, slcb);
                for (size_t i = v->list_ref->len; i > 0; i -= 1) {
                    size_t li = i - 1;
                    jify_stk_push(&s, (JifyStkEl){
                        .t = J_V,
                        .v = v->list_ref->value[li],
                        .r = "",
                        .d = child_dl,
                    });
                    if (li > 0) {
                        Xl* stlelsep = s_rpt(t->string_value, child_dl);
                        Xl* slelsep = p ? s_jn(mk_s(",\n"), stlelsep, NULL) : mk_s(",");
                        jify_stk_push(&s, (JifyStkEl){
                            .t = J_R,
                            .v = NULL,
                            .r = slelsep->string_value,
                            .d = child_dl,
                        });
                        l_psh(gcor, stlelsep);
                        l_psh(gcor, slelsep);
                    }
                }
                Xl* stlob = s_rpt(t->string_value, child_dl);
                Xl* slob = p ? s_jn(mk_s("[\n"), stlob, NULL) : mk_s("[");
                jify_stk_push(&s, (JifyStkEl){
                    .t = J_R,
                    .v = NULL,
                    .r = slob->string_value,
                    .d = child_dl,
                });
                l_psh(gcor, stlob);
                l_psh(gcor, slob);
                break;
            }
            case DICT: {
                Dict* d_ref = v->dict_ref;
                if (d_ref == NULL || d_ref->len == 0) {
                    sb_apd(r, "{}");
                    continue;
                }
                int child_dd = cur_d + 1;
                Xl* stdcb = s_rpt(t->string_value, cur_d);
                Xl* sdcb = p ? s_jn(mk_s("\n"), stdcb, mk_s("}"), NULL) : mk_s("}");
                jify_stk_push(&s, (JifyStkEl){
                    .t = J_R,
                    .v = NULL,
                    .r = sdcb->string_value,
                    .d = cur_d,
                });
                l_psh(gcor, stdcb);
                l_psh(gcor, sdcb);
                Pair** dpl = malloc(sizeof(Pair*) * d_ref->len);
                size_t pi = 0;
                for (size_t i = 0; i < DICT_SIZE; i += 1) {
                    Pair* curr = d_ref->items[i];
                    while (curr != NULL) {
                        dpl[pi] = curr;
                        pi += 1;
                        curr = curr->next;
                    }
                }
                for (size_t i = d_ref->len; i > 0; i -= 1) {
                    size_t deli = i - 1;
                    Pair* del = dpl[deli];
                    jify_stk_push(&s, (JifyStkEl){
                        .t = J_V,
                        .v = del->value,
                        .r = "",
                        .d = child_dd,
                    });
                    Xl* sdksep = p ? s_jn(mk_s("\""), mk_s(del->key), mk_s("\": "), NULL) : s_jn(mk_s("\""), mk_s(del->key), mk_s("\":"), NULL);
                    jify_stk_push(&s, (JifyStkEl){
                        .t = J_R,
                        .v = NULL,
                        .r = sdksep->string_value,
                        .d = child_dd,
                    });
                    l_psh(gcor, sdksep);
                    if (deli > 0) {
                        Xl* stdsep = s_rpt(t->string_value, child_dd);
                        Xl* spsep = p ? s_jn(mk_s(",\n"), stdsep, NULL) : mk_s(",");
                        jify_stk_push(&s, (JifyStkEl){
                            .t = J_R,
                            .v = NULL,
                            .r = spsep->string_value,
                            .d = child_dd,
                        });
                        l_psh(gcor, stdsep);
                        l_psh(gcor, spsep);
                    }
                }
                free(dpl);
                Xl* stdob = s_rpt(t->string_value, child_dd);
                Xl* sdob = p ? s_jn(mk_s("{\n"), stdob, NULL) : mk_s("{");
                jify_stk_push(&s, (JifyStkEl){
                    .t = J_R,
                    .v = NULL,
                    .r = sdob->string_value,
                    .d = child_dd,
                });
                l_psh(gcor, stdob);
                l_psh(gcor, sdob);
                break;
            }
            default:
                sb_apd(r, "\"[object [\\\"C Object\\\"]]\"");
                break;
        }
    }
    free(s.value);
    fr_mm(t);
    String rv = r->value ? strdup(r->value) : "";
    free(r->value);
    free(r);
    for (size_t i = 0; i < gcor->len; i += 1) {
        Xl* g = gcor->value[i];
        if (g->type == STRING && g->string_value != NULL) {
            size_t s_len = strlen(g->string_value);
            if (s_len > 1 || (g->string_value[0] != ']' && g->string_value[0] != '[' && g->string_value[0] != ',' && g->string_value[0] != '{' && g->string_value[0] != '}')) {
                free((void*)g->string_value);
            }
        }
        free(g);
    }
    free(gcor->value);
    free(gcor);
    return rv;
}

static inline Bool to_b(Xl* a) {
    if (a == NULL || a->type != BOOL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    return a->bool_value;
}

static inline Int to_i(Xl* a) {
    if (a == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    switch (a->type) {
        case INT:
            return a->int_value;
        case FLOAT:
            return (Int)a->float_value;
        default:
            fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
            exit(1);
    }
}

static inline Float to_f(Xl* a) {
    if (a == NULL) {
        fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
        exit(1);
    }
    switch (a->type) {
        case INT:
            return (Float)a->int_value;
        case FLOAT:
            return a->float_value;
        default:
            fprintf(stderr, "XlRuntimeError: Invalid arguments.\n");
            exit(1);
    }
}

static inline String to_s(Xl* a) {
    if (a == NULL || a->type == NONE) return strdup("null");
    switch (a->type) {
        case BOOL:
            return strdup(a->bool_value ? "true" : "false");
        case STRING:
            return a->string_value ? strdup(a->string_value) : strdup("");
        case INT: {
            char buf[64];
            sprintf(buf, "%d", a->int_value);
            return strdup(buf);
        }
        case FLOAT: {
            char buf[64];
            sprintf(buf, "%g", a->float_value);
            return strdup(buf);
        }
        default: {
            return jify(a, (JifyOpt){ .pretty = false });
        }
    }
}

static inline void fr_mm(Xl* a) {
    if (a == NULL) return;
    switch (a->type) {
        case STRING:
            if (a->string_value != NULL) {
                free((void*)a->string_value);
            }
            break;
        case LIST:
            if (a->list_ref != NULL) {
                for (size_t i = 0; i < a->list_ref->len; i += 1) {
                    fr_mm(a->list_ref->value[i]);
                }
                free(a->list_ref->value);
                free(a->list_ref);
            }
            break;
        case DICT:
            if (a->dict_ref != NULL) {
                for (size_t i = 0; i < DICT_SIZE; i += 1) {
                    Pair* c = a->dict_ref->items[i];
                    while (c != NULL) {
                        Pair* tmp = c;
                        c = c->next;
                        fr_mm(tmp->value);
                        free(tmp);
                    }
                }
                free(a->dict_ref);
            }
            break;
        case LAMBDA:
            if (a->ctx_ref != NULL) {
                fr_mm(a->ctx_ref);
            }
            break;
        case ITERATOR:
            if (a->iterator_ref != NULL) {
                free(a->iterator_ref);
            }
            break;
        default:
            break;
    }
    free(a);
}

typedef struct {
    Xl* (*init_none)();
    Xl* (*init_bool)(Bool);
    Xl* (*init_string)(String);
    Xl* (*init_int)(Int);
    Xl* (*init_float)(Float);
    Xl* (*mk_l)(Xl*, ...);
    Xl* (*mk_d)(Pair, ...);
    Xl* (*mk_c)(Lambda, Xl*);
    Xl* (*call)(Xl*, Xl*);
    Xl* (*get)(Xl*, String);
    Xl* (*iter)(Xl*);
    Xl* (*next)(Xl*);
    void (*free)(Xl*);
    Xl* (*join)(Xl*, ...);
    Xl* (*repeat)(String, Int);
    String (*jify)(Xl*, JifyOpt);
    Pair (*init_pair)(String, Xl*);
    void (*prnt)(String, ...); 
    Bool (*to_bool)(Xl*);
    String (*to_string)(Xl*);
    Int (*to_int)(Xl*);
    Float (*to_float)(Xl*);
} XlNamespace;

const static XlNamespace xl = {
    .init_none = mk_n,
    .init_bool = mk_b,
    .init_string = mk_s,
    .init_int = mk_i,
    .init_float = mk_f,
    .mk_l = mk_l,
    .mk_d = mk_d,
    .mk_c = mk_c,
    .call = c_c,
    .get = d_g,
    .iter = l_itr,
    .next = itr_nxt,
    .free = fr_mm,
    .join = s_jn,
    .repeat = s_rpt,
    .jify = jify,
    .init_pair = mk_p,
    .prnt = prnt,
    .to_bool = to_b,
    .to_string = to_s,
    .to_int = to_i,
    .to_float = to_f,
};

#define init_list(...) mk_l(__VA_ARGS__, NULL)
#define init_dict(...) mk_d(__VA_ARGS__, mk_p(NULL, NULL))
#define init_lambda(body, ctx) mk_c(({ Xl* __fn__ (Xl* ctx_ref, Xl* vararg) body; __fn__; }), ctx)
#define json_stringify(_a, ...) jify((_a), (JifyOpt){ .pretty = false, __VA_ARGS__ })
#define print(...) prnt(__VA_ARGS__, NULL)

#endif // WILLYHORIZONT_RUNTIME_XL_H
