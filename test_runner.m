suite = testsuite("tests");

import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoverageReport
runner = testrunner("textoutput");
sourceCodeFolder = "itp_matlab";
reportFolder = "coverage";
reportFormat = CoverageReport(reportFolder);
p = CodeCoveragePlugin.forFolder( ...
    sourceCodeFolder,"Producing",reportFormat);
runner.addPlugin(p)

runner.run(suite);