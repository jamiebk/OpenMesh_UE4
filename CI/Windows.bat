mkdir build-release

cd build-release

IF "%ARCHITECTURE%" == "x64" (
  set ARCH_VS= Win64
  set STRING_ARCH=64-Bit
) else (
  set ARCH_VS=
  set STRING_ARCH=32-Bit
)

IF "%SHARED%" == "TRUE" (
  set STRING_DLL=-DLL
) ELSE (
  set STRING_DLL=
)

IF "%BUILD_PLATFORM%" == "VS2012" (
    set LIBPATH=E:\libs\VS2012
    set GTESTVERSION=gtest-1.6.0
    set GENERATOR=Visual Studio 11%ARCH_VS%
    set VS_PATH="C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv.com"
    set QT_VERSION=
    IF "%ARCHITECTURE%" == "x64" (
      set QT_INSTALL_PATH=E:\Qt\4.8.5-vs2012-%STRING_ARCH%\
      set QT_BASE_CONFIG=-DQT_QMAKE_EXECUTABLE=E:\Qt\4.8.5-vs2012-%STRING_ARCH%\bin\qmake.exe
    )

    IF "%ARCHITECTURE%" == "x32" (
      set QT_INSTALL_PATH=E:\Qt\4.8.5-vs2012-%STRING_ARCH%\
      set QT_BASE_CONFIG=-DQT_QMAKE_EXECUTABLE=E:\Qt\4.8.5-vs2012-%STRING_ARCH%\bin\qmake.exe 
    )
) 

IF "%BUILD_PLATFORM%" == "VS2013" (
    set LIBPATH=E:\libs\VS2013
    set GTESTVERSION=gtest-1.6.0
    set GENERATOR=Visual Studio 12%ARCH_VS%
    set VS_PATH="C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.com"
    set QT_VERSION=
    IF "%ARCHITECTURE%" == "x64" (
      set QT_INSTALL_PATH=E:\Qt\Qt5.3.1-vs2013-%STRING_ARCH%\5.3\msvc2013_64_opengl
      set QT_BASE_CONFIG=-DQT5_INSTALL_PATH=E:\Qt\Qt5.3.1-vs2013-%STRING_ARCH%\5.3\msvc2013_64_opengl
    )

    IF "%ARCHITECTURE%" == "x32" (
      set QT_INSTALL_PATH=E:\Qt\Qt5.3.1-vs2013-%STRING_ARCH%\5.3\msvc2013_opengl
      set QT_BASE_CONFIG=-DQT5_INSTALL_PATH=E:\Qt\Qt5.3.1-vs2013-%STRING_ARCH%\5.3\msvc2013_opengl
    )
) 

IF "%BUILD_PLATFORM%" == "VS2015" (
    set LIBPATH=E:\libs\VS2015
    set GTESTVERSION=gtest-1.7.0
    set GENERATOR=Visual Studio 14%ARCH_VS%
    set VS_PATH="C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.com"

    set QT_VERSION=
    IF "%ARCHITECTURE%" == "x64" (
      set QT_INSTALL_PATH=E:\Qt\Qt5.6.0-vs2015-%STRING_ARCH%\5.6\msvc2015_64
      set QT_BASE_CONFIG=-DQT5_INSTALL_PATH=E:\Qt\Qt5.6.0-vs2015-%STRING_ARCH%\5.6\msvc2015_64
    )

    IF "%ARCHITECTURE%" == "x32" (
      set QT_INSTALL_PATH=E:\Qt\Qt5.6.0-vs2015-%STRING_ARCH%\5.6\msvc2015
      set QT_BASE_CONFIG=-DQT5_INSTALL_PATH=E:\Qt\Qt5.6.0-vs2015-%STRING_ARCH%\5.6\msvc2015
    )

) 


IF "%APPS%" == "ON" (
  set STRING_APPS=

  REM Create the platform plugins subdirectory for the qt plugins required to run the gui apps
  mkdir Build\plugins
  mkdir Build\plugins\platforms

  REM Copy the platform plugins subdirectory for the qt plugins required to run the gui apps
  xcopy /Y %QT_INSTALL_PATH%\plugins\platforms Build\plugins\platforms 

  IF "%BUILD_PLATFORM%" == "VS2015" (
    set CMAKE_CONFIGURATION=%QT_BASE_CONFIG% -DGLUT_INCLUDE_DIR="%LIBPATH%\%ARCHITECTURE%\freeglut-3.0.0\include" -DGLUT_glut_LIBRARY="%LIBPATH%\%ARCHITECTURE%\freeglut-3.0.0\lib\freeglut.lib"


  ) ELSE (
    set CMAKE_CONFIGURATION=%QT_BASE_CONFIG% -DGLUT_INCLUDE_DIR="%LIBPATH%\%ARCHITECTURE%\freeglut-2.8.1\include" -DGLUT_glut_LIBRARY="%LIBPATH%\%ARCHITECTURE%\freeglut-2.8.1\lib\freeglut.lib"
  )
) ELSE (
  set STRING_APPS=-no-apps
  set CMAKE_CONFIGURATION=
)


"C:\Program Files (x86)\CMake\bin\cmake.exe" -DGTEST_PREFIX="%LIBPATH%\%ARCHITECTURE%\%GTESTVERSION%" -G "%GENERATOR%"  -DCMAKE_BUILD_TYPE=Release -DBUILD_APPS=%APPS% -DOPENMESH_BUILD_UNIT_TESTS=TRUE -DCMAKE_WINDOWS_LIBS_DIR="e:\libs" -DOPENMESH_BUILD_SHARED=%SHARED% %CMAKE_CONFIGURATION% ..

%VS_PATH% /Build "Release" OpenMesh.sln /Project "ALL_BUILD"

IF %errorlevel% NEQ 0 exit /b %errorlevel%

cd unittests

unittests.exe --gtest_output=xml

cd ..

cd ..

mkdir build-debug

cd build-debug

"C:\Program Files (x86)\CMake\bin\cmake.exe" -DGTEST_PREFIX="%LIBPATH%\%ARCHITECTURE%\%GTESTVERSION%" -G "%GENERATOR%" -DOPENMESH_BUILD_UNIT_TESTS=TRUE  -DCMAKE_BUILD_TYPE=Debug -DOPENMESH_BUILD_SHARED=%SHARED% -DBUILD_APPS=%APPS% %CMAKE_CONFIGURATION% ..

%VS_PATH% /Build "Debug" OpenMesh.sln /Project "ALL_BUILD"

IF %errorlevel% NEQ 0 exit /b %errorlevel%


copy Build\lib\*d.lib ..\build-release\Build\lib

IF "%SHARED%" == "TRUE" (
  copy Build\*.dll ..\build-release\Build
) 


cd unittests

unittests.exe --gtest_output=xml

IF %errorlevel% NEQ 0 exit /b %errorlevel%

cd ..

cd ..

cd build-release

del *.exe

"C:\Program Files (x86)\CMake\bin\cmake.exe" -DGTEST_PREFIX="%LIBPATH%\%ARCHITECTURE%\%GTESTVERSION%"  -G "%GENERATOR%" -DBUILD_APPS=%APPS% -DCMAKE_BUILD_TYPE=Release %CMAKE_CONFIGURATION% ..

%VS_PATH% /Build "Release" OpenMesh.sln /Project "PACKAGE"

IF %errorlevel% NEQ 0 exit /b %errorlevel%

move OpenMesh-*.exe "OpenMesh-7.0-Git-Master-%CI_BUILD_REF%-%BUILD_PLATFORM%-%STRING_ARCH%%STRING_DLL%%STRING_APPS%.exe"



