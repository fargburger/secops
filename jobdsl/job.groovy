pipelineJob("mans-ansible-collection-template") {
  description()
  keepDependencies(false)
  definition {
    cpsScm {
      scm {
        git {
          remote {
            github("cdwlabs/mans-ansible-collection-template", "https")
            credentials("cdwbrad_gh_token")
          }
          branch("*/master")

          configure { node ->
            node / 'extensions' << 'hudson.plugins.git.extensions.impl.PreBuildMerge' {
              options {
                mergeRemote 'origin'
                mergeTarget 'master'
                mergeStrategy 'default'
                fastForwardMode 'FF'
              }
            } // extensions

            node / 'extensions' << 'hudson.plugins.git.extensions.impl.AuthorInChangelog' {
            } // extensions

            node / 'extensions' << 'hudson.plugins.git.extensions.impl.CleanBeforeCheckout' {
              deleteUntrackedNestedRepositories 'false'
            } // extensions

            node / submoduleCfg(class: 'list')

          } // configure git
        } // git
      } // scm
      scriptPath("Jenkinsfile")
    } // cpsScm
  } // definition
  disabled(false)
  configure { project ->
    project / 'properties' << 'hudson.plugins.jira.JiraProjectProperty' {
    }

    project / 'properties' << 'org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty' {
      triggers {
        'triggers' << 'org.jenkinsci.plugins.github.pullrequest.GitHubPRTrigger' {
          spec ''
          triggerMode 'HEAVY_HOOKS'
          cancelQueued 'true'
          abortRunning 'false'
          skipFirstRun 'false'
          repoProviders {
            'repoProviders' << 'com.github.kostyasha.github.integration.generic.repoprovider.GitHubPluginRepoProvider' {
              cacheConnection 'true'
              manageHooks 'true'
              repoPermission 'ADMIN'
            }
          } // repoProviders

          errorsAction {
            delegate.description('GitHub Pull Requests Trigger Errors')
            errors(class: 'java.util.Collections$SynchronizedSet',  serialization: 'custom') << 'java.util.Collections_-SynchronizedCollection' {
              'default' {
                c(class: 'set')
                mutex(class: 'java.util.Collections$SynchronizedSet', reference: '../../..')
              }
            }
          } // errorsAction

          events {
            'events' << 'org.jenkinsci.plugins.github.pullrequest.events.impl.GitHubPROpenEvent' {
            }
          }
          preStatus 'false'
        } // GitHubPRTrigger

        'triggers' << 'com.cloudbees.jenkins.GitHubPushTrigger' {
          spec ''
        } // GitHubPushTrigger

        'triggers' << 'hudson.triggers.SCMTrigger' {
          spec ''
          ignorePostCommitHooks 'false'
        } // SCMTrigger

      } // triggers
    } // PipelineTriggersJobProperty

  } // configure project
}
