// acclFromPos_mex.cpp
#include "acclFromPos_mex.hpp"
#include "mex.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
    if (nrhs != 2)
        mexErrMsgTxt("Expected 2 inputs: positions (Nx2), preset (struct)");

    double* pos = mxGetPr(prhs[0]);
    size_t N = mxGetM(prhs[0]);

    const mxArray* preset = prhs[1];
    double* masses = mxGetPr(mxGetField(preset, 0, "masses"));
    double* bounds = mxGetPr(mxGetField(preset, 0, "bounds"));
    double G = *mxGetPr(mxGetField(preset, 0, "G"));
    double eps = *mxGetPr(mxGetField(preset, 0, "eps"));
    double theta = *mxGetPr(mxGetField(preset, 0, "theta"));

    plhs[0] = mxCreateDoubleMatrix(N, 2, mxREAL);
    double* acc = mxGetPr(plhs[0]);

    std::vector<std::vector<double>> bnd = {
        {bounds[0], bounds[2]},
        {bounds[1], bounds[3]}
    };
    Node root(bnd);

    for (size_t i = 0; i < N; ++i) {
        Body b = {pos[i], pos[i + N], masses[i], static_cast<int>(i)};
        root.insert(b);
    }

    for (size_t i = 0; i < N; ++i) {
        Body b = {pos[i], pos[i + N], masses[i], static_cast<int>(i)};
        std::vector<double> F = root.computeForce(b, theta, G, eps);
        acc[i] = F[0] / b.mass;
        acc[i + N] = F[1] / b.mass;
    }
}
