#pragma once

#include <vector>
#include <memory>
#include <unordered_map>
#include <string>

namespace ast {

class Root;
class Function;
class TypeDef;
// class DataDef;
class Block;
class Instruction;

class Visitor {
public:
    virtual ~Visitor() = default;

    virtual void visit(Root& node) = 0;
    virtual void visit(TypeDef& node) = 0;

    virtual void visit(Function& node) = 0;
    virtual void visit(Block& node) = 0;
    virtual void visit(Instruction& node) = 0;
};

class Node {
public:
    virtual ~Node() = default;

    virtual void accept(Visitor& visitor) = 0;
};

class Root : public Node {
public:
    ~Root() override = default;

    void accept(Visitor& visitor) override {
        visitor.visit(*this);
    }

private:
    std::vector<std::shared_ptr<Function>> functions_{};
    std::unordered_map<std::string, std::shared_ptr<TypeDef>> typedefs_{};
    // std::vector<std::shared_ptr<DataDef>> dataDefs_;
};

class TypeDef : public Node {
public:
    ~TypeDef() override = default;

    void accept(Visitor& visitor) override {
        visitor.visit(*this);
    }

};

class Function : public Node {
public:
    ~Function() override = default;

    void accept(Visitor& visitor) override {
        visitor.visit(*this);
    }
};

class Block : public Node {
public:
    ~Block() override = default;

    void accept(Visitor& visitor) override {
        visitor.visit(*this);
    }
};

class Instruction : public Node {
public:
    ~Instruction() override = default;

    void accept(Visitor& visitor) override {
        visitor.visit(*this);
    }
};

}