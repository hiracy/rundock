## v1.2.1

Update

- Update support ruby version(2.4.1,2.6.0)
- Support circleci 2.0

## v1.2.0

Update

- Support target plugins

## v1.1.7

Update

- Support multi external task file

## v1.1.6

Fix

- Fix error if merging scenario task and external task
- Fix rundock ssh of comma separated host arguments

Update

- Support multi external task file
- Support filtered tasks

## v1.1.5

Update

 - Support simple string replace to deploy erb operation
 - Support binding argument to deploy erb operation

## v1.1.2

Update

 - Support deploy arguments to deploy operation

## v1.1.1

Update

 - Support task arguments to deploy operation

## v1.1.0

Update

 - Support ssh configure
 - Support task with environment variables

## v1.0.2

Update

 - Support task with arguments
 - Update specify private ssh setting unless current ssh setting

## v1.0.0

Update

 - Support rake tasks
 - Fix ssh config host alias did not work

## v0.5.4

Update

 - Support change directory
 - Support sudo in scenario

## v0.5.3

Update

- Support taskfile
- Support targetfile

## v0.5.2

Update

- Support deploy ERB Template file

## v0.5.1

Update

- Support target group in scenario section

## v0.5.0

Update

- Change scenario 'node' attribute to 'target'

## v0.4.16

Update

- Support hooks define in scenario file

## v0.4.15

Update

- Add datetime to log output
- Support short header log mode

## v0.4.14

Update

- Add formatted logs function for plugins

## v0.4.13

Update

- Rename node_attributes to operation_attributes

## v0.4.11

Update

- Add dry_run state attribute for node info

Fix

- Fix task execute can not carry over attributes

## v0.4.9

Update

- Change the hook callback to include the operation info

## v0.4.2

Update

- Omit get of other node information in operating node

## v0.4.1

Update

- Change continue with an empty operation for node hook

## v0.4.0

Improvements

- Support node hooks

Fix

- Fix plugin lib search path bug

## v0.3.0

Improvements

- Support local to Remote deploy operation

Fix

- Fix rundock ssh with -g option was failed because not considered nodeinfo completion

## v0.2.11

Fix

- Fix attributes has lost original nodeinfo and others

## v0.2.10

Improvements

- Add running operation to other node information

Fix

- Fix command in task have been excuted though cli command option was specified
- Fix unavail cli --run-anyway option if -g options specified

## v0.2.9

Improvements

- Support dry-run

Fix

- Change stderr to strip

## v0.2.8

Improvements

- Support to use backend(etc: node ip-address) attributes for any operations

## v0.2.7

Fix

- Fix plugin was not found

## v0.2.5

Improvements

- Support host inventory

## v0.2.4

Fix

- Fix plugin load path replacement

## v0.2.3

Fix

- Fix symbol host access if localhost

Improvements

- Support operation plugins for extension

## v0.2.2

Fix

- Fix ssh options conflict bugs
- Support docker 1.6.2 for Circle CI environtment

## v0.2.1

Improvements

- Support error-exit options.(like shellscript set -e/+e)
- Change file path option name from '*_yaml' to '*'
- Add a option that stdout can no-header

## v0.2.0

Refactoring

- Refactoring Rundoc::Runner for build scnenario and options
- Refactoring parse options and yaml files

Improvements

- Implement multi host execute for rundock ssh
- Enable hostgroup file executing for rundock-ssh

## v0.1.0

- The first public version.
