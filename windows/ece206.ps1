# ==================================================================== #
#                            script: ece206                            #
# ==================================================================== #
#% SYNOPSIS
#+    ece206 [COMMAND]
#%
#% DESCRIPTION
#-    A helper script to assist in utlizing a docker environment
#+    to write and test verilog projects.
#%
#% COMMANDS
#-    init    Create cli and working directory for projects
#-    start   Start docker container with ~/ece206 mounted
#-    update  Update the VSCode configuration and Docker image
#-    code    Open a preconfigured VSCode session in Docker
#%
#% OPTIONS
#-    --help                    Print help information
#%
#% EXAMPLES
#-    ece206 start
#%
#=======================================================================
#% IMPLEMENTATION
#-    version         0.0.2
#-    last updated    2022/1/21
#-    author(s)       BENJAMIN HERBER,
#-    repository      https://github.com/benherber/ece206-dockerenv
#%
#=======================================================================
#% HISTORY
#-    2021/10/21 : Benjamin Herber : Created Script
#-    2022/1/21 : Benjamin Herber : Updated to support .devcontainer
#=======================================================================

# #################################################################### #
#                              VARIABLES                               #
# #################################################################### #

Function Global:ece206 {
    [CmdletBinding()]
    Param([parameter(Position = 0)]$cmd)

    $WORKDIR = $HOME + "\ece206" # Working directory for projects
    $DEVDIR = "$WORKDIR\.devcontainer"

    $VERSION = "0.0.2"          # Version number
    $LAST_UPDATED = "Jan. 2022" # Last update to script

    $IMAGE="benherber/ece206:latest"                                          # Docker base image
    $REPO="https://raw.githubusercontent.com/benherber/ece206-dockerenv/main" # GitHub Repository for raw downloads
    $DEVDOCKERFILE="${REPO}/.devcontainer/Dockerfile"                         # Devcontainer Dockerfile
    $DEVCONFIG="${REPO}/.devcontainer/devcontainer.json"                      # Devcontainer configuration
    
    # Error Code
    $SUCCESS=0
    $FAILURE=-1

    # #################################################################### #
    #                              FUNCTIONS                               #
    # #################################################################### #

    # Error out on usage issue
    # OUTPUTS:
    #   Write help message to stderr
    Function Usage {
        throw "Unrecognized command - try ``ece206 --help`` for more options."
    }

    # -------------------------------------------------------------------- #

    # Start the docker container with $WORKDIR volume mounted
    # GLOBALS:
    #   WORKDIR
    # OUTPUTS:
    #   Interactive shell session within container

    Function StartContainer {
        docker run `
            --rm `
            -v ${WORKDIR}:/workspace `
            -e BROADWAY=5 `
            -p 8085:8085 `
            -it benherber/ece206:latest /bin/bash
    }

    # -------------------------------------------------------------------- #

    # Update VSCode configuration and Docker image
    # GLOBALS:
    #   DEVDIR
    #   DEVCONFIG
    #   DEVDOCKERFILE
    #   IMAGE

    Function Update {
        # Validate directory structure
        If (!(Test-Path ${DEVDIR})) {
            throw "Please run ``ece206 init`` first"
        }
        If ((Test-Path "${DEVDIR}\devcontainer.json")) {
            Remove-Item -Force -Path "${DEVDIR}\devcontainer.json"
        }
        If ((Test-Path "${DEVDIR}\Dockerfile")) {
            Remove-Item -Force -Path "${DEVDIR}\Dockerfile"
        }

        # Get vscode configuration
        curl `
            -o "${DEVDIR}\devcontainer.json" "${DEVCONFIG}" `
            -o "${DEVDIR}\Dockerfile" "${DEVDOCKERFILE}"

        # Update Docker image
        docker pull benherber/ece206:latest
    }

    # -------------------------------------------------------------------- #

    # Open a preconfigured VSCode session inside a Docker container.
    # GLOBALS:
    #   WORKDIR
    # RETURN:
    #   0 if succeeded, non-zero on error.

    Function Code {
        Try {
            If (Get-Command devcontainer) {
                devcontainer open "${WORKDIR}"
            }
        } Catch {
            throw ("Please run ``Remote-Containers: Install devcontainer CLI``" +
                   "from the command pallete (ctrl+shift+P) in VSCode")
        }
    }

    # -------------------------------------------------------------------- #

    # Create working directory (C:\%USERPROFILE%\ece206) and ensure script integrity
    # GLOBALS:
    #   DEVDIR
    #   DEVCONFIG
    #   DEVDOCKERFILE
    #   IMAGE

    Function Init {
        Try {
            If (Get-Command docker) { 
                # Validate directory structure
                If (!(Test-Path ${WORKDIR})) {
                    New-Item -ItemType Directory -Force -Path ${WORKDIR}
                }
                If (!(Test-Path ${DEVDIR})) {
                    New-Item -ItemType Directory -Force -Path ${DEVDIR}
                }
                If ((Test-Path "${DEVDIR}\devcontainer.json")) {
                    Remove-Item  -Force -Path "${DEVDIR}\devcontainer.json"
                }
                If ((Test-Path "${DEVDIR}\Dockerfile")) {
                    Remove-Item -Force -Path "${DEVDIR}\Dockerfile"
                }

                # Validate CLI
                If (!(Test-Path ${PROFILE})) {
                    throw "Please paste these Functions into ${PROFILE}"
                }

                # Get vscode configuration
                curl `
                    -o "${DEVDIR}\devcontainer.json" "${DEVCONFIG}" `
                    -o "${DEVDIR}\Dockerfile" "${DEVDOCKERFILE}"

                # Update Docker image
                docker pull benherber/ece206:latest
            }
        } Catch {
            throw "Install WSL2 and Docker and make sure Docker running"
        }
    }

    # -------------------------------------------------------------------- #

    # Print help information to stdout
    # GLOBALS:
    #   VERSION, LAST_UPDATED
    # OUTPUTS:
    #   Write help info to stdout

    Function HelpMe {
        $TAB = "`t"
        $MSG = @(
            ""
            "SYNOPSIS"
            "${TAB}ece206 [COMMAND]"
            ""
            "DESCRIPTION"
            "${TAB}A helper script to assist in utlizing a docker environment to write and test verilog projects."
            ""
            "COMMANDS"
            "${TAB}init${TAB}Create cli and working directory for projects"
            "${TAB}start${TAB}Start docker container with ~/ece206 mounted"
            "${TAB}update${TAB}Update the VSCode configuration and Docker image"
            "${TAB}code${TAB}Open a preconfigured VSCode session in Docker"
            ""
            "OPTIONS"
            "${TAB}--help | -h${TAB}Show this screen"
            ""
            "version: ${VERSION}, last updated: ${LAST_UPDATED}"
            ""
        ) -join "`r`n"


        Write-Host -Separator "" ${MSG}
    }

# #################################################################### #
#                             MAIN PROGRAM                             #
# #################################################################### #

    # Parse Args:
    try {
        switch (${cmd}) {
            "init"   { Init; Break           }
            "start"  { StartContainer; Break }
            "--help" { HelpMe; Break         }
            "-h"     { HelpMe; Break         }
            "update" { Update; Break         }
            "code"   { Code; Break           }
            Default  { Usage; Break          }
        }
    } catch {
        Write-Error $_
        Return
    }
}