classdef TestSystemOptic < matlab.unittest.TestCase
    properties
        
        ax
        testSystemOptic
    end
    
    methods(TestMethodSetup)
        function createSystemOptic(testCase)
            a = gca;
            testCase.testSystemOptic  = SystemOptic();
            testCase.testSystemOptic.createAxesBanch(a)
        end
    end
    
    methods(TestMethodTeardown)
        function deleteLens(testCase)
            delete(testCase.testSystemOptic)
        end
    end
    
    methods (Test)
        function testClass(testCase)
            testCase.verifyClass(testCase.testSystemOptic,'SystemOptic');
        end
        
        function test_findLensIndx(testCase)
            %% create 3 lens
            len1 = Lens();
            len2 = Lens();
            len3 = Lens();
            %% update position lens
            len1.x  = 10;
            len2.x = 16;
            %% add lens to the system
            testCase.testSystemOptic.addLens(len1)
            testCase.testSystemOptic.addLens(len2)
            testCase.testSystemOptic.addLens(len3)
            indx = testCase.testSystemOptic.findLensIndx(len3);
            testCase.verifyEqual(indx,testCase.testSystemOptic.indx);
        end
        
        function test_addFig(testCase)
           f = Fig();
           testCase.testSystemOptic.addFigure(f);
           testCase.verifyEqual(testCase.testSystemOptic.figure,f); 
        end
        
        
        function test_resetSystem(testCase)
                       %% create 3 lens
            len1 = Lens();
            len2 = Lens();
            len3 = Lens();
            %% update position lens
            len1.x  = 10;
            len2.x = 16;
                %% add lens to the system
            testCase.testSystemOptic.addLens(len1)
            testCase.testSystemOptic.addLens(len2)
            testCase.testSystemOptic.addLens(len3)
            testCase.testSystemOptic.resetSystem();
            testCase.verifyEmpty(testCase.testSystemOptic.lens)
        end
        
    end
end