@echo off
@rem java -Xms512m -Xmx1024m -cp bin;externalpackages\java-cup-11a.jar;externalpackages\jung-1.7.6.jar;externalpackages\colt.jar;externalpackages\commons-collections-3.1.jar;externalpackages\TableLayout.jar;externalpackages\xercesImpl.jar GUI.App
@java -Xms512m -Xmx1024m -cp charlie.jar;externalpackages\* charlie.Charlie %*
