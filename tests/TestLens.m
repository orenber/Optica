classdef TestLens < matlab.unittest.TestCase
    properties
        
        ax
        testLens
    end
    
    methods(TestMethodSetup)
        function createLens(testCase)
            
            testCase.ax = gca;
            xlim( testCase.ax ,[-10,10])
            ylim( testCase.ax ,[-10,10])
            testCase.testLens = Lens('color','green','height',5,...
                'radius_right',-1.8);
        end
    end
    
    methods(TestMethodTeardown)
        function deleteLens(testCase)
            delete(testCase.testLens)
        end
    end
    
    methods (Test)
        function testClass(testCase)
            lens = testCase.testLens();
            testCase.verifyClass(lens, 'Lens');
        end
        
        
        function test_x(testCase)
            testCase.testLens.x = 5;
            testCase.verifyEqual(testCase.testLens.x,5);
        end
        
        function test_y(testCase)
            testCase.testLens.y = 3;
            testCase.verifyEqual(testCase.testLens.y,3);
        end
        
        function test_height(testCase)
            testCase.testLens.height = 8;
            testCase.verifyEqual(testCase.testLens.height,8);
        end
        
        function test_width(testCase)
            testCase.testLens.width = 3;
            testCase.verifyEqual(testCase.testLens.width,3);
        end
        
        function test_radius_left(testCase)
            testCase.testLens.radius_left = inf;
            testCase.verifyEqual(testCase.testLens.radius_left,inf);
        end
        
        function test_radius_right(testCase)
            testCase.testLens.radius_right = inf;
            testCase.verifyEqual(testCase.testLens.radius_right,inf);
        end
        
        function test_color(testCase)
            testCase.testLens.color = 'red';
            testCase.verifyEqual(testCase.testLens.color,'Red');
        end
        function test_focal(testCase)
            
            testCase.verifyEqual(round(testCase.testLens.focal,4),2.7183^-1);
        end
        
        function test_getMatrix(testCase)
            matrix = testCase.testLens.getMatrix();
            testCase.verifyClass(matrix,'sym');
        end
        
    end
end