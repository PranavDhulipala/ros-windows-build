[CmdletBinding()]
param(
    $badParam
)
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
# Powershell2-compatible way of forcing named-parameters
if ($badParam)
{
    throw "Only named parameters are allowed"
}

try
{
    $scriptsDir = split-path -parent $script:MyInvocation.MyCommand.Definition
    $rootDir = split-path -parent $scriptsDir

    $arguments = @{
        Distro = "humble"
        Version = "humble/2022-05-23"
        Packages = @(
            'navigation2',
            'desktop',
            'random_numbers',
            'joint_state_publisher',
            'octomap_msgs',
            'object_recognition_msgs',
            'turtlebot3_msgs',
            'gazebo_ros_pkgs',
            'realtime_tools',
            'xacro',
            'eigen_stl_containers',
            'control_msgs',
            'urdfdom_py',
            'warehouse_ros',
            'diagnostics'
        )
    }

    & (Join-Path $rootDir "generateRepos.ps1") @arguments
}
catch
{
  Write-Warning "Failed to generate Humble repos."
  throw
}
