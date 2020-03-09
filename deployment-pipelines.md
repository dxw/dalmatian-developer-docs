# Deployment pipelines

Deployment pipelines are automaticaly triggered by changes to branches in the application's GitHub repository.

To view the pipelines, log into your AWS user account and ensure you have switched to a role that provides the reqired permissions.

1. From the 'Services' dropdown (top left), select 'CodePipeline'

2. Select the pipeline for the relevent service / environment

Sometimes a pipeline may fail on the 'Build Phase' due to a flakey test which requires it to be ran again.

This can be done by clicking 'Release Change' when viewing a pipeline
