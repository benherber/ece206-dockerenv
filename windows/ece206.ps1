# ==================================================================== #
#                            script: ece206                            #
# ==================================================================== #
#% SYNOPSIS
#+    ece206 [COMMAND]
#%
#% DESCRIPTION
#+    A helper script to assist in utlizing a docker environment
#+    to write and test verilog projects.
#%
#% COMMANDS
#+    init          Create cli and working directory for projects
#+    start         Start docker container with ~/ece206 mounted
#%
#% OPTIONS
#+    -h, --help                    Print help information
#+    -v, --version                 Print version information
#%
#% EXAMPLES
#+    ece206 start
#%
#=======================================================================
#- IMPLEMENTATION
#-    version         0.0.1
#-    last updated    2021/10/21
#-    author(s)       BENJAMIN HERBER,
#-    repository      https://github.com/benherber/ece206-dockerenv
#-
#=======================================================================
#  HISTORY
#     2021/10/21 : Benjamin Herber : Created Script
#=======================================================================

# #################################################################### #
#                              VARIABLES                               #
# #################################################################### #

$WORKDIR = $HOME + "\ece206" # Working directory for projects

$VERSION = "0.0.1"          # Version number
$LAST_UPDATED = "Oct. 2021" # Last update to script

# #################################################################### #
#                              FUNCTIONS                               #
# #################################################################### #

# Error out on usage issue
# OUTPUTS:
#   Write help message to stderr
function PrivateECE206Usage {
    Write-Error "Unrecognized command: try ``ece206 --help`` for more options"
}

# -------------------------------------------------------------------- #

# Start the docker container with $WORKDIR volume mounted
# GLOBALS:
#   WORKDIR
# OUTPUTS:
#   Interactive shell session within container

function PrivateECE206StartContainer {
    docker run `
        --rm `
        -v "$WORKDIR":/workspace `
        -e BROADWAY=5 `
        -p 8085:8085 `
        -it bherber/ece206:latest /bin/bash
}

# -------------------------------------------------------------------- #

# Create working directory (C:\%USERPROFILE%\ece206) and put script in bin directory
# GLOBALS:
#   WORKDIR
# RETURN:
#   0 if succeeded, non-zero on error.

function PrivateECE206Init {
    If (!(Test-Path $WORKDIR)) {
        New-Item -ItemType Directory -Force -Path $WORKDIR
    }
    If (!(Test-Path $PROFILE)) {
    #     $presentwdir = Get-Location | Foreach-Object { $_.Path }
    #     $present = $presentwdir + "\ece206.ps1"
    #     Copy-Item $present -Destination $PROFILE
    # }
    # else {
        Write-Error "ERROR: Please paste these functions into $PROFILE"
    }
    docker pull benherber/ece206:latest
    return 0
}

# -------------------------------------------------------------------- #

# Print help information to stdout
# GLOBALS:
#   VERSION, LAST_UPDATED
# OUTPUTS:
#   Write help info to stdout
# RETURN:
#   0 if print succeeds, non-zero on error.

function PrivateECE206HelpMe() {
    Write-Host ""
    Write-Host "SYNOPSIS"
    Write-Host "  ece206 [COMMAND]"
    Write-Host ""
    Write-Host "DESCRIPTION"
    Write-Host "  A helper script to assist in utlizing a docker environment to write and test verilog projects."
    Write-Host ""
    Write-Host "COMMANDS"
    Write-Host "  init   Create cli and working directory for projects"
    Write-Host "  start  Start docker container with ~/ece206 mounted"
    Write-Host ""
    Write-Host "OPTIONS"
    Write-Host "  --help | -h  Show this screen"
    Write-Host ""
    Write-Host "version: $VERSION, last updated: $LAST_UPDATED"
    Write-Host ""
    return 0
}

# #################################################################### #
#                             MAIN PROGRAM                             #
# #################################################################### #

function ece206 {
    [CmdletBinding()]
    Param([parameter(Position = 0)]$arg0)

    # Parse Args:
    switch ($arg0) {
        "init" { PrivateECE206Init; Break }
        "start" { PrivateECE206StartContainer; Break }
        "-h" { PrivateECE206HelpMe; Break }
        "--help" { PrivateECE206HelpMe; Break }
        Default { PrivateECE206Usage; Break }
    }
}