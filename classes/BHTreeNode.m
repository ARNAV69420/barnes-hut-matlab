classdef BHTreeNode < handle
    properties
        bounds   % [x_min x_max; y_min y_max]
        mass     % total mass in node
        cm       % center of mass [x, y]
        body     % body in this node: [x y mass id]
        children % 4-cell array: NW, NE, SW, SE
        isLeaf   % true if this is a leaf node
    end

    methods
        function obj = BHTreeNode(bounds)
            obj.bounds = bounds;
            obj.mass = 0;
            obj.cm = [0, 0];
            obj.body = [];
            obj.children = cell(1, 4);
            obj.isLeaf = true;
        end

        function insert(obj, body)
            % body is expected in this form [x_cord, y_cord, mass, id]
            
            % initialize stacks
            stack = {obj};
            data = {body};
            % do DFS using stack, else suffer very high recursion depth
            while ~isempty(stack)
                % pop stack
                node = stack{end}; stack(end) = [];
                b = data{end}; data(end) = [];
                
                pos = b(1:2);

                if ~obj.inBounds(node.bounds, pos)
                    continue;
                end

                if isempty(node.body) && all(cellfun(@isempty, node.children))
                    node.body = b;
                    node.mass = b(3);
                    node.cm = pos;
                    continue;
                end

                if node.isLeaf
                    % Subdivide
                    node.subdivide();
                    oldBody = node.body;
                    node.body = [];
                    node.isLeaf = false;
                    stack{end+1} = node; data{end+1} = b;
                    stack{end+1} = node; data{end+1} = oldBody;
                    continue;
                end

                % Update mass and CM
                total_mass = node.mass + b(3);
                node.cm = (node.cm * node.mass + pos * b(3)) / total_mass;
                node.mass = total_mass;

                % Push to appropriate child
                q = node.whichQuadrant(pos);
                if isempty(node.children{q})
                    node.children{q} = BHTreeNode(node.childBounds(q));
                end
                stack{end+1} = node.children{q};
                data{end+1} = b;
            end
        end

        function inside = inBounds(~, bounds, pos)
            inside = pos(1) >= bounds(1,1) && pos(1) <= bounds(1,2) && ...
                     pos(2) >= bounds(2,1) && pos(2) <= bounds(2,2);
        end

        function F = computeForceOn(obj, body, theta, G, eps)
            F = [0, 0];
            stack = {obj};
            pos = body(1:2);
            id = body(4);

            while ~isempty(stack)
                node = stack{end}; stack(end) = [];

                if isempty(node) || (node.isLeaf && isempty(node.body))
                    continue;
                end

                if node.isLeaf && node.body(4) == id
                    continue; % same body
                end

                s = node.bounds(1,2) - node.bounds(1,1);
                d = norm(node.cm - pos) + eps;

                if node.isLeaf || (s / d < theta)
                    % Approximate
                    dx = node.cm(1) - pos(1);
                    dy = node.cm(2) - pos(2);
                    dist = sqrt(dx^2 + dy^2 + eps^2);
                    F = F + G * node.mass * body(3) * [dx, dy] / dist^3;
                else
                    for i = 1:4
                        if ~isempty(node.children{i})
                            stack{end+1} = node.children{i};
                        end
                    end
                end
            end
        end

        function q = whichQuadrant(obj, pos)
            xmid = mean(obj.bounds(1,:));
            ymid = mean(obj.bounds(2,:));
            x = pos(1); y = pos(2);
            if x <= xmid && y >= ymid
                q = 1; % NW
            elseif x > xmid && y >= ymid
                q = 2; % NE
            elseif x <= xmid && y < ymid
                q = 3; % SW
            else
                q = 4; % SE
            end
        end

        function subdivide(obj)
            for i = 1:4
                obj.children{i} = BHTreeNode(obj.childBounds(i));
            end
        end

        function b = childBounds(obj, q)
            xmid = mean(obj.bounds(1,:));
            ymid = mean(obj.bounds(2,:));
            switch q
                case 1, b = [obj.bounds(1,1) xmid; ymid obj.bounds(2,2)]; % NW
                case 2, b = [xmid obj.bounds(1,2); ymid obj.bounds(2,2)]; % NE
                case 3, b = [obj.bounds(1,1) xmid; obj.bounds(2,1) ymid]; % SW
                case 4, b = [xmid obj.bounds(1,2); obj.bounds(2,1) ymid]; % SE
            end
        end
    end
end