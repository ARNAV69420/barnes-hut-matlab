#include <vector>
#include <cmath>
#include <cstdio>
#include <memory>
#include <stdexcept>

struct Body {
    double x, y, mass;
    int id;
};

class Node {
public:
    std::vector<std::vector<double>> bounds; // [ [x_min, x_max], [y_min, y_max] ]
    double mass = 0.0;
    std::vector<double> cm = {0.0, 0.0};     // Center of mass
    std::vector<Body> body;                 // Either empty or size 1
    std::vector<std::unique_ptr<Node>> children; // 0 or 4 children

    Node(const std::vector<std::vector<double>>& bnds)
        : bounds(bnds) {}

    bool isLeaf() const {
        return children.empty();
    }

    bool isEmpty() const {
        return body.empty() && isLeaf();
    }

    bool inBounds(const std::vector<double>& pos) const {
        return pos[0] >= bounds[0][0] && pos[0] <= bounds[0][1] &&
               pos[1] >= bounds[1][0] && pos[1] <= bounds[1][1];
    }

    int whichQuadrant(const std::vector<double>& pos) const {
        double xmid = (bounds[0][0] + bounds[0][1]) / 2.0;
        double ymid = (bounds[1][0] + bounds[1][1]) / 2.0;
        if (pos[0] <= xmid && pos[1] >= ymid) return 0; // NW
        if (pos[0] >  xmid && pos[1] >= ymid) return 1; // NE
        if (pos[0] <= xmid && pos[1] <  ymid) return 2; // SW
        return 3; // SE
    }

    std::vector<std::vector<double>> childBounds(int q) const {
        double xmid = (bounds[0][0] + bounds[0][1]) / 2.0;
        double ymid = (bounds[1][0] + bounds[1][1]) / 2.0;

        switch (q) {
            case 0: return {{bounds[0][0], xmid}, {ymid, bounds[1][1]}};
            case 1: return {{xmid, bounds[0][1]}, {ymid, bounds[1][1]}};
            case 2: return {{bounds[0][0], xmid}, {bounds[1][0], ymid}};
            case 3: return {{xmid, bounds[0][1]}, {bounds[1][0], ymid}};
            default: throw std::runtime_error("Invalid quadrant");
        }
    }

    void subdivide() {
        for (int q = 0; q < 4; ++q)
            children.emplace_back(std::make_unique<Node>(childBounds(q)));
    }

    void insert(const Body& b) {
        std::vector<Node*> stack = {this};
        std::vector<Body> data = {b};

        while (!stack.empty()) {
            Node* node = stack.back(); stack.pop_back();
            Body current = data.back(); data.pop_back();

            std::vector<double> pos = {current.x, current.y};
            if (!node->inBounds(pos)) continue;

            if (node->isEmpty()) {
                node->body.push_back(current);
                node->mass = current.mass;
                node->cm = {current.x, current.y};
                continue;
            }

            if (node->isLeaf()) {
                Body old = node->body[0];
                node->body.clear();
                node->subdivide();
                stack.push_back(node); data.push_back(current);
                stack.push_back(node); data.push_back(old);
                continue;
            }

            // Update CM and mass
            double totalMass = node->mass + current.mass;
            node->cm[0] = (node->cm[0] * node->mass + current.x * current.mass) / totalMass;
            node->cm[1] = (node->cm[1] * node->mass + current.y * current.mass) / totalMass;
            node->mass = totalMass;

            int q = node->whichQuadrant(pos);
            stack.push_back(node->children[q].get());
            data.push_back(current);
        }
    }

    std::vector<double> computeForce(const Body& target, double theta, double G, double eps) const {
        std::vector<double> F = {0.0, 0.0};
        std::vector<const Node*> stack = {this};
        std::vector<double> pos = {target.x, target.y};

        while (!stack.empty()) {
            const Node* node = stack.back(); stack.pop_back();
            if (node->isEmpty()) continue;
            if (node->isLeaf() && node->body[0].id == target.id) continue;

            double dx = node->cm[0] - pos[0];
            double dy = node->cm[1] - pos[1];
            double dist2 = dx * dx + dy * dy + eps * eps;
            double dist = std::sqrt(dist2);
            double width = node->bounds[0][1] - node->bounds[0][0];

            if (node->isLeaf() || (width / dist < theta)) {
                double forceMag = G * node->mass * target.mass / (dist2 * dist);
                F[0] += forceMag * dx;
                F[1] += forceMag * dy;
            } else {
                for (const auto& child : node->children)
                    stack.push_back(child.get());
            }
        }

        return F;
    }
};
