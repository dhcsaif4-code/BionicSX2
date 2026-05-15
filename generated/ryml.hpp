#pragma once
#include <stddef.h>
#include <string>
namespace ryml {
struct csubstr {
    const char* p; size_t len;
    csubstr() : p(nullptr), len(0) {}
    csubstr(const char* s, size_t l) : p(s), len(l) {}
};
struct NodeRef {
    NodeRef() {}
    bool valid() const { return false; }
    bool has_child(csubstr) const { return false; }
    NodeRef operator[](csubstr) const { return NodeRef(); }
    csubstr key() const { return csubstr(); }
    csubstr val() const { return csubstr(); }
    bool is_seq() const { return false; }
    bool is_map() const { return false; }
    size_t num_children() const { return 0; }
    NodeRef first_child() const { return NodeRef(); }
    NodeRef next_sibling() const { return NodeRef(); }
};
struct Tree {
    Tree() {}
    bool empty() const { return true; }
    NodeRef rootref() { return NodeRef(); }
};
bool parse_in_place(csubstr, csubstr, Tree*) { return false; }
void parse(csubstr, Tree*) {}
}
