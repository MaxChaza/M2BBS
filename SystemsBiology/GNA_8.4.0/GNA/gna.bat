REM Command script that launch GNA in command line (inside Iogma Environment)
REM
REM Change variable below to point to Iogma installation directory if you intend
REM to run this script from another path
REM e.g. set IOGMA_HOME=C:/Iogma
SET IOGMA_HOME=/home/quentin/GNA_8.4.0
REM
java -Diogma.home=%IOGMA_HOME% -classpath "%IOGMA_HOME%/GNA/bin/GNA.jar;%IOGMA_HOME%/GNA/bin/java_cup.jar;%IOGMA_HOME%/GNA/bin/saxon8.jar;%IOGMA_HOME%/GNA/bin/saxon8-dom.jar;%IOGMA_HOME%/bin/JSAP.jar;%IOGMA_HOME%/bin/log4j.jar;%IOGMA_HOME%/bin/IogmaCore.jar;%IOGMA_HOME%/bin/HelixUtils.jar;%IOGMA_HOME%/bin/IogmaNetwork.jar" -Dlog4j.configuration="%IOGMA_HOME%/GNA/log4j.simu.xml" gna.kernel.Project %1 %2 %3 %4 %5 %6
SET IOGMA_HOME=
