@ECHO OFF

SET COMPOSE_FILE_PATH=%CD%\target\classes\docker\docker-compose.yml

IF [%M2_HOME%]==[] (
    SET MVN_EXEC=mvn
)

IF NOT [%M2_HOME%]==[] (
    SET MVN_EXEC=%M2_HOME%\bin\mvn
)

IF [%1]==[] (
    echo "Usage: %0 {build_start|build_start_it_supported|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
    GOTO END
)

IF %1==build_start (
    CALL :down
    CALL :build
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==build_start_it_supported (
    CALL :down
    CALL :build
    CALL :prepare-test
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==start (
    CALL :start
    CALL :tail
    GOTO END
)
IF %1==stop (
    CALL :down
    GOTO END
)
IF %1==purge (
    CALL:down
    CALL:purge
    GOTO END
)
IF %1==tail (
    CALL :tail
    GOTO END
)
IF %1==reload_share (
    CALL :build_share
    CALL :start_share
    CALL :tail
    GOTO END
)
IF %1==reload_acs (
    CALL :build_acs
    CALL :start_acs
    CALL :tail
    GOTO END
)
IF %1==build_test (
    CALL :down
    CALL :build
    CALL :prepare-test
    CALL :start
    CALL :test
    CALL :tail_all
    CALL :down
    GOTO END
)
IF %1==test (
    CALL :test
    GOTO END
)
echo "Usage: %0 {build_start|start|stop|purge|tail|reload_share|reload_acs|build_test|test}"
:END
EXIT /B %ERRORLEVEL%

:start
    docker volume create qrcode-alfresco-new-acs-volume
    docker volume create qrcode-alfresco-new-db-volume
    docker volume create qrcode-alfresco-new-ass-volume
    docker compose -f "%COMPOSE_FILE_PATH%" up --build -d
EXIT /B 0
:start_share
    docker compose -f "%COMPOSE_FILE_PATH%" up --build -d qrcode-alfresco-new-share
EXIT /B 0
:start_acs
    docker compose -f "%COMPOSE_FILE_PATH%" up --build -d qrcode-alfresco-new-acs
EXIT /B 0
:down
    if exist "%COMPOSE_FILE_PATH%" (
        docker compose -f "%COMPOSE_FILE_PATH%" down
    )
EXIT /B 0
:build
	call %MVN_EXEC% clean package
EXIT /B 0
:build_share
    docker compose -f "%COMPOSE_FILE_PATH%" kill qrcode-alfresco-new-share
    docker compose -f "%COMPOSE_FILE_PATH%" rm -f qrcode-alfresco-new-share
	call %MVN_EXEC% clean package -pl qrcode-alfresco-new-share,qrcode-alfresco-new-share-docker
EXIT /B 0
:build_acs
    docker compose -f "%COMPOSE_FILE_PATH%" kill qrcode-alfresco-new-acs
    docker compose -f "%COMPOSE_FILE_PATH%" rm -f qrcode-alfresco-new-acs
	call %MVN_EXEC% clean package -pl qrcode-alfresco-new-integration-tests,qrcode-alfresco-new-platform,qrcode-alfresco-new-platform-docker
EXIT /B 0
:tail
    docker compose -f "%COMPOSE_FILE_PATH%" logs -f
EXIT /B 0
:tail_all
    docker compose -f "%COMPOSE_FILE_PATH%" logs --tail="all"
EXIT /B 0
:prepare-test
    call %MVN_EXEC% verify -DskipTests=true -pl qrcode-alfresco-new-platform,qrcode-alfresco-new-integration-tests,qrcode-alfresco-new-platform-docker
EXIT /B 0
:test
    call %MVN_EXEC% verify -pl qrcode-alfresco-new-platform,qrcode-alfresco-new-integration-tests
EXIT /B 0
:purge
    docker volume rm -f qrcode-alfresco-new-acs-volume
    docker volume rm -f qrcode-alfresco-new-db-volume
    docker volume rm -f qrcode-alfresco-new-ass-volume
EXIT /B 0