//
//  LevenbergMarquardt.h
//  Group5iBeacons
//
//  Created by Nemanja Joksovic on 6/11/14.
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#ifndef Group5iBeacons_LevenbergMarquardt_h
#define Group5iBeacons_LevenbergMarquardt_h

#include "Eigen/Core"
#include "Eigen/Dense"

#include "unsupported/Eigen/NonLinearOptimization"
#include "unsupported/Eigen/NumericalDiff"

template<typename _Scalar, int NX = Eigen::Dynamic, int NY = Eigen::Dynamic>

struct Functor {
    
    typedef _Scalar Scalar;
    enum {
        InputsAtCompileTime = NX,
        ValuesAtCompileTime = NY
    };
    typedef Eigen::Matrix<Scalar,InputsAtCompileTime,1> InputType;
    typedef Eigen::Matrix<Scalar,ValuesAtCompileTime,1> ValueType;
    typedef Eigen::Matrix<Scalar,ValuesAtCompileTime,InputsAtCompileTime> JacobianType;
    
    int m_inputs, m_values;
    
    Functor() : m_inputs(InputsAtCompileTime), m_values(ValuesAtCompileTime) {}
    Functor(int inputs, int values) : m_inputs(inputs), m_values(values) {}
    
    int inputs() const { return m_inputs; }
    int values() const { return m_values; }
};

struct distance_functor : Functor<double> {

    Eigen::MatrixXd matrix;
    
    distance_functor( Eigen::MatrixXd &m, int count) : matrix(m), Functor<double>(count, count) {}
    
    int operator()(const Eigen::VectorXd &b, Eigen::VectorXd &fvec) const {
        for(int i = 0; i < matrix.rows(); i++) {
            fvec[i] = 1 - sqrt(pow(matrix(i, 0) - b[0], 2) + pow(matrix(i, 1) - b[1], 2)) / matrix(i, 2);
        }

        return 0;
    }
};

#endif
